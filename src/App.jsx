import About from './components/About';
import Features from './components/Features';
import Hero from './components/Hero';
import NavBar from './components/Navbar';
import Story from "./components/Story.jsx";

function App() {

    return (
        <main className='relative min-h-screen w-screen overflow-x-hidden'>
            <NavBar/>
            <Hero/>
            <About/>
      <Feature />
      <Story />
        </main>
    )
}

export default App
