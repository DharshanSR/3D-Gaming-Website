import About from './components/About';
import Hero from './components/Hero';
import NavBar from './components/Navbar';
import Contact from "./components/Contact.jsx";
import Footer from "./components/Footer.jsx";
import Story from "./components/Story.jsx";
import Features from "./components/Features.jsx";

function App() {

    return (
        <main className='relative min-h-screen w-screen overflow-x-hidden'>
            <NavBar />
            <Hero />
            <About />
            <Features />
            <Story />
            <Contact />
            <Footer />
        </main>
    )
}

export default App
