package com.octo.rdo.positive_thinker

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.imagedescription.ImageDescriber
import com.google.mlkit.genai.imagedescription.ImageDescriberOptions
import com.google.mlkit.genai.imagedescription.ImageDescription
import com.google.mlkit.genai.imagedescription.ImageDescriptionRequest
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel
import com.google.mlkit.genai.summarization.Summarization
import com.google.mlkit.genai.summarization.SummarizationRequest
import com.google.mlkit.genai.summarization.Summarizer
import com.google.mlkit.genai.summarization.SummarizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.future.future
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private lateinit var generativeModel: GenerativeModel
    private lateinit var imageDescriber: ImageDescriber
    private lateinit var summarizer: Summarizer
    private var modelDownloaded: Boolean = false
    private val CHANNEL = "gemini_nano_service"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "initialize") {
                lifecycleScope.launch {
                    try {
                        initGenerativeModel()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "INIT_ERROR",
                            "Failed to initialize generative model: ${e.message}",
                            null
                        )
                    }
                }
            } else if (call.method == "prompt") {
                val promptString = call.arguments<String>()
                generateContent(promptString!!, result)
            } else if (call.method == "summarize") {
                val promptString = call.arguments<String>()
                summarizeContent(promptString!!, result)
            } else if (call.method == "imageDescription") {
                val filePath = call.arguments<String>()
                describeImage(filePath!!, result)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::generativeModel.isInitialized) {
            generativeModel.close()
        }
        if (::imageDescriber.isInitialized) {
            imageDescriber.close()
        }
        if (::summarizer.isInitialized) {
            summarizer.close()
        }
    }

    private fun generateContent(request: String, result: MethodChannel.Result) {
        lifecycleScope.future {
            try {
                val response = generativeModel.generateContent(request)
                val generatedText = response.candidates.firstOrNull()?.text ?: ""
                result.success(generatedText)
            } catch (e: Exception) {
                result.error("GENERATION_ERROR", e.message ?: "Failed to generate content", null)
            }
        }
    }

    private fun summarizeContent(
        promptString: String,
        result: MethodChannel.Result
    ) {
        lifecycleScope.future {
            try {
                val summarizerOptions = SummarizerOptions.builder(context)
                    .setInputType(SummarizerOptions.InputType.ARTICLE)
                    .setOutputType(SummarizerOptions.OutputType.THREE_BULLETS)
                    .setLanguage(SummarizerOptions.Language.ENGLISH)
                    .build()
                summarizer = Summarization.getClient(summarizerOptions)
                prepareAndStartSummarization(summarizer, promptString, result)
            } catch (e: Exception) {
                result.error("GENERATION_ERROR", e.message ?: "Failed to generate content", null)
            }
        }
    }


    private fun describeImage(filePath: String, result: MethodChannel.Result) {
        lifecycleScope.future {
            try {
                val options = ImageDescriberOptions.builder(context).build()
                imageDescriber = ImageDescription.getClient(options)
                val bitmap = BitmapFactory.decodeFile(filePath)
                prepareAndStartImageDescription(bitmap, imageDescriber, result)
            } catch (e: Exception) {
                result.error("GENERATION_ERROR", e.message ?: "Failed to generate content", null)
            }
        }
    }

    suspend fun prepareAndStartImageDescription(
        bitmap: Bitmap,
        imageDescriber: ImageDescriber,
        result: MethodChannel.Result
    ) {
        // Check feature availability, status will be one of the following:
        // UNAVAILABLE, DOWNLOADABLE, DOWNLOADING, AVAILABLE
        val featureStatus = imageDescriber.checkFeatureStatus().await()

        if (featureStatus == FeatureStatus.DOWNLOADABLE) {
            // Download feature if necessary.
            // If downloadFeature is not called, the first inference request
            // will also trigger the feature to be downloaded if it's not
            // already downloaded.
            imageDescriber.downloadFeature(object : DownloadCallback {
                override fun onDownloadStarted(bytesToDownload: Long) {
                    Log.d("ZERXTCFYVGUBHINJ", "starting download for Gemini Nano Image machin truc")
                }

                override fun onDownloadProgress(totalBytesDownloaded: Long) {
                    Log.d(
                        "ZERXTCFYVGUBHINJ",
                        "starting download for Gemini Nano Image machin truc : $totalBytesDownloaded bytes"
                    )
                }

                override fun onDownloadCompleted() {
                    lifecycleScope.future {
                        startImageDescriptionRequest(bitmap, imageDescriber, result)
                    }
                }

                override fun onDownloadFailed(p0: GenAiException) {
                    Log.e("ZERXTCFYVGUBHINJ", "Dowload image machin failed")
                }
            })
        } else if (featureStatus == FeatureStatus.DOWNLOADING) {
            startImageDescriptionRequest(bitmap, imageDescriber, result)
        } else if (featureStatus == FeatureStatus.AVAILABLE) {
            startImageDescriptionRequest(bitmap, imageDescriber, result)
        }
    }

    suspend fun startImageDescriptionRequest(
        bitmap: Bitmap,
        imageDescriber: ImageDescriber,
        result: MethodChannel.Result
    ) {
        // Create task request
        val imageDescriptionRequest = ImageDescriptionRequest
            .builder(bitmap)
            .build()


        // Run inference with a streaming callback
        val imageDescription =
            imageDescriber.runInference(imageDescriptionRequest).await().description
        result.success(imageDescription)
    }

    private suspend fun initGenerativeModel() {
        generativeModel = Generation.getClient()
        val status = generativeModel.checkStatus()
        when (status) {
            FeatureStatus.UNAVAILABLE -> {
                // Gemini Nano not supported on this device or device hasn't fetched the latest configuration to support it
            }

            FeatureStatus.DOWNLOADABLE -> {
                // Gemini Nano can be downloaded on this device, but is not currently downloaded
                generativeModel.download().collect { status ->
                    when (status) {
                        is DownloadStatus.DownloadStarted ->
                            Log.d("ZERXTCFYVGUBHINJ", "starting download for Gemini Nano")

                        is DownloadStatus.DownloadProgress ->
                            Log.d(
                                "ZERXTCFYVGUBHINJ",
                                "Nano ${status.totalBytesDownloaded} bytes downloaded"
                            )

                        DownloadStatus.DownloadCompleted -> {
                            Log.d("ZERXTCFYVGUBHINJ", "Gemini Nano download complete")
                            modelDownloaded = true
                        }

                        is DownloadStatus.DownloadFailed -> {
                            Log.e("ZERXTCFYVGUBHINJ", "Nano download failed ${status.e.message}")
                        }
                    }
                }
            }

            FeatureStatus.DOWNLOADING -> {
                // Gemini Nano currently being downloaded
            }

            FeatureStatus.AVAILABLE -> {
                modelDownloaded = true
            }
        }

    }
}

suspend fun prepareAndStartSummarization(
    summarizer: Summarizer,
    articleToSummarize: String,
    result: MethodChannel.Result
) {
    // Check feature availability. Status will be one of the following:
    // UNAVAILABLE, DOWNLOADABLE, DOWNLOADING, AVAILABLE
    val featureStatus = summarizer.checkFeatureStatus().await()

    if (featureStatus == FeatureStatus.DOWNLOADABLE) {
        // Download feature if necessary. If downloadFeature is not called,
        // the first inference request will also trigger the feature to be
        // downloaded if it's not already downloaded.
        summarizer.downloadFeature(object : DownloadCallback {
            override fun onDownloadStarted(bytesToDownload: Long) {}

            override fun onDownloadFailed(e: GenAiException) {}

            override fun onDownloadProgress(totalBytesDownloaded: Long) {}

            override fun onDownloadCompleted() {
                startSummarizationRequest(articleToSummarize, summarizer, result)
            }
        })
    } else if (featureStatus == FeatureStatus.DOWNLOADING) {
        // Inference request will automatically run once feature is
        // downloaded. If Gemini Nano is already downloaded on the device,
        // the feature-specific LoRA adapter model will be downloaded
        // quickly. However, if Gemini Nano is not already downloaded, the
        // download process may take longer.
        startSummarizationRequest(articleToSummarize, summarizer, result)
    } else if (featureStatus == FeatureStatus.AVAILABLE) {
        startSummarizationRequest(articleToSummarize, summarizer, result)
    }
}

fun startSummarizationRequest(text: String, summarizer: Summarizer, result: MethodChannel.Result) {
    // Create task request
    val summarizationRequest = SummarizationRequest.builder(text).build()

    val summarizationResult = summarizer.runInference(summarizationRequest).get().summary
    result.success(summarizationResult)
}
