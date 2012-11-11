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

    watch: {
      coffee: {
        files: ['./src/scripts/**/*.coffee', './controllers/*.coffee'],
        tasks: 'coffeeLint coffee lint'
      },
      less: {
        files: './src/styles/**/*.less',
        tasks: 'less'
      },
    },

    server: {
      app: {
        src: './app.coffee',
        port: 4000,
        watch: ['./view/**']
      }
    }
  });

  grunt.loadNpmTasks('grunt-hustler');
  grunt.registerTask('core', 'delete coffeeLint coffee lint less');
  grunt.registerTask('bootstrap', 'core copy:staging copy:dev');
  grunt.registerTask('default', 'bootstrap');
  grunt.registerTask('dev', 'bootstrap watch');
  grunt.registerTask('prod', 'core copy:staging copy:prod');
};
