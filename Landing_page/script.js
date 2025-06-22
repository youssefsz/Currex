// Mobile Menu Management
class MobileMenuManager {
    constructor() {
        this.isMenuOpen = false;
        this.init();
    }

    init() {
        const mobileMenuToggle = document.getElementById('mobileMenuToggle');
        const navLinks = document.getElementById('navLinks');

        if (mobileMenuToggle && navLinks) {
            mobileMenuToggle.addEventListener('click', () => this.toggleMenu());
            
            // Close menu when clicking on a link
            const navLinksElements = navLinks.querySelectorAll('.nav-link');
            navLinksElements.forEach(link => {
                link.addEventListener('click', () => this.closeMenu());
            });

            // Close menu when clicking outside
            document.addEventListener('click', (e) => {
                if (!navLinks.contains(e.target) && !mobileMenuToggle.contains(e.target)) {
                    this.closeMenu();
                }
            });

            // Close menu on escape key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') {
                    this.closeMenu();
                }
            });
        }
    }

    toggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
        this.updateMenu();
    }

    closeMenu() {
        this.isMenuOpen = false;
        this.updateMenu();
    }

    openMenu() {
        this.isMenuOpen = true;
        this.updateMenu();
    }

    updateMenu() {
        const navLinks = document.getElementById('navLinks');
        const mobileMenuToggle = document.getElementById('mobileMenuToggle');

        if (navLinks && mobileMenuToggle) {
            navLinks.classList.toggle('mobile-open', this.isMenuOpen);
            
            // Update hamburger icon to X when open
            const icon = mobileMenuToggle.querySelector('svg');
            if (this.isMenuOpen) {
                icon.innerHTML = `
                    <line x1="18" y1="6" x2="6" y2="18"/>
                    <line x1="6" y1="6" x2="18" y2="18"/>
                `;
            } else {
                icon.innerHTML = `
                    <line x1="3" y1="6" x2="21" y2="6"/>
                    <line x1="3" y1="12" x2="21" y2="12"/>
                    <line x1="3" y1="18" x2="21" y2="18"/>
                `;
            }

            // Prevent body scroll when menu is open
            document.body.style.overflow = this.isMenuOpen ? 'hidden' : '';
        }
    }
}

// Theme Management
class ThemeManager {
    constructor() {
        this.isDarkMode = true; // Default to dark mode as requested
        this.init();
    }

    init() {
        // Set initial theme
        document.body.classList.toggle('dark-mode', this.isDarkMode);
        this.updateThemeIcon();
        this.updateAllImages();

        // Add theme toggle event listener
        const themeToggle = document.getElementById('themeToggle');
        if (themeToggle) {
            themeToggle.addEventListener('click', () => this.toggleTheme());
        }

        // Listen for system theme changes
        if (window.matchMedia) {
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
                if (!localStorage.getItem('theme-preference')) {
                    this.isDarkMode = e.matches;
                    this.applyTheme();
                }
            });
        }
    }

    toggleTheme() {
        // Add switching animation class
        const themeToggle = document.getElementById('themeToggle');
        if (themeToggle) {
            themeToggle.classList.add('theme-switching');
            setTimeout(() => {
                themeToggle.classList.remove('theme-switching');
            }, 600);
        }

        this.isDarkMode = !this.isDarkMode;
        this.applyTheme();
        localStorage.setItem('theme-preference', this.isDarkMode ? 'dark' : 'light');
    }

    applyTheme() {
        document.body.classList.toggle('dark-mode', this.isDarkMode);
        this.updateThemeIcon();
        this.updateAllImages();
        this.triggerThemeAnimation();
    }

    updateThemeIcon() {
        const themeIcon = document.querySelector('.theme-icon');
        if (themeIcon) {
            // Remove existing classes
            themeIcon.classList.remove('sun-icon', 'moon-icon');
            
            if (this.isDarkMode) {
                // Light mode icon (sun) - shows when in dark mode
                themeIcon.classList.add('sun-icon');
                themeIcon.innerHTML = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="5"/>
                    <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>
                </svg>`;
            } else {
                // Dark mode icon (moon) - shows when in light mode
                themeIcon.classList.add('moon-icon');
                themeIcon.innerHTML = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                </svg>`;
            }
        }
    }

    updateAllImages() {
        const imageMap = {
            'heroScreenshot': 'screenshot-{theme}-convert.jpg',
            'primaryScreenshot': 'screenshot-{theme}-convert.jpg',
            'leftScreenshot': 'screenshot-{theme}-charts.jpg',
            'rightScreenshot': 'screenshot-{theme}-currencies.jpg',
            'convertScreenshot': 'screenshot-{theme}-convert.jpg',
            'chartsScreenshot': 'screenshot-{theme}-charts.jpg',
            'currenciesScreenshot': 'screenshot-{theme}-currencies.jpg',
            'settingsScreenshot': 'screenshot-{theme}-settings.jpg'
        };

        const theme = this.isDarkMode ? 'dark' : 'light';
        
        Object.keys(imageMap).forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                const filename = imageMap[id].replace('{theme}', theme);
                element.src = `./imgs/${theme}/${filename}`;
            }
        });

        // Update the modern screenshot showcase if it exists
        if (window.modernScreenshotShowcase) {
            window.modernScreenshotShowcase.updateImages();
        }
    }

    triggerThemeAnimation() {
        // Add a subtle animation effect when switching themes
        document.body.style.transition = 'background-color 0.5s ease, color 0.5s ease';
        setTimeout(() => {
            document.body.style.transition = '';
        }, 500);
    }
}

// Modern Screenshot Showcase Management
class ModernScreenshotShowcase {
    constructor() {
        this.currentFeature = 'convert';
        this.features = ['convert', 'charts', 'currencies', 'settings'];
        this.autoplayInterval = null;
        this.isTransitioning = false;
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupHotspots();
        this.setupKeyboardNavigation();
        this.setupDeviceAnimations();
        // this.startAutoplay(); // Disabled automatic transitions
        this.updateImages();
    }

    setupNavigation() {
        const navBtns = document.querySelectorAll('.feature-nav-btn');
        navBtns.forEach((btn) => {
            btn.addEventListener('click', (e) => {
                const feature = btn.getAttribute('data-screen');
                this.switchToFeature(feature);
                // this.resetAutoplay(); // Disabled autoplay
            });
        });
    }

    setupHotspots() {
        const hotspots = document.querySelectorAll('.hotspot');
        hotspots.forEach((hotspot) => {
            hotspot.addEventListener('click', (e) => {
                const feature = hotspot.getAttribute('data-feature');
                if (feature === 'rates') this.switchToFeature('convert');
                else if (feature === 'swap') this.switchToFeature('convert');
                else if (feature === 'favorites') this.switchToFeature('currencies');
                // this.resetAutoplay(); // Disabled autoplay
            });
        });
    }

    setupKeyboardNavigation() {
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') {
                this.previousFeature();
                // this.resetAutoplay(); // Disabled autoplay
            } else if (e.key === 'ArrowRight') {
                this.nextFeature();
                // this.resetAutoplay(); // Disabled autoplay
            }
        });
    }

    setupDeviceAnimations() {
        const devices = document.querySelectorAll('.device-mockup');
        devices.forEach((device) => {
            device.addEventListener('mouseenter', () => {
                // this.pauseAutoplay(); // Disabled autoplay
            });
            
            device.addEventListener('mouseleave', () => {
                // this.resetAutoplay(); // Disabled autoplay
            });
        });
    }

    switchToFeature(feature) {
        if (this.isTransitioning || feature === this.currentFeature) return;
        
        this.isTransitioning = true;
        this.currentFeature = feature;

        // Update navigation
        this.updateNavigation();
        
        // Update feature content with staggered animation
        this.updateFeatureContent();
        
        // Update device screenshots with smooth transition
        this.updateDeviceScreenshots();
        
        // Update floating elements
        this.animateFloatingElements();

        setTimeout(() => {
            this.isTransitioning = false;
        }, 600);
    }

    updateNavigation() {
        const navBtns = document.querySelectorAll('.feature-nav-btn');
        navBtns.forEach((btn) => {
            btn.classList.remove('active');
            if (btn.getAttribute('data-screen') === this.currentFeature) {
                btn.classList.add('active');
            }
        });
    }

    updateFeatureContent() {
        const contents = document.querySelectorAll('.feature-content');
        
        // Hide current content
        contents.forEach((content) => {
            content.classList.remove('active');
        });

        // Show new content with delay
        setTimeout(() => {
            const newContent = document.querySelector(`.feature-content[data-feature="${this.currentFeature}"]`);
            if (newContent) {
                newContent.classList.add('active');
            }
        }, 200);
    }

    updateDeviceScreenshots() {
        const imageMap = {
            'convert': 'screenshot-{theme}-convert.jpg',
            'charts': 'screenshot-{theme}-charts.jpg',
            'currencies': 'screenshot-{theme}-currencies.jpg',
            'settings': 'screenshot-{theme}-settings.jpg'
        };

        const theme = document.body.classList.contains('dark-mode') ? 'dark' : 'light';
        
        // Update primary device
        const primaryScreenshot = document.getElementById('primaryScreenshot');
        if (primaryScreenshot && imageMap[this.currentFeature]) {
            const filename = imageMap[this.currentFeature].replace('{theme}', theme);
            this.smoothImageTransition(primaryScreenshot, `./imgs/${theme}/${filename}`);
        }

        // Secondary devices are hidden, no need to update them
        // const leftScreenshot = document.getElementById('leftScreenshot');
        // const rightScreenshot = document.getElementById('rightScreenshot');
        
        // if (leftScreenshot && rightScreenshot) {
        //     const leftFeature = this.features[(this.features.indexOf(this.currentFeature) + 1) % this.features.length];
        //     const rightFeature = this.features[(this.features.indexOf(this.currentFeature) + 2) % this.features.length];
        //     
        //     const leftFilename = imageMap[leftFeature].replace('{theme}', theme);
        //     const rightFilename = imageMap[rightFeature].replace('{theme}', theme);
        //     
        //     this.smoothImageTransition(leftScreenshot, `./imgs/${theme}/${leftFilename}`);
        //     this.smoothImageTransition(rightScreenshot, `./imgs/${theme}/${rightFilename}`);
        // }
    }

    smoothImageTransition(imgElement, newSrc) {
        imgElement.style.opacity = '0.7';
        imgElement.style.transform = 'scale(0.95)';
        
        setTimeout(() => {
            imgElement.src = newSrc;
            imgElement.style.opacity = '1';
            imgElement.style.transform = 'scale(1)';
        }, 200);
    }

    animateFloatingElements() {
        const elements = document.querySelectorAll('.floating-element');
        elements.forEach((element, index) => {
            element.style.transform = 'translateY(-10px) scale(1.05)';
            setTimeout(() => {
                element.style.transform = '';
            }, 300 + (index * 100));
        });
    }

    updateImages() {
        // Update all images based on current theme
        this.updateDeviceScreenshots();
    }

    nextFeature() {
        const currentIndex = this.features.indexOf(this.currentFeature);
        const nextIndex = (currentIndex + 1) % this.features.length;
        this.switchToFeature(this.features[nextIndex]);
    }

    previousFeature() {
        const currentIndex = this.features.indexOf(this.currentFeature);
        const prevIndex = (currentIndex - 1 + this.features.length) % this.features.length;
        this.switchToFeature(this.features[prevIndex]);
    }

    startAutoplay() {
        this.autoplayInterval = setInterval(() => {
            this.nextFeature();
        }, 6000); // Change feature every 6 seconds
    }

    resetAutoplay() {
        this.pauseAutoplay();
        this.startAutoplay();
    }

    pauseAutoplay() {
        if (this.autoplayInterval) {
            clearInterval(this.autoplayInterval);
            this.autoplayInterval = null;
        }
    }

    stopAutoplay() {
        this.pauseAutoplay();
    }
}

// Smooth Scrolling and Navigation
class SmoothNavigation {
    constructor() {
        this.init();
    }

    init() {
        // Add smooth scrolling to navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Update active navigation link on scroll
        window.addEventListener('scroll', () => this.updateActiveNavLink());
    }

    updateActiveNavLink() {
        const sections = document.querySelectorAll('section[id]');
        const navLinks = document.querySelectorAll('.nav-link');
        
        let currentSection = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop - 100;
            const sectionHeight = section.offsetHeight;
            
            if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
                currentSection = section.getAttribute('id');
            }
        });

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSection}`) {
                link.classList.add('active');
            }
        });
    }
}

// Animations and Effects
class AnimationManager {
    constructor() {
        this.init();
    }

    init() {
        this.setupScrollAnimations();
        this.setupHoverEffects();
        this.setupLoadingAnimations();
    }

    setupScrollAnimations() {
        // Intersection Observer for fade-in animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Observe elements for animation
        document.querySelectorAll('.feature-card, .testimonial-card, .screenshot-item').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(30px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });
    }

    setupHoverEffects() {
        // Add hover effects to interactive elements
        document.querySelectorAll('.feature-card').forEach(card => {
            card.addEventListener('mouseenter', () => {
                card.style.transform = 'translateY(-8px) scale(1.02)';
            });
            
            card.addEventListener('mouseleave', () => {
                card.style.transform = 'translateY(0) scale(1)';
            });
        });
    }

    setupLoadingAnimations() {
        // Animate elements on page load
        window.addEventListener('load', () => {
            document.body.classList.add('loaded');
            
            // Animate hero elements
            const heroElements = document.querySelectorAll('.hero-badge, .hero-title, .hero-description, .hero-buttons');
            heroElements.forEach((el, index) => {
                setTimeout(() => {
                    el.style.opacity = '1';
                    el.style.transform = 'translateY(0)';
                }, index * 200);
            });
        });
    }
}

// Utility Functions
function scrollToDownload() {
    const downloadSection = document.getElementById('download');
    if (downloadSection) {
        downloadSection.scrollIntoView({ behavior: 'smooth' });
    }
}

function scrollToFeatures() {
    const featuresSection = document.getElementById('features');
    if (featuresSection) {
        featuresSection.scrollIntoView({ behavior: 'smooth' });
    }
}

// Performance Optimizations
class PerformanceOptimizer {
    constructor() {
        this.init();
    }

    init() {
        this.lazyLoadImages();
        this.optimizeScrolling();
    }

    lazyLoadImages() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.remove('lazy');
                        observer.unobserve(img);
                    }
                });
            });

            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        }
    }

    optimizeScrolling() {
        let ticking = false;

        function updateScrollEffects() {
            // Removed parallax effect to prevent hero section gaps
            // Just update scroll position for other potential effects
            ticking = false;
        }

        window.addEventListener('scroll', () => {
            if (!ticking) {
                requestAnimationFrame(updateScrollEffects);
                ticking = true;
            }
        });
    }
}

// Mobile Optimizations
class MobileOptimizer {
    constructor() {
        this.isMobile = window.innerWidth <= 768;
        this.init();
    }

    init() {
        this.setupTouchGestures();
        this.optimizeForMobile();
        
        // Listen for orientation changes
        window.addEventListener('orientationchange', () => {
            setTimeout(() => this.handleOrientationChange(), 100);
        });
    }

    setupTouchGestures() {
        if (this.isMobile) {
            let startX = 0;
            let startY = 0;

            document.addEventListener('touchstart', (e) => {
                startX = e.touches[0].clientX;
                startY = e.touches[0].clientY;
            });

            document.addEventListener('touchend', (e) => {
                const endX = e.changedTouches[0].clientX;
                const endY = e.changedTouches[0].clientY;
                
                const diffX = startX - endX;
                const diffY = startY - endY;

                // Horizontal swipe for screenshot showcase
                if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
                    const showcase = window.modernScreenshotShowcase;
                    if (showcase) {
                        if (diffX > 0) {
                            showcase.nextFeature();
                        } else {
                            showcase.previousFeature();
                        }
                    }
                }
            });
        }
    }

    optimizeForMobile() {
        if (this.isMobile) {
            // Reduce animations for better performance
            document.documentElement.style.setProperty('--animation-duration', '0.3s');
            
            // Optimize floating cards for mobile
            const floatingCards = document.querySelector('.floating-cards');
            if (floatingCards) {
                floatingCards.style.display = 'none';
            }
        }
    }

    handleOrientationChange() {
        // Force a repaint to fix layout issues
        document.body.style.display = 'none';
        document.body.offsetHeight; // Trigger reflow
        document.body.style.display = '';
    }
}

// Testimonials Manager for Infinite Sliding Carousel
class TestimonialsManager {
    constructor() {
        this.isPaused = false;
        this.testimonialTrack = null;
        this.pauseBtn = null;
        this.playBtn = null;
        this.init();
    }

    init() {
        this.testimonialTrack = document.getElementById('testimonialsTrack');
        this.pauseBtn = document.getElementById('pauseTestimonials');
        this.playBtn = document.getElementById('playTestimonials');

        if (this.testimonialTrack && this.pauseBtn && this.playBtn) {
            this.setupControls();
            this.setupIntersectionObserver();
            // Add a small delay to ensure DOM is fully loaded
            setTimeout(() => {
                this.duplicateTestimonials();
            }, 100);
        } else {
            console.warn('Testimonials elements not found, retrying...');
            // Retry after a short delay
            setTimeout(() => this.init(), 500);
        }
    }

    setupControls() {
        this.pauseBtn.addEventListener('click', () => this.pauseAnimations());
        this.playBtn.addEventListener('click', () => this.playAnimations());
    }

    pauseAnimations() {
        this.isPaused = true;
        this.testimonialTrack.classList.add('paused');
        this.pauseBtn.classList.add('hidden');
        this.playBtn.classList.remove('hidden');
    }

    playAnimations() {
        this.isPaused = false;
        this.testimonialTrack.classList.remove('paused');
        this.playBtn.classList.add('hidden');
        this.pauseBtn.classList.remove('hidden');
    }

    setupIntersectionObserver() {
        // Pause animations when not in view for better performance
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    if (!this.isPaused) {
                        this.testimonialTrack.classList.remove('paused');
                    }
                } else {
                    this.testimonialTrack.classList.add('paused');
                }
            });
        }, {
            threshold: 0.3
        });

        if (this.testimonialTrack) {
            observer.observe(this.testimonialTrack);
        }
    }

    duplicateTestimonials() {
        // Duplicate testimonials for seamless infinite scroll
        const rows = this.testimonialTrack.querySelectorAll('.testimonials-row');
        
        rows.forEach(row => {
            const originalCards = Array.from(row.querySelectorAll('.testimonial-card'));
            
            // Create exactly one duplicate set for seamless infinite loop
            // This ensures when the first set reaches -50%, the duplicate set is at 0%
            originalCards.forEach(card => {
                const clone = card.cloneNode(true);
                row.appendChild(clone);
            });
        });
    }

    // Add hover pause functionality
    addHoverPause() {
        const testimonialCards = document.querySelectorAll('.testimonial-card.glass');
        
        testimonialCards.forEach(card => {
            card.addEventListener('mouseenter', () => {
                if (!this.isPaused) {
                    this.testimonialTrack.classList.add('paused');
                }
            });
            
            card.addEventListener('mouseleave', () => {
                if (!this.isPaused) {
                    this.testimonialTrack.classList.remove('paused');
                }
            });
        });
    }

    // Smooth scroll on mobile touch
    setupTouchEvents() {
        let startX = 0;
        let currentX = 0;
        let isDragging = false;

        if (this.testimonialTrack) {
            this.testimonialTrack.addEventListener('touchstart', (e) => {
                startX = e.touches[0].clientX;
                isDragging = true;
                this.pauseAnimations();
            });

            this.testimonialTrack.addEventListener('touchmove', (e) => {
                if (!isDragging) return;
                currentX = e.touches[0].clientX;
                const diffX = currentX - startX;
                
                // Optional: Add visual feedback for touch interaction
                if (Math.abs(diffX) > 50) {
                    e.preventDefault();
                }
            });

            this.testimonialTrack.addEventListener('touchend', () => {
                isDragging = false;
                // Resume after a delay
                setTimeout(() => {
                    if (!this.isPaused) {
                        this.playAnimations();
                    }
                }, 2000);
            });
        }
    }

    // Performance optimization
    optimizeForPerformance() {
        // Reduce animation complexity on lower-end devices
        const isLowEndDevice = navigator.hardwareConcurrency <= 4 || 
                               /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        
        if (isLowEndDevice) {
            const cards = document.querySelectorAll('.testimonial-card.glass');
            cards.forEach(card => {
                card.style.willChange = 'auto';
                card.style.backfaceVisibility = 'hidden';
            });
            

        }
    }

    // Initialize all features
    initializeAll() {
        this.addHoverPause();
        this.setupTouchEvents();
        this.optimizeForPerformance();
    }
}

// Scroll to Top Manager
class ScrollToTopManager {
    constructor() {
        this.scrollToTopBtn = document.getElementById('scrollToTop');
        this.showThreshold = 300;
        this.isVisible = false;
        this.init();
    }

    init() {
        if (!this.scrollToTopBtn) return;

        // Add click event for smooth scroll
        this.scrollToTopBtn.addEventListener('click', () => this.scrollToTop());

        // Add scroll event with throttling for performance
        this.throttledScrollHandler = this.throttle(() => this.handleScroll(), 100);
        window.addEventListener('scroll', this.throttledScrollHandler);

        // Initial check
        this.handleScroll();
    }

    handleScroll() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > this.showThreshold && !this.isVisible) {
            this.showButton();
        } else if (scrollTop <= this.showThreshold && this.isVisible) {
            this.hideButton();
        }
    }

    showButton() {
        this.isVisible = true;
        this.scrollToTopBtn.classList.add('visible');
    }

    hideButton() {
        this.isVisible = false;
        this.scrollToTopBtn.classList.remove('visible');
    }

    scrollToTop() {
        // Use the browser's native smooth scrolling
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    throttle(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize all managers
    window.mobileMenuManager = new MobileMenuManager();
    window.themeManager = new ThemeManager();
    window.modernScreenshotShowcase = new ModernScreenshotShowcase();
    window.smoothNavigation = new SmoothNavigation();
    window.animationManager = new AnimationManager();
    window.performanceOptimizer = new PerformanceOptimizer();
    window.mobileOptimizer = new MobileOptimizer();
    window.testimonialsManager = new TestimonialsManager();
    window.scrollToTopManager = new ScrollToTopManager();

    // Add loading state management
    window.addEventListener('load', () => {
        document.body.classList.add('page-loaded');
    });

    // Add error handling for images
    document.querySelectorAll('img').forEach(img => {
        img.addEventListener('error', () => {
            img.style.display = 'none';
            console.warn(`Failed to load image: ${img.src}`);
        });
    });

    // Initialize all features
    window.testimonialsManager.initializeAll();
});

// Export for debugging
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        MobileMenuManager,
        ThemeManager,
        ScreenshotCarousel,
        SmoothNavigation,
        AnimationManager,
        PerformanceOptimizer,
        MobileOptimizer,
        TestimonialsManager
    };
} 