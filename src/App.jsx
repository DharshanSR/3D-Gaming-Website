import About from './components/About';
import Features from './components/Features';
import Hero from './components/Hero';
import NavBar from './components/Navbar';
import Contact from "./components/Contact.jsx";
import Footer from "./components/Footer.jsx";
import Story from "./components/Story.jsx";

function App() {

    return (
        <main className='relative min-h-screen w-screen overflow-x-hidden'>
            <NavBar/>
            <Hero/>
            <About/>
      <Feature />
      <Story />
      <Contact />
        <Footer />
        </main>
    )
}

export default App
