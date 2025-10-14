allprojects {
    var kotlin_version = "1.7.10"
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.google.com/")
        }
    }
//    dependencies {
//        classpath("com.android.tools.build:gradle:7.3.0")
//        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
//    }
}
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}