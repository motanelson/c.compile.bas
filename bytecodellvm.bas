' Compilador FreeBASIC para gerar LLVM IR
' Suporta: int, i=i+1, i=i-1, while, return

Sub RemoveSpaces(ByRef linha As String)
    Dim As String nova
    For i As Integer = 1 To Len(linha)
        If Mid(linha, i, 1) <> " " Then nova += Mid(linha, i, 1)
    Next
    linha = nova
End Sub

Sub GerarLLVM(inputFile As String, outputFile As String)
    Dim As Integer fIn = FreeFile
    Open inputFile For Input As #fIn

    Dim As Integer fOut = FreeFile
    Open outputFile For Output As #fOut

    Print #fOut, "define i32 @main() {"
    Print #fOut, "entry:"
    Print #fOut, "  %i = alloca i32"

    Dim As String linha
    Dim As Integer label = 0

    While Not Eof(fIn)
        Line Input #fIn, linha
        RemoveSpaces(linha)

        If Left(linha, 3) = "int" Then
            Dim As Integer num = Val(Mid(linha, 4))
            Print #fOut, "  store i32 " & num & ", i32* %i"

        ElseIf Instr(linha, "i=i+1") Or Instr(linha, "i+=1") Then
            Print #fOut, "  %tmp" & label & " = load i32, i32* %i"
            Print #fOut, "  %tmp" & label & "a = add i32 %tmp" & label & ", 1"
            Print #fOut, "  store i32 %tmp" & label & "a, i32* %i"
            label += 1

        ElseIf Instr(linha, "i=i-1") Or Instr(linha, "i-=1") Or Instr(linha, "i--") Then
            Print #fOut, "  %tmp" & label & " = load i32, i32* %i"
            Print #fOut, "  %tmp" & label & "s = sub i32 %tmp" & label & ", 1"
            Print #fOut, "  store i32 %tmp" & label & "s, i32* %i"
            label += 1

        ElseIf Left(linha, 6) = "while(" Then
            Dim As Integer num = Val(Mid(linha, 9, Len(linha) - 9))
            Print #fOut, "  br label %L" & label
            Print #fOut, "L" & label & ":"
            Print #fOut, "  %tmp" & label & "c = load i32, i32* %i"
            Print #fOut, "  %cmp" & label & " = icmp slt i32 %tmp" & label & "c, " & num
            Print #fOut, "  br i1 %cmp" & label & ", label %L" & label & "body, label %L" & label & "done"
            Print #fOut, "L" & label & "body:"

        ElseIf linha = "}" Then
            Print #fOut, "  br label %L" & label
            Print #fOut, "L" & label & "done:"
            label += 1

        ElseIf Left(linha, 6) = "return" Then
            Print #fOut, "  ret i32 0"
        End If
    Wend

    Print #fOut, "}"
    Close #fIn
    Close #fOut
End Sub

Dim As String entrada, saida
color 0,6
cls
Input "Ficheiro C de entrada: ", entrada
saida = Left(entrada, Len(entrada) - 2) + ".ll"
GerarLLVM(entrada, saida)
Print "Código LLVM IR gerado em: " + saida
