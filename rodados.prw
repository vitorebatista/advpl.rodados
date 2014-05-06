#include "Protheus.ch"

//-----------------------------------------------
// Versao minima para a utilizacao deste exemplo
//-----------------------------------------------
#DEFINE MIN_BUILD_VERSION "7.00.111010P-20120315"

#DEFINE __VERSION "v2.0"

//-------------------------------------------
// Variaveis com as posicoes da array aShape
//-------------------------------------------
#DEFINE __IDPNEU__     1
#DEFINE __CODPNEU__    2
#DEFINE __IMGX__       3
#DEFINE __IMGY__       4
#DEFINE __TYPE__       5	
#DEFINE __INFO__       7
#DEFINE __TOOLTIP__    8
#DEFINE __WIDTH__      9
#DEFINE __HEIGHT__     10
#DEFINE __VIDA__       1
#DEFINE __ESTEPE__     2

//------------------------------------
// Controle de shape em movimento (-1 significa não movimentando)
//------------------------------------
Static __nShape := -1

//-----------------------------
// Controle de ID de shape
//-----------------------------
Static nId := 0

//-----------------------------
// Array de controle de shape
//-----------------------------
Static aShape := {}

//---------------------------------------------------------------------
/*/{Protheus.doc} rodados
Exemplo de utilização da classe TPaintPanel

@author Vitor Emanuel Batista
@since 24/02/2012             
@build 7.00.111010P-20120315
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
User Function rodados
	Local oTPanel
	Local cCadastro := __VERSION+" Arraste os pneus utilizando o mouse"		

	//----------------------------------
	// Valida se Build esta atualizada
	//----------------------------------
	If GetBuild() < MIN_BUILD_VERSION
		MsgStop(	"Foi detectada uma incompatibilidade na versão da Build do Protheus." + Chr(13)+Chr(10) + ;
					"Favor atualizar Protheus Server e Protheus Remote." + Chr(13)+Chr(10) + ;
					"Versão mínima necessária:" + MIN_BUILD_VERSION)
		Final("Incompatibilidade com a versão da Build.")
	EndIf
	
	If !FindFunction("NGRETESTRU") 
		Final('Atualize o seu RPO')
	EndIf	
	
	DEFINE DIALOG oDlg TITLE cCadastro From 0,0 To 0,0 PIXEL COLOR CLR_BLACK,CLR_WHITE

		oTPanel  := TPaintPanel():new(0,0,0,0,oDlg,.f.)
			oTPanel:Align       := CONTROL_ALIGN_ALLCLIENT			
			oTPanel:SetReleaseButton(.T.) //Para ser executado bloco de código do blClicked ao release do shape
			oTPanel:bRClicked   := {|x,y| ShapeList() }  //Botao direito
			oTPanel:blClicked   := {|x,y| lClick(x,y,oTPanel)}

			//------------------------
			// Cria estrutura e pneus
			//------------------------
			CriaEstrutura(oTPanel)
	
	ACTIVATE DIALOG oDlg CENTER
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaEstrutura
Cria estrutura com os pneus aleatórios

@author Vitor Emanuel Batista
@since 24/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaEstrutura(oTPanel)
	Local nX, nY
	Local nVida
	Local aEstruturas := NGRETESTRU() //Array de estrutura de pneus (MNTA221)
	Local nPosEstru   := Randomize(1,Len(aEstruturas)) //Cria estrutura de forma randomica
	Local cEstrutura  := "NG_ESTRUTURA_"+aEstruturas[nPosEstru][1]+".PNG"
	Local cId
	Local nPneu := 0

	//---------------------	
	//Tamanho da estrutura
	//---------------------
	cEstruLarg := cValToChar(Val(aEstruturas[nPosEstru][2]) + 20) 
	cEstruAlt  := cValToChar(Val(aEstruturas[nPosEstru][3]) + 20) 

	//-------------------------------
	//Ajusta tela conforme estrutura
	//-------------------------------
	oTPanel:oWnd:nHeight :=  Val(cEstruAlt) 
	oTPanel:oWnd:nWidth  :=  Val(cEstruLarg) 
	
	//-----------------------------
	// Altura largura da estrutura
	//-----------------------------
	cAltura  := '0'
	cLargura := '0'

	//----------------
	// Cria Container
	//----------------
	oTPanel:addShape(	"id="+RetId()+";type=1;left=0;top=0;width="+cValToChar(Val(cEstruLarg))+";height="+cValToChar(Val(cEstruAlt))+";"+;
							"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")
	
	//------------------------------------
	// Cria shape com imagem da Estrutura
	//------------------------------------
	cId := RetId()
	oTPanel:addShape("id="+cId+";type=8;left="+cLargura+";top="+cAltura+";width="+cEstruLarg+";height="+cEstruAlt+;
							";image-file=rpo:"+cEstrutura+";tooltip=Rodados;can-move=0;can-deform=0;can-mark=0;is-container=1")
	
	For nX := 1 to Len(aEstruturas[nPosEstru][4])
		For nY := 1 To Len(aEstruturas[nPosEstru][4][nX])
			//-------------------------
			// Randomiza cores do pneu
			//-------------------------
			nVida := Randomize(1,5) 

			//-----------------------------------------
			// Tipo do pneu (carro, moto, trator, etc)
			//-----------------------------------------
			cCodType := aEstruturas[nPosEstru][4][nX][nY][1]
			nPneu++
			
			CriaPneu( oTPanel,;
							Val(cLargura)+Val(aEstruturas[nPosEstru][4][nX][nY][2]),;
							Val(cAltura)+Val(aEstruturas[nPosEstru][4][nX][nY][3]),;
							cCodType,;
							"PNEU"+cValToChar(nPneu),;
							nVida,;
							.f.,;
							.f.,;
							.f.,;
							aEstruturas[nPosEstru][4][nX][nY])
							
			Next nY
	Next nX

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetId
Controle de ID para os shapes

@author Vitor Emanuel Batista
@since 24/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetId()
Return cValToChar(++nId)

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaPneu
 Funcao que cria imagem do pneu na tela
 
@param oPanel - Panel que sera criada imagem
@param nImgX  - Posicao X da imagem
@param nImgY  - Posicao Y da imagem
@param cCodPneu - Codigo do Bem
@param nVida    - Vida do Pneu
@param lEstepe  - Indica se pneu adicionado sera estepe
@param lClick   - Indica se pneu adicionado sera criado pelo duplo clique, ficando mais claro/escuro
@param lInvisible - Indica que shape ficara invisible, utilizado somente para se ter o evento do clique
@param aInfo    - Array onde sera adici. no aShape para consultas
@author Vitor Emanuel Batista
@since 24/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaPneu(oPanel,nImgX,nImgY,cType,cCodPneu,nVida,lEstepe,lClick,lInvisible,aInfo)
	Local aInfoPneu := NGRETPNEUS(cType)
	Local cWidth    := aInfoPneu[2] //tamanho do pneu
	Local cHeight   := aInfoPneu[3] //tamanho do pneu
	
	Local cImgId   := RetId()
	
	Local nTxtX, nTxtY, nLenTxt
	Local cTxtId   := cImgId //Mesmo ID para concatenar imagem do pneu com texto
	
	Local cPneuNovo
	Local cPneuVermelho
	Local cPneuVerde
	Local cPneuAzul
	Local cPneu := ""
	Local cCalota
	
	Local cTypeImg
	
	//Cor da Letra, Fonte e tamanho
	Local cCorTxt  := "FFFFFF"
	Local cTxtFont := "Calibri"
	Local cTxtTam  := "13"
	
	Default lEstepe := .f.
	Default lClick  := .f.
	Default aInfo   := {}
	Default lInvisible := .f.
	
	//Calcula Posicao do Txt
	nLenTxt  := Len(AllTrim(cCodPneu))
	nTxtX    := nImgX+Val(cWidth)/If(nLenTxt<3,3,Len(AllTrim(cCodPneu)))
	nTxtY    := nImgY+If(lEstepe,24,If(cType=="3",0,4))
	
	If lClick
		//Se criado pelo clique, fica mais claro
		cTypeImg  := "CLARO"
		cCorTxt   := "000000"
	Else
		cTypeImg  := "ESCURO"
	EndIf
	
	cPneuNovo     := "NG_PNEU_PRETO_"+cTypeImg+"_"+cType+".png"
	cPneuVermelho := "NG_PNEU_VERMELHO_"+cTypeImg+"_"+cType+".png"
	cPneuVerde    := "NG_PNEU_VERDE_"+cTypeImg+"_"+cType+".png"
	cPneuAzul     := "NG_PNEU_AZUL_"+cTypeImg+"_"+cType+".png"	
	cCalota       := "NG_CALOTA.PNG"
	
	If !lInvisible
		If nVida <= 1
			cPneu := cPneuNovo
		Elseif nVida == 2
			cPneu := cPneuVerde
		Elseif nVida == 3
			cPneu := cPneuAzul
		Elseif nVida >= 4
			cPneu := cPneuVermelho
		EndIf

		cToolTip := "Código do pneu: - " + Trim(cCodPneu)

	Else
		cCodPneu := ""
		cPneu    := ""
	EndIf
	
	//Array contendo nas primeiras posicoes variaveis padroes - (Id,Codigo, PosX, PosY, Tipo, {Texto}) e ultima posicao array Especifica do shape
	aAdd(aShape,{	Val(cImgId),; //CODIGO DO SHAPE
						cCodPneu,;    //DESCRICAO(CODIGO) DO PNEU ACIMA DA IMAGEM DO PNEU
						nImgX,;       //POSICAO X DO PNEU
						nImgY,;       //POSICAO Y DO PNEU
						cType,;
						{Val(cTxtId),nTxtX,nTxtY},; //ARRAY DO TEXTO
						aInfo,; //ARRAY COM INFORMACOES ADICIONAIS
						cToolTip,; //DESCRIÇÃO QUANDO PASSAR O MOUSE SOBRE O SHAPE
						Val(cWidth),; //LARGURA DA IMAGEM
						Val(cHeight),; //ALTURA DA IMAGEM
						{nVida,lEstepe,lInvisible}}; //ARRAY DA VIDA DO PNEU, SE ELE EH ESTEPE, SE ESTA INVISIVEL
					)
	
	//Pneu					
	oPanel:addShape("id="+cImgId+";type=8;left="+Str(nImgX)+";top="+Str(nImgY)+";width="+cWidth+";height="+cHeight+";image-file=rpo:"+lower(cPneu)+";tooltip="+cToolTip+";can-move=1;can-deform=1;can-mark=0;is-container=0")

	If lInvisible .And. lEstepe
		//Calota
		oPanel:addShape("id="+cTxtId+";type=8;left="+Str(nImgX+15)+";top="+Str(nImgY+15)+";width="+Str(Val(cWidth)/1.6)+";height="+Str(Val(cHeight)/1.6)+";image-file=rpo:"+lower(cCalota)+";tooltip="+cToolTip+";can-move=1;can-deform=1;can-mark=0;is-container=0")
	Else	
		//Texto
		oPanel:addShape("id="+cTxtId+";type=7;left="+Str(nTxtX)+";top="+Str(nTxtY)+";width=70;height=20;text="+cCodPneu+";font="+cTxtFont+","+cTxtTam+",1,0,1;pen-color=#"+cCorTxt+";pen-width=1;;tooltip="+cToolTip+";can-move=1;can-deform=1;can-mark=0;is-container=0")	
	EndIf
	
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} TrocaPneu
Faz a troca entre dois pneus na estrutura

@param nOrigem - Posicao na array aShape do pneu de Origem
@param nPnlOrig - Objeto TPaintPanel do pneu de origem
@param nDestino - Posicao na array aShape do pneu de Destino
@param oPnlDest - Objeto TPaintPanel do pneu de destino
@author Vitor Emanuel Batista
@since 24/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function TrocaPneu(nOrigem,oPnlOrig,nDestino,oPnlDest)
	Local nIdPneuOri := aShape[nOrigem][__IDPNEU__]
	Local nIdPneuDes := aShape[nDestino][__IDPNEU__]	
	
	//Array contendo informacoes adicionario sobre o penu
	Local aInfoOri   := aClone(aShape[nOrigem][__INFO__])
	Local aInfoDes   := aClone(aShape[nDestino][__INFO__])
	
	//Codigo do Pneu
	Local cCodPneuOri := aShape[nOrigem][__CODPNEU__]
	Local cCodPneuDes := aShape[nDestino][__CODPNEU__]
	
	//Posicao X e Y do pneu de origem
	Local nImgXOri := aShape[nOrigem][__IMGX__] 
	Local nImgYOri := aShape[nOrigem][__IMGY__]
   
	//Posicao X e Y do pneu de destino
	Local nImgXDes := aShape[nDestino][__IMGX__] 
	Local nImgYDes := aShape[nDestino][__IMGY__]
	
	//Vida dos Pneus
	Local nVidaOri := aTail(aShape[nOrigem])[__VIDA__]
	Local nVidaDes := aTail(aShape[nDestino])[__VIDA__]

	//Se os pneus sao Estepe ou nao
	Local lEstepeOri := aTail(aShape[nOrigem])[__ESTEPE__]
	Local lEstepeDes := aTail(aShape[nDestino])[__ESTEPE__]	
	
	Local cToolTipOri   := aShape[nOrigem][__TOOLTIP__]
	Local cToolTipDes   := aShape[nDestino][__TOOLTIP__]
	
	//Codigo do tipo do pneu
	Local cTypeOri      := aShape[nOrigem][__TYPE__]
	Local cTypeDes      := aShape[nDestino][__TYPE__]
	
	//Exclui shapes da array de controle
	aDel( aShape, Max(nDestino,nOrigem) )
	aDel( aShape, Min(nDestino,nOrigem) )
	aSize( aShape, Len( aShape ) - 2 )	
	
	//Exclui shapes da tela
	oPnlDest:DeleteItem(nIdPneuDes)
	oPnlOrig:DeleteItem(nIdPneuOri)

	//Cria novamente os pneus
	CriaPneu(@oPnlOrig,nImgXOri,nImgYOri,cTypeOri,cCodPneuDes,nVidaDes,lEstepeOri,.f.,.f.,aInfoDes,cToolTipDes)
	CriaPneu(@oPnlDest,nImgXDes,nImgYDes,cTypeDes,cCodPneuOri,nVidaOri,lEstepeDes,.f.,.f.,aInfoOri,cToolTipOri)	
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} lClick
Controle de movimentação de pneu

@author Vitor Emanuel Batista
@since 24/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function lClick(x,y,oPanel)
	Local nShape
	Local nDestino

	//Clicou na Imagem Pneu
	nShape := aSCAN(aShape,{|x| (x[__IDPNEU__] == oPanel:ShapeAtu) })

	//Se encontrou o shape
	If nShape > 0
		If isMoving()
			
			nDestino := aSCAN(aShape,{ |a| a[__IMGX__] < x .And. a[__IMGX__]+a[__WIDTH__] > x .And. a[__IMGY__] < y .And. a[__IMGY__]+a[__HEIGHT__] > y })			
			If nDestino > 0 .And. nDestino <> nShape
				conout("--------")
				conout("Você soltou no shape: " + cValtoChar(aShape[nDestino][__IDPNEU__]) + " - " + aShape[nDestino][__CODPNEU__])
				conout("--------")
				TrocaPneu(nShape,oPanel,nDestino,oPanel)
			Else
				//--------------------------
				// Volta a Posição original
				//--------------------------
				oPanel:SetPosition(aShape[nShape][__IDPNEU__],aShape[nShape][__IMGX__],aShape[nShape][__IMGY__]) 
				
				conout("--------")
				conout("Não houve troca de shapes, retornado shape para inicio da movimentação. | X=" + cValToChar(x) + " | Y="+cValToChar(y))
				conout("--------")
				
			EndIf
			
			//-------------------------------------------
			// Indica que não há mais shape em movimento
			//-------------------------------------------
			SetShapeAtu()
			
		Else
		
			conout("--------")
			conout("Você clicou no shape: " + cValtoChar(aShape[nShape][__IDPNEU__]) + " - " + aShape[nShape][__CODPNEU__] + "| X=" + cValToChar(x) + " | Y="+cValToChar(y))
			conout("--------")
			
			//-------------------------
			//Seta shape em movimento
			//-------------------------
			SetShapeAtu(nShape)
			
		EndIf
	Else
		conout("Shape não encontrado! Shape=" + cValToChar(oPanel:ShapeAtu) + "| X=" + cValToChar(x) + " | Y="+cValToChar(y))
	EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} SetShapeAtu
Seta shape em movimento

@author Vitor Emanuel Batista
@since 28/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetShapeAtu(nShape)

	If Empty(nShape)
		__nShape := -1
	Else
		__nShape := nShape
	EndIf
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetShapeAtu
Seta shape em movimento

@author Vitor Emanuel Batista
@since 28/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetShapeAtu()
Return __nShape

//---------------------------------------------------------------------
/*/{Protheus.doc} isMoving
Indica se o shape está em movimento

@author Vitor Emanuel Batista
@since 28/02/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function isMoving()
Return __nShape <> -1

//---------------------------------------------------------------------
/*/{Protheus.doc} ShapeList
Lista no console os shapes e pneus contidos na array aShape, apenas
para visualização das informações já alteradas na array

@author Vitor Emanuel Batista
@since 13/03/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ShapeList()
	Local nShape
	
	conout("--------")
	conout("Abaixo serão listados todos os shapes/pneus")
	conout("--------")
	For nShape := 1 To Len(aShape)
		conout(cValToChar(aShape[nShape][__IDPNEU__])+ "=" +aShape[nShape][__CODPNEU__])
	Next nShape
	
Return