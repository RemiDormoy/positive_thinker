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
import com.google.mlkit.genai.proofreading.Proofreader
import com.google.mlkit.genai.proofreading.ProofreaderOptions
import com.google.mlkit.genai.proofreading.Proofreading
import com.google.mlkit.genai.proofreading.ProofreadingRequest
import com.google.mlkit.genai.rewriting.Rewriter
import com.google.mlkit.genai.rewriting.RewriterOptions
import com.google.mlkit.genai.rewriting.Rewriting
import com.google.mlkit.genai.rewriting.RewritingRequest
import com.google.mlkit.genai.summarization.Summarization
import com.google.mlkit.genai.summarization.SummarizationRequest
import com.google.mlkit.genai.summarization.Summarizer
import com.google.mlkit.genai.summarization.SummarizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.future
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private lateinit var generativeModel: GenerativeModel
    private lateinit var imageDescriber: ImageDescriber
    private lateinit var summarizer: Summarizer
    private lateinit var proofreader: Proofreader
    private lateinit var rewriter: Rewriter
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
            } else if (call.method == "correct") {
                val promptString = call.arguments<String>()
                correctContent(promptString!!, result)
            } else if (call.method == "reformulate") {
                val promptString = call.arguments<List<String>>()
                val originalText = promptString!![0]
                val type = promptString[1]
                rewriteContent(originalText, type, result)
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
        if (::rewriter.isInitialized) {
            rewriter.close()
        }
        if (::proofreader.isInitialized) {
            proofreader.close()
        }
    }

    private fun generateContent(request: String, result: MethodChannel.Result) {
        lifecycleScope.future {
            withContext(Dispatchers.IO) {

                try {
                    val response = generativeModel.generateContent(request)
                    val generatedText = response.candidates.firstOrNull()?.text ?: ""
                    result.success(generatedText)
                } catch (e: Exception) {
                    result.error(
                        "GENERATION_ERROR",
                        e.message ?: "Failed to generate content",
                        null
                    )
                }
            }
        }
    }

    private fun summarizeContent(
        promptString: String,
        result: MethodChannel.Result
    ) {
        lifecycleScope.future {
            withContext(Dispatchers.IO) {
                try {
                    val summarizerOptions = SummarizerOptions.builder(context)
                        .setInputType(SummarizerOptions.InputType.ARTICLE)
                        .setOutputType(SummarizerOptions.OutputType.THREE_BULLETS)
                        .setLanguage(SummarizerOptions.Language.ENGLISH)
                        .build()
                    summarizer = Summarization.getClient(summarizerOptions)
                    prepareAndStartSummarization(summarizer, promptString, result)
                } catch (e: Exception) {
                    result.error(
                        "GENERATION_ERROR",
                        e.message ?: "Failed to generate content",
                        null
                    )
                }
            }
        }
    }

    private fun correctContent(
        promptString: String,
        result: MethodChannel.Result
    ) {
        lifecycleScope.future {
            withContext(Dispatchers.IO) {
                try {
                    val options = ProofreaderOptions.builder(context)
                        .setInputType(ProofreaderOptions.InputType.KEYBOARD)
                        .setLanguage(ProofreaderOptions.Language.FRENCH)
                        .build()
                    proofreader = Proofreading.getClient(options)
                    prepareAndStartProofread(proofreader, promptString, result)
                } catch (e: Exception) {
                    result.error(
                        "GENERATION_ERROR",
                        e.message ?: "Failed to generate content",
                        null
                    )
                }
            }
        }
    }

    private fun rewriteContent(
        originalContent: String,
        type: String,
        result: MethodChannel.Result
    ) {
        lifecycleScope.future {
            withContext(Dispatchers.IO) {
                try {
                    val outputType = when (type) {
                        "DEVELOP" -> RewriterOptions.OutputType.ELABORATE
                        "EMOJIFY" -> RewriterOptions.OutputType.EMOJIFY
                        "REFORMULATE" -> RewriterOptions.OutputType.REPHRASE
                        "DYNAMISE" -> RewriterOptions.OutputType.FRIENDLY
                        else -> RewriterOptions.OutputType.ELABORATE
                    }
                    val rewriterOptions = RewriterOptions.builder(context)
                        // OutputType can be one of the following: ELABORATE, EMOJIFY, SHORTEN,
                        // FRIENDLY, PROFESSIONAL, REPHRASE
                        .setOutputType(outputType)
                        .setLanguage(RewriterOptions.Language.FRENCH)
                        .build()
                    rewriter = Rewriting.getClient(rewriterOptions)
                    prepareAndStartRewrite(rewriter, originalContent, result)
                } catch (e: Exception) {
                    result.error(
                        "GENERATION_ERROR",
                        e.message ?: "Failed to generate content",
                        null
                    )
                }
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

fun startRewritingRequest(text: String, rewriter: Rewriter, result: MethodChannel.Result) {
    // Create task request
    val rewritingRequest = RewritingRequest.builder(text).build()
    val rewriteResults =
        rewriter.runInference(rewritingRequest).get()
    val returnString = rewriteResults.results[rewriteResults.results.size - 1].text

    result.success(returnString)
}

suspend fun prepareAndStartProofread(
    proofreader: Proofreader,
    textToProofread: String,
    result: MethodChannel.Result
) {
    val featureStatus = proofreader.checkFeatureStatus().await()

    if (featureStatus == FeatureStatus.DOWNLOADABLE) {
        proofreader.downloadFeature(object : DownloadCallback {
            override fun onDownloadStarted(bytesToDownload: Long) { }

            override fun onDownloadFailed(e: GenAiException) { }

            override fun onDownloadProgress(
                totalBytesDownloaded: Long
            ) {}

            override fun onDownloadCompleted() {
                startProofreadingRequest(textToProofread, proofreader, result)
            }
        })
    } else if (featureStatus == FeatureStatus.DOWNLOADING) {
        startProofreadingRequest(textToProofread, proofreader, result)
    } else if (featureStatus == FeatureStatus.AVAILABLE) {
        startProofreadingRequest(textToProofread, proofreader, result)
    }
}

fun startProofreadingRequest(
    text: String, proofreader: Proofreader, result: MethodChannel.Result
) {
    // Create task request
    val proofreadingRequest =
        ProofreadingRequest.builder(text).build()

    val proofreadingResults =
        proofreader.runInference(proofreadingRequest).get().results
    val returnString = proofreadingResults[proofreadingResults.size - 1].text

    result.success(returnString)
}

suspend fun prepareAndStartRewrite(
    rewriter: Rewriter,
    textToRewrite: String,
    result: MethodChannel.Result
) {
    // Check feature availability, status will be one of the following:
    // UNAVAILABLE, DOWNLOADABLE, DOWNLOADING, AVAILABLE
    val featureStatus = rewriter.checkFeatureStatus().await()

    if (featureStatus == FeatureStatus.DOWNLOADABLE) {
        // Download feature if necessary.
        // If downloadFeature is not called, the first inference request will
        // also trigger the feature to be downloaded if it's not already
        // downloaded.
        rewriter.downloadFeature(object : DownloadCallback {
            override fun onDownloadStarted(bytesToDownload: Long) {}

            override fun onDownloadFailed(e: GenAiException) {}

            override fun onDownloadProgress(totalBytesDownloaded: Long) {}

            override fun onDownloadCompleted() {
                startRewritingRequest(textToRewrite, rewriter, result)
            }
        })
    } else if (featureStatus == FeatureStatus.DOWNLOADING) {
        // Inference request will automatically run once feature is
        // downloaded.
        // If Gemini Nano is already downloaded on the device, the
        // feature-specific LoRA adapter model will be downloaded
        // quickly. However, if Gemini Nano is not already downloaded,
        // the download process may take longer.
        startRewritingRequest(textToRewrite, rewriter, result)
    } else if (featureStatus == FeatureStatus.AVAILABLE) {
        startRewritingRequest(textToRewrite, rewriter, result)
    }
}
