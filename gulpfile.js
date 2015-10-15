var gulp = require('gulp');
var stylus = require("gulp-stylus");
var plumber = require("gulp-plumber");

gulp.task("stylus", function(){
  gulp.src("public/stylesheet/*.styl")
    .pipe(plumber())
    .pipe(stylus())
    .pipe(gulp.dest("public/stylesheet/"));
});

gulp.task("watch", function(){
  gulp.watch("public/stylesheet/*.styl", ["stylus"]);
})

gulp.task("default", ["stylus", "watch"]);
