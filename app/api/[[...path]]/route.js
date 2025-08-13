import { NextResponse } from 'next/server';

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

    // Handle contact form submissions
    if (pathname.includes('/api/contact')) {
      const body = await request.json();
      const { name, email, message, subject = 'Nouveau message de contact' } = body;
      
      // Validate required fields
      if (!name || !email || !message) {
        return NextResponse.json(
          { error: 'Le nom, l\'email et le message sont requis' },
          { status: 400 }
        );
      }

      // For now, we'll just log the contact form submission
      // Email functionality will be added once Gmail credentials are provided
      console.log('Contact form submission:', {
        name,
        email,
        subject,
        message,
        timestamp: new Date().toISOString()
      });

      // Return success response
      return NextResponse.json({
        success: true,
        message: 'Message reçu avec succès ! Nous vous recontacterons bientôt.',
        timestamp: new Date().toISOString()
      });
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