/*global module*/

module.exports = function (grunt) {
  'use strict';

  grunt.initConfig({
    pkg: '<json:package.json>',

    // delete the dist folder
    clean: {
      build: ['./staging/'],
      release: ['./dist/']
    },

    // lint CoffeeScript
    coffeelint: {
      app: ['controllers/*.coffee', 'modules/*.coffee', 'models/*.coffee', 'routes/*.coffee', './src/scripts/**/*.coffee'],
      options: {
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
        files: {
          'staging/app.js': 'src/scripts/**/*.coffee',
        },
        options: {
          bare: true
        }
      }
    },

    copy: {
      staging: {
        files: [
          {expand: true, cwd: 'src/scripts/libs/', src: ['*'], dest: 'staging/scripts/libs/'},
          {expand: true, cwd: 'src/scripts/angular/', src: ['*'], dest: 'staging/scripts/angular/'},
          {expand: true, cwd: 'src/scripts/bootstrap/', src: ['*'], dest: 'staging/scripts/bootstrap/'},
          {expand: true, cwd: 'src/img/', src: ['*'], dest: 'staging/img/'},
          {src: ['src/favicon.ico'], dest: 'staging/favicon.ico'}
        ]
      },
      dev: {
        files: [
          {expand: true, cwd: 'staging/', src: ['**'], dest: 'dist/'},
        ]
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

    // lint: {
    //   scripts: ['./src/!(libs)**/*.js']
    // },

    jshint: {
      options: {
        // CoffeeScript uses null for default parameter values
        eqnull: true
      }
    },

    // compile Less to CSS
    less: {
      dist: {
        src: './src/styles/app.less',
        dest: './staging/styles/styles.css'
      }
    },

    watch: {
      coffee: {
        files: ['./src/scripts/**/*.coffee', './controllers/*.coffee'],
        tasks: 'coffeelint coffee lint'
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

  grunt.registerTask('clean', ['clean']);
  grunt.registerTask('core', ['clean', 'coffeelint', 'coffee', 'less']);
  grunt.registerTask('bootstrap', ['core', 'copy:staging', 'copy:dev']);
  grunt.registerTask('default', ['bootstrap']);
  grunt.registerTask('dev', ['bootstrap', 'watch']);
  grunt.registerTask('prod', ['core', 'copy:staging', 'copy:prod']);

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-less');
};
