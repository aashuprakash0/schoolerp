import './globals.css';
import Link from 'next/link';
export const metadata={title:'Adarsh Avasiya School Portal',description:'School administration and fee portal'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body><header><div className="nav"><Link href="/" className="brand">Adarsh Avasiya School</Link><nav><Link href="/notices">Notice Board</Link><Link href="/login">Parent / Admin Login</Link></nav></div></header>{children}<footer>© {new Date().getFullYear()} Adarsh Avasiya School</footer></body></html>}
