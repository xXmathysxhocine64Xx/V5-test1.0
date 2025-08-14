import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

// Security utilities
function sanitizeHtml(str) {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}

function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function validateInput(str, maxLength = 500) {
  if (!str || typeof str !== 'string') return false;
  if (str.length > maxLength) return false;
  // Remove any null bytes and control characters
  const cleaned = str.replace(/[\x00-\x1F\x7F]/g, '');
  return cleaned.length > 0;
}

// Rate limiting store (in production, use Redis or database)
const rateLimitStore = new Map();
const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes
const RATE_LIMIT_MAX_REQUESTS = 5; // Max 5 requests per window

function isRateLimited(ip) {
  const now = Date.now();
  const key = ip;
  
  if (!rateLimitStore.has(key)) {
    rateLimitStore.set(key, { count: 1, firstRequest: now });
    return false;
  }
  
  const record = rateLimitStore.get(key);
  
  // Reset if window has passed
  if (now - record.firstRequest > RATE_LIMIT_WINDOW) {
    rateLimitStore.set(key, { count: 1, firstRequest: now });
    return false;
  }
  
  // Increment counter
  record.count++;
  
  return record.count > RATE_LIMIT_MAX_REQUESTS;
}

// GET handler for testing
export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const path = searchParams.get('path') || 'API de GetYourSite';
  
  return NextResponse.json({
    message: `Bienvenue sur l'API de GetYourSite`,
    path: path,
    timestamp: new Date().toISOString(),
    status: 'active'
  });
}

// POST handler for contact form and other POST requests
export async function POST(request) {
  try {
    const url = new URL(request.url);
    const pathname = url.pathname;

    // Get client IP for rate limiting
    const forwarded = request.headers.get('x-forwarded-for');
    const ip = forwarded ? forwarded.split(',')[0] : request.headers.get('x-real-ip') || 'unknown';

    // Handle contact form submissions
    if (pathname.includes('/api/contact')) {
      // Rate limiting check
      if (isRateLimited(ip)) {
        return NextResponse.json(
          { error: 'Trop de requêtes. Veuillez patienter avant de réessayer.' },
          { status: 429 }
        );
      }

      const body = await request.json();
      const { name, email, message, subject = 'Nouveau message de GetYourSite' } = body;
      
      // Enhanced validation
      if (!validateInput(name, 100)) {
        return NextResponse.json(
          { error: 'Le nom est requis et doit contenir moins de 100 caractères' },
          { status: 400 }
        );
      }

      if (!validateInput(email, 254) || !validateEmail(email)) {
        return NextResponse.json(
          { error: 'Une adresse email valide est requise' },
          { status: 400 }
        );
      }

      if (!validateInput(message, 2000)) {
        return NextResponse.json(
          { error: 'Le message est requis et doit contenir moins de 2000 caractères' },
          { status: 400 }
        );
      }

      if (subject && !validateInput(subject, 200)) {
        return NextResponse.json(
          { error: 'Le sujet doit contenir moins de 200 caractères' },
          { status: 400 }
        );
      }

      // Check if Gmail is configured
      if (!process.env.GMAIL_USER || !process.env.GMAIL_APP_PASSWORD || process.env.GMAIL_USER === 'votre-email@gmail.com') {
        console.log('Contact form submission (Gmail not configured):', {
          name: sanitizeHtml(name), 
          email: sanitizeHtml(email), 
          subject: sanitizeHtml(subject), 
          messageLength: message.length,
          ip: ip,
          timestamp: new Date().toISOString()
        });
        
        return NextResponse.json({
          success: true,
          message: 'Message reçu ! Nous vous recontacterons bientôt.',
          note: 'Configuration Gmail requise pour l\'envoi automatique'
        });
      }

      try {
        // Create email transporter
        const transporter = nodemailer.createTransporter({
          host: process.env.SMTP_HOST,
          port: parseInt(process.env.SMTP_PORT),
          secure: false, // true for 465, false for other ports
          auth: {
            user: process.env.GMAIL_USER,
            pass: process.env.GMAIL_APP_PASSWORD,
          },
        });
        
        // Sanitize all inputs for email
        const sanitizedName = sanitizeHtml(name);
        const sanitizedEmail = sanitizeHtml(email);
        const sanitizedMessage = sanitizeHtml(message);
        const sanitizedSubject = sanitizeHtml(subject);
        
        // Format email content with sanitized data
        const mailOptions = {
          from: `"GetYourSite" <${process.env.GMAIL_USER}>`, // Fixed from field
          to: process.env.GMAIL_RECIPIENT || process.env.GMAIL_USER,
          replyTo: email, // Keep original for reply purposes
          subject: sanitizedSubject,
          text: `
            Nouveau message depuis GetYourSite
            
            Nom: ${sanitizedName}
            Email: ${sanitizedEmail}
            
            Message:
            ${sanitizedMessage}
          `,
          html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #2563eb;">Nouveau message depuis GetYourSite</h2>
              <p><strong>Nom:</strong> ${sanitizedName}</p>
              <p><strong>Email:</strong> ${sanitizedEmail}</p>
              <p><strong>Message:</strong></p>
              <div style="background-color: #f8fafc; padding: 15px; border-radius: 5px; border-left: 4px solid #2563eb;">
                ${sanitizedMessage.replace(/\n/g, '<br>')}
              </div>
              <p style="color: #64748b; font-size: 12px; margin-top: 20px;">
                Ce message a été envoyé depuis le formulaire de contact de GetYourSite.
              </p>
            </div>
          `,
        };
        
        // Send email
        await transporter.sendMail(mailOptions);
        
        return NextResponse.json({ 
          success: true, 
          message: 'Votre message a été envoyé avec succès !'
        });
        
      } catch (emailError) {
        console.error('Email sending error occurred at:', new Date().toISOString());
        
        // Log the message even if email fails (with sanitized data)
        console.log('Contact form submission (email failed):', {
          name: sanitizeHtml(name), 
          email: sanitizeHtml(email), 
          subject: sanitizeHtml(subject), 
          messageLength: message.length,
          ip: ip,
          timestamp: new Date().toISOString()
        });
        
        return NextResponse.json(
          { error: 'Erreur lors de l\'envoi de l\'email. Veuillez réessayer.' },
          { status: 500 }
        );
      }
    }

    // Default POST response for other endpoints
    return NextResponse.json({
      message: 'API POST endpoint active',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Erreur serveur' },
      { status: 500 }
    );
  }
}

// PUT handler
export async function PUT(request) {
  return NextResponse.json({
    message: 'PUT endpoint active',
    timestamp: new Date().toISOString()
  });
}

// DELETE handler  
export async function DELETE(request) {
  return NextResponse.json({
    message: 'DELETE endpoint active',
    timestamp: new Date().toISOString()
  });
}