'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { 
  LogOut,
  Settings,
  FileText,
  MessageSquare,
  Save,
  Edit,
  Trash2,
  Plus,
  Eye,
  EyeOff
} from 'lucide-react'

export default function AdminPanel() {
  const router = useRouter()
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [loginForm, setLoginForm] = useState({ username: '', password: '' })
  const [loginError, setLoginError] = useState('')
  
  // Content states
  const [siteContent, setSiteContent] = useState(null)
  const [contactMessages, setContactMessages] = useState([])
  const [editingSection, setEditingSection] = useState(null)
  const [tempContent, setTempContent] = useState({})

  // Check authentication on load
  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      verifyToken(token)
    } else {
      setIsLoading(false)
    }
  }, [])

  const verifyToken = async (token) => {
    try {
      const response = await fetch('/api/admin/verify', {
        headers: { Authorization: `Bearer ${token}` }
      })
      
      if (response.ok) {
        setIsAuthenticated(true)
        loadSiteContent()
        loadContactMessages()
      } else {
        localStorage.removeItem('admin_token')
      }
    } catch (error) {
      console.error('Token verification failed:', error)
      localStorage.removeItem('admin_token')
    } finally {
      setIsLoading(false)
    }
  }

  const handleLogin = async (e) => {
    e.preventDefault()
    setLoginError('')
    
    try {
      const response = await fetch('/api/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(loginForm)
      })
      
      const data = await response.json()
      
      if (response.ok) {
        localStorage.setItem('admin_token', data.token)
        setIsAuthenticated(true)
        loadSiteContent()
        loadContactMessages()
      } else {
        setLoginError(data.error || 'Erreur de connexion')
      }
    } catch (error) {
      setLoginError('Erreur de connexion')
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('admin_token')
    setIsAuthenticated(false)
    router.push('/admin')
  }

  const loadSiteContent = async () => {
    try {
      const response = await fetch('/api/content')
      const data = await response.json()
      setSiteContent(data)
    } catch (error) {
      console.error('Failed to load content:', error)
    }
  }

  const loadContactMessages = async () => {
    try {
      const token = localStorage.getItem('admin_token')
      const response = await fetch('/api/admin/messages', {
        headers: { Authorization: `Bearer ${token}` }
      })
      const data = await response.json()
      setContactMessages(data)
    } catch (error) {
      console.error('Failed to load messages:', error)
    }
  }

  const updateContent = async (type, data) => {
    try {
      const token = localStorage.getItem('admin_token')
      const response = await fetch('/api/admin/content', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ type, data })
      })
      
      if (response.ok) {
        loadSiteContent()
        setEditingSection(null)
        alert('Contenu mis à jour avec succès!')
      }
    } catch (error) {
      console.error('Failed to update content:', error)
      alert('Erreur lors de la mise à jour')
    }
  }

  const startEditing = (section, content) => {
    setEditingSection(section)
    setTempContent(content)
  }

  const saveSection = () => {
    updateContent(editingSection, tempContent)
  }

  const markAsRead = async (messageId) => {
    try {
      const token = localStorage.getItem('admin_token')
      await fetch('/api/admin/messages/read', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ messageId })
      })
      
      loadContactMessages()
    } catch (error) {
      console.error('Failed to mark as read:', error)
    }
  }

  const deleteMessage = async (messageId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce message ?')) return
    
    try {
      const token = localStorage.getItem('admin_token')
      await fetch(`/api/admin/messages/${messageId}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
      })
      
      loadContactMessages()
    } catch (error) {
      console.error('Failed to delete message:', error)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-slate-600">Chargement...</p>
        </div>
      </div>
    )
  }

  // Login form
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl">Panel Administrateur</CardTitle>
            <CardDescription>GetYourSite - Connexion Admin</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Nom d'utilisateur</label>
                <Input
                  type="text"
                  value={loginForm.username}
                  onChange={(e) => setLoginForm({...loginForm, username: e.target.value})}
                  placeholder="admin_getyoursite"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Mot de passe</label>
                <Input
                  type="password"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm({...loginForm, password: e.target.value})}
                  placeholder="Votre mot de passe"
                  required
                />
              </div>
              
              {loginError && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-md text-red-800 text-sm">
                  {loginError}
                </div>
              )}
              
              <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700">
                Se connecter
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    )
  }

  // Admin dashboard
  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="bg-white border-b border-slate-200">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">
              Panel Admin - <span className="text-blue-600">GetYourSite</span>
            </h1>
          </div>
          <Button onClick={handleLogout} variant="outline" className="flex items-center gap-2">
            <LogOut className="w-4 h-4" />
            Déconnexion
          </Button>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <Tabs defaultValue="content" className="space-y-6">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="content" className="flex items-center gap-2">
              <FileText className="w-4 h-4" />
              Gestion du Contenu
            </TabsTrigger>
            <TabsTrigger value="messages" className="flex items-center gap-2">
              <MessageSquare className="w-4 h-4" />
              Messages ({contactMessages.filter(m => !m.read).length})
            </TabsTrigger>
          </TabsList>

          {/* Content Management */}
          <TabsContent value="content">
            {siteContent && (
              <div className="space-y-6">
                {/* Hero Section */}
                <Card>
                  <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                      <CardTitle>Section Hero</CardTitle>
                      <CardDescription>Titre principal et description</CardDescription>
                    </div>
                    <Button 
                      onClick={() => startEditing('hero', siteContent.hero)}
                      variant="outline"
                      className="flex items-center gap-2"
                    >
                      <Edit className="w-4 h-4" />
                      Modifier
                    </Button>
                  </CardHeader>
                  
                  {editingSection === 'hero' ? (
                    <CardContent className="space-y-4">
                      <div>
                        <label className="block text-sm font-medium mb-2">Titre</label>
                        <Input
                          value={tempContent.title || ''}
                          onChange={(e) => setTempContent({...tempContent, title: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">Sous-titre</label>
                        <Input
                          value={tempContent.subtitle || ''}
                          onChange={(e) => setTempContent({...tempContent, subtitle: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">Description</label>
                        <Textarea
                          value={tempContent.description || ''}
                          onChange={(e) => setTempContent({...tempContent, description: e.target.value})}
                          rows={3}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">URL Image</label>
                        <Input
                          value={tempContent.image || ''}
                          onChange={(e) => setTempContent({...tempContent, image: e.target.value})}
                        />
                      </div>
                      
                      <div className="flex gap-2">
                        <Button onClick={saveSection} className="bg-green-600 hover:bg-green-700">
                          <Save className="w-4 h-4 mr-2" />
                          Sauvegarder
                        </Button>
                        <Button 
                          onClick={() => setEditingSection(null)} 
                          variant="outline"
                        >
                          Annuler
                        </Button>
                      </div>
                    </CardContent>
                  ) : (
                    <CardContent>
                      <div className="grid md:grid-cols-2 gap-6">
                        <div>
                          <p><strong>Titre:</strong> {siteContent.hero.title}</p>
                          <p><strong>Sous-titre:</strong> {siteContent.hero.subtitle}</p>
                          <p><strong>Description:</strong> {siteContent.hero.description}</p>
                        </div>
                        <div>
                          <img 
                            src={siteContent.hero.image} 
                            alt="Hero" 
                            className="w-full h-32 object-cover rounded"
                          />
                        </div>
                      </div>
                    </CardContent>
                  )}
                </Card>

                {/* Services Section */}
                <Card>
                  <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                      <CardTitle>Services</CardTitle>
                      <CardDescription>Gestion des services proposés</CardDescription>
                    </div>
                    <Button 
                      onClick={() => startEditing('services', siteContent.services)}
                      variant="outline"
                      className="flex items-center gap-2"
                    >
                      <Edit className="w-4 h-4" />
                      Modifier
                    </Button>
                  </CardHeader>
                  
                  {editingSection === 'services' ? (
                    <CardContent>
                      <div className="space-y-4">
                        {tempContent.map((service, index) => (
                          <div key={service.id} className="border p-4 rounded">
                            <div className="grid md:grid-cols-2 gap-4">
                              <div>
                                <label className="block text-sm font-medium mb-2">Titre</label>
                                <Input
                                  value={service.title}
                                  onChange={(e) => {
                                    const newServices = [...tempContent]
                                    newServices[index].title = e.target.value
                                    setTempContent(newServices)
                                  }}
                                />
                              </div>
                              <div>
                                <label className="block text-sm font-medium mb-2">Icône (nom Lucide)</label>
                                <Input
                                  value={service.icon}
                                  onChange={(e) => {
                                    const newServices = [...tempContent]
                                    newServices[index].icon = e.target.value
                                    setTempContent(newServices)
                                  }}
                                />
                              </div>
                            </div>
                            <div className="mt-4">
                              <label className="block text-sm font-medium mb-2">Description</label>
                              <Textarea
                                value={service.description}
                                onChange={(e) => {
                                  const newServices = [...tempContent]
                                  newServices[index].description = e.target.value
                                  setTempContent(newServices)
                                }}
                                rows={2}
                              />
                            </div>
                          </div>
                        ))}
                      </div>
                      
                      <div className="flex gap-2 mt-6">
                        <Button onClick={saveSection} className="bg-green-600 hover:bg-green-700">
                          <Save className="w-4 h-4 mr-2" />
                          Sauvegarder
                        </Button>
                        <Button 
                          onClick={() => setEditingSection(null)} 
                          variant="outline"
                        >
                          Annuler
                        </Button>
                      </div>
                    </CardContent>
                  ) : (
                    <CardContent>
                      <div className="grid md:grid-cols-3 gap-4">
                        {siteContent.services.map(service => (
                          <div key={service.id} className="border p-4 rounded">
                            <h3 className="font-semibold">{service.title}</h3>
                            <p className="text-sm text-slate-600 mt-2">{service.description}</p>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  )}
                </Card>

                {/* Portfolio Section */}
                <Card>
                  <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                      <CardTitle>Portfolio</CardTitle>
                      <CardDescription>Gestion des projets en portfolio</CardDescription>
                    </div>
                    <Button 
                      onClick={() => startEditing('portfolio', siteContent.portfolio)}
                      variant="outline"
                      className="flex items-center gap-2"
                    >
                      <Edit className="w-4 h-4" />
                      Modifier
                    </Button>
                  </CardHeader>
                  
                  {editingSection === 'portfolio' ? (
                    <CardContent>
                      <div className="space-y-6">
                        {tempContent.map((project, index) => (
                          <div key={project.id} className="border p-4 rounded">
                            <div className="grid md:grid-cols-2 gap-4">
                              <div>
                                <label className="block text-sm font-medium mb-2">Titre</label>
                                <Input
                                  value={project.title}
                                  onChange={(e) => {
                                    const newProjects = [...tempContent]
                                    newProjects[index].title = e.target.value
                                    setTempContent(newProjects)
                                  }}
                                />
                              </div>
                              <div>
                                <label className="block text-sm font-medium mb-2">Catégorie</label>
                                <Input
                                  value={project.category}
                                  onChange={(e) => {
                                    const newProjects = [...tempContent]
                                    newProjects[index].category = e.target.value
                                    setTempContent(newProjects)
                                  }}
                                />
                              </div>
                            </div>
                            <div className="mt-4">
                              <label className="block text-sm font-medium mb-2">Description</label>
                              <Textarea
                                value={project.description}
                                onChange={(e) => {
                                  const newProjects = [...tempContent]
                                  newProjects[index].description = e.target.value
                                  setTempContent(newProjects)
                                }}
                                rows={2}
                              />
                            </div>
                            <div className="mt-4">
                              <label className="block text-sm font-medium mb-2">URL Image</label>
                              <Input
                                value={project.image}
                                onChange={(e) => {
                                  const newProjects = [...tempContent]
                                  newProjects[index].image = e.target.value
                                  setTempContent(newProjects)
                                }}
                              />
                            </div>
                          </div>
                        ))}
                      </div>
                      
                      <div className="flex gap-2 mt-6">
                        <Button onClick={saveSection} className="bg-green-600 hover:bg-green-700">
                          <Save className="w-4 h-4 mr-2" />
                          Sauvegarder
                        </Button>
                        <Button 
                          onClick={() => setEditingSection(null)} 
                          variant="outline"
                        >
                          Annuler
                        </Button>
                      </div>
                    </CardContent>
                  ) : (
                    <CardContent>
                      <div className="grid md:grid-cols-3 gap-4">
                        {siteContent.portfolio.map(project => (
                          <div key={project.id} className="border rounded overflow-hidden">
                            <img 
                              src={project.image} 
                              alt={project.title}
                              className="w-full h-32 object-cover"
                            />
                            <div className="p-3">
                              <div className="flex items-center gap-2 mb-2">
                                <Badge variant="secondary">{project.category}</Badge>
                              </div>
                              <h3 className="font-semibold">{project.title}</h3>
                              <p className="text-sm text-slate-600">{project.description}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  )}
                </Card>
              </div>
            )}
          </TabsContent>

          {/* Messages Tab */}
          <TabsContent value="messages">
            <Card>
              <CardHeader>
                <CardTitle>Messages de Contact</CardTitle>
                <CardDescription>
                  {contactMessages.length} message(s) reçu(s) - {contactMessages.filter(m => !m.read).length} non lu(s)
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {contactMessages.map(message => (
                    <div 
                      key={message._id} 
                      className={`border rounded p-4 ${!message.read ? 'bg-blue-50 border-blue-200' : 'bg-slate-50'}`}
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-2">
                            <h3 className="font-semibold">{message.name}</h3>
                            <span className="text-sm text-slate-500">{message.email}</span>
                            {!message.read && <Badge variant="default" className="text-xs">Nouveau</Badge>}
                          </div>
                          <p className="text-sm text-slate-600 mb-2">{message.subject}</p>
                          <p className="text-sm">{message.message}</p>
                          <p className="text-xs text-slate-400 mt-2">
                            {new Date(message.createdAt).toLocaleString('fr-FR')}
                          </p>
                        </div>
                        <div className="flex gap-2 ml-4">
                          {!message.read && (
                            <Button
                              onClick={() => markAsRead(message._id)}
                              variant="outline"
                              size="sm"
                            >
                              <Eye className="w-4 h-4" />
                            </Button>
                          )}
                          <Button
                            onClick={() => deleteMessage(message._id)}
                            variant="outline"
                            size="sm"
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                  
                  {contactMessages.length === 0 && (
                    <div className="text-center py-8 text-slate-500">
                      Aucun message reçu pour le moment
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}