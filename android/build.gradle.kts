allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Auto-assign namespace untuk library yang belum punya namespace (AGP 8.0+ compatibility)
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = group.toString().ifEmpty { "com.unknown.${project.name}" }
                println("Auto-assigned namespace: $namespace for ${project.name}")
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension> {
            if (namespace == null) {
                namespace = group.toString().ifEmpty { "com.unknown.${project.name}" }
                println("Auto-assigned namespace: $namespace for ${project.name}")
            }
        }
    }
    
    // Paksa versi library agar tidak minta AGP 8.9.1+
    project.configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
