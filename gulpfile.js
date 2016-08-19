// Include gulp
var gulp = require('gulp');

// Define main directories
var assets = 'assets/';
var destination = 'build/';

// Concatenate & Minify JS
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');

gulp.task('customeScripts', function() {
  return gulp.src([assets + 'js/jquery.min.js',
                   assets + 'js/bootstrap.min.js',
                   assets + 'js/modernizr.js',
                   assets + 'js/jquery-cookie.js',
                   assets + 'js/jquery-lang.js',
                   assets + 'js/openSUSE-search-layout.js'])
    .pipe(concat('main.js'))
    .pipe(rename({suffix: '.min'}))
    .pipe(uglify())
    .pipe(gulp.dest(destination + 'js'));
});

// Preprocess CSS
var less = require('gulp-less');
var path = require('path');

gulp.task('less', function () {
  return gulp.src(assets +'css/openSUSE.less')
    .pipe(less({
      paths: [ path.join(__dirname, 'less', 'includes') ]
    }))
    .pipe(rename({suffix: '.min'}))
    .pipe(gulp.dest(destination + 'css'));
});

// Watch for changes in our custom assets
gulp.task('watch', function() {
  // Watch .js files
  gulp.watch(assets + 'js/*.js', ['customeScripts']);
  // Watch .scss files
  gulp.watch(assets + 'css/*.less', ['less']);
 });

var serverCommand = 'python -m SimpleHTTPServer';
var shell = require('gulp-shell');
gulp.task('runServer', shell.task([
  serverCommand
]))

// Default Task
gulp.task('default', ['customeScripts','less', 'watch', 'runServer' ]);
