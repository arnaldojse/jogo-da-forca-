import java.util.*;
import java.io.*;
import java.nio.file.*;
import java.time.*;
import java.time.format.DateTimeFormatter;

public class JogoMarciano {

    // Scanner para ler as entradas do jogador
    static Scanner sc = new Scanner(System.in);

    // Gerador de números aleatórios
    static Random rand = new Random();

    // Arquivo onde os recordes serão salvos
    static final String ARQUIVO_RECORDES = "recordes_marciano.txt";

    // Quantidade máxima de recordes no ranking
    static final int LIMITE_RECORDES = 5;

    // Classe interna para armazenar os dados de cada recorde
    static class Recorde {
        String nome;
        int pontos;
        int tentativasUsadas;
        String data;

        Recorde(String nome, int pontos, int tentativasUsadas, String data) {
            this.nome = nome;
            this.pontos = pontos;
            this.tentativasUsadas = tentativasUsadas;
            this.data = data;
        }
    }

    public static void main(String[] args) {
        introducao();
        carregarRecordes();

        boolean jogar = true;

        while (jogar) {
            exibirMenu();
            int opcao = lerInteiro("Escolha uma opção: ");

            switch (opcao) {
                case 1:
                    jogarPartida();
                    break;
                case 2:
                    mostrarRecordes();
                    break;
                case 3:
                    System.out.println("Até logo, comandante da Terra!");
                    break;
                default:
                    System.out.println("Opção inválida!");
                    break;
            }

            if (opcao == 1) {
                jogar = perguntarJogarNovamente();
            } else if (opcao == 3) {
                jogar = false;
            }
        }
    }

    // Introdução com história
    static void introducao() {
        System.out.println("=====================================");
        System.out.println("          INVASÃO MARCIANA          ");
        System.out.println("=====================================");
        System.out.println("A Terra recebeu um ataque misterioso.");
        System.out.println("Um marciano escondeu o código secreto");
        System.out.println("de sua nave em um número oculto.");
        System.out.println("Sua missão é descobrir esse número");
        System.out.println("antes que ele escape para Marte.");
        System.out.println("Boa sorte, defensor da humanidade!\n");
    }

    // Exibe o menu principal
    static void exibirMenu() {
        System.out.println("\n========= MENU =========");
        System.out.println("1 - Jogar");
        System.out.println("2 - Ver recordes");
        System.out.println("3 - Sair");
        System.out.println("=========================");
    }

    // Inicia uma partida
    static void jogarPartida() {
        System.out.println("\nEscolha a dificuldade:");
        System.out.println("1 - Fácil   (1 a 50, 8 tentativas)");
        System.out.println("2 - Normal  (1 a 100, 10 tentativas)");
        System.out.println("3 - Difícil (1 a 200, 12 tentativas)");

        int dificuldade = lerInteiro("Opção: ");

        int limite;
        int tentativas;
        String nomeDificuldade;

        switch (dificuldade) {
            case 1:
                limite = 50;
                tentativas = 8;
                nomeDificuldade = "Fácil";
                break;
            case 3:
                limite = 200;
                tentativas = 12;
                nomeDificuldade = "Difícil";
                break;
            case 2:
                limite = 100;
                tentativas = 10;
                nomeDificuldade = "Normal";
                break;
            default:
                System.out.println("Dificuldade inválida. Jogando no modo Normal.");
                limite = 100;
                tentativas = 10;
                nomeDificuldade = "Normal";
                break;
        }

        int numeroSecreto = rand.nextInt(limite) + 1;
        int usadas = 0;
        boolean acertou = false;

        System.out.println("\n--- Missão iniciada ---");
        System.out.println("Dificuldade: " + nomeDificuldade);
        System.out.println("Você deve adivinhar um número de 1 a " + limite + ".");
        System.out.println("Você tem " + tentativas + " tentativas.\n");

        while (tentativas > 0) {
            int chute = lerInteiro("Digite seu chute: ");

            if (chute < 1 || chute > limite) {
                System.out.println("Digite um número entre 1 e " + limite + ".");
                continue;
            }

            usadas++;
            tentativas--;

            if (chute == numeroSecreto) {
                System.out.println("\nAcertou! Você salvou a Terra!");

                int pontos = calcularPontos(limite, usadas);
                System.out.println("Você fez " + pontos + " pontos.");

                atualizarRecorde(usadas, pontos);

                acertou = true;
                break;
            } else {
                System.out.println(chute < numeroSecreto ? "Muito baixo!" : "Muito alto!");

                if (tentativas > 0) {
                    darDica(numeroSecreto, chute, limite, tentativas);
                    System.out.println("Tentativas restantes: " + tentativas);
                }
            }
        }

        if (!acertou) {
            System.out.println("\nVocê perdeu!");
            System.out.println("O número secreto era: " + numeroSecreto);
        }
    }

    // Dá dicas durante a partida
    static void darDica(int numeroSecreto, int chute, int limite, int tentativasRestantes) {
        int diferenca = Math.abs(numeroSecreto - chute);

        if (diferenca <= limite / 10) {
            System.out.println("Dica: você está MUITO perto!");
        } else if (diferenca <= limite / 4) {
            System.out.println("Dica: você está perto.");
        } else {
            System.out.println("Dica: ainda está longe.");
        }

        if (tentativasRestantes == 5) {
            System.out.println("Alerta marciano: o número é " + (numeroSecreto % 2 == 0 ? "par" : "ímpar") + ".");
        }

        if (tentativasRestantes == 3) {
            System.out.println("Radar da Terra: o número está na metade " +
                    (numeroSecreto <= limite / 2 ? "menor" : "maior") + " do intervalo.");
        }
    }

    // Calcula a pontuação final
    static int calcularPontos(int limite, int tentativasUsadas) {
        int base = limite * 10;
        int bonusTentativas = Math.max(0, (limite / 2) - tentativasUsadas * 10);
        return base + bonusTentativas;
    }

    // Atualiza o ranking com o novo recorde
    static void atualizarRecorde(int tentativasUsadas, int pontos) {
        System.out.print("Digite seu nome para o ranking: ");
        String nome = sc.nextLine().trim();
        if (nome.isEmpty()) nome = "Jogador";

        String data = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        Recorde novo = new Recorde(nome, pontos, tentativasUsadas, data);

        List<Recorde> recordes = lerRecordesDoArquivo();
        recordes.add(novo);

        recordes.sort((a, b) -> {
            if (b.pontos != a.pontos) {
                return Integer.compare(b.pontos, a.pontos);
            }
            return Integer.compare(a.tentativasUsadas, b.tentativasUsadas);
        });

        if (recordes.size() > LIMITE_RECORDES) {
            recordes = recordes.subList(0, LIMITE_RECORDES);
        }

        salvarRecordes(recordes);
        System.out.println("Seu nome foi salvo no ranking!");
    }

    // Mostra os recordes salvos
    static void mostrarRecordes() {
        List<Recorde> recordes = lerRecordesDoArquivo();

        System.out.println("\n========= TOP " + LIMITE_RECORDES + " RECORDES =========");

        if (recordes.isEmpty()) {
            System.out.println("Ainda não há recordes salvos.");
            return;
        }

        for (int i = 0; i < recordes.size(); i++) {
            Recorde r = recordes.get(i);
            System.out.println((i + 1) + "º - " + r.nome +
                    " | " + r.pontos + " pontos" +
                    " | " + r.tentativasUsadas + " tentativas" +
                    " | " + r.data);
        }
    }

    // Pergunta se o jogador quer continuar
    static boolean perguntarJogarNovamente() {
        System.out.println("\nDeseja jogar novamente? (s/n)");
        String resp = sc.nextLine().trim();
        return resp.equalsIgnoreCase("s");
    }

    // Lê números inteiros com tratamento de erro
    static int lerInteiro(String mensagem) {
        while (true) {
            System.out.print(mensagem);
            String entrada = sc.nextLine().trim();

            try {
                return Integer.parseInt(entrada);
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida. Digite um número inteiro.");
            }
        }
    }

    // Cria o arquivo de recordes se ele não existir
    static void carregarRecordes() {
        File arquivo = new File(ARQUIVO_RECORDES);
        if (!arquivo.exists()) {
            try {
                arquivo.createNewFile();
            } catch (IOException e) {
                System.out.println("Não foi possível criar o arquivo de recordes.");
            }
        }
    }

    // Lê os recordes já salvos no arquivo
    static List<Recorde> lerRecordesDoArquivo() {
        List<Recorde> recordes = new ArrayList<>();
        Path caminho = Paths.get(ARQUIVO_RECORDES);

        if (!Files.exists(caminho)) {
            return recordes;
        }

        try (BufferedReader br = Files.newBufferedReader(caminho)) {
            String linha;

            while ((linha = br.readLine()) != null) {
                String[] partes = linha.split(";");
                if (partes.length == 4) {
                    String nome = partes[0];
                    int pontos = Integer.parseInt(partes[1]);
                    int tentativas = Integer.parseInt(partes[2]);
                    String data = partes[3];
                    recordes.add(new Recorde(nome, pontos, tentativas, data));
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.out.println("Erro ao ler os recordes.");
        }

        recordes.sort((a, b) -> {
            if (b.pontos != a.pontos) {
                return Integer.compare(b.pontos, a.pontos);
            }
            return Integer.compare(a.tentativasUsadas, b.tentativasUsadas);
        });

        return recordes;
    }

    // Salva os recordes no arquivo
    static void salvarRecordes(List<Recorde> recordes) {
        try (PrintWriter pw = new PrintWriter(new FileWriter(ARQUIVO_RECORDES))) {
            for (Recorde r : recordes) {
                pw.println(r.nome + ";" + r.pontos + ";" + r.tentativasUsadas + ";" + r.data);
            }
        } catch (IOException e) {
            System.out.println("Erro ao salvar os recordes.");
        }
    }
}
