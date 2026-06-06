allprojects {
    repositories {
        google()
        mavenCentral()
    }
    extra.set("compileSdkVersion", 36)
    extra.set("targetSdkVersion", 36)
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

subprojects {
    if (project.name != "app") {
        val configureAndroid = {
            if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
                val android = extensions.findByName("android")
                if (android is com.android.build.gradle.BaseExtension) {
                    android.compileSdkVersion(36)
                }
            }
        }
        if (state.executed) {
            configureAndroid()
        } else {
            afterEvaluate {
                configureAndroid()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
