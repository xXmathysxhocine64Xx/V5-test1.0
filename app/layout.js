import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'GetYourSite - Création et Développement de Sites Web',
  description: 'Expert en conception, déploiement et refonte de sites web pour particuliers et professionnels. Transformez votre présence en ligne avec GetYourSite.',
  keywords: 'création site web, développement web, refonte site, conception web',
}

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <body className={inter.className}>{children}</body>
    </html>
  )
}