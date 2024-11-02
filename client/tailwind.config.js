module.exports = {
  content: ["./index.html", "./src/**/*.{gleam,mjs}"],
  theme: {
    extend: {},
  },
  plugins: [

    require('daisyui')],

      daisyui: {
      themes: [ "sunset"
  //       {
  //         mytheme: {
            
  // "primary": "#bbf7d0",
            
  // "secondary": "#fef08a",
            
  // "accent": "#fb7185",
            
  // "neutral": "#2d2725",
            
  // "base-100": "#1c2433",
            
  // "info": "#00d5ff",
            
  // "success": "#bef264",
            
  // "warning": "#fcd34d",
            
  // "error": "#fca5a5",
  //           },
  //         },
        ], // false: only light + dark | true: all themes | array: specific themes like this ["light", "dark", "cupcake"]
      darkTheme: "sunset", // name of one of the included themes for dark mode
      base: true, // applies background color and foreground color for root element by default
      styled: true, // include daisyUI colors and design decisions for all components
      utils: true, // adds responsive and modifier utility classes
      prefix: "", // prefix for daisyUI classnames (components, modifiers and responsive class names. Not colors)
      logs: false, // Shows info about daisyUI version and used config in the console when building your CSS
      themeRoot: ":root", // The element that receives theme color CSS variables
    },

};
