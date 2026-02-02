import Flutter
import UIKit
import FoundationModels

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let geminiChannel = FlutterMethodChannel(name: "gemini_nano_service",
                                           binaryMessenger: controller.binaryMessenger)
    
    geminiChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      self.handleGeminiMethodCall(call: call, result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleGeminiMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(result: result)
    case "prompt":
      if let input = call.arguments as? String {
        if #available(iOS 26.0, *) {
          handlePrompt(input: input, result: result)
        } else {
          result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected String input", details: nil))
      }
    case "summarize":
      if let input = call.arguments as? String {
        if #available(iOS 26.0, *) {
          handleSummarize(input: input, result: result)
        } else {
          result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected String input", details: nil))
      }
    case "imageDescription":
      if let imagePath = call.arguments as? String {
        if #available(iOS 26.0, *) {
          handleImageDescription(imagePath: imagePath, result: result)
        } else {
          result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected String image path", details: nil))
      }
    case "reformulate":
      if let arguments = call.arguments as? [String], arguments.count >= 2 {
        if #available(iOS 26.0, *) {
          handleReformulate(input: arguments[0], type: arguments[1], result: result)
        } else {
          result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected [String, String] arguments", details: nil))
      }
    case "correct":
      if let input = call.arguments as? String {
        if #available(iOS 26.0, *) {
          handleCorrect(input: input, result: result)
        } else {
          result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected String input", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleInitialize(result: @escaping FlutterResult) {
    // Vérifier la disponibilité d'iOS 26.0 et du modèle Apple Intelligence
    if #available(iOS 26.0, *) {
      do {
        let model = SystemLanguageModel.default
        print("DEBUG: SystemLanguageModel obtenu, vérification de l'availability...")
        
        switch model.availability {
        case .available:
          print("DEBUG: Modèle disponible!")
          result(nil) // Succès
        case .unavailable(.appleIntelligenceNotEnabled):
          print("DEBUG: Apple Intelligence n'est pas activé")
          result(FlutterError(code: "AI_NOT_ENABLED", message: "Apple Intelligence n'est pas activé dans les réglages. Allez dans Réglages > Apple Intelligence & Siri pour l'activer.", details: nil))
        case .unavailable(.modelNotReady):
          print("DEBUG: Modèle en cours de téléchargement")
          result(FlutterError(code: "MODEL_NOT_READY", message: "Le modèle n'est pas encore prêt (téléchargement en cours). Veuillez patienter quelques minutes.", details: nil))
        case .unavailable(let other):
          print("DEBUG: Modèle non disponible pour une autre raison: \(other)")
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible. Détails: \(other). Vérifiez que vous êtes sur un appareil compatible avec Apple Intelligence et que la fonction est activée dans les réglages.", details: ["reason": "\(other)"]))
        }
      } catch {
        print("DEBUG: Erreur lors de l'accès au modèle: \(error)")
        result(FlutterError(code: "MODEL_ACCESS_ERROR", message: "Erreur lors de l'accès au modèle: \(error.localizedDescription)", details: nil))
      }
    } else {
      result(FlutterError(code: "iOS_VERSION_NOT_SUPPORTED", message: "iOS 26.0 ou plus récent requis pour Apple Foundation Models", details: nil))
    }
  }
  
  @available(iOS 26.0, *)
  private func handlePrompt(input: String, result: @escaping FlutterResult) {
    Task {
      do {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible", details: nil))
          return
        }
        
        let session = LanguageModelSession()
        let instructions = "Tu es un chien positif et bienveillant qui aide les utilisateurs à voir la vie du bon côté. Réponds toujours de manière optimiste et encourageante, en français, et avec de la personnalité canine."
        
        let fullPrompt = "\(instructions)\n\nUtilisateur: \(input)"
        let response = try await session.respond(to: fullPrompt)
          print(response.content)
        
        DispatchQueue.main.async {
            result(response.content)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "GENERATION_ERROR", message: "Erreur lors de la génération: \(error.localizedDescription)", details: nil))
        }
      }
    }
  }
  
  @available(iOS 26.0, *)
  private func handleSummarize(input: String, result: @escaping FlutterResult) {
    Task {
      do {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible", details: nil))
          return
        }
        
        let session = LanguageModelSession()
        let instructions = "Tu es un assistant qui résume les textes de manière concise et positive. Fais ressortir les aspects positifs du texte dans ton résumé."
        
        let fullPrompt = "\(instructions)\n\nRésume ce texte en français: \(input)"
        let response = try await session.respond(to: fullPrompt)
        
        DispatchQueue.main.async {
            result(response.content)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "SUMMARIZE_ERROR", message: "Erreur lors du résumé: \(error.localizedDescription)", details: nil))
        }
      }
    }
  }
  
  @available(iOS 26.0, *)
  private func handleImageDescription(imagePath: String, result: @escaping FlutterResult) {
    Task {
      do {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible", details: nil))
          return
        }
        
        // Note: Apple Foundation Models ne supporte pas directement l'analyse d'images
        // Pour une vraie implémentation, il faudrait utiliser Vision Framework + Foundation Models
        let session = LanguageModelSession()
        let instructions = "Génère une description positive et inspirante d'une image basée sur le chemin fourni."
        
        let fullPrompt = "\(instructions)\n\nDécris de manière positive une image située à: \(imagePath)"
        let response = try await session.respond(to: fullPrompt)
        
        DispatchQueue.main.async {
          result(response.content)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "IMAGE_ANALYSIS_ERROR", message: "Erreur lors de l'analyse d'image: \(error.localizedDescription)", details: nil))
        }
      }
    }
  }
  
  @available(iOS 26.0, *)
  private func handleReformulate(input: String, type: String, result: @escaping FlutterResult) {
    Task {
      do {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible", details: nil))
          return
        }
        
        let session = LanguageModelSession()
        var prompt = ""
        var instructions = ""
        
        switch type {
        case "DYNAMISE":
          prompt = "Reformule ce texte de manière plus dynamique et énergique: \(input)"
          instructions = "Transforme le texte en version plus énergique et motivante, en gardant le sens original."
        case "EMOJIFY":
          prompt = "Ajoute des emojis appropriés à ce texte: \(input)"
          instructions = "Ajoute des emojis pertinents pour enrichir le texte sans en changer le sens."
        case "REFORMULATE":
          prompt = "Reformule ce texte différemment: \(input)"
          instructions = "Réécris le texte avec des mots différents mais en gardant exactement le même sens."
        case "DEVELOP":
          prompt = "Développe et enrichis ce texte: \(input)"
          instructions = "Développe le texte en ajoutant des détails pertinents et des explications supplémentaires."
        default:
          prompt = "Reformule ce texte: \(input)"
          instructions = "Reformule le texte de manière claire et positive."
        }
        
        let fullPrompt = "\(instructions)\n\n\(prompt)"
        let response = try await session.respond(to: fullPrompt)
        
        DispatchQueue.main.async {
          result(response)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "REFORMULATE_ERROR", message: "Erreur lors de la reformulation: \(error.localizedDescription)", details: nil))
        }
      }
    }
  }
  
  @available(iOS 26.0, *)
  private func handleCorrect(input: String, result: @escaping FlutterResult) {
    Task {
      do {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
          result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Modèle non disponible", details: nil))
          return
        }
        
        let session = LanguageModelSession()
        let instructions = "Corrige les erreurs d'orthographe, de grammaire et de syntaxe dans le texte. Retourne uniquement le texte corrigé, sans commentaires supplémentaires."
        
        let fullPrompt = "\(instructions)\n\nCorrige ce texte en français: \(input)"
        let response = try await session.respond(to: fullPrompt)
        
        DispatchQueue.main.async {
          result(response.content)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "CORRECTION_ERROR", message: "Erreur lors de la correction: \(error.localizedDescription)", details: nil))
        }
      }
    }
  }
}
