/*global module*/

module.exports = function (grunt) {
  'use strict';

  grunt.initConfig({
    pkg: '<json:package.json>',

    // delete the dist folder
    delete: {
      reset: {
        files: ['./dist/', './staging/']
      }
    },

    // lint CoffeeScript
    coffeeLint: {
      scripts: {
        src: './src/scripts/**/*.coffee',
        indentation: {
          value: 2,
          level: 'error'
        },
        max_line_length: {
          level: 'ignore'
        },
        no_tabs: {
          level: 'ignore'
        }
      }
    },

    // compile CoffeeScript to JavaScript
    coffee: {
      dist: {
        src: './src/scripts/**/*.coffee',
        dest: './staging/scripts/',
        bare: true
      }
    },

    copy: {
      staging: {
        files: {
          './staging/scripts/libs/': './src/scripts/libs/',
          './staging/scripts/angular/': './src/scripts/angular/',
          './staging/scripts/bootstrap/': './src/scripts/bootstrap/',
          './staging/img/': './src/img/',
          './staging/favicon.ico': './src/favicon.ico',
        }
      },
      dev: {
        files: {
          './dist/': './staging/'
        }
      },
      prod: {
        files: {
          './dist/scripts/': './staging/scripts/scripts.min.js',
          './dist/styles/': './staging/styles/styles.min.css',
          './dist/img/': './staging/img/',
          './dist/': './staging/index.html'
        }
      }
    },

    lint: {
      scripts: ['./src/!(libs)**/*.js']
    },

    jshint: {
      options: {
        // CoffeeScript uses null for default parameter values
        eqnull: true
      }
    },

    // compile Less to CSS
    less: {
      dist: {
        src: './src/styles/app.less',//bootstrap/bootstrap
        dest: './staging/styles/styles.css'
      }
    },

    // compile templates
    // template: {
    //   directives: {
    //     src: './src/scripts/directives/templates/**/*.template',
    //     dest: './staging/scripts/directives/templates/'
    //   },
    //   dev: {
    //     src: './src/**/*.template',
    //     dest: './staging/',
    //     environment: 'dev'
    //   },
    //   prod: {
    //     src: '<config:template.dev.src>',
    //     dest: '<config:template.dev.dest>',
    //     ext: '<config:template.dev.ext>',
    //     environment: 'prod'
    //   }
    // },

    // optimizes files managed by RequireJS
    // requirejs: {
    //   scripts: {
    //     baseUrl: './staging/scripts/',
    //     findNestedDependencies: true,
    //     include: 'requireLib',
    //     logLevel: 0,
    //     mainConfigFile: './staging/scripts/main.js',
    //     name: 'main',
    //     optimize: 'uglify',
    //     out: './staging/scripts/scripts.min.js',
    //     paths: {
    //       requireLib: 'libs/require'
    //     },
    //     preserveLicenseComments: false,
    //     uglify: {
    //       no_mangle: true
    //     }
    //   },
    //   styles: {
    //     baseUrl: './staging/styles/',
    //     cssIn: './staging/styles/styles.css',
    //     logLevel: 0,
    //     optimizeCss: 'standard',
    //     out: './staging/styles/styles.min.css'
    //   }
    // },

    watch: {
      coffee: {
        files: './src/scripts/**/*.coffee',
        tasks: 'coffeeLint coffee lint'
      },
      less: {
        files: './src/styles/**/*.less',
        tasks: 'less'
      },
      // template: {
      //   files: '<config:template.dev.src>',
      //   tasks: 'template:dev'
      // }
    },

    server: {
      app: {
        src: './app.coffee',
        port: 3005,
        watch: ['./view/**']
      }
    }
  });

  grunt.loadNpmTasks('grunt-hustler');
  grunt.registerTask('core', 'delete coffeeLint coffee lint less');
  grunt.registerTask('bootstrap', 'core copy:staging copy:dev');// template:dev
  grunt.registerTask('default', 'bootstrap');
  grunt.registerTask('dev', 'bootstrap watch');
  grunt.registerTask('prod', 'core copy:staging template:directives requirejs template:prod copy:prod');
};
