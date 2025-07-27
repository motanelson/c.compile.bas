using System;
using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        Console.BackgroundColor = ConsoleColor.DarkYellow;
        Console.ForegroundColor = ConsoleColor.Black;
        Console.Clear();

        Console.Write("Nome do ficheiro HTML a ler: ");
        string fileName = Console.ReadLine();

        if (!File.Exists(fileName))
        {
            Console.WriteLine("Erro: ficheiro não encontrado!");
            return;
        }

        bool inBody = false;
        bool inScript = false;

        foreach (var line in File.ReadLines(fileName))
        {
            string lowerLine = line.ToLower();

            if (!inBody)
            {
                if (lowerLine.Contains("<body"))
                {
                    inBody = true;
                }
                continue;
            }

            if (lowerLine.Contains("<script"))
            {
                inScript = true;
            }
            if (lowerLine.Contains("</script"))
            {
                inScript = false;
                continue;
            }

            if (!inScript)
            {
                string cleanLine = line;

                // Substituir <br>, <p>, </p> por nova linha
                cleanLine = Regex.Replace(cleanLine, @"<\s*(br|p|/p)\s*/?>", "\n", RegexOptions.IgnoreCase);

                // Extrair hrefs
                var hrefs = Regex.Matches(cleanLine, @"href\s*=\s*[""']([^""']+)[""']", RegexOptions.IgnoreCase);
                foreach (Match m in hrefs)
                {
                    Console.WriteLine($"[LINK] {m.Groups[1].Value}");
                }

                // Remover todas as outras tags
                cleanLine = Regex.Replace(cleanLine, "<.*?>", "");

                // Mostrar resultado final
                Console.WriteLine(cleanLine.Trim());
            }
        }
    }
}
