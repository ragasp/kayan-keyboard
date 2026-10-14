#!/usr/bin/env bash
set -e

echo "🚀 جاري إنشاء هيكل مشروع كيبورد كيان الذكي..."

mkdir -p app/src/main/assets
mkdir -p app/src/main/java/com/kayan/aikeyboard
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml

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
rootProject.name = "KayanAIKeyboard"
include(":app")
EOF

# 2. Root build.gradle.kts
cat << 'EOF' > build.gradle.kts
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF

# 3. gradle.properties
cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

# 4. app/build.gradle.kts
cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.kayan.aikeyboard"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.kayan.aikeyboard"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.webkit:webkit:1.11.0")
}
EOF

# 5. app/src/main/res/values/strings.xml
cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">كيبورد كيان الذكي</string>
    <string name="subtype_ar">العربية (كيبورد كيان الذكي)</string>
    <string name="subtype_en">English (Kayan AI Keyboard)</string>
</resources>
EOF

# 6. app/src/main/res/xml/method.xml
cat << 'EOF' > app/src/main/res/xml/method.xml
<?xml version="1.0" encoding="utf-8"?>
<input-method xmlns:android="http://schemas.android.com/apk/res/android"
    android:settingsActivity="com.kayan.aikeyboard.MainActivity"
    android:supportsSwitchingToNextInputMethod="true">

    <subtype
        android:label="@string/subtype_ar"
        android:imeSubtypeLocale="ar"
        android:imeSubtypeMode="keyboard" />

    <subtype
        android:label="@string/subtype_en"
        android:imeSubtypeLocale="en_US"
        android:imeSubtypeMode="keyboard" />
</input-method>
EOF

# 7. app/src/main/AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.kayan.aikeyboard">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>

    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:usesCleartextTraffic="true"
        android:theme="@style/Theme.AppCompat.DayNight.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".KayanKeyboardService"
            android:label="@string/app_name"
            android:permission="android.permission.BIND_INPUT_METHOD"
            android:exported="true">
            <intent-filter>
                <action android:name="android.view.InputMethod" />
            </intent-filter>
            <meta-data
                android:name="android.view.im"
                android:resource="@xml/method" />
        </service>

    </application>
</manifest>
EOF

# 8. MainActivity.kt
cat << 'EOF' > app/src/main/java/com/kayan/aikeyboard/MainActivity.kt
package com.kayan.aikeyboard

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.view.inputmethod.InputMethodManager
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#0F172A"))
            setPadding(48, 80, 48, 48)
            gravity = Gravity.CENTER_HORIZONTAL
        }

        val title = TextView(this).apply {
            text = "كيبورد كيان الذكي 100%"
            textSize = 24f
            setTextColor(Color.parseColor("#34D399"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 16)
        }

        val subtitle = TextView(this).apply {
            text = "اتبع الخطوات الثلاث بالأسفل لتفعيل الكيبورد والترجمة والذكاء الاصطناعي في جميع تطبيقات هاتفك:"
            textSize = 14f
            setTextColor(Color.parseColor("#CBD5E1"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        val btnMic = createStyledButton("1️⃣ السماح بالميكروفون (للإملاء الصوتي)", "#0284C7") {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 101)
            } else {
                Toast.makeText(this, "✅ صلاحية الميكروفون مفعلة بالفعل!", Toast.LENGTH_SHORT).show()
            }
        }

        val btnEnable = createStyledButton("2️⃣ تفعيل الكيبورد من إعدادات النظام", "#10B981") {
            startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS))
        }

        val btnSelect = createStyledButton("3️⃣ اختيار كيبورد كيان كلوحة أساسية", "#8B5CF6") {
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.showInputMethodPicker()
        }

        val testInput = EditText(this).apply {
            hint = "اضغط هنا لتجربة الكيبورد بعد التفعيل..."
            setHintTextColor(Color.parseColor("#64748B"))
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#1E293B"))
            setPadding(36, 36, 36, 36)
            minLines = 4
            gravity = Gravity.TOP or Gravity.RIGHT
        }

        val lp = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply { topMargin = 32 }

        root.addView(title)
        root.addView(subtitle)
        root.addView(btnMic)
        root.addView(btnEnable)
        root.addView(btnSelect)
        root.addView(testInput, lp)

        setContentView(root)
    }

    private fun createStyledButton(label: String, hexColor: String, onClick: () -> Unit): Button {
        return Button(this).apply {
            text = label
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor(hexColor))
            textSize = 15f
            setPadding(32, 32, 32, 32)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = 28 }
            setOnClickListener { onClick() }
        }
    }
}
EOF

# 9. KayanKeyboardService.kt
cat << 'EOF' > app/src/main/java/com/kayan/aikeyboard/KayanKeyboardService.kt
package com.kayan.aikeyboard

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.ExtractedTextRequest
import android.webkit.JavascriptInterface
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import java.util.Locale

class KayanKeyboardService : InputMethodService(), TextToSpeech.OnInitListener {

    private lateinit var webView: WebView
    private var tts: TextToSpeech? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        tts = TextToSpeech(this, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale("ar")
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreateInputView(): View {
        val density = resources.displayMetrics.density
        val keyboardHeightPx = (330 * density).toInt()

        val container = FrameLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                keyboardHeightPx
            )
        }

        webView = WebView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                keyboardHeightPx
            )
            isVerticalScrollBarEnabled = false
            isHorizontalScrollBarEnabled = false

            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                databaseEnabled = true
                mediaPlaybackRequiresUserGesture = false
                allowFileAccess = true
            }

            isFocusable = false
            isFocusableInTouchMode = false

            webChromeClient = object : WebChromeClient() {
                override fun onPermissionRequest(request: PermissionRequest?) {
                    request?.grant(request.resources)
                }
            }
            webViewClient = WebViewClient()

            addJavascriptInterface(AndroidKeyboardBridge(), "AndroidIME")
            loadUrl("file:///android_asset/index.html")
        }

        container.addView(webView)
        return container
    }

    override fun onEvaluateFullscreenMode(): Boolean = false

    inner class AndroidKeyboardBridge {

        @JavascriptInterface
        fun commitText(text: String) {
            vibrateKey()
            if (text == "\n") {
                sendEnterOrAction()
            } else {
                currentInputConnection?.commitText(text, 1)
            }
        }

        @JavascriptInterface
        fun deleteBackward() {
            vibrateKey()
            val ic = currentInputConnection ?: return
            val selected = ic.getSelectedText(0)
            if (selected.isNullOrEmpty()) {
                ic.deleteSurroundingText(1, 0)
            } else {
                ic.commitText("", 1)
            }
        }

        @JavascriptInterface
        fun getExtractedText(): String {
            val ic = currentInputConnection ?: return ""
            val extracted = ic.getExtractedText(ExtractedTextRequest(), 0)
            return extracted?.text?.toString() ?: ""
        }

        @JavascriptInterface
        fun replaceAllText(newText: String) {
            val ic = currentInputConnection ?: return
            val extracted = ic.getExtractedText(ExtractedTextRequest(), 0)
            if (extracted != null && extracted.text != null) {
                ic.beginBatchEdit()
                ic.setSelection(0, extracted.text.length)
                ic.commitText(newText, 1)
                ic.endBatchEdit()
            } else {
                ic.commitText(newText, 1)
            }
        }

        @JavascriptInterface
        fun speak(text: String, langCode: String) {
            val locale = if (langCode.startsWith("en")) Locale.US else Locale("ar")
            tts?.language = locale
            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "kayan_tts_id")
        }

        @JavascriptInterface
        fun startVoiceDictation(langCode: String) {
            mainHandler.post {
                try {
                    if (speechRecognizer == null) {
                        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this@KayanKeyboardService)
                        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
                            override fun onReadyForSpeech(params: Bundle?) {
                                notifyJsVoiceState(true, "🎙️ تحدث الآن...")
                            }
                            override fun onBeginningOfSpeech() {}
                            override fun onRmsChanged(rmsdB: Float) {}
                            override fun onBufferReceived(buffer: ByteArray?) {}
                            override fun onEndOfSpeech() {
                                notifyJsVoiceState(false, "🎤 إملاء صوتي")
                            }
                            override fun onError(error: Int) {
                                notifyJsVoiceState(false, "🎤 إملاء صوتي")
                            }
                            override fun onResults(results: Bundle?) {
                                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                                if (!matches.isNullOrEmpty()) {
                                    val spoken = matches[0]
                                    currentInputConnection?.commitText("$spoken ", 1)
                                    webView.evaluateJavascript(
                                        "window.onNativeVoiceResult && window.onNativeVoiceResult(${org.json.JSONObject.quote(spoken)});",
                                        null
                                    )
                                }
                                notifyJsVoiceState(false, "🎤 إملاء صوتي")
                            }
                            override fun onPartialResults(partialResults: Bundle?) {}
                            override fun onEvent(eventType: Int, params: Bundle?) {}
                        })
                    }

                    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE, if (langCode == "en") "en-US" else "ar-EG")
                        putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                    }
                    speechRecognizer?.startListening(intent)
                } catch (e: Exception) {
                    notifyJsVoiceState(false, "🎤 إملاء صوتي")
                }
            }
        }
    }

    private fun notifyJsVoiceState(recording: Boolean, label: String) {
        mainHandler.post {
            webView.evaluateJavascript(
                "window.updateNativeMicUi && window.updateNativeMicUi($recording, '$label');",
                null
            )
        }
    }

    private fun sendEnterOrAction() {
        val ic = currentInputConnection ?: return
        val info = currentInputEditorInfo
        if (info != null && (info.imeOptions and EditorInfo.IME_FLAG_NO_ENTER_ACTION) == 0) {
            val action = info.imeOptions and EditorInfo.IME_MASK_ACTION
            if (action == EditorInfo.IME_ACTION_SEARCH ||
                action == EditorInfo.IME_ACTION_SEND ||
                action == EditorInfo.IME_ACTION_GO ||
                action == EditorInfo.IME_ACTION_DONE
            ) {
                ic.performEditorAction(action)
                return
            }
        }
        ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
        ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER))
    }

    private fun vibrateKey() {
        try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(14, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(14)
            }
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        speechRecognizer?.destroy()
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
EOF

# 10. app/src/main/assets/index.html (Complete Keyboard + Android Bridge Integrated)
cat << 'EOF' > app/src/main/assets/index.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>كيبورد كيان الذكي</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; user-select: none; -webkit-user-select: none; font-family: 'Cairo', sans-serif; }
    :root {
      --kb-bg: #111827; --key-bg: #1f2937; --key-spec: #0f172a; --accent: #10b981; --text-main: #f9fafb;
    }
    .theme-emerald { --kb-bg: #062c22; --key-bg: #0c4a3a; --key-spec: #041f18; --accent: #34d399; --text-main: #ecfdf5; }
    .theme-cyber { --kb-bg: #0f0722; --key-bg: #23114b; --key-spec: #160a30; --accent: #f43f5e; --text-main: #fce7f3; }
    .kb-container { background-color: var(--kb-bg); color: var(--text-main); }
    .kb-key {
      background-color: var(--key-bg); color: var(--text-main);
      border-bottom: 3px solid rgba(0,0,0,0.35); border-radius: 0.45rem;
      display: flex; align-items: center; justify-content: center;
      font-weight: 700; cursor: pointer; height: 42px; flex: 1; min-width: 24px; font-size: 1rem;
    }
    .kb-key:active { transform: translateY(2px); background-color: var(--accent); color: #fff; }
    .kb-key-spec { background-color: var(--key-spec); }
    .kb-accent { background-color: var(--accent); color: #ffffff; }
    .no-scrollbar::-webkit-scrollbar { display: none; }
    .mic-recording { background-color: #ef4444 !important; color: white !important; }
  </style>
</head>
<body class="bg-transparent m-0 p-0 overflow-hidden">
  <textarea id="mainEditor" class="hidden"></textarea>

  <div id="keyboardRoot" class="kb-container w-full h-screen flex flex-col justify-between m-0">
    <!-- Top Smart Toolbar -->
    <div class="flex items-center justify-between px-1.5 py-1 border-b border-black/20 bg-black/25 gap-1 overflow-x-auto no-scrollbar">
      <button onclick="switchPanel('keys')" id="tab-keys" class="px-2.5 py-1 rounded-lg text-xs font-bold kb-accent whitespace-nowrap">⌨️ الكيبورد</button>
      <button onclick="switchPanel('translate')" id="tab-translate" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap">🌐 ترجمة 100%</button>
      <button onclick="switchPanel('ai')" id="tab-ai" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap">🤖 ذكاء + نطق</button>
      <button onclick="switchPanel('clipboard')" id="tab-clipboard" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap">📋 الحافظة <span id="clipBadge" class="bg-emerald-500 text-black px-1 rounded-full text-[10px]">0</span></button>
      <button onclick="switchPanel('emoji')" id="tab-emoji" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap">😀 إيموجي</button>
      <button onclick="toggleZakhrafa()" id="zakhrafaBtn" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap">✨ زخرفة</button>
      <button onclick="toggleVoiceDictation()" id="micBtn" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-rose-500/20 text-rose-300 whitespace-nowrap">🎤 صوتي</button>
      <button onclick="cycleTheme()" class="px-2 py-1 rounded-lg text-xs bg-white/10">🎨</button>
    </div>

    <!-- Suggestions & Tashkeel Strip -->
    <div class="flex items-center justify-between px-1.5 py-1 bg-black/15 border-b border-black/20 gap-1 overflow-x-auto no-scrollbar">
      <div id="predictionsList" class="flex items-center gap-1 flex-grow overflow-x-auto no-scrollbar"></div>
      <div class="flex items-center gap-1 border-r border-white/15 pr-1.5">
        <button onclick="insertChar('َ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـَ</button>
        <button onclick="insertChar('ُ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـُ</button>
        <button onclick="insertChar('ِ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـِ</button>
        <button onclick="insertChar('ّ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـّ</button>
        <button onclick="insertChar('ْ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـْ</button>
        <button onclick="insertChar('ـ')" class="px-1.5 py-0.5 rounded bg-white/10 text-xs font-bold">ـ</button>
      </div>
    </div>

    <!-- Panel A: Keys -->
    <div id="panel-keys" class="p-1.5 flex flex-col gap-1 flex-grow justify-end">
      <div id="rowsContainer" class="flex flex-col gap-1"></div>
    </div>

    <!-- Panel B: Translator -->
    <div id="panel-translate" class="hidden p-2 flex flex-col gap-2 flex-grow overflow-y-auto">
      <div class="flex items-center justify-between gap-1.5">
        <select id="transSource" class="bg-slate-800 text-white text-xs rounded-lg px-2 py-1 flex-1">
          <option value="ar">العربية</option><option value="en">الإنجليزية</option><option value="fr">الفرنسية</option><option value="tr">التركية</option>
        </select>
        <button onclick="swapTranslationLangs()" class="px-2.5 py-1 rounded-lg bg-white/10 text-xs font-bold">⇄</button>
        <select id="transTarget" class="bg-slate-800 text-white text-xs rounded-lg px-2 py-1 flex-1">
          <option value="en">الإنجليزية</option><option value="ar">العربية</option><option value="fr">الفرنسية</option><option value="tr">التركية</option>
        </select>
        <button onclick="runKeyboardTranslation()" id="transBtn" class="px-3 py-1 rounded-lg kb-accent font-bold text-xs">ترجم النص المكتوب ⚡</button>
      </div>
      <div class="bg-black/35 border border-white/10 rounded-xl p-2 flex-grow flex flex-col justify-between">
        <p id="transResultText" class="text-xs text-emerald-300" dir="auto">اكتب جملتك في الشات ثم اضغط "ترجم النص المكتوب ⚡" ليتم ترجمتها ونطقها فوراً.</p>
        <div class="flex items-center justify-end gap-1.5 mt-1 pt-1 border-t border-white/10">
          <button onclick="speakTranslatedText()" class="px-2 py-1 rounded bg-cyan-500/20 text-cyan-300 text-xs font-bold">🔊 نطق</button>
          <button onclick="insertTranslatedText(false)" class="px-2 py-1 rounded bg-emerald-500/20 text-emerald-300 text-xs font-bold">➕ إضافة</button>
          <button onclick="insertTranslatedText(true)" class="px-2 py-1 rounded bg-amber-500/20 text-amber-300 text-xs font-bold">🔄 استبدال بالشات</button>
        </div>
      </div>
    </div>

    <!-- Panel C: AI Assistant -->
    <div id="panel-ai" class="hidden p-2 flex flex-col gap-2 flex-grow overflow-y-auto">
      <div class="flex flex-wrap gap-1">
        <button onclick="runAiAction('tashkeel')" class="px-2 py-1 rounded bg-emerald-500/20 text-emerald-300 text-xs font-bold">✍️ تشكيل تلقائي</button>
        <button onclick="runAiAction('grammar')" class="px-2 py-1 rounded bg-cyan-500/20 text-cyan-300 text-xs font-bold">✅ تصحيح إملائي</button>
        <button onclick="runAiAction('formal')" class="px-2 py-1 rounded bg-purple-500/20 text-purple-300 text-xs font-bold">🎩 صياغة رسمية</button>
        <button onclick="runAiAction('reply')" class="px-2 py-1 rounded bg-amber-500/20 text-amber-300 text-xs font-bold">💬 اقتراح رد ذكي</button>
      </div>
      <div class="bg-black/35 border border-white/10 rounded-xl p-2 flex-grow flex flex-col justify-between">
        <p id="aiOutputText" class="text-xs text-slate-200" dir="auto">اكتب رسالتك في الشات ثم اختر مهارة من الأعلى لمعالجتها ونطقها صوتياً!</p>
        <div class="flex items-center justify-between mt-1 pt-1 border-t border-white/10">
          <label class="flex items-center gap-1 text-[11px] text-slate-300">
            <input type="checkbox" id="autoSpeakAi" checked /> نطق تلقائي 🗣️
          </label>
          <div class="flex gap-1.5">
            <button onclick="speakText(document.getElementById('aiOutputText').innerText)" class="px-2 py-1 rounded bg-cyan-500/20 text-cyan-300 text-xs font-bold">🔊 نطق</button>
            <button onclick="applyAiOutput()" class="px-2 py-1 rounded bg-emerald-500/20 text-emerald-300 text-xs font-bold">📥 استبدال بالشات</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel D: Clipboard -->
    <div id="panel-clipboard" class="hidden p-2 flex flex-col gap-1.5 flex-grow overflow-y-auto">
      <div class="flex gap-1.5">
        <button onclick="saveCurrentHostTextToClip()" class="px-3 py-1 rounded-lg kb-accent text-xs font-bold flex-1">+ حفظ النص المكتوب حالياً في الشات للحافظة</button>
        <button onclick="clearUnpinnedClips()" class="px-2.5 py-1 rounded-lg bg-rose-500/20 text-rose-300 text-xs font-bold">مسح غير المثبت</button>
      </div>
      <div id="clipboardList" class="grid grid-cols-1 gap-1.5 overflow-y-auto"></div>
    </div>

    <!-- Panel E: Emoji -->
    <div id="panel-emoji" class="hidden p-2 flex flex-col gap-1.5 flex-grow overflow-y-auto">
      <div class="flex items-center gap-1 overflow-x-auto no-scrollbar border-b border-white/10 pb-1">
        <button onclick="renderEmojiCategory('faces')" class="px-2 py-0.5 rounded bg-white/10 text-xs font-bold">😀 وجوه</button>
        <button onclick="renderEmojiCategory('hands')" class="px-2 py-0.5 rounded bg-white/10 text-xs font-bold">👋 أيدي</button>
        <button onclick="renderEmojiCategory('hearts')" class="px-2 py-0.5 rounded bg-white/10 text-xs font-bold">❤️ قلوب</button>
        <button onclick="renderEmojiCategory('islamic')" class="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 text-xs font-bold">🕌 إسلاميات</button>
      </div>
      <div id="emojiGrid" class="grid grid-cols-8 gap-1 overflow-y-auto flex-grow"></div>
    </div>
  </div>

  <script>
    let currentLang = 'ar';
    let isShift = false;
    let isZakhrafa = false;
    let currentThemeIndex = 0;
    const themes = ['', 'theme-emerald', 'theme-cyber'];
    const editor = document.getElementById('mainEditor');
    const isAndroidIME = typeof window.AndroidIME !== 'undefined';

    const layouts = {
      ar: [
        ['ض','ص','ث','ق','ف','غ','ع','ه','خ','ح','ج','د'],
        ['ش','س','ي','ب','ل','ا','ت','ن','م','ك','ط'],
        ['ئ','ء','ؤ','ر','لا','ى','ة','و','ز','ظ','⌫']
      ],
      arShift: [
        ['أ','إ','آ','َ','ً','ُ','ٌ','ِ','ٍ','ْ','ّ','ـ'],
        ['«','»','؛','،','ـ','لأ','لإ','لآ','÷','×','؟'],
        ['~','!','@','#','$','%','^','&','*','(','⌫']
      ],
      en: [
        ['q','w','e','r','t','y','u','i','o','p'],
        ['a','s','d','f','g','h','j','k','l'],
        ['⇧','z','x','c','v','b','n','m','⌫']
      ],
      num: [
        ['1','2','3','4','5','6','7','8','9','0'],
        ['@','#','$','_','&','-','+','(',')','/'],
        ['*','"',"'",':',';','!','?','،','.','⌫']
      ]
    };

    const zakhrafaMap = {
      'ا':'آ','ب':'بـٌ','ت':'تـٌ','ث':'ثـٌ','ج':'جـِ','ح':'حـً','خ':'خـّ','د':'دٍ','ذ':'ذِ','ر':'رٍ','ز':'زٍ',
      'س':'سـّ','ش':'شـّ','ص':'صـْ','ض':'ضـْ','ط':'طـِ','ظ':'ظـِ','ع':'عـْ','غ':'غـْ','ف':'فـِ','ق':'قـٌ',
      'ك':'كـْ','ل':'لـِ','م':'مـْ','ن':'نـِ','ه':'هـْ','و':'وٌ','ي':'يـﮯ'
    };

    const dictionary = {
      ar: ['السلام عليكم ورحمة الله','بسم الله الرحمن الرحيم','إن شاء الله','ما شاء الله','الحمد لله','شكراً جزيلاً','جزاك الله خيراً'],
      en: ['Thank you so much','How are you?','Sounds great!','See you soon','As soon as possible']
    };

    const emojiCategories = {
      faces: ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','😉','😊','😇','🥰','😍','🤩','😘','😎','🥳','🥺','😢','😭','😡','🤔','🫡'],
      hands: ['👋','👌','🤌','✌️','🤞','👍','👎','👏','🙌','🫶','🤲','🤝','🙏','✍️','💪'],
      hearts: ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','💔','✨','🌟','🔥','💯','✅','❌','⚡','💎','👑','🎉'],
      islamic: ['ﷺ','ﷻ','﷽','السلام عليكم','وعليكم السلام','إن شاء الله','ما شاء الله','سبحان الله','الحمد لله','الله أكبر','جزاك الله خيراً','بارك الله فيك']
    };

    let clipboardItems = JSON.parse(localStorage.getItem('kayan_clipboard') || 'null') || [
      { id: 1, text: 'السلام عليكم ورحمة الله وبركاته', pinned: true },
      { id: 2, text: 'بسم الله الرحمن الرحيم', pinned: true },
      { id: 3, text: 'سبحان الله وبحمده، سبحان الله العظيم', pinned: true }
    ];

    function cycleTheme() {
      const root = document.getElementById('keyboardRoot');
      if (themes[currentThemeIndex]) root.classList.remove(themes[currentThemeIndex]);
      currentThemeIndex = (currentThemeIndex + 1) % themes.length;
      if (themes[currentThemeIndex]) root.classList.add(themes[currentThemeIndex]);
    }

    function renderKeyboard() {
      const container = document.getElementById('rowsContainer');
      container.innerHTML = '';
      const activeRows = currentLang === 'num' ? layouts.num : (currentLang === 'ar' ? (isShift ? layouts.arShift : layouts.ar) : layouts.en);

      activeRows.forEach((rowKeys, rowIdx) => {
        const rowDiv = document.createElement('div');
        rowDiv.className = 'flex items-center justify-center gap-1 w-full';
        if (currentLang === 'ar' && rowIdx === 2) {
          const shiftBtn = document.createElement('button');
          shiftBtn.className = `kb-key kb-key-spec ${isShift ? 'kb-accent' : ''}`;
          shiftBtn.style.flex = '1.3';
          shiftBtn.innerText = isShift ? 'حروف' : 'تشكيل';
          shiftBtn.onclick = () => { isShift = !isShift; renderKeyboard(); };
          rowDiv.appendChild(shiftBtn);
        }
        rowKeys.forEach(k => {
          const btn = document.createElement('button');
          btn.className = 'kb-key';
          let ch = (currentLang === 'en' && isShift && k.length === 1) ? k.toUpperCase() : k;
          if (k === '⌫' || k === '⇧') { btn.classList.add('kb-key-spec'); btn.style.flex = '1.4'; }
          btn.innerText = ch;
          btn.onclick = () => handleKeyPress(ch);
          rowDiv.appendChild(btn);
        });
        container.appendChild(rowDiv);
      });

      const bottomRow = document.createElement('div');
      bottomRow.className = 'flex items-center gap-1 w-full mt-0.5';
      bottomRow.append(
        createSpecBtn(currentLang === 'num' ? 'أبجد' : '?123', 1.2, () => { currentLang = currentLang === 'num' ? 'ar' : 'num'; renderKeyboard(); }),
        createSpecBtn(currentLang === 'ar' ? '🌐 EN' : '🌐 عربي', 1.3, () => { currentLang = currentLang === 'ar' ? 'en' : 'ar'; isShift = false; renderKeyboard(); updatePredictions(); }),
        createSpecBtn('،', 0.8, () => insertChar('،')),
        createSpecBtn(currentLang === 'ar' ? 'مسافة (كيان الذكي)' : 'Space', 4.0, () => insertChar(' ')),
        createSpecBtn('.', 0.8, () => insertChar('.')),
        createSpecBtn('↵', 1.4, () => insertChar('\n'), true)
      );
      container.appendChild(bottomRow);
    }

    function createSpecBtn(label, flexVal, fn, isAcc = false) {
      const b = document.createElement('button');
      b.className = `kb-key ${isAcc ? 'kb-accent' : 'kb-key-spec'} text-xs`;
      b.style.flex = String(flexVal);
      b.innerText = label;
      b.onclick = fn;
      return b;
    }

    function handleKeyPress(key) {
      if (key === '⌫') { deleteBackward(); return; }
      if (key === '⇧') { isShift = !isShift; renderKeyboard(); return; }
      let out = (isZakhrafa && zakhrafaMap[key]) ? zakhrafaMap[key] : key;
      insertChar(out);
    }

    function getHostText() {
      if (isAndroidIME) {
        const t = window.AndroidIME.getExtractedText();
        if (t && t.trim()) return t.trim();
      }
      return editor.value.trim();
    }

    function insertChar(str) {
      if (isAndroidIME) window.AndroidIME.commitText(str);
      editor.value += str;
      updatePredictions();
    }

    function deleteBackward() {
      if (isAndroidIME) window.AndroidIME.deleteBackward();
      editor.value = editor.value.slice(0, -1);
      updatePredictions();
    }

    function toggleZakhrafa() {
      isZakhrafa = !isZakhrafa;
      const b = document.getElementById('zakhrafaBtn');
      b.className = isZakhrafa ? 'px-2.5 py-1 rounded-lg text-xs font-bold kb-accent whitespace-nowrap' : 'px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap';
    }

    function updatePredictions() {
      const listEl = document.getElementById('predictionsList');
      listEl.innerHTML = '';
      const pool = currentLang === 'en' ? dictionary.en : dictionary.ar;
      pool.forEach(phrase => {
        const chip = document.createElement('button');
        chip.className = 'px-2 py-0.5 rounded bg-white/10 text-xs whitespace-nowrap';
        chip.innerText = phrase;
        chip.onclick = () => insertChar(phrase + ' ');
        listEl.appendChild(chip);
      });
    }

    function switchPanel(panelName) {
      ['keys', 'translate', 'ai', 'clipboard', 'emoji'].forEach(p => {
        document.getElementById(`panel-${p}`).classList.add('hidden');
        const tab = document.getElementById(`tab-${p}`);
        if (tab) tab.className = 'px-2.5 py-1 rounded-lg text-xs font-bold bg-white/10 whitespace-nowrap';
      });
      document.getElementById(`panel-${panelName}`).classList.remove('hidden');
      const activeTab = document.getElementById(`tab-${panelName}`);
      if (activeTab) activeTab.className = 'px-2.5 py-1 rounded-lg text-xs font-bold kb-accent whitespace-nowrap';
    }

    function swapTranslationLangs() {
      const s = document.getElementById('transSource');
      const t = document.getElementById('transTarget');
      const tmp = s.value; s.value = t.value; t.value = tmp;
    }

    async function runKeyboardTranslation() {
      const resultEl = document.getElementById('transResultText');
      const sourceText = getHostText();
      if (!sourceText) {
        resultEl.innerText = '⚠️ اكتب نصاً في الشات أولاً ثم اضغط ترجم.';
        return;
      }
      const sl = document.getElementById('transSource').value;
      const tl = document.getElementById('transTarget').value;
      resultEl.innerText = '⏳ جاري الترجمة الفورية...';
      try {
        const res = await fetch(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(sourceText)}&langpair=${sl}|${tl}`);
        const data = await res.json();
        resultEl.innerText = data?.responseData?.translatedText || 'تعذر الترجمة حالياً.';
      } catch (e) {
        resultEl.innerText = 'تأكد من اتصالك بالإنترنت.';
      }
    }

    function speakText(text, langCode = null) {
      const isAr = /[\u0600-\u06FF]/.test(text);
      const lang = langCode || (isAr ? 'ar' : 'en');
      if (isAndroidIME) {
        window.AndroidIME.speak(text, lang);
      } else if ('speechSynthesis' in window) {
        const u = new SpeechSynthesisUtterance(text);
        u.lang = lang === 'ar' ? 'ar-SA' : 'en-US';
        window.speechSynthesis.speak(u);
      }
    }

    function speakTranslatedText() {
      speakText(document.getElementById('transResultText').innerText, document.getElementById('transTarget').value);
    }

    function insertTranslatedText(replaceAll) {
      const txt = document.getElementById('transResultText').innerText;
      if (!txt || txt.includes('اكتب جملتك')) return;
      if (replaceAll && isAndroidIME) {
        window.AndroidIME.replaceAllText(txt);
      } else {
        insertChar(' ' + txt);
      }
      switchPanel('keys');
    }

    function toggleVoiceDictation() {
      if (isAndroidIME) {
        window.AndroidIME.startVoiceDictation(currentLang === 'en' ? 'en' : 'ar');
      }
    }

    window.updateNativeMicUi = function(recording, label) {
      const micBtn = document.getElementById('micBtn');
      if (recording) micBtn.classList.add('mic-recording');
      else micBtn.classList.remove('mic-recording');
      micBtn.innerText = label;
    };

    window.onNativeVoiceResult = function(spokenText) {
      editor.value += ' ' + spokenText;
    };

    function runAiAction(mode) {
      const outEl = document.getElementById('aiOutputText');
      const baseText = getHostText();
      if (!baseText) {
        outEl.innerText = '⚠️ اكتب نصاً في الشات أولاً ليقوم الذكاء الاصطناعي بمعالجته.';
        return;
      }
      let result = baseText;
      if (mode === 'tashkeel') {
        result = baseText.split(/\s+/).map(w => w.length > 2 ? w[0] + 'َ' + w.slice(1, -1) + 'ُ' + w.slice(-1) : w).join(' ');
      } else if (mode === 'grammar') {
        result = baseText.replace(/ان شاء الله/g, 'إن شاء الله').replace(/هاذا/g, 'هذا').replace(/لاكن/g, 'لكن');
      } else if (mode === 'formal') {
        result = `تحية طيبة وبعد، أود إفادتكم بالتالي: ${baseText}، وتفضلوا بقبول فائق الاحترام.`;
      } else if (mode === 'reply') {
        result = `وعليكم السلام ورحمة الله، شكراً جزيلاً لتواصلك الكريم، تم الاستلام وسأوافيك بالرد قريباً.`;
      }
      outEl.innerText = result;
      if (document.getElementById('autoSpeakAi').checked) speakText(result);
    }

    function applyAiOutput() {
      const txt = document.getElementById('aiOutputText').innerText;
      if (!txt || txt.includes('اكتب رسالتك')) return;
      if (isAndroidIME) window.AndroidIME.replaceAllText(txt);
      editor.value = txt;
      switchPanel('keys');
    }

    function saveClips() {
      localStorage.setItem('kayan_clipboard', JSON.stringify(clipboardItems));
      renderClipboard();
    }

    function renderClipboard() {
      const list = document.getElementById('clipboardList');
      document.getElementById('clipBadge').innerText = clipboardItems.length;
      list.innerHTML = '';
      clipboardItems.forEach(item => {
        const card = document.createElement('div');
        card.className = 'bg-black/35 border border-white/10 rounded-lg p-1.5 flex items-center justify-between gap-2';
        const b = document.createElement('button');
        b.className = 'text-xs text-right flex-1 truncate';
        b.innerText = item.text;
        b.onclick = () => insertChar(item.text + ' ');
        const del = document.createElement('button');
        del.className = 'px-1.5 py-0.5 rounded text-xs bg-rose-500/20 text-rose-300';
        del.innerText = '✕';
        del.onclick = () => { clipboardItems = clipboardItems.filter(c => c.id !== item.id); saveClips(); };
        card.append(b, del);
        list.appendChild(card);
      });
    }

    function saveCurrentHostTextToClip() {
      const val = getHostText();
      if (!val) return;
      clipboardItems.unshift({ id: Date.now(), text: val, pinned: false });
      saveClips();
    }

    function clearUnpinnedClips() {
      clipboardItems = clipboardItems.filter(c => c.pinned);
      saveClips();
    }

    function renderEmojiCategory(cat) {
      const grid = document.getElementById('emojiGrid');
      grid.innerHTML = '';
      const items = emojiCategories[cat] || emojiCategories.faces;
      grid.className = cat === 'islamic' ? 'grid grid-cols-3 gap-1 overflow-y-auto flex-grow' : 'grid grid-cols-8 gap-1 overflow-y-auto flex-grow';
      items.forEach(em => {
        const b = document.createElement('button');
        b.className = 'p-1 rounded bg-white/5 text-center font-bold ' + (cat === 'islamic' ? 'text-xs py-1.5' : 'text-lg');
        b.innerText = em;
        b.onclick = () => insertChar(em + (cat === 'islamic' ? ' ' : ''));
        grid.appendChild(b);
      });
    }

    renderKeyboard();
    updatePredictions();
    renderClipboard();
    renderEmojiCategory('faces');
  </script>
</body>
</html>
EOF

echo "✅ تم توليد جميع ملفات المشروع بنجاح!"
