'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { 
  Code2, 
  Rocket, 
  RefreshCw, 
  Mail, 
  Phone, 
  MapPin, 
  Star,
  Users,
  Globe,
  Zap,
  Menu,
  X
} from 'lucide-react'

export default function HomePage() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [siteContent, setSiteContent] = useState(null)
  const [contactForm, setContactForm] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [submitStatus, setSubmitStatus] = useState(null)

  // Load site content on mount
  useEffect(() => {
    const loadContent = async () => {
      try {
        const response = await fetch('/api/content')
        const data = await response.json()
        setSiteContent(data)
      } catch (error) {
        console.error('Failed to load content:', error)
        // Fallback to default content if API fails
        setSiteContent(getDefaultContent())
      }
    }
    
    loadContent()
  }, [])

  // Default content fallback
  const getDefaultContent = () => ({
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
    }
  })

  // Get dynamic data or fallback to defaults
  const services = siteContent?.services || getDefaultContent().services
  const portfolio = siteContent?.portfolio || getDefaultContent().portfolio
  const hero = siteContent?.hero || getDefaultContent().hero
  const contact = siteContent?.contact || getDefaultContent().contact

  // Enhanced validation function
  const validateForm = () => {
    const errors = []
    
    // Name validation
    if (!contactForm.name.trim()) {
      errors.push('Le nom est requis')
    } else if (contactForm.name.length > 100) {
      errors.push('Le nom doit contenir moins de 100 caractères')
    }
    
    // Email validation
    if (!contactForm.email.trim()) {
      errors.push('L\'email est requis')
    } else {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(contactForm.email)) {
        errors.push('L\'email n\'est pas valide')
      } else if (contactForm.email.length > 254) {
        errors.push('L\'email est trop long')
      }
    }
    
    // Message validation
    if (!contactForm.message.trim()) {
      errors.push('Le message est requis')
    } else if (contactForm.message.length > 2000) {
      errors.push('Le message doit contenir moins de 2000 caractères')
    }
    
    // Subject validation
    if (contactForm.subject && contactForm.subject.length > 200) {
      errors.push('Le sujet doit contenir moins de 200 caractères')
    }
    
    return errors
  }

  const handleContactSubmit = async (e) => {
    e.preventDefault()
    
    // Client-side validation
    const validationErrors = validateForm()
    if (validationErrors.length > 0) {
      setSubmitStatus({ 
        type: 'error', 
        message: validationErrors.join('. ') 
      })
      return
    }

    setIsSubmitting(true)
    setSubmitStatus(null)

    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: contactForm.name.trim(),
          email: contactForm.email.trim().toLowerCase(),
          subject: contactForm.subject.trim(),
          message: contactForm.message.trim()
        })
      })

      const data = await response.json()

      if (response.ok) {
        setContactForm({ name: '', email: '', subject: '', message: '' })
        setSubmitStatus({ type: 'success', message: 'Votre message a été envoyé avec succès!' })
      } else {
        if (response.status === 429) {
          setSubmitStatus({ type: 'error', message: 'Trop de tentatives. Veuillez patienter avant de réessayer.' })
        } else {
          setSubmitStatus({ type: 'error', message: data.error || 'Erreur lors de l\'envoi' })
        }
      }
    } catch (error) {
      setSubmitStatus({ type: 'error', message: 'Une erreur de connexion est survenue' })
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleInputChange = (e) => {
    setContactForm({
      ...contactForm,
      [e.target.name]: e.target.value
    })
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-slate-200 sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <div className="text-2xl font-bold text-slate-800">
              Get<span className="text-blue-600">Your</span>Site
            </div>
            
            <div className="hidden md:flex space-x-8">
              <a href="#accueil" className="text-slate-600 hover:text-blue-600 transition-colors">Accueil</a>
              <a href="#services" className="text-slate-600 hover:text-blue-600 transition-colors">Services</a>
              <a href="#portfolio" className="text-slate-600 hover:text-blue-600 transition-colors">Portfolio</a>
              <a href="#contact" className="text-slate-600 hover:text-blue-600 transition-colors">Contact</a>
            </div>

            <Button 
              variant="ghost" 
              className="md:hidden"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <X /> : <Menu />}
            </Button>
          </div>

          {isMenuOpen && (
            <div className="md:hidden mt-4 space-y-2">
              <a href="#accueil" className="block py-2 text-slate-600 hover:text-blue-600">Accueil</a>
              <a href="#services" className="block py-2 text-slate-600 hover:text-blue-600">Services</a>
              <a href="#portfolio" className="block py-2 text-slate-600 hover:text-blue-600">Portfolio</a>
              <a href="#contact" className="block py-2 text-slate-600 hover:text-blue-600">Contact</a>
            </div>
          )}
        </div>
      </nav>

      {/* Hero Section */}
      <section id="accueil" className="py-20 px-4">
        <div className="container mx-auto text-center max-w-6xl">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="space-y-6">
              <h1 className="text-4xl md:text-6xl font-bold text-slate-800 leading-tight">
                {hero.title}
                <span className="text-blue-600 block">{hero.subtitle}</span>
              </h1>
              <p className="text-xl text-slate-600 max-w-lg">
                {hero.description}
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start">
                <Button size="lg" className="bg-blue-600 hover:bg-blue-700">
                  <a href="#services">Découvrir mes services</a>
                </Button>
                <Button size="lg" variant="outline">
                  <a href="#portfolio">Voir mes réalisations</a>
                </Button>
              </div>
              
              <div className="flex items-center gap-8 justify-center md:justify-start pt-8">
                {hero.stats?.map((stat, index) => (
                  <div key={index} className="text-center">
                    <div className="text-2xl font-bold text-slate-800">{stat.number}</div>
                    <div className="text-sm text-slate-600">{stat.label}</div>
                  </div>
                ))}
              </div>
            </div>
            
            <div className="relative">
              <div className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-500 rounded-2xl transform rotate-3"></div>
              <img 
                src={hero.image || "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b"} 
                alt="Développement web"
                className="relative rounded-2xl shadow-2xl w-full h-96 object-cover"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Services Section */}
      <section id="services" className="py-20 px-4 bg-white">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-slate-800 mb-4">
              Mes Services
            </h2>
            <p className="text-xl text-slate-600 max-w-2xl mx-auto">
              Des solutions complètes pour votre présence en ligne, adaptées à vos besoins
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {services.map((service, index) => {
              // Dynamic icon mapping
              const IconComponent = service.icon === 'Code2' ? Code2 : 
                                   service.icon === 'Rocket' ? Rocket : 
                                   service.icon === 'RefreshCw' ? RefreshCw : Code2
              
              return (
                <Card key={service.id || index} className="hover:shadow-xl transition-shadow duration-300 border-0 shadow-lg">
                  <CardHeader className="text-center">
                    <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <IconComponent className="w-8 h-8 text-blue-600" />
                    </div>
                    <CardTitle className="text-xl mb-2">{service.title}</CardTitle>
                    <CardDescription className="text-slate-600">
                      {service.description}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-2">
                      {service.features?.map((feature, idx) => (
                        <li key={idx} className="flex items-center text-sm text-slate-600">
                          <Zap className="w-4 h-4 text-blue-600 mr-2" />
                          {feature}
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </div>
      </section>

      {/* Portfolio Section */}
      <section id="portfolio" className="py-20 px-4">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-slate-800 mb-4">
              Mes Réalisations
            </h2>
            <p className="text-xl text-slate-600">
              Découvrez quelques-uns de mes projets récents
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {portfolio.map((project, index) => (
              <Card key={project.id || index} className="overflow-hidden hover:shadow-xl transition-shadow duration-300">
                <div className="relative h-48 overflow-hidden">
                  <img 
                    src={project.image}
                    alt={project.title}
                    className="w-full h-full object-cover hover:scale-110 transition-transform duration-300"
                  />
                  <Badge className="absolute top-4 left-4 bg-blue-600">
                    {project.category}
                  </Badge>
                </div>
                <CardHeader>
                  <CardTitle className="text-lg">{project.title}</CardTitle>
                  <CardDescription>{project.description}</CardDescription>
                </CardHeader>
              </Card>
            ))}
          </div>

          <div className="text-center mt-12">
            <Button variant="outline" size="lg">
              Voir plus de réalisations
            </Button>
          </div>
        </div>
      </section>

      {/* Why Choose Us */}
      <section className="py-20 px-4 bg-slate-900 text-white">
        <div className="container mx-auto max-w-6xl text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-12">
            Pourquoi choisir GetYourSite ?
          </h2>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="space-y-4">
              <Globe className="w-12 h-12 text-blue-400 mx-auto" />
              <h3 className="text-xl font-semibold">Technologies Modernes</h3>
              <p className="text-slate-300">
                Utilisation des dernières technologies pour des sites performants et sécurisés
              </p>
            </div>
            <div className="space-y-4">
              <Users className="w-12 h-12 text-blue-400 mx-auto" />
              <h3 className="text-xl font-semibold">Accompagnement Personnalisé</h3>
              <p className="text-slate-300">
                Suivi personnalisé de votre projet de la conception à la maintenance
              </p>
            </div>
            <div className="space-y-4">
              <Star className="w-12 h-12 text-blue-400 mx-auto" />
              <h3 className="text-xl font-semibold">Qualité Garantie</h3>
              <p className="text-slate-300">
                Sites optimisés pour le référencement, les performances et l'expérience utilisateur
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="py-20 px-4 bg-white">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-slate-800 mb-4">
              Contactez-moi
            </h2>
            <p className="text-xl text-slate-600">
              Prêt à démarrer votre projet ? Discutons de vos besoins
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            {/* Contact Info */}
            <div className="space-y-8">
              <div>
                <h3 className="text-2xl font-semibold text-slate-800 mb-6">
                  Parlons de votre projet
                </h3>
                <p className="text-slate-600 mb-6">
                  Je suis là pour vous accompagner dans la création de votre site web. 
                  Contactez-moi pour un devis gratuit et personnalisé.
                </p>
              </div>

              <div className="space-y-4">
                <div className="flex items-center space-x-4">
                  <Mail className="w-6 h-6 text-blue-600" />
                  <span className="text-slate-700">contact@getyoursite.com</span>
                </div>
                <div className="flex items-center space-x-4">
                  <Phone className="w-6 h-6 text-blue-600" />
                  <span className="text-slate-700">+33 (0)1 23 45 67 89</span>
                </div>
                <div className="flex items-center space-x-4">
                  <MapPin className="w-6 h-6 text-blue-600" />
                  <span className="text-slate-700">France</span>
                </div>
              </div>

              <div className="bg-blue-50 p-6 rounded-lg">
                <h4 className="font-semibold text-slate-800 mb-2">
                  Devis gratuit
                </h4>
                <p className="text-slate-600 text-sm">
                  Recevez une estimation personnalisée pour votre projet dans les 24h
                </p>
              </div>
            </div>

            {/* Contact Form */}
            <Card>
              <CardHeader>
                <CardTitle>Envoyez-moi un message</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleContactSubmit} className="space-y-4">
                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-2 text-slate-700">
                        Nom *
                      </label>
                      <Input
                        name="name"
                        value={contactForm.name}
                        onChange={handleInputChange}
                        placeholder="Votre nom"
                        maxLength={100}
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2 text-slate-700">
                        Email *
                      </label>
                      <Input
                        name="email"
                        type="email"
                        value={contactForm.email}
                        onChange={handleInputChange}
                        placeholder="votre@email.com"
                        maxLength={254}
                        required
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-slate-700">
                      Sujet
                    </label>
                    <Input
                      name="subject"
                      value={contactForm.subject}
                      onChange={handleInputChange}
                      placeholder="Sujet de votre demande"
                      maxLength={200}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-slate-700">
                      Message *
                    </label>
                    <Textarea
                      name="message"
                      value={contactForm.message}
                      onChange={handleInputChange}
                      placeholder="Décrivez votre projet..."
                      rows={5}
                      maxLength={2000}
                      required
                    />
                  </div>

                  {submitStatus && (
                    <div className={`p-4 rounded-md text-sm ${
                      submitStatus.type === 'success' 
                        ? 'bg-green-50 text-green-800 border border-green-200' 
                        : 'bg-red-50 text-red-800 border border-red-200'
                    }`}>
                      {submitStatus.message}
                    </div>
                  )}

                  <Button 
                    type="submit" 
                    className="w-full bg-blue-600 hover:bg-blue-700"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? 'Envoi en cours...' : 'Envoyer le message'}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-12 px-4">
        <div className="container mx-auto max-w-6xl">
          <div className="grid md:grid-cols-4 gap-8">
            <div className="col-span-2">
              <div className="text-2xl font-bold mb-4">
                Get<span className="text-blue-400">Your</span>Site
              </div>
              <p className="text-slate-300 mb-4">
                Votre partenaire pour créer une présence en ligne professionnelle 
                et performante. De la conception au déploiement, je vous accompagne 
                dans la réussite de votre projet web.
              </p>
            </div>
            
            <div>
              <h4 className="font-semibold mb-4">Services</h4>
              <ul className="space-y-2 text-slate-300">
                <li>Conception web</li>
                <li>Déploiement</li>
                <li>Refonte</li>
                <li>Maintenance</li>
              </ul>
            </div>
            
            <div>
              <h4 className="font-semibold mb-4">Contact</h4>
              <ul className="space-y-2 text-slate-300">
                <li>contact@getyoursite.com</li>
                <li>+33 (0)1 23 45 67 89</li>
                <li>France</li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-slate-800 mt-8 pt-8 text-center text-slate-400">
            <p>&copy; 2024 GetYourSite. Tous droits réservés.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}