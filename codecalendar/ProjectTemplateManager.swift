//
//  ProjectTemplate.swift
//  codecalendar
//
//  Created by Cameron on 3/19/26.
//

import Foundation
import SwiftData

struct ProjectTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: String
    let estimatedDays: Int
    let difficulty: Difficulty
    let tasks: [TemplateTask]
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: String {
            switch self {
            case .beginner: return "green"
            case .intermediate: return "orange"
            case .advanced: return "red"
            }
        }
    }
}

struct TemplateTask {
    let name: String
    let description: String
    let effortScore: Int
    let estimatedHours: Int  // Used to calculate due date offset
    let resourceLinks: [String]?
}

class ProjectTemplateManager {
    static let shared = ProjectTemplateManager()
    
    var templates: [ProjectTemplate] {
        return [
            websitePortfolio,
            dataAnalystProject,
            aiAgent,
            pokeApiFrontend,
            webCrawler,
            weatherApp,
            taskManagerClone,
            blogCMS,
            eCommerceBasics,
            machineLearningIntro,
            mobileAppPrototype,
            apiBackend
        ]
    }
    
    // MARK: - Website Portfolio
    private var websitePortfolio: ProjectTemplate {
        ProjectTemplate(
            name: "Personal Portfolio Website",
            description: "Create a responsive website showcasing your projects, skills, and professional journey. Perfect for job applications and freelancing.",
            icon: "person.crop.circle",
            color: "blue",
            estimatedDays: 5,
            difficulty: .beginner,
            tasks: [
                TemplateTask(
                    name: "HTML Structure",
                    description: "Learn semantic HTML5 and create the basic structure of your portfolio. Include sections for about, projects, and contact.",
                    effortScore: 3,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://www.freecodecamp.org/learn/responsive-web-design/",
                        "https://developer.mozilla.org/en-US/docs/Learn/HTML"
                    ]
                ),
                TemplateTask(
                    name: "CSS Styling",
                    description: "Style your portfolio with modern CSS. Learn Flexbox, Grid, and responsive design principles.",
                    effortScore: 5,
                    estimatedHours: 8,
                    resourceLinks: [
                        "https://css-tricks.com/guides/",
                        "https://www.freecodecamp.org/learn/responsive-web-design/#css-flexbox"
                    ]
                ),
                TemplateTask(
                    name: "JavaScript Interactivity",
                    description: "Add interactive elements like a dark mode toggle, smooth scrolling, and form validation.",
                    effortScore: 4,
                    estimatedHours: 6,
                    resourceLinks: [
                        "https://javascript.info/",
                        "https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/"
                    ]
                ),
                TemplateTask(
                    name: "Deploy to GitHub Pages",
                    description: "Learn Git basics and deploy your portfolio for free using GitHub Pages.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://pages.github.com/",
                        "https://www.freecodecamp.org/news/how-to-host-your-website-for-free/"
                    ]
                )
            ]
        )
    }
    
    // MARK: - Data Analyst Project
    private var dataAnalystProject: ProjectTemplate {
        ProjectTemplate(
            name: "Sales Dashboard Analytics",
            description: "Analyze real sales data and create an interactive dashboard. Learn pandas, data visualization, and business intelligence.",
            icon: "chart.bar.fill",
            color: "purple",
            estimatedDays: 7,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Set Up Environment",
                    description: "Install Python, Jupyter Notebook, and essential libraries (pandas, matplotlib, seaborn).",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://www.python.org/downloads/",
                        "https://jupyter.org/install"
                    ]
                ),
                TemplateTask(
                    name: "Find & Load Dataset",
                    description: "Download a sales dataset from Kaggle and load it into pandas. Explore the data structure.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://www.kaggle.com/datasets",
                        "https://pandas.pydata.org/docs/getting_started/intro_tutorials/01_table_oriented.html"
                    ]
                ),
                TemplateTask(
                    name: "Data Cleaning",
                    description: "Handle missing values, remove duplicates, and convert data types. Document your cleaning process.",
                    effortScore: 4,
                    estimatedHours: 5,
                    resourceLinks: [
                        "https://pandas.pydata.org/docs/getting_started/intro_tutorials/03_subset_data.html",
                        "https://realpython.com/python-data-cleaning/"
                    ]
                ),
                TemplateTask(
                    name: "Exploratory Analysis",
                    description: "Calculate key metrics: total sales, average order value, top products, monthly trends.",
                    effortScore: 4,
                    estimatedHours: 5,
                    resourceLinks: [
                        "https://pandas.pydata.org/docs/getting_started/intro_tutorials/06_calculate_statistics.html"
                    ]
                ),
                TemplateTask(
                    name: "Create Visualizations",
                    description: "Build a dashboard with matplotlib/seaborn showing sales trends, category performance, and geographic distribution.",
                    effortScore: 5,
                    estimatedHours: 6,
                    resourceLinks: [
                        "https://matplotlib.org/stable/tutorials/index.html",
                        "https://seaborn.pydata.org/tutorial.html"
                    ]
                ),
                TemplateTask(
                    name: "Write Findings",
                    description: "Create a final report with your insights and recommendations. Include your visualizations.",
                    effortScore: 3,
                    estimatedHours: 4,
                    resourceLinks: nil
                )
            ]
        )
    }
    
    // MARK: - AI Agent
    private var aiAgent: ProjectTemplate {
        ProjectTemplate(
            name: "Personal AI Assistant",
            description: "Build a command-line AI agent that can answer questions, summarize text, and perform basic tasks using OpenAI's API.",
            icon: "brain.head.profile",
            color: "green",
            estimatedDays: 4,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "API Setup",
                    description: "Get OpenAI API key, set up Python environment, and make your first API call.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://platform.openai.com/api-keys",
                        "https://platform.openai.com/docs/quickstart"
                    ]
                ),
                TemplateTask(
                    name: "Basic Chat Interface",
                    description: "Create a simple command-line loop that takes user input and returns AI responses.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://platform.openai.com/docs/guides/chat"
                    ]
                ),
                TemplateTask(
                    name: "Add System Prompt",
                    description: "Give your AI a personality and specific capabilities using system prompts.",
                    effortScore: 3,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://platform.openai.com/docs/guides/chat/instructing-chat-models"
                    ]
                ),
                TemplateTask(
                    name: "Text Summarization Feature",
                    description: "Add a feature that can summarize long articles or notes passed to the AI.",
                    effortScore: 4,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://platform.openai.com/docs/guides/summarization"
                    ]
                ),
                TemplateTask(
                    name: "Conversation Memory",
                    description: "Implement conversation history so the AI remembers context within a session.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://platform.openai.com/docs/guides/chat/managing-conversations"
                    ]
                ),
                TemplateTask(
                    name: "Save Conversations",
                    description: "Add ability to save conversations to a text file for later reference.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files"
                    ]
                )
            ]
        )
    }
    
    // MARK: - PokeAPI Frontend
    private var pokeApiFrontend: ProjectTemplate {
        ProjectTemplate(
            name: "Pokédex Web App",
            description: "Build a modern Pokédex using the PokéAPI. Search for Pokémon, view stats, sprites, and evolutions.",
            icon: "bolt.fill",
            color: "yellow",
            estimatedDays: 5,
            difficulty: .beginner,
            tasks: [
                TemplateTask(
                    name: "Project Setup",
                    description: "Choose a framework (React, Vue, or vanilla JS) and set up your development environment.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://react.dev/learn",
                        "https://vuejs.org/guide/introduction.html"
                    ]
                ),
                TemplateTask(
                    name: "API Research",
                    description: "Explore the PokéAPI documentation and understand the endpoints you'll need.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://pokeapi.co/docs/v2"
                    ]
                ),
                TemplateTask(
                    name: "Search Functionality",
                    description: "Create a search bar that fetches Pokémon by name or ID from the API.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API"
                    ]
                ),
                TemplateTask(
                    name: "Pokémon Display Card",
                    description: "Design a card showing Pokémon name, image, types, and basic stats.",
                    effortScore: 4,
                    estimatedHours: 5,
                    resourceLinks: [
                        "https://pokeapi.co/docs/v2#pokemon"
                    ]
                ),
                TemplateTask(
                    name: "Stats Visualization",
                    description: "Add stat bars or radar charts for HP, Attack, Defense, etc.",
                    effortScore: 5,
                    estimatedHours: 6,
                    resourceLinks: [
                        "https://www.chartjs.org/docs/latest/"
                    ]
                ),
                TemplateTask(
                    name: "Evolution Chain",
                    description: "Fetch and display evolution chain with images and requirements.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://pokeapi.co/docs/v2#evolution-chains"
                    ]
                ),
                TemplateTask(
                    name: "Responsive Design",
                    description: "Make your Pokédex work beautifully on mobile and desktop.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design"
                    ]
                )
            ]
        )
    }
    
    // MARK: - Web Crawler
    private var webCrawler: ProjectTemplate {
        ProjectTemplate(
            name: "Basic Web Crawler",
            description: "Build a Python web crawler that navigates websites, extracts links, and saves content for analysis.",
            icon: "network",
            color: "indigo",
            estimatedDays: 4,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Environment Setup",
                    description: "Install Python and required libraries (requests, BeautifulSoup4).",
                    effortScore: 1,
                    estimatedHours: 1,
                    resourceLinks: [
                        "https://www.python.org/downloads/",
                        "https://www.crummy.com/software/BeautifulSoup/bs4/doc/"
                    ]
                ),
                TemplateTask(
                    name: "Basic HTTP Requests",
                    description: "Learn to make HTTP requests and handle responses. Start with a single page.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://requests.readthedocs.io/en/latest/"
                    ]
                ),
                TemplateTask(
                    name: "HTML Parsing",
                    description: "Use BeautifulSoup to parse HTML and extract specific elements (titles, headings).",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://www.crummy.com/software/BeautifulSoup/bs4/doc/#navigating-the-tree"
                    ]
                ),
                TemplateTask(
                    name: "Link Extraction",
                    description: "Extract all links from a page and filter for same-domain URLs.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://docs.python.org/3/library/urllib.parse.html"
                    ]
                ),
                TemplateTask(
                    name: "Crawl Logic",
                    description: "Implement BFS/DFS to crawl multiple pages while avoiding duplicates.",
                    effortScore: 5,
                    estimatedHours: 5,
                    resourceLinks: [
                        "https://www.redblobgames.com/pathfinding/a-star/introduction.html"
                    ]
                ),
                TemplateTask(
                    name: "Rate Limiting",
                    description: "Add delays between requests to be respectful to servers.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://docs.python.org/3/library/time.html"
                    ]
                ),
                TemplateTask(
                    name: "Save Results",
                    description: "Store crawled data in a JSON file for later analysis.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://docs.python.org/3/library/json.html"
                    ]
                )
            ]
        )
    }
    
    // MARK: - Additional Templates
    
    private var weatherApp: ProjectTemplate {
        ProjectTemplate(
            name: "Weather Dashboard",
            description: "Create a weather app using OpenWeatherMap API. Search cities, view forecasts, and save favorites.",
            icon: "cloud.sun.fill",
            color: "cyan",
            estimatedDays: 3,
            difficulty: .beginner,
            tasks: [
                TemplateTask(
                    name: "Get API Key",
                    description: "Sign up for OpenWeatherMap and get your free API key.",
                    effortScore: 1,
                    estimatedHours: 1,
                    resourceLinks: [
                        "https://openweathermap.org/api"
                    ]
                ),
                TemplateTask(
                    name: "Current Weather",
                    description: "Fetch and display current weather for a searched city.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://openweathermap.org/current"
                    ]
                ),
                TemplateTask(
                    name: "5-Day Forecast",
                    description: "Add forecast display with temperature highs/lows.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://openweathermap.org/forecast5"
                    ]
                ),
                TemplateTask(
                    name: "Weather Icons",
                    description: "Map weather conditions to appropriate icons.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://openweathermap.org/weather-conditions"
                    ]
                ),
                TemplateTask(
                    name: "Favorites",
                    description: "Allow users to save favorite cities locally.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                )
            ]
        )
    }
    
    private var taskManagerClone: ProjectTemplate {
        ProjectTemplate(
            name: "Task Manager Clone",
            description: "Build a simplified version of this very app! Practice CRUD operations and local storage.",
            icon: "checklist",
            color: "orange",
            estimatedDays: 4,
            difficulty: .beginner,
            tasks: [
                TemplateTask(
                    name: "Project Setup",
                    description: "Set up HTML/CSS/JS structure or choose a framework.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Create Task UI",
                    description: "Build the form to add new tasks with name and due date.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form"
                    ]
                ),
                TemplateTask(
                    name: "Task List Display",
                    description: "Display all tasks in a list with completion checkboxes.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Local Storage",
                    description: "Save tasks to localStorage so they persist after refresh.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage"
                    ]
                ),
                TemplateTask(
                    name: "Edit & Delete",
                    description: "Add ability to edit task details and delete tasks.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Filter Tasks",
                    description: "Add filters for All/Active/Completed tasks.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                )
            ]
        )
    }
    
    private var blogCMS: ProjectTemplate {
        ProjectTemplate(
            name: "Simple Blog CMS",
            description: "Create a content management system where you can write, edit, and publish blog posts.",
            icon: "doc.text.fill",
            color: "pink",
            estimatedDays: 6,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Database Setup",
                    description: "Set up SQLite or MongoDB for storing posts.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://www.sqlite.org/index.html",
                        "https://www.mongodb.com/docs/"
                    ]
                ),
                TemplateTask(
                    name: "Post Creation",
                    description: "Build a form with rich text editing for creating posts.",
                    effortScore: 4,
                    estimatedHours: 5,
                    resourceLinks: [
                        "https://quilljs.com/"
                    ]
                ),
                TemplateTask(
                    name: "Post Listing",
                    description: "Display all posts with titles, excerpts, and dates.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Single Post View",
                    description: "Create a detailed view for individual posts.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Edit & Delete",
                    description: "Add ability to edit existing posts and delete them.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Markdown Support",
                    description: "Add Markdown support for writing posts.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://www.markdownguide.org/getting-started/"
                    ]
                )
            ]
        )
    }
    
    private var eCommerceBasics: ProjectTemplate {
        ProjectTemplate(
            name: "E-Commerce Basics",
            description: "Build a simple product catalog with shopping cart functionality.",
            icon: "cart.fill",
            color: "green",
            estimatedDays: 5,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Product Data",
                    description: "Create a JSON file with sample products (name, price, image, description).",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Product Grid",
                    description: "Display products in a responsive grid layout.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Product Details",
                    description: "Create a detail page for each product with more info.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Shopping Cart",
                    description: "Implement add-to-cart functionality with quantity controls.",
                    effortScore: 5,
                    estimatedHours: 6,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Cart Persistence",
                    description: "Save cart items in localStorage.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage"
                    ]
                ),
                TemplateTask(
                    name: "Cart Summary",
                    description: "Show cart total and item count in header.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: nil
                )
            ]
        )
    }
    
    private var machineLearningIntro: ProjectTemplate {
        ProjectTemplate(
            name: "ML Intro: Iris Classifier",
            description: "Build your first machine learning model using the classic Iris dataset.",
            icon: "chart.line.uptrend.xyaxis",
            color: "purple",
            estimatedDays: 4,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Environment Setup",
                    description: "Install Python, scikit-learn, pandas, and jupyter.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://scikit-learn.org/stable/install.html"
                    ]
                ),
                TemplateTask(
                    name: "Load Dataset",
                    description: "Load the Iris dataset and explore its structure.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://scikit-learn.org/stable/datasets/toy_dataset.html"
                    ]
                ),
                TemplateTask(
                    name: "Data Exploration",
                    description: "Create visualizations to understand feature relationships.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://pandas.pydata.org/docs/getting_started/intro_tutorials/04_plotting.html"
                    ]
                ),
                TemplateTask(
                    name: "Train/Test Split",
                    description: "Split data into training and testing sets.",
                    effortScore: 3,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html"
                    ]
                ),
                TemplateTask(
                    name: "Choose & Train Model",
                    description: "Train a KNN classifier on the training data.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://scikit-learn.org/stable/modules/neighbors.html"
                    ]
                ),
                TemplateTask(
                    name: "Evaluate Model",
                    description: "Test your model and calculate accuracy.",
                    effortScore: 3,
                    estimatedHours: 2,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Make Predictions",
                    description: "Allow user input to predict flower species.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                )
            ]
        )
    }
    
    private var mobileAppPrototype: ProjectTemplate {
        ProjectTemplate(
            name: "Mobile App Prototype",
            description: "Design a clickable prototype in Figma for a fitness tracking app.",
            icon: "iphone",
            color: "gray",
            estimatedDays: 3,
            difficulty: .beginner,
            tasks: [
                TemplateTask(
                    name: "Figma Setup",
                    description: "Create a Figma account and learn the basics.",
                    effortScore: 1,
                    estimatedHours: 1,
                    resourceLinks: [
                        "https://www.figma.com/education/"
                    ]
                ),
                TemplateTask(
                    name: "User Flow",
                    description: "Sketch the main screens and user journey.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://www.figma.com/best-practices/guide-to-user-flows/"
                    ]
                ),
                TemplateTask(
                    name: "Wireframes",
                    description: "Create low-fidelity wireframes for all screens.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Design System",
                    description: "Create color palette, typography, and UI components.",
                    effortScore: 4,
                    estimatedHours: 4,
                    resourceLinks: [
                        "https://www.figma.com/best-practices/creating-design-systems/"
                    ]
                ),
                TemplateTask(
                    name: "High-Fidelity Design",
                    description: "Apply colors and styles to create polished screens.",
                    effortScore: 5,
                    estimatedHours: 6,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Prototyping",
                    description: "Add interactions to make it clickable.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://help.figma.com/hc/en-us/articles/360040314193-Guide-to-prototyping-in-Figma"
                    ]
                )
            ]
        )
    }
    
    private var apiBackend: ProjectTemplate {
        ProjectTemplate(
            name: "RESTful API Backend",
            description: "Build a complete REST API with Node.js, Express, and MongoDB for a note-taking app.",
            icon: "server.rack",
            color: "indigo",
            estimatedDays: 5,
            difficulty: .intermediate,
            tasks: [
                TemplateTask(
                    name: "Project Setup",
                    description: "Initialize Node.js project and install Express, Mongoose, and dotenv.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://expressjs.com/en/starter/installing.html",
                        "https://mongoosejs.com/docs/"
                    ]
                ),
                TemplateTask(
                    name: "Database Connection",
                    description: "Set up MongoDB Atlas and connect your app.",
                    effortScore: 3,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://www.mongodb.com/atlas/database"
                    ]
                ),
                TemplateTask(
                    name: "Note Model",
                    description: "Create a Mongoose schema for notes (title, content, createdAt).",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://mongoosejs.com/docs/guide.html"
                    ]
                ),
                TemplateTask(
                    name: "CRUD Routes",
                    description: "Implement GET, POST, PUT, DELETE endpoints for notes.",
                    effortScore: 5,
                    estimatedHours: 6,
                    resourceLinks: [
                        "https://expressjs.com/en/guide/routing.html"
                    ]
                ),
                TemplateTask(
                    name: "Error Handling",
                    description: "Add proper error handling and validation.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: nil
                ),
                TemplateTask(
                    name: "Test with Postman",
                    description: "Test all endpoints using Postman and document them.",
                    effortScore: 2,
                    estimatedHours: 2,
                    resourceLinks: [
                        "https://www.postman.com/"
                    ]
                ),
                TemplateTask(
                    name: "Deploy",
                    description: "Deploy your API to Render or Railway.",
                    effortScore: 3,
                    estimatedHours: 3,
                    resourceLinks: [
                        "https://render.com/docs/deploy-node-express-app"
                    ]
                )
            ]
        )
    }
}
