# 🚀 SwiftCleaner Pro

**SwiftCleaner Pro** é um utilitário de linha de comando de alto desempenho, desenvolvido em Swift, projetado para otimizar sistemas macOS. Ele foca na limpeza profunda de caches de desenvolvedor (Xcode, Cargo, SPM) e logs de sistema que ferramentas comuns costumam ignorar.

## 🛠 Funcionalidades
- **Análise Recursiva:** Cálculo preciso do tamanho de diretórios profundos.
- **Modo Interativo:** Você decide o que apagar após ver o espaço ocupado.
- **Foco em Devs:** Limpeza específica para `DerivedData`, `Cargo Registry`, `Homebrew` e `Simuladores`.
- **Manutenção de Sistema:** Flush de DNS e execução de scripts periódicos do macOS.
- **Interface Colorida:** Feedback visual claro e elegante no terminal.

## 📋 Pré-requisitos
- macOS 12.0 ou superior.
- Swift 5.5+ instalado.
- Acesso de superusuário (`sudo`).

## 🚀 Instalação Rápida

1. Clone o repositório:
```bash
git clone [https://github.com/denenewton/swiftcleaner-pro.git](https://github.com/denenewton/swiftcleaner-pro.git)
cd swiftcleaner-pro
