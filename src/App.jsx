import About from './components/About';
import Hero from './components/Hero';
import NavBar from './components/Navbar';
import Story from "./components/Story.jsx";

function App() {

    return (
        <main className='relative min-h-screen w-screen overflow-x-hidden'>
            <NavBar/>
            <Hero/>
            <About/>
            <Story/>
        </main>
    )
}

export default App
