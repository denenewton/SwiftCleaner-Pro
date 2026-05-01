import Foundation

// MARK: - Logger (Estética Profissional)
enum Cor {
    static let reset = "\u{001B}[0;0m"
    static let verde = "\u{001B}[0;32m"
    static let amarelo = "\u{001B}[0;33m"
    static let vermelho = "\u{001B}[0;31m"
    static let ciano = "\u{001B}[0;36m"
    static let negrito = "\u{001B}[1m"
}

// MARK: - Engine Principal
@main
struct SwiftCleaner {

    static func main() {
        imprimirHeader()

        // Verificação de Root (Necessário para /Library e logs de sistema)
        guard NSUserName() == "root" else {
            print("\(Cor.vermelho)❌ Erro: Este utilitário precisa ser executado com 'sudo'.\(Cor.reset)")
            return
        }

        let espacoInicial = obterEspacoDisponivel()

        let alvos = [
            ("Xcode DerivedData", "~/Library/Developer/Xcode/DerivedData"),
            ("iOS DeviceSupport", "~/Library/Developer/Xcode/iOS DeviceSupport"),
            ("Simuladores Caches", "~/Library/Developer/CoreSimulator/Caches"),
            ("Swift PM", "~/Library/Caches/org.swift.swiftpm"),
            ("Homebrew Cache", "~/Library/Caches/Homebrew"),
            ("Cargo Registry", "~/.cargo/registry"),
            ("Cargo Git Cache", "~/.cargo/git"),
            ("Caches de Usuário", "~/Library/Caches"),
            ("Logs de Aplicativos", "~/Library/Logs"),
            ("Caches de Sistema", "/Library/Caches"),
            ("Logs de Sistema", "/private/var/log"),
            ("Lixeira", "~/.Trash")
        ]

        print("\(Cor.ciano)🔍 Analisando sistema...\(Cor.reset)\n")

        for (nome, caminho) in alvos {
            processarAlvo(nome: nome, caminho: caminho)
        }

        executarManutencaoSistema()

        let espacoFinal = obterEspacoDisponivel()
        exibirRelatorioFinal(antes: espacoInicial, depois: espacoFinal)
    }

    // MARK: - Lógica de Processamento
    static func processarAlvo(nome: String, caminho: String) {
        let pathExpandido = (caminho as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: pathExpandido)

        guard FileManager.default.fileExists(atPath: url.path) else { return }

        // Feedback de progresso para pastas grandes
        print("\(Cor.amarelo)⌛ Calculando \(nome)...", terminator: "\r")
        fflush(stdout)

        let bytes = calculaTamanhoRecursivo(url: url)
        if bytes == 0 { return }

        let mb = Double(bytes) / 1024 / 1024

        // Limpa a linha de "calculando" e mostra o resultado
        print("\r\(Cor.negrito)📦 \(nome.padding(toLength: 25, withPad: " ", startingAt: 0)) \(String(format: "%.2f", mb)) MB\(Cor.reset)")
        print("   └─ Limpar? (s/N): ", terminator: "")

        if let entrada = readLine()?.lowercased(), entrada == "s" {
            removerConteudo(de: url)
            print("   \(Cor.verde)✅ Limpo\(Cor.reset)\n")
        } else {
            print("   \(Cor.reset)⏭️  Ignorado\(Cor.reset)\n")
        }
    }

    static func removerConteudo(de url: URL) {
        let fm = FileManager.default
        guard let itens = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return }

        for item in itens {
            try? fm.removeItem(at: item)
        }
    }

    // MARK: - Ferramentas de Sistema
    static func executarManutencaoSistema() {
        print("\n\(Cor.ciano)⚙️ Executando tarefas de sistema...\(Cor.reset)")

        // Flush DNS
        print("   ⚡ Flushing DNS...", terminator: " ")
        executarBinario(caminho: "/usr/bin/dscacheutil", argumentos: ["-flushcache"])
        print("\(Cor.verde)OK\(Cor.reset)")

        executarBinario(caminho: "/usr/sbin/periodic", argumentos: ["daily", "weekly", "monthly"])

        // Homebrew (com verificação)
        let brewPath = "/usr/local/bin/brew"
        if FileManager.default.fileExists(atPath: brewPath) {
            print("   🍺 Homebrew Cleanup (Aguarde)...")
            executarBinario(caminho: brewPath, argumentos: ["cleanup", "-s"], mostrarSaida: false)
        }
    }

    static func executarBinario(caminho: String, argumentos: [String], mostrarSaida: Bool = false) {
        let processo = Process()
        processo.executableURL = URL(fileURLWithPath: caminho)
        processo.arguments = argumentos

        if mostrarSaida {
            processo.standardOutput = FileHandle.standardOutput
            processo.standardError = FileHandle.standardError
        } else {
            processo.standardOutput = nil
            processo.standardError = nil
        }

        try? processo.run()
        processo.waitUntilExit()
    }

    // MARK: - Helpers
    static func calculaTamanhoRecursivo(url: URL) -> Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            let recursos = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
            total += Int64(recursos?.fileSize ?? 0)
        }
        return total
    }

    static func obterEspacoDisponivel() -> Int64 {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let valores = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        return Int64(valores?.volumeAvailableCapacity ?? 0)
    }

    static func imprimirHeader() {
        print("\(Cor.ciano)\(Cor.negrito)")
        print("╔════════════════════════════════════════╗")
        print("║          SWIFT CLEANER PRO             ║")
        print("║       Optimization for macOS           ║")
        print("╚════════════════════════════════════════╝")
        print("\(Cor.reset)")
    }

    static func exibirRelatorioFinal(antes: Int64, depois: Int64) {
        let diff = depois - antes
        print("\n\(Cor.negrito)📊 RESUMO DA OPERAÇÃO\(Cor.reset)")

        if diff <= 0 {
            print("\(Cor.verde)✨ Seu sistema já estava otimizado.\(Cor.reset)")
        } else {
            let gb = Double(diff) / (1024 * 1024 * 1024)
            let mb = Double(diff) / (1024 * 1024)
            let valorFormatado = gb >= 1 ? String(format: "%.2f GB", gb) : String(format: "%.2f MB", mb)
            print("\(Cor.verde)🚀 Sucesso! Você recuperou \(Cor.negrito)\(valorFormatado)\(Cor.reset)\(Cor.verde).\(Cor.reset)")
        }
        print("------------------------------------------\n")
    }
}
