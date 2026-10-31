#!/usr/bin/env bash
# ==============================================================================
# VIZIN — Script de Inicialização Completa do Projeto Nativo Android e Backend
# ==============================================================================
set -e

echo "Criando estrutura de diretórios do projeto VIZIN..."

mkdir -p app/src/main/java/br/com/vizin/app/core/network
mkdir -p app/src/main/java/br/com/vizin/app/domain/model
mkdir -p app/src/main/java/br/com/vizin/app/data/repository
mkdir -p app/src/main/java/br/com/vizin/app/features/home
mkdir -p app/src/main/java/br/com/vizin/app/features/create
mkdir -p app/src/main/java/br/com/vizin/app/features/chat
mkdir -p app/src/main/java/br/com/vizin/app/features/ai
mkdir -p app/src/main/java/br/com/vizin/app/navigation
mkdir -p app/src/main/java/br/com/vizin/app/ui/theme
mkdir -p app/src/main/res/values
mkdir -p app/src/test/java/br/com/vizin/app
mkdir -p supabase/migrations
mkdir -p supabase/functions/vizin-ai

echo "Gerando configurações de build (Gradle)..."

# 1. settings.gradle.kts
cat << 'EOF' > settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "VIZIN"
include(":app")
EOF

# 2. build.gradle.kts (Raiz)
cat << 'EOF' > build.gradle.kts
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    id("org.jetbrains.kotlin.plugin.serialization") version "1.9.24" apply false
}
EOF

# 3. gradle.properties
cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOF

# 4. app/build.gradle.kts
cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.serialization")
}

android {
    namespace = "br.com.vizin.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "br.com.vizin.app"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }

        buildConfigField("String", "SUPABASE_URL", "\"https://SEU_PROJETO.supabase.co\"")
        buildConfigField("String", "SUPABASE_ANON_KEY", "\"SUA_CHAVE_PUBLICA_ANONIMA\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.09.00")
    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.5")
    implementation("androidx.activity:activity-compose:1.9.2")

    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3:1.3.0")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.navigation:navigation-compose:2.8.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.5")

    val supabaseVersion = "2.6.1"
    implementation("io.github.jan-tennert.supabase:postgrest-kt:$supabaseVersion")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:$supabaseVersion")
    implementation("io.github.jan-tennert.supabase:realtime-kt:$supabaseVersion")
    implementation("io.github.jan-tennert.supabase:storage-kt:$supabaseVersion")
    implementation("io.github.jan-tennert.supabase:functions-kt:$supabaseVersion")
    implementation("io.ktor:ktor-client-android:2.3.12")

    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("io.coil-kt:coil-compose:2.7.0")
    implementation("com.google.android.gms:play-services-location:21.3.0")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
EOF

# 5. app/proguard-rules.pro
cat << 'EOF' > app/proguard-rules.pro
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keep class io.github.jan.supabase.** { *; }
-keep class br.com.vizin.app.domain.model.** { *; }
EOF

# 6. app/src/main/AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

    <application
        android:name=".VizinApplication"
        android:allowBackup="true"
        android:icon="@android:drawable/sym_def_app_icon"
        android:label="VIZIN"
        android:roundIcon="@android:drawable/sym_def_app_icon"
        android:supportsRtl="true"
        android:theme="@style/Theme.VIZIN">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.VIZIN"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# 7. app/src/main/res/values/themes.xml
cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.VIZIN" parent="android:Theme.Material.Light.NoActionBar">
        <item name="android:statusBarColor">#16A34A</item>
    </style>
</resources>
EOF

echo "Gerando código-fonte Kotlin..."

# 8. ui/theme/Color.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/ui/theme/Color.kt
package br.com.vizin.app.ui.theme

import androidx.compose.ui.graphics.Color

val VizinGreenPrimary = Color(0xFF16A34A)
val VizinGreenDark = Color(0xFF15803D)
val VizinGreenSoft = Color(0xFFDCFCE7)
val VizinGreenContainer = Color(0xFFF0FDF4)

val VizinBackground = Color(0xFFFFFFFF)
val VizinBackgroundSecondary = Color(0xFFF8FAFC)
val VizinSurface = Color(0xFFFFFFFF)

val VizinTextPrimary = Color(0xFF111827)
val VizinTextSecondary = Color(0xFF64748B)
val VizinBorder = Color(0xFFE5E7EB)

val VizinError = Color(0xFFDC2626)
val VizinSuccess = Color(0xFF16A34A)
val VizinWarning = Color(0xFFF59E0B)
EOF

# 9. ui/theme/Theme.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/ui/theme/Theme.kt
package br.com.vizin.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColorScheme = lightColorScheme(
    primary = VizinGreenPrimary,
    onPrimary = Color.White,
    primaryContainer = VizinGreenSoft,
    onPrimaryContainer = VizinGreenDark,
    secondary = VizinGreenDark,
    onSecondary = Color.White,
    background = VizinBackground,
    onBackground = VizinTextPrimary,
    surface = VizinSurface,
    onSurface = VizinTextPrimary,
    surfaceVariant = VizinBackgroundSecondary,
    onSurfaceVariant = VizinTextSecondary,
    outline = VizinBorder,
    error = VizinError
)

private val DarkColorScheme = darkColorScheme(
    primary = VizinGreenPrimary,
    onPrimary = Color.White,
    primaryContainer = Color(0xFF064E3B),
    onPrimaryContainer = VizinGreenSoft,
    secondary = VizinGreenSoft,
    background = Color(0xFF0F172A),
    onBackground = Color(0xFFF8FAFC),
    surface = Color(0xFF1E293B),
    onSurface = Color(0xFFF8FAFC),
    outline = Color(0xFF334155)
)

@Composable
fun VIZINTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
EOF

# 10. core/network/SupabaseClient.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/core/network/SupabaseClient.kt
package br.com.vizin.app.core.network

import br.com.vizin.app.BuildConfig
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.functions.Functions
import io.github.jan.supabase.gotrue.Auth
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.realtime.Realtime
import io.github.jan.supabase.storage.Storage

object SupabaseProvider {
    val client: SupabaseClient by lazy {
        createSupabaseClient(
            supabaseUrl = BuildConfig.SUPABASE_URL,
            supabaseKey = BuildConfig.SUPABASE_ANON_KEY
        ) {
            install(Auth)
            install(Postgrest)
            install(Storage)
            install(Realtime)
            install(Functions)
        }
    }
}
EOF

# 11. domain/model/Models.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/domain/model/Models.kt
package br.com.vizin.app.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Profile(
    val id: String,
    val username: String,
    @SerialName("full_name") val fullName: String,
    @SerialName("avatar_url") val avatarUrl: String? = null,
    val bio: String? = null,
    val city: String,
    val neighborhood: String? = null,
    @SerialName("account_type") val accountType: String = "individual",
    @SerialName("is_verified") val isVerified: Boolean = false
)

@Serializable
data class Category(
    val id: String,
    val name: String,
    val slug: String,
    val icon: String,
    @SerialName("sort_order") val sortOrder: Int = 0
)

@Serializable
data class ListingNearbyDTO(
    val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("author_name") val authorName: String,
    @SerialName("author_avatar") val authorAvatar: String? = null,
    val title: String,
    val description: String,
    @SerialName("category_id") val categoryId: String,
    @SerialName("listing_type") val listingType: String,
    val price: Double? = null,
    val negotiable: Boolean = false,
    val city: String,
    val neighborhood: String,
    @SerialName("approx_lat") val approxLat: Double,
    @SerialName("approx_lng") val approxLng: Double,
    @SerialName("distance_meters") val distanceMeters: Double,
    @SerialName("thumbnail_url") val thumbnailUrl: String? = null,
    @SerialName("created_at") val createdAt: String
) {
    val formattedDistance: String
        get() = if (distanceMeters < 1000) {
            "${distanceMeters.toInt()} m"
        } else {
            String.format("%.1f km", distanceMeters / 1000.0)
        }
}

@Serializable
data class ChatMessage(
    val id: String? = null,
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("sender_id") val senderId: String,
    val content: String? = null,
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class AiGenerateResponse(
    val result: String
)

@Serializable
data class AiListingSuggestion(
    val title: String,
    val description: String,
    @SerialName("suggested_price") val suggestedPrice: Double = 0.0
)
EOF

# 12. data/repository/ListingsRepository.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/data/repository/ListingsRepository.kt
package br.com.vizin.app.data.repository

import br.com.vizin.app.core.network.SupabaseProvider
import br.com.vizin.app.domain.model.Category
import br.com.vizin.app.domain.model.ListingNearbyDTO
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.rpc
import io.github.jan.supabase.storage.storage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import java.util.UUID

class ListingsRepository {
    private val client = SupabaseProvider.client

    suspend fun fetchCategories(): List<Category> = withContext(Dispatchers.IO) {
        client.postgrest["categories"]
            .select()
            .decodeList<Category>()
    }

    suspend fun getNearbyListings(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 25000.0,
        query: String? = null,
        categoryId: String? = null
    ): List<ListingNearbyDTO> = withContext(Dispatchers.IO) {
        val params = buildJsonObject {
            put("user_lat", latitude)
            put("user_lng", longitude)
            put("radius_meters", radiusMeters)
            if (!query.isNullOrBlank()) put("search_query", query)
            if (!categoryId.isNullOrBlank()) put("filter_category", categoryId)
        }

        client.postgrest.rpc("search_listings_nearby", params)
            .decodeList<ListingNearbyDTO>()
    }

    suspend fun uploadListingImage(byteArray: ByteArray): String = withContext(Dispatchers.IO) {
        val filename = "${UUID.randomUUID()}.jpg"
        val bucket = client.storage["listing-images"]
        bucket.upload(filename, byteArray)
        bucket.publicUrl(filename)
    }

    suspend fun createListing(
        title: String,
        description: String,
        categoryId: String,
        listingType: String,
        price: Double?,
        negotiable: Boolean,
        city: String,
        neighborhood: String,
        latitude: Double,
        longitude: Double,
        imageUrls: List<String>
    ): String = withContext(Dispatchers.IO) {
        val user = client.auth.currentUserOrNull()
            ?: throw IllegalStateException("Usuário não autenticado")

        val ewktLocation = "SRID=4326;POINT($longitude $latitude)"
        
        val insertResponse = client.postgrest["listings"].insert(
            buildJsonObject {
                put("user_id", user.id)
                put("title", title)
                put("description", description)
                put("category_id", categoryId)
                put("listing_type", listingType)
                price?.let { put("price", it) }
                put("negotiable", negotiable)
                put("city", city)
                put("neighborhood", neighborhood)
                put("location", ewktLocation)
            }
        ) {
            select()
        }.decodeSingle<ListingNearbyDTO>()

        imageUrls.forEachIndexed { index, url ->
            client.postgrest["listing_images"].insert(
                buildJsonObject {
                    put("listing_id", insertResponse.id)
                    put("image_url", url)
                    put("position", index)
                }
            )
        }

        insertResponse.id
    }
}
EOF

# 13. data/repository/ChatRepository.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/data/repository/ChatRepository.kt
package br.com.vizin.app.data.repository

import br.com.vizin.app.core.network.SupabaseProvider
import br.com.vizin.app.domain.model.ChatMessage
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Order
import io.github.jan.supabase.realtime.PostgresAction
import io.github.jan.supabase.realtime.channel
import io.github.jan.supabase.realtime.postgresChangeFlow
import io.github.jan.supabase.realtime.realtime
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

class ChatRepository {
    private val client = SupabaseProvider.client

    fun currentUserId(): String? = client.auth.currentUserOrNull()?.id

    suspend fun getMessages(conversationId: String): List<ChatMessage> = withContext(Dispatchers.IO) {
        client.postgrest["messages"]
            .select {
                filter { eq("conversation_id", conversationId) }
                order("created_at", order = Order.ASCENDING)
            }
            .decodeList<ChatMessage>()
    }

    suspend fun sendMessage(conversationId: String, content: String): ChatMessage = withContext(Dispatchers.IO) {
        val uid = currentUserId() ?: throw IllegalStateException("Não autenticado")
        client.postgrest["messages"].insert(
            ChatMessage(
                conversationId = conversationId,
                senderId = uid,
                content = content
            )
        ) {
            select()
        }.decodeSingle<ChatMessage>()
    }

    fun observeRealtimeMessages(conversationId: String): Flow<ChatMessage> {
        val channel = client.realtime.channel("chat:$conversationId")
        return channel.postgresChangeFlow<PostgresAction.Insert>(schema = "public") {
            table = "messages"
        }.map { insertAction ->
            insertAction.decodeRecord<ChatMessage>()
        }.flowOn(Dispatchers.IO)
    }
}
EOF

# 14. data/repository/AiRepository.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/data/repository/AiRepository.kt
package br.com.vizin.app.data.repository

import br.com.vizin.app.core.network.SupabaseProvider
import br.com.vizin.app.domain.model.AiGenerateResponse
import br.com.vizin.app.domain.model.AiListingSuggestion
import io.github.jan.supabase.functions.functions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

class AiRepository {
    private val client = SupabaseProvider.client
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun generateListingAssistant(prompt: String, categoryName: String): Result<AiListingSuggestion> = withContext(Dispatchers.IO) {
        try {
            val response = client.functions.invoke(
                function = "vizin-ai",
                body = buildJsonObject {
                    put("prompt", prompt)
                    put("category", categoryName)
                    put("task", "generate_listing")
                }
            )
            val decoded = json.decodeFromString<AiGenerateResponse>(response.body())
            val structured = json.decodeFromString<AiListingSuggestion>(decoded.result)
            Result.success(structured)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun askAssistant(userMessage: String): Result<String> = withContext(Dispatchers.IO) {
        try {
            val response = client.functions.invoke(
                function = "vizin-ai",
                body = buildJsonObject {
                    put("prompt", userMessage)
                    put("task", "assistant_chat")
                }
            )
            val decoded = json.decodeFromString<AiGenerateResponse>(response.body())
            Result.success(decoded.result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
EOF

# 15. features/home/HomeViewModel.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/features/home/HomeViewModel.kt
package br.com.vizin.app.features.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import br.com.vizin.app.data.repository.ListingsRepository
import br.com.vizin.app.domain.model.Category
import br.com.vizin.app.domain.model.ListingNearbyDTO
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class HomeUiState(
    val isLoading: Boolean = true,
    val categories: List<Category> = emptyList(),
    val nearbyListings: List<ListingNearbyDTO> = emptyList(),
    val errorMessage: String? = null,
    val selectedCategory: String? = null,
    val currentDistanceFilter: Double = 10000.0
)

class HomeViewModel(
    private val listingsRepo: ListingsRepository = ListingsRepository()
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private var lastKnownLat = -23.550520
    private var lastKnownLng = -46.633308

    init {
        loadInitialData()
    }

    fun updateCoordinates(lat: Double, lng: Double) {
        lastKnownLat = lat
        lastKnownLng = lng
        loadListings()
    }

    fun selectCategory(categoryId: String?) {
        _uiState.value = _uiState.value.copy(selectedCategory = categoryId)
        loadListings()
    }

    fun setDistanceFilter(meters: Double) {
        _uiState.value = _uiState.value.copy(currentDistanceFilter = meters)
        loadListings()
    }

    fun loadInitialData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val cats = listingsRepo.fetchCategories()
                _uiState.value = _uiState.value.copy(categories = cats)
                loadListings()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Falha ao sincronizar dados: ${e.localizedMessage}"
                )
            }
        }
    }

    private fun loadListings() {
        viewModelScope.launch {
            try {
                val list = listingsRepo.getNearbyListings(
                    latitude = lastKnownLat,
                    longitude = lastKnownLng,
                    radiusMeters = _uiState.value.currentDistanceFilter,
                    categoryId = _uiState.value.selectedCategory
                )
                _uiState.value = _uiState.value.copy(
                    nearbyListings = list,
                    isLoading = false,
                    errorMessage = null
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Erro ao carregar anúncios: ${e.localizedMessage}"
                )
            }
        }
    }
}
EOF

# 16. features/home/HomeScreen.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/features/home/HomeScreen.kt
package br.com.vizin.app.features.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import br.com.vizin.app.domain.model.ListingNearbyDTO
import br.com.vizin.app.ui.theme.VizinGreenPrimary
import br.com.vizin.app.ui.theme.VizinGreenSoft
import coil.compose.AsyncImage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToListingDetail: (String) -> Unit,
    onNavigateToCreate: () -> Unit,
    onNavigateToAi: () -> Unit,
    viewModel: HomeViewModel = viewModel()
) {
    val state by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(
                            modifier = Modifier.size(36.dp),
                            shape = CircleShape,
                            color = VizinGreenPrimary
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Text("V", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                            }
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("VIZIN", fontWeight = FontWeight.ExtraBold, letterSpacing = 1.sp)
                    }
                },
                actions = {
                    IconButton(onClick = onNavigateToAi) {
                        Icon(Icons.Default.AutoAwesome, contentDescription = "VIZIN AI", tint = VizinGreenPrimary)
                    }
                    IconButton(onClick = { viewModel.loadInitialData() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Atualizar")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onNavigateToCreate,
                containerColor = VizinGreenPrimary,
                contentColor = Color.White,
                shape = CircleShape
            ) {
                Icon(Icons.Default.Add, contentDescription = "Criar Publicação")
            }
        }
    ) { padding ->
        if (state.isLoading && state.nearbyListings.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = VizinGreenPrimary)
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .background(MaterialTheme.colorScheme.surfaceVariant),
                contentPadding = PaddingValues(bottom = 80.dp)
            ) {
                item {
                    DistanceFilterChips(
                        currentDistance = state.currentDistanceFilter,
                        onSelectDistance = { viewModel.setDistanceFilter(it) }
                    )
                }

                item {
                    Text(
                        text = "Categorias",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp,
                        modifier = Modifier.padding(start = 16.dp, top = 8.dp, bottom = 8.dp)
                    )
                    LazyRow(
                        contentPadding = PaddingValues(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        item {
                            FilterChip(
                                selected = state.selectedCategory == null,
                                onClick = { viewModel.selectCategory(null) },
                                label = { Text("Todas") }
                            )
                        }
                        items(state.categories) { cat ->
                            FilterChip(
                                selected = state.selectedCategory == cat.id,
                                onClick = { viewModel.selectCategory(cat.id) },
                                label = { Text(cat.name) }
                            )
                        }
                    }
                }

                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp)
                            .clickable { onNavigateToAi() },
                        colors = CardDefaults.cardColors(containerColor = VizinGreenSoft),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.AutoAwesome,
                                contentDescription = null,
                                tint = VizinGreenPrimary,
                                modifier = Modifier.size(32.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Column {
                                Text(
                                    "Precisa de ajuda rápida?",
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onBackground
                                )
                                Text(
                                    "Use a VIZIN AI para achar serviços ou redigir seu anúncio em segundos.",
                                    fontSize = 12.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }
                }

                item {
                    Text(
                        text = "Perto de Você",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                if (state.nearbyListings.isEmpty()) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                "Nenhuma publicação encontrada neste raio.",
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                } else {
                    items(state.nearbyListings) { listing ->
                        ListingCardItem(
                            listing = listing,
                            onClick = { onNavigateToListingDetail(listing.id) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun DistanceFilterChips(
    currentDistance: Double,
    onSelectDistance: (Double) -> Unit
) {
    val distances = listOf(
        1000.0 to "1 km",
        5000.0 to "5 km",
        10000.0 to "10 km",
        25000.0 to "25 km",
        50000.0 to "50 km"
    )
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        distances.forEach { (dist, label) ->
            InputChip(
                selected = currentDistance == dist,
                onClick = { onSelectDistance(dist) },
                label = { Text(label) },
                leadingIcon = {
                    if (currentDistance == dist) {
                        Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(16.dp))
                    }
                }
            )
        }
    }
}

@Composable
fun ListingCardItem(
    listing: ListingNearbyDTO,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp)
            .clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth()
        ) {
            AsyncImage(
                model = listing.thumbnailUrl ?: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=300",
                contentDescription = listing.title,
                modifier = Modifier
                    .size(90.dp)
                    .clip(RoundedCornerShape(8.dp)),
                contentScale = ContentScale.Crop
            )

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier
                    .weight(1f)
                    .align(Alignment.CenterVertically)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = listing.city + " • " + listing.neighborhood,
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Surface(
                        color = VizinGreenSoft,
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text(
                            text = listing.formattedDistance,
                            color = VizinGreenPrimary,
                            fontWeight = FontWeight.Bold,
                            fontSize = 11.sp,
                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = listing.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Text(
                    text = listing.description,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(6.dp))

                if (listing.price != null && listing.price > 0) {
                    Text(
                        text = "R$ " + String.format("%.2f", listing.price),
                        fontWeight = FontWeight.ExtraBold,
                        color = VizinGreenPrimary,
                        fontSize = 15.sp
                    )
                } else {
                    Text(
                        text = "A Combinar",
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        fontSize = 13.sp
                    )
                }
            }
        }
    }
}
EOF

# 17. features/create/CreateListingScreen.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/features/create/CreateListingScreen.kt
package br.com.vizin.app.features.create

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.vizin.app.data.repository.AiRepository
import br.com.vizin.app.data.repository.ListingsRepository
import br.com.vizin.app.ui.theme.VizinGreenPrimary
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateListingScreen(
    onListingCreated: () -> Unit,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    val repo = remember { ListingsRepository() }
    val aiRepo = remember { AiRepository() }

    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var priceText by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("São Paulo") }
    var neighborhood by remember { mutableStateOf("Pinheiros") }
    var selectedListingType by remember { mutableStateOf("service_offered") }
    var isNegotiable by remember { mutableStateOf(false) }

    var isSubmitting by remember { mutableStateOf(false) }
    var isAiLoading by remember { mutableStateOf(false) }
    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    var statusMessage by remember { mutableStateOf<String?>(null) }

    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        selectedImageUri = uri
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Nova Publicação", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Voltar")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Tipo de Oportunidade", fontWeight = FontWeight.Bold)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "service_offered" to "Oferecer Serviço",
                    "product_sale" to "Vender Produto",
                    "help_request" to "Ajuda Local"
                ).forEach { (type, label) ->
                    FilterChip(
                        selected = selectedListingType == type,
                        onClick = { selectedListingType = type },
                        label = { Text(label, fontSize = 12.sp) }
                    )
                }
            }

            OutlinedButton(
                onClick = {
                    if (title.isBlank()) {
                        statusMessage = "Digite ao menos um rascunho de título para a IA refinar."
                        return@OutlinedButton
                    }
                    isAiLoading = true
                    coroutineScope.launch {
                        aiRepo.generateListingAssistant(title, selectedListingType)
                            .onSuccess { suggestion ->
                                title = suggestion.title
                                description = suggestion.description
                                if (suggestion.suggestedPrice > 0) {
                                    priceText = suggestion.suggestedPrice.toString()
                                }
                                statusMessage = "Anúncio otimizado com a VIZIN AI!"
                            }
                            .onFailure {
                                statusMessage = "Erro ao invocar IA: ${it.localizedMessage}"
                            }
                        isAiLoading = false
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isAiLoading
            ) {
                Icon(Icons.Default.AutoAwesome, contentDescription = null, tint = VizinGreenPrimary)
                Spacer(modifier = Modifier.width(8.dp))
                Text(if (isAiLoading) "VIZIN AI gerando anúncio..." else "Melhorar com VIZIN AI", color = VizinGreenPrimary)
            }

            OutlinedTextField(
                value = title,
                onValueChange = { title = it },
                label = { Text("Título da Oportunidade") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = description,
                onValueChange = { description = it },
                label = { Text("Descrição detalhada") },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
                maxLines = 5
            )

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = priceText,
                    onValueChange = { priceText = it },
                    label = { Text("Preço (R$)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.weight(1f)
                )

                OutlinedTextField(
                    value = neighborhood,
                    onValueChange = { neighborhood = it },
                    label = { Text("Bairro") },
                    modifier = Modifier.weight(1f)
                )
            }

            Button(
                onClick = { imagePickerLauncher.launch("image/*") },
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Default.PhotoCamera, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    if (selectedImageUri != null) "Foto Selecionada ✓" else "Adicionar Foto",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            statusMessage?.let {
                Text(it, color = VizinGreenPrimary, fontSize = 13.sp)
            }

            Spacer(modifier = Modifier.weight(1f))

            Button(
                onClick = {
                    if (title.isBlank() || description.isBlank()) {
                        statusMessage = "Preencha todos os campos obrigatórios."
                        return@Button
                    }
                    isSubmitting = true
                    coroutineScope.launch {
                        try {
                            val uploadedUrls = mutableListOf<String>()
                            selectedImageUri?.let { uri ->
                                val stream = context.contentResolver.openInputStream(uri)
                                val bytes = stream?.readBytes()
                                if (bytes != null) {
                                    val url = repo.uploadListingImage(bytes)
                                    uploadedUrls.add(url)
                                }
                            }

                            val defaultCatId = "a1b2c3d4-0000-0000-0000-000000000001"
                            repo.createListing(
                                title = title,
                                description = description,
                                categoryId = defaultCatId,
                                listingType = selectedListingType,
                                price = priceText.toDoubleOrNull(),
                                negotiable = isNegotiable,
                                city = city,
                                neighborhood = neighborhood,
                                latitude = -23.550520,
                                longitude = -46.633308,
                                imageUrls = uploadedUrls
                            )
                            onListingCreated()
                        } catch (e: Exception) {
                            statusMessage = "Erro ao publicar: ${e.localizedMessage}"
                        } finally {
                            isSubmitting = false
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp),
                enabled = !isSubmitting,
                colors = ButtonDefaults.buttonColors(containerColor = VizinGreenPrimary)
            ) {
                if (isSubmitting) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Text("Publicar no VIZIN", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }
        }
    }
}
EOF

# 18. features/chat/ChatScreen.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/features/chat/ChatScreen.kt
package br.com.vizin.app.features.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.vizin.app.data.repository.ChatRepository
import br.com.vizin.app.domain.model.ChatMessage
import br.com.vizin.app.ui.theme.VizinGreenPrimary
import br.com.vizin.app.ui.theme.VizinGreenSoft
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
    conversationId: String,
    onBack: () -> Unit
) {
    val chatRepo = remember { ChatRepository() }
    val coroutineScope = rememberCoroutineScope()
    var messageText by remember { mutableStateOf("") }
    val messages = remember { mutableStateListOf<ChatMessage>() }
    val currentUserId = remember { chatRepo.currentUserId() }

    LaunchedEffect(conversationId) {
        val history = chatRepo.getMessages(conversationId)
        messages.addAll(history)

        chatRepo.observeRealtimeMessages(conversationId).collect { newMsg ->
            if (messages.none { it.id == newMsg.id }) {
                messages.add(newMsg)
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Conversa com Vizinho", fontSize = 18.sp) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Voltar")
                    }
                }
            )
        },
        bottomBar = {
            Surface(
                tonalElevation = 4.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .padding(horizontal = 8.dp, vertical = 6.dp)
                        .imePadding(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = messageText,
                        onValueChange = { messageText = it },
                        placeholder = { Text("Mensagem segura...") },
                        modifier = Modifier.weight(1f),
                        maxLines = 3,
                        shape = RoundedCornerShape(24.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    IconButton(
                        onClick = {
                            if (messageText.isNotBlank()) {
                                val textToSend = messageText
                                messageText = ""
                                coroutineScope.launch {
                                    chatRepo.sendMessage(conversationId, textToSend)
                                }
                            }
                        }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.Send, contentDescription = "Enviar", tint = VizinGreenPrimary)
                    }
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(messages) { msg ->
                val isMe = msg.senderId == currentUserId
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = if (isMe) Alignment.CenterEnd else Alignment.CenterStart
                ) {
                    Surface(
                        color = if (isMe) VizinGreenPrimary else VizinGreenSoft,
                        shape = RoundedCornerShape(
                            topStart = 12.dp,
                            topEnd = 12.dp,
                            bottomStart = if (isMe) 12.dp else 0.dp,
                            bottomEnd = if (isMe) 0.dp else 12.dp
                        )
                    ) {
                        Text(
                            text = msg.content ?: "",
                            color = if (isMe) Color.White else Color.Black,
                            modifier = Modifier.padding(10.dp),
                            fontSize = 14.sp
                        )
                    }
                }
            }
        }
    }
}
EOF

# 19. features/ai/VizinAiScreen.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/features/ai/VizinAiScreen.kt
package br.com.vizin.app.features.ai

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.vizin.app.data.repository.AiRepository
import br.com.vizin.app.ui.theme.VizinGreenPrimary
import br.com.vizin.app.ui.theme.VizinGreenSoft
import kotlinx.coroutines.launch

data class MessageBubble(val text: String, val isAi: Boolean)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VizinAiScreen(onBack: () -> Unit) {
    val aiRepo = remember { AiRepository() }
    val scope = rememberCoroutineScope()
    var input by remember { mutableStateOf("") }
    var isThinking by remember { mutableStateOf(false) }

    val chatHistory = remember {
        mutableStateListOf(
            MessageBubble(
                "Olá, vizinho! Sou a inteligência artificial do VIZIN. Como posso te apoiar hoje com ideias de precificação, redação de anúncios ou busca por profissionais locais?",
                true
            )
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.AutoAwesome, contentDescription = null, tint = VizinGreenPrimary)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("VIZIN AI", fontWeight = FontWeight.Bold)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Voltar")
                    }
                }
            )
        },
        bottomBar = {
            Surface(tonalElevation = 3.dp) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp)
                        .imePadding(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = input,
                        onValueChange = { input = it },
                        placeholder = { Text("Pergunte algo à IA...") },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    IconButton(
                        onClick = {
                            if (input.isNotBlank() && !isThinking) {
                                val userQuery = input
                                input = ""
                                chatHistory.add(MessageBubble(userQuery, false))
                                isThinking = true

                                scope.launch {
                                    aiRepo.askAssistant(userQuery)
                                        .onSuccess { aiResponse ->
                                            chatHistory.add(MessageBubble(aiResponse, true))
                                        }
                                        .onFailure {
                                            chatHistory.add(
                                                MessageBubble(
                                                    "Desculpe, ocorreu uma instabilidade na conexão: ${it.localizedMessage}",
                                                    true
                                                )
                                            )
                                        }
                                    isThinking = false
                                }
                            }
                        }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.Send, contentDescription = "Enviar", tint = VizinGreenPrimary)
                    }
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(chatHistory) { bubble ->
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = if (bubble.isAi) Alignment.CenterStart else Alignment.CenterEnd
                ) {
                    Surface(
                        color = if (bubble.isAi) VizinGreenSoft else VizinGreenPrimary,
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text(
                            text = bubble.text,
                            color = if (bubble.isAi) MaterialTheme.colorScheme.onBackground else Color.White,
                            modifier = Modifier.padding(12.dp),
                            fontSize = 14.sp
                        )
                    }
                }
            }

            if (isThinking) {
                item {
                    Text(
                        "VIZIN AI está analisando...",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(4.dp)
                    )
                }
            }
        }
    }
}
EOF

# 20. navigation/VizinNavGraph.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/navigation/VizinNavGraph.kt
package br.com.vizin.app.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavType
import androidx.navigation.compose.*
import androidx.navigation.navArgument
import br.com.vizin.app.features.ai.VizinAiScreen
import br.com.vizin.app.features.chat.ChatScreen
import br.com.vizin.app.features.create.CreateListingScreen
import br.com.vizin.app.features.home.HomeScreen

sealed class Screen(val route: String, val title: String, val icon: ImageVector) {
    object Home : Screen("home", "Início", Icons.Default.Home)
    object Explore : Screen("explore", "Explorar", Icons.Default.Search)
    object Create : Screen("create", "Publicar", Icons.Default.AddCircleOutline)
    object Messages : Screen("messages", "Mensagens", Icons.Default.ChatBubbleOutline)
    object Profile : Screen("profile", "Perfil", Icons.Default.PersonOutline)
    object AiChat : Screen("ai_chat", "VIZIN AI", Icons.Default.AutoAwesome)
    object ChatDetail : Screen("chat/{conversationId}", "Chat", Icons.Default.Chat) {
        fun createRoute(conversationId: String) = "chat/$conversationId"
    }
}

@Composable
fun VizinMainApp() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val bottomItems = listOf(
        Screen.Home,
        Screen.Explore,
        Screen.Create,
        Screen.Messages,
        Screen.Profile
    )

    val showBottomBar = bottomItems.any { it.route == currentRoute }

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar {
                    bottomItems.forEach { screen ->
                        NavigationBarItem(
                            icon = { Icon(screen.icon, contentDescription = screen.title) },
                            label = { Text(screen.title) },
                            selected = currentRoute == screen.route,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) {
                HomeScreen(
                    onNavigateToListingDetail = { listingId ->
                        navController.navigate(Screen.ChatDetail.createRoute(listingId))
                    },
                    onNavigateToCreate = { navController.navigate(Screen.Create.route) },
                    onNavigateToAi = { navController.navigate(Screen.AiChat.route) }
                )
            }
            composable(Screen.Explore.route) {
                HomeScreen(
                    onNavigateToListingDetail = {},
                    onNavigateToCreate = { navController.navigate(Screen.Create.route) },
                    onNavigateToAi = { navController.navigate(Screen.AiChat.route) }
                )
            }
            composable(Screen.Create.route) {
                CreateListingScreen(
                    onListingCreated = { navController.popBackStack() },
                    onBack = { navController.popBackStack() }
                )
            }
            composable(Screen.Messages.route) {
                ChatScreen(
                    conversationId = "00000000-0000-0000-0000-000000000000",
                    onBack = { navController.popBackStack() }
                )
            }
            composable(Screen.Profile.route) {
                VizinAiScreen(onBack = { navController.popBackStack() })
            }
            composable(Screen.AiChat.route) {
                VizinAiScreen(onBack = { navController.popBackStack() })
            }
            composable(
                route = Screen.ChatDetail.route,
                arguments = listOf(navArgument("conversationId") { type = NavType.StringType })
            ) { backStackEntry ->
                val convId = backStackEntry.arguments?.getString("conversationId") ?: ""
                ChatScreen(conversationId = convId, onBack = { navController.popBackStack() })
            }
        }
    }
}
EOF

# 21. VizinApplication.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/VizinApplication.kt
package br.com.vizin.app

import android.app.Application
import br.com.vizin.app.core.network.SupabaseProvider

class VizinApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        SupabaseProvider.client
    }
}
EOF

# 22. MainActivity.kt
cat << 'EOF' > app/src/main/java/br/com/vizin/app/MainActivity.kt
package br.com.vizin.app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import br.com.vizin.app.navigation.VizinMainApp
import br.com.vizin.app.ui.theme.VIZINTheme

class MainActivity : ComponentActivity() {

    private val locationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { _ -> }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            locationPermissionLauncher.launch(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                )
            )
        }

        setContent {
            VIZINTheme {
                VizinMainApp()
            }
        }
    }
}
EOF

# 23. Teste Unitário
cat << 'EOF' > app/src/test/java/br/com/vizin/app/ListingsDistanceUnitTest.kt
package br.com.vizin.app

import br.com.vizin.app.domain.model.ListingNearbyDTO
import org.junit.Assert.assertEquals
import org.junit.Test

class ListingsDistanceUnitTest {

    @Test
    fun testDistanceFormattingInMeters() {
        val dto = ListingNearbyDTO(
            id = "1",
            userId = "u1",
            authorName = "Ana",
            authorAvatar = null,
            title = "Aulas de Violão",
            description = "Aulas para iniciantes",
            categoryId = "cat-1",
            listingType = "service_offered",
            price = 50.0,
            negotiable = false,
            city = "São Paulo",
            neighborhood = "Pinheiros",
            approxLat = -23.561,
            approxLng = -46.682,
            distanceMeters = 450.0,
            thumbnailUrl = null,
            createdAt = "2026-10-31T00:00:00Z"
        )
        assertEquals("450 m", dto.formattedDistance)
    }

    @Test
    fun testDistanceFormattingInKilometers() {
        val dto = ListingNearbyDTO(
            id = "2",
            userId = "u2",
            authorName = "Carlos",
            title = "Pintor Residencial",
            description = "Pintura em geral",
            categoryId = "cat-2",
            listingType = "service_offered",
            city = "São Paulo",
            neighborhood = "Vila Mariana",
            approxLat = -23.589,
            approxLng = -46.634,
            distanceMeters = 5400.0,
            createdAt = "2026-10-31T00:00:00Z"
        )
        assertEquals("5.4 km", dto.formattedDistance)
    }
}
EOF

echo "Gerando artefatos do Backend Supabase..."

# 24. Migração SQL Supabase
cat << 'EOF' > supabase/migrations/20261031000000_vizin_core.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

CREATE TYPE account_type_enum AS ENUM ('individual', 'business', 'freelancer');
CREATE TYPE listing_type_enum AS ENUM ('product_sale', 'service_offered', 'service_needed', 'job_opportunity', 'help_request', 'local_business');
CREATE TYPE listing_status_enum AS ENUM ('active', 'paused', 'sold', 'completed', 'deleted');
CREATE TYPE report_status_enum AS ENUM ('pending', 'investigating', 'resolved', 'dismissed');

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(30) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    city VARCHAR(100) NOT NULL,
    neighborhood VARCHAR(100),
    account_type account_type_enum DEFAULT 'individual' NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(80) NOT NULL,
    slug VARCHAR(80) UNIQUE NOT NULL,
    icon VARCHAR(50) NOT NULL,
    parent_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
    active BOOLEAN DEFAULT TRUE NOT NULL,
    sort_order INT DEFAULT 0 NOT NULL
);

CREATE TABLE public.listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    listing_type listing_type_enum NOT NULL,
    price NUMERIC(12, 2),
    negotiable BOOLEAN DEFAULT FALSE NOT NULL,
    status listing_status_enum DEFAULT 'active' NOT NULL,
    city VARCHAR(100) NOT NULL,
    neighborhood VARCHAR(100) NOT NULL,
    location GEOGRAPHY(Point, 4326) NOT NULL,
    views_count INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '45 days') NOT NULL
);

CREATE TABLE public.listing_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    position INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_favorite UNIQUE(user_id, listing_id)
);

CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE public.conversation_participants (
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT,
    image_url TEXT,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT chk_content_or_image CHECK (content IS NOT NULL OR image_url IS NOT NULL)
);

CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reviewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT no_self_review CHECK (reviewer_id <> reviewed_user_id),
    CONSTRAINT unique_reviewer_listing UNIQUE(reviewer_id, listing_id)
);

CREATE TABLE public.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
    reason VARCHAR(80) NOT NULL,
    details TEXT,
    status report_status_enum DEFAULT 'pending' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE public.user_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_block UNIQUE(blocker_id, blocked_id)
);

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(120) NOT NULL,
    body TEXT NOT NULL,
    reference_id UUID,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE public.ai_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    feature VARCHAR(60) NOT NULL,
    tokens_used INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE INDEX idx_listings_location ON public.listings USING GIST(location);
CREATE INDEX idx_listings_user_id ON public.listings(user_id);
CREATE INDEX idx_listings_category ON public.listings(category_id);
CREATE INDEX idx_listings_status ON public.listings(status);
CREATE INDEX idx_listings_created_at ON public.listings(created_at DESC);
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at ASC);
CREATE INDEX idx_favorites_user ON public.favorites(user_id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    gen_username VARCHAR(30);
BEGIN
    gen_username := LOWER(SPLIT_PART(NEW.email, '@', 1)) || '_' || SUBSTRING(NEW.id::text, 1, 4);
    INSERT INTO public.profiles (id, username, full_name, avatar_url, city, neighborhood)
    VALUES (
        NEW.id,
        gen_username,
        COALESCE(NEW.raw_user_meta_data->>'full_name', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url',
        'São Paulo',
        'Centro'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.search_listings_nearby(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_meters DOUBLE PRECISION DEFAULT 10000,
    search_query TEXT DEFAULT NULL,
    filter_category UUID DEFAULT NULL,
    filter_type listing_type_enum DEFAULT NULL,
    limit_count INT DEFAULT 30,
    offset_count INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    author_name VARCHAR,
    author_avatar TEXT,
    title VARCHAR,
    description TEXT,
    category_id UUID,
    listing_type listing_type_enum,
    price NUMERIC,
    negotiable BOOLEAN,
    city VARCHAR,
    neighborhood VARCHAR,
    approx_lat DOUBLE PRECISION,
    approx_lng DOUBLE PRECISION,
    distance_meters DOUBLE PRECISION,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.user_id,
        p.full_name AS author_name,
        p.avatar_url AS author_avatar,
        l.title,
        l.description,
        l.category_id,
        l.listing_type,
        l.price,
        l.negotiable,
        l.city,
        l.neighborhood,
        ROUND(ST_Y(l.location::geometry)::numeric, 3)::double precision AS approx_lat,
        ROUND(ST_X(l.location::geometry)::numeric, 3)::double precision AS approx_lng,
        ST_Distance(l.location, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography) AS distance_meters,
        (SELECT img.image_url FROM public.listing_images img WHERE img.listing_id = l.id ORDER BY img.position ASC LIMIT 1) AS thumbnail_url,
        l.created_at
    FROM public.listings l
    JOIN public.profiles p ON p.id = l.user_id
    WHERE l.status = 'active'
      AND ST_DWithin(l.location, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography, radius_meters)
      AND (search_query IS NULL OR (l.title ILIKE '%' || search_query || '%' OR l.description ILIKE '%' || search_query || '%'))
      AND (filter_category IS NULL OR l.category_id = filter_category)
      AND (filter_type IS NULL OR l.listing_type = filter_type)
    ORDER BY distance_meters ASC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

INSERT INTO public.categories (name, slug, icon, sort_order) VALUES
('Serviços Domésticos', 'servicos-domesticos', 'cleaning_services', 1),
('Tecnologia & TI', 'tecnologia', 'devices', 2),
('Beleza & Estética', 'beleza-estetica', 'spa', 3),
('Educação & Aulas', 'educacao', 'school', 4),
('Transporte & Mudanças', 'transporte', 'local_shipping', 5),
('Alimentação Caseira', 'alimentacao', 'restaurant', 6),
('Construção & Reformas', 'construcao', 'handyman', 7),
('Produtos Usados', 'produtos-usados', 'storefront', 8),
('Empregos Locais', 'empregos', 'work', 9),
('Animais & Pet Care', 'pets', 'pets', 10),
('Outros', 'outros', 'category', 11);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Active listings are public" ON public.listings FOR SELECT USING (status = 'active' OR auth.uid() = user_id);
CREATE POLICY "Users can create listings" ON public.listings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own listings" ON public.listings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own listings" ON public.listings FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Listing images are public" ON public.listing_images FOR SELECT USING (true);
CREATE POLICY "Owners can manage images" ON public.listing_images FOR ALL USING (
    EXISTS (SELECT 1 FROM public.listings WHERE listings.id = listing_images.listing_id AND listings.user_id = auth.uid())
);

CREATE POLICY "Users view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users manage own favorites" ON public.favorites FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Participants view conversations" ON public.conversations FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_participants.conversation_id = id AND conversation_participants.user_id = auth.uid())
);
CREATE POLICY "Participants can view conversation members" ON public.conversation_participants FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.conversation_participants cp WHERE cp.conversation_id = conversation_id AND cp.user_id = auth.uid())
);
CREATE POLICY "Participants view messages" ON public.messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_id = auth.uid())
);
CREATE POLICY "Participants insert messages" ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_id = auth.uid())
);

CREATE POLICY "Users see own ai usage" ON public.ai_usage FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service inserts ai usage" ON public.ai_usage FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Buckets de Armazenamento
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('listing-images', 'listing-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('chat-images', 'chat-images', false);

CREATE POLICY "Avatars Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Avatars User Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Listing Images Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'listing-images');
CREATE POLICY "Listing Images Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'listing-images' AND auth.role() = 'authenticated');

CREATE POLICY "Chat Images Access" ON storage.objects FOR SELECT USING (bucket_id = 'chat-images' AND auth.role() = 'authenticated');
CREATE POLICY "Chat Images Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'chat-images' AND auth.role() = 'authenticated');
EOF

# 25. Supabase Edge Function (VIZIN AI)
cat << 'EOF' > supabase/functions/vizin-ai/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Não autorizado" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { prompt, task, title, category } = await req.json();

    let systemInstruction = "Você é o VIZIN AI, o assistente inteligente da plataforma de oportunidades locais VIZIN.";
    if (task === "generate_listing") {
      systemInstruction += " Gere um título atraente, descrição vendedora detalhada e sugestão de preço competitivo para o anúncio com base nas anotações do usuário. Retorne exclusivamente em JSON no formato: {\"title\": \"...\", \"description\": \"...\", \"suggested_price\": 0.0}";
    } else if (task === "improve_text") {
      systemInstruction += " Reescreva e aprimore o texto a seguir, tornando-o claro, profissional, sem erros gramaticais e persuasivo.";
    }

    const llmApiKey = Deno.env.get("OPENAI_API_KEY");
    if (!llmApiKey) {
      throw new Error("Chave de API do provedor LLM não configurada no servidor.");
    }

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${llmApiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemInstruction },
          { role: "user", content: `Contexto Categoria: ${category || "Geral"}. Entrada: ${prompt || title}` }
        ],
        temperature: 0.7
      })
    });

    const llmData = await response.json();
    const resultText = llmData.choices[0].message.content;

    await supabaseClient.from("ai_usage").insert({
      user_id: user.id,
      feature: task || "chat",
      tokens_used: llmData.usage?.total_tokens || 100
    });

    return new Response(JSON.stringify({ result: resultText }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});
EOF

echo ""
echo "=============================================================================="
echo " Projeto VIZIN gerado com sucesso!"
echo "=============================================================================="
echo "Próximos passos:"
echo "1. Configure suas chaves do Supabase em 'app/build.gradle.kts'."
echo "2. Execute 'supabase/migrations/20261031000000_vizin_core.sql' no Supabase SQL Editor."
echo "3. Compile o aplicativo com:"
echo "   ./gradlew assembleDebug"
echo "=============================================================================="