# Correcciones para la Configuración de Build Gradle

## Problemas identificados en android/app/build.gradle

1. **Versiones desactualizadas**: compileSdkVersion es muy baja
2. **Falta de configuración completa**: No se especifican todas las configuraciones necesarias
3. **Dependencias incompletas**: Falta la dependencia específica de Firebase

## Configuración corregida para android/build.gradle (proyecto)

```gradle
buildscript {
    ext.kotlin_version = '1.7.10' // Versión actualizada de Kotlin
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.2.1' // Versión compatible
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.13' // Plugin de Google Services
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

## Configuración corregida para android/app/build.gradle

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services' // Plugin de Google Services
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 33 // Actualizado a la versión recomendada

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.salon_app"
        minSdkVersion 21 // Aumentado para mejor compatibilidad
        targetSdkVersion 33 // Actualizado
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true // Habilitar multidex para evitar problemas de límite de métodos
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug // Para producción, usar configuración de firma adecuada
            minifyEnabled true // Habilitar minificación para releases
            useProguard true // Usar ProGuard para ofuscar código
        }
        debug {
            minifyEnabled false
            useProguard false
        }
    }
    
    // Configuración adicional para evitar problemas de memoria
    dexOptions {
        javaMaxHeapSize "4g"
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:31.2.0') // BOM de Firebase
    implementation 'com.google.firebase:firebase-analytics' // Analytics de Firebase
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1' // Soporte para multidex
}
```

## Configuración recomendada para android/gradle.properties

```properties
org.gradle.jvmargs=-Xmx4608m
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
```

## Beneficios de las correcciones

1. **Compatibilidad mejorada**: Versiones actualizadas para mejor soporte
2. **Mejor rendimiento**: Configuraciones optimizadas para memoria y compilación
3. **Seguridad**: Configuración adecuada para releases
4. **Soporte multidex**: Para aplicaciones con muchas dependencias
5. **Configuración completa**: Todas las configuraciones necesarias incluidas

## Consideraciones importantes

1. **Versiones compatibles**: Asegúrese de que las versiones de plugins sean compatibles entre sí
2. **API levels**: Verifique que minSdkVersion sea compatible con los dispositivos objetivo
3. **Firma de releases**: Para producción, configure una keystore adecuada
4. **ProGuard rules**: Si usa ProGuard, agregue reglas específicas para sus dependencias
5. **Pruebas**: Pruebe la compilación en diferentes dispositivos y versiones de Android