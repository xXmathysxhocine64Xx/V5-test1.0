import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';
import { MongoClient } from 'mongodb';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

// MongoDB connection
let client = null;
let db = null;

async function connectToDatabase() {
  if (db) return db;
  
  try {
    client = new MongoClient(process.env.MONGO_URL);
    await client.connect();
    db = client.db(process.env.DB_NAME);
    console.log('Connected to MongoDB');
    return db;
  } catch (error) {
    console.error('MongoDB connection error:', error);
    throw error;
  }
}

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
  const cleaned = str.replace(/[-\x1F\x7F]/g, '');
  return cleaned.length > 0;
}

// JWT utilities
function verifyToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return null;
  }
}

// Rate limiting store
const rateLimitStore = new Map();
const RATE_LIMIT_WINDOW = 15 * 60 * 1000;
const RATE_LIMIT_MAX_REQUESTS = 5;

function isRateLimited(ip) {
  const now = Date.now();
  const key = ip;
  
  if (!rateLimitStore.has(key)) {
    rateLimitStore.set(key, { count: 1, firstRequest: now });
    return false;
  }
  
  const record = rateLimitStore.get(key);
  
  if (now - record.firstRequest > RATE_LIMIT_WINDOW) {
    rateLimitStore.set(key, { count: 1, firstRequest: now });
    return false;
  }
  
  record.count++;
  return record.count > RATE_LIMIT_MAX_REQUESTS;
}

// Initialize default content
async function initializeDefaultContent() {
  try {
    const database = await connectToDatabase();
    const content = await database.collection('site_content').findOne({ type: 'main' });
    
    if (!content) {
      const defaultContent = {
        type: 'main',
        hero: {
          title: "Créez votre",
          subtitle: "présence en ligne",
          description: "Expert en conception, déploiement et refonte de sites web pour particuliers et professionnels. Transformez vos idées en réalité digitale.",
          image: "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b",
          stats: [
            { number: "50+", label: "Sites créés" },
            { number: "100%", label: "Satisfaction client" },
            { number: "24h", label: "Support" }
          ]
        },
        services: [
          {
            id: "conception",
            icon: "Code2",
            title: "Conception Web",
            description: "Création sur mesure de sites web modernes et performants, adaptés à vos besoins et votre identité visuelle.",
            features: ["Design responsive", "UX/UI optimisée", "Technologies modernes"]
          },
          {
            id: "deploiement",
            icon: "Rocket",
            title: "Déploiement",
            description: "Mise en ligne professionnelle avec hébergement sécurisé, nom de domaine et optimisation des performances.",
            features: ["Hébergement sécurisé", "Configuration SSL", "Optimisation SEO"]
          },
          {
            id: "refonte",
            icon: "RefreshCw",
            title: "Refonte",
            description: "Modernisation de votre site existant pour améliorer les performances, le design et l'expérience utilisateur.",
            features: ["Audit complet", "Amélioration design", "Optimisation technique"]
          }
        ],
        portfolio: [
          {
            id: "ecommerce",
            title: "Site E-commerce",
            category: "Conception",
            description: "Boutique en ligne complète avec paiement sécurisé",
            image: "https://images.unsplash.com/photo-1591439657848-9f4b9ce436b9"
          },
          {
            id: "portfolio-pro",
            title: "Portfolio Professionnel",
            category: "Refonte",
            description: "Refonte complète d'un portfolio d'architecte",
            image: "https://images.unsplash.com/photo-1544717297-fa95b6ee9643"
          },
          {
            id: "app-web",
            title: "Application Web",
            category: "Déploiement",
            description: "Déploiement d'une application de gestion",
            image: "https://images.unsplash.com/photo-1613203713329-b2e39e14c266"
          }
        ],
        contact: {
          email: "contact@getyoursite.com",
          phone: "+33 (0)1 23 45 67 89",
          location: "France"
        },
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      await database.collection('site_content').insertOne(defaultContent);
      console.log('Default content initialized');
    }
  } catch (error) {
    console.error('Error initializing content:', error);
  }
}

// GET handler
export async function GET(request) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  try {
    // Admin login check
    if (pathname.includes('/api/admin/verify')) {
      const token = request.headers.get('authorization')?.replace('Bearer ', '');
      
      if (!token) {
        return NextResponse.json({ valid: false }, { status: 401 });
      }
      
      const decoded = verifyToken(token);
      if (!decoded) {
        return NextResponse.json({ valid: false }, { status: 401 });
      }
      
      return NextResponse.json({ valid: true, user: decoded });
    }

    // Get site content
    if (pathname.includes('/api/content')) {
      await initializeDefaultContent();
      const database = await connectToDatabase();
      const content = await database.collection('site_content').findOne({ type: 'main' });
      
      return NextResponse.json(content || {});
    }

    // Admin: Get contact messages
    if (pathname.includes('/api/admin/messages')) {
      const token = request.headers.get('authorization')?.replace('Bearer ', '');
      const decoded = verifyToken(token);
      
      if (!decoded) {
        return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
      }
      
      const database = await connectToDatabase();
      const messages = await database.collection('contact_submissions')
        .find({})
        .sort({ createdAt: -1 })
        .limit(100)
        .toArray();
      
      return NextResponse.json(messages);
    }

  } catch (error) {
    console.error('GET error:', error);
  }

  // Default GET response
  return NextResponse.json({
    message: `API GetYourSite active`,
    timestamp: new Date().toISOString(),
    status: 'active'
  });
}

// POST handler
export async function POST(request) {
  try {
    const url = new URL(request.url);
    const pathname = url.pathname;
    const forwarded = request.headers.get('x-forwarded-for');
    const ip = forwarded ? forwarded.split(',')[0] : request.headers.get('x-real-ip') || 'unknown';

    // Admin login
    if (pathname.includes('/api/admin/login')) {
      const body = await request.json();
      const { username, password } = body;

      // Debug logging
      console.log('Admin login attempt:', { username, password });
      console.log('Expected credentials:', { 
        username: process.env.ADMIN_USERNAME, 
        password: process.env.ADMIN_PASSWORD 
      });

      if (username !== process.env.ADMIN_USERNAME || password !== process.env.ADMIN_PASSWORD) {
        return NextResponse.json(
          { error: 'Identifiants incorrects' },
          { status: 401 }
        );
      }

      const token = jwt.sign(
        { username, role: 'admin' },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
      );

      return NextResponse.json({
        success: true,
        token,
        message: 'Connexion réussie'
      });
    }

    // Contact form submission
    if (pathname.includes('/api/contact')) {
      if (isRateLimited(ip)) {
        return NextResponse.json(
          { error: 'Trop de requêtes. Veuillez patienter avant de réessayer.' },
          { status: 429 }
        );
      }

      const body = await request.json();
      const { name, email, message, subject = 'Nouveau message de GetYourSite' } = body;
      
      // Validation
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

      // Store in database
      try {
        const database = await connectToDatabase();
        await database.collection('contact_submissions').insertOne({
          name: sanitizeHtml(name),
          email: sanitizeHtml(email),
          subject: sanitizeHtml(subject),
          message: sanitizeHtml(message),
          ip,
          createdAt: new Date(),
          read: false
        });
      } catch (dbError) {
        console.error('Database storage error:', dbError);
      }

      // Send email if configured
      if (process.env.GMAIL_USER && process.env.GMAIL_APP_PASSWORD && process.env.GMAIL_USER !== 'votre-email@gmail.com') {
        try {
          const transporter = nodemailer.createTransporter({
            host: process.env.SMTP_HOST,
            port: parseInt(process.env.SMTP_PORT),
            secure: false,
            auth: {
              user: process.env.GMAIL_USER,
              pass: process.env.GMAIL_APP_PASSWORD,
            },
          });
          
          const sanitizedName = sanitizeHtml(name);
          const sanitizedEmail = sanitizeHtml(email);
          const sanitizedMessage = sanitizeHtml(message);
          const sanitizedSubject = sanitizeHtml(subject);
          
          const mailOptions = {
            from: `"GetYourSite" <${process.env.GMAIL_USER}>`,
            to: process.env.GMAIL_RECIPIENT || process.env.GMAIL_USER,
            replyTo: email,
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
          
          await transporter.sendMail(mailOptions);
        } catch (emailError) {
          console.error('Email sending error:', emailError);
        }
      }
      
      return NextResponse.json({ 
        success: true, 
        message: 'Votre message a été envoyé avec succès !'
      });
    }

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

// PUT handler for admin updates
export async function PUT(request) {
  try {
    const url = new URL(request.url);
    const pathname = url.pathname;
    
    // Verify admin token
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    const decoded = verifyToken(token);
    
    if (!decoded) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const database = await connectToDatabase();

    // Update site content
    if (pathname.includes('/api/admin/content')) {
      const { type, data } = body;
      
      await database.collection('site_content').updateOne(
        { type: 'main' },
        { 
          $set: { 
            [type]: data,
            updatedAt: new Date()
          }
        }
      );
      
      return NextResponse.json({ success: true, message: 'Contenu mis à jour' });
    }

    // Mark message as read
    if (pathname.includes('/api/admin/messages/read')) {
      const { messageId } = body;
      
      await database.collection('contact_submissions').updateOne(
        { _id: new require('mongodb').ObjectId(messageId) },
        { $set: { read: true } }
      );
      
      return NextResponse.json({ success: true });
    }

    return NextResponse.json({
      message: 'PUT endpoint active',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('PUT error:', error);
    return NextResponse.json(
      { error: 'Erreur serveur' },
      { status: 500 }
    );
  }
}

// DELETE handler
export async function DELETE(request) {
  try {
    const url = new URL(request.url);
    const pathname = url.pathname;
    
    // Verify admin token
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    const decoded = verifyToken(token);
    
    if (!decoded) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const database = await connectToDatabase();

    // Delete contact message
    if (pathname.includes('/api/admin/messages/')) {
      const messageId = pathname.split('/').pop();
      
      await database.collection('contact_submissions').deleteOne(
        { _id: new require('mongodb').ObjectId(messageId) }
      );
      
      return NextResponse.json({ success: true, message: 'Message supprimé' });
    }

    return NextResponse.json({
      message: 'DELETE endpoint active',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('DELETE error:', error);
    return NextResponse.json(
      { error: 'Erreur serveur' },
      { status: 500 }
    );
  }
}