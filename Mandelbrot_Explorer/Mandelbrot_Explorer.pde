// "Mandelbrot Explorer" - Av Tobias Eriksson och Anna Gyllenklev, 2018. //<>//

/* 
 Bakgrund:
 Vi hade som uppgift att med hjälp av repetition av kod ta fram spännande effekter och mönster, i delkursen "kreativ programmering".
 Detta förde tankarna till fraktaler, och mandelbrot, vilket vi ansåg intressant att dyka in i. 
 Det tillhörde också uppgiften att programmet skulle vara interaktivt. Mandelbrot visas ofta som en filmsekvens, där man renderat färdiga bilder
 där man "zoomas in" och får därför se de mönster som skaparna har valt att zooma in på.
 
 Vår idé blev då att man själv skulle få "åka runt" och zooma in på det område man vill, som en upptäcksfärd i mandelbrotvärlden. Det är detta som är
 huvudtemat i denna applikation. För att tydliggöra detta ännu mer, så har man som en ficklampa (kan stängas av / sättas på), som lyser upp kring muspekaren.
 
 Det första vi fick göra var att sätta oss in i matematiken och metoderna som utgör mandelbrot. Som tur var fanns det massvis med information på nätet. 
 Vi har vart väldigt noga med att skapa programmen helt själva, dvs inte baserat på kod vi hittar på internet, då vårt mål till stor del också var att
 förstå mandelbrot och hur man kan skapa det med programmeringen. 
 
 
 
 Kort om mandelbrot:
 Mandelbrot baseras på en iterativ funktion, med värden från det komplexa talplanet. Det komplexa talplanet är ett tvådimensionellt koordinatsystem där
 x-axeln representerar reella tal (R) och y-axeln representerar imaginära tal (i). Ett komplext tal kan uttryckas som: a+bi, där alltså a är den reella
 komponenten, och b är den imaginära. Själva programytan representerar detta komplexa talplan, och kommer att börja i skalan: x1:-2 till x2:2, och y1:-2
 ill y2:2. Detta är för att det endast är inom detta intervall som det finns komplexa talsom inte växer till oändlighet när man kör de i funktionen.
 
 Funktionen ser ut på följande sätt: f(z) = z^2 + c, där c utgör koordinaten som man först stoppade in i funktionen. Som man ser i funktionen, så kör den
 sitt nya itererade värde + det ursprungliga, om och om igen, och därför har man en gräns för hur många iterationer man vill testa. Gränsen för iterationer styr
 detaljnivån. Antalet iterationen som blev av ett visst tal på en viss plats på skärmen är också det som ligger till grund för vilken färg talet får på skärmen,
 och på så sätt visar sig de mönster som funktionen producerar.
 
 
 Information om källkoden:
 Alla funktioner i Processing grundar sig på datatypen float, som är 32-bitars flyttal. Vi började därför att använda oss av den datatypen, men upptäckte sedan att 
 inzoomningen blev väldigt begränsad med denna datatyp. Därmed fick vi prova double istället som kan lagra 62-bit, vilket marknads möjliggjorde en högre detaljnivå,
 och därmed kan man zooma in betydligt längre (inzoomningen görs genom att visa områden med mindre och mindre tal). Detta byte blev på bekostnad av att vi inte kunde 
 använda oss av processings egna metoder, utan vi fick skriva egna metoder. Detta var inga större problem dock, då det i huvudsak var två metoder som vi använde oss 
 av (abs() och map()). Dess var ganska enkla att själva återskapa med tillräcklig noggranhet för att få vårt program att fungera.
 All kod i programmet är helt skrivet av oss, ingen kod är alltså kopierad.
 
 Eftersom denna uppgift började med att man skulle prova rita egna figurer med 2d-objekt blandade, så behöll vi vår "ritaEnGrej", för att visa att vi gjorde hela 
 uppgiften, samt att vi inte ville hålla vår manderbrotrendering för långt ifrån uppgiftens instruktioner.
 
 
 
 Upptäckt bugg:
 Om man zoomar in över 100 gånger (100 i zoomAmount), så börjar bilden att "pixla" sig. Om den har gjort det, kan den ibland fastna så, även om man zoomar ut. 
 En misstanke till anledningen att det fastnar är att x2 och x1 eller y2 och y1 nått gränsen för datatypen double, och därmed blir proportionerna fel, kanske på grund 
 av avrundningar. Buggen har hänt kanske 2 gånger, och å andra sidan så bör "pixlingen" korrigeras när man zoomat ut tillräckligt långt för att man skall få rätt 
 värden. Man borde kolla utzoomningsfunktionen, förmodligen blir något fel där när det är mycket små tal man håller på med, så att det på något sätt aldrig zoomas ut. 
 
*/


// Variabler för det komplexa talplanet:
double x1 = -2d; // x1 är det första talet i x-led som skall visas.
double x2 = 2d; // x2 är det sista talet i x-led som skall visas.
double y1 = -2d; // y1 är det första talet i y-led som skall visas.
double y2 = 2d; // y2 är det första talet i y-led som skall visas.

// Dessa variablar är till för att visa koordinaterna i info-panelen:
// De formateras för att få plats i panelen. 
// %16.8e betyder att vi visar talen med 6 decimalers noggrannhet.
String strX1 = String.format("%.6E", x1); // För att formatera x1.
String strX2 = String.format("%.6E", x2); // För att formatera x2. 
String strY1 = String.format("%.6E", y1);  // För att formatera y1.
String strY2 = String.format("%.6E", y2);  // För att formatera y2.


PImage instructionImg = new PImage(); // Instans för bildobjekt, som ska rendera instruktionsbilden.
boolean showInstructions = true; // Variabel för om instruktionsbilden skall renderas eller inte (när draw() körs).
boolean showInfo = false; // Variabel för om infopanelen skall renderas eller inte.
boolean showShip = true; // Variabel för om rymdskeppet skall renderas eller inte.
boolean flashLight = true; // Variabel för om ficklampa-effekten skall köras eller inte.


float zoom = 2.0f; // Variabel för skalan som skall zoomas in eller ut. (2 - 10, vilket vid t.ex ger en inzoomningskapacitet på mellan 1/2 och 1/10 av den aktuella nummerrymden).
int zoomAmount = 0; // Håll koll på hur många zoomningar som gjorts (varje gång man zoomar in/ ut så läggs det till eller dras bort hur mycket man zoomade med.)
int maxIterations = 10; // Denna variabel styr hur många iterationer som testas. Detta avgör detaljnivån! Så när man zoomar in, så behöver man öka denna för att visa mer mönster.
int maxDistance = 16; // Denna är satt till 16. Det finns ett matematiskt bevis på att om avståndet från origo drar iväg över 16 så kommer den växa exponentiellt, och inte hålla sig inom -2 och 2 gränsen igen.
int n = 0; // Variabel för antal iterationer som sker av ett visst tal i talplanet. 

float rectPosX; // Zoomrektangelns x-position (mitten av rektangeln).
float rectPosY;// Zoomrektangelns y-position (mitten av rektangeln).

int colorId = 4; //// Denna variabel styr vilket färgschema som skall renderas. 1 - 3 (3:an är monokrom) 
color mapping1[] = new color[16]; // Vektor för färgschema 1.
color mapping2[] = new color[16]; // Vektor för färgschema 1.
color mapping3[] = new color[16]; // Vektor för färgschema 1.
color mapping4[] = new color[16]; // Vektor för färgschema 1.

float currShipX = 0; // Rymdskeppets "joint-point" (mitten av skeppet i x-led).
float currShipY = 0;// Rymdskeppets "joint-point" (mitten av skeppet i y-led).



// Dessa metoder är de vi behövde skriva själva för att kringgå processings begränsning till float:

// Denna metod är för att få absolutbeloppen av en variabel med datatyp double.
double dAbs(double a) {
  // Riktiga definitionen för absolut belopp tror vi är: sqrt(pow(a, 2)), men för de operationer vi använder abs till här, så duger denna procedur:
  // Kolla om a är negativ.Isåfall, returnera negativt för att göra den positiv.
  if (a < 0) {
    return -a; // Returnera negativt.
  } else {
    return a;// Returnera positiv.
  }
}



// Denna metod fungerar precis som map() gör, fast den tar datatypen double istället för float.
double dMap(double value, double cStart, double cStop, double nStart, double nStop) {
  // För att göra om det till värdets position i en annan skala:            
  // hur kommer man fram till denna formel?

  // c står för current (ex cStart är current-start). n står för new.
  // t.ex
  // nStart = 10
  // nStop = 50
  // cStart = 50
  // cStio = 150
  // value = 100

  // 1. Kolla hur många procent värdet är av den gamla skalan (-current start för att få rätt uträkning om skalan inte börjar vid 0):
  // (value - cStart / (cStop - cStart))
  // Sätt in värden: (100 - 50) / (150 - 50) = 50 / 100 = 1/2

  // 2. Vad skulle value ha för värde om den hade samma procentuella relation fast i den nya skalan.
  // 
  //Vi ställer upp en ekvation:
  // Nya värdet är x. Vi behöver lösa ut x.
  // (x - nStart) / (nStop - nStart) = 1/2

  // högerledet har vi fått från (value - cStart / (cStop - cStart)). Vi sätter in det istället för 1 / 2.
  // (x - nStart) / (nStop - nStart) = (value - cStart / (cStop - cStart))

  //Multiplicera bägge led med (nStop - nStart):
  // x - nStart = (value - cStart / (cStop - cStart)) * (nStop - nStart)

  // addera till sist n-Start på bägge sidor:
  // x = nStart + (value - cStart / (cStop - cStart)) * (nStop - nStart) 

  // genom att returnera x så ger alltså funktionen rätt värde!

  return nStart + ((value - cStart) / (cStop - cStart)) * (nStop - nStart); // Returnera nya värdet.
}


void setup () {

  size(800, 800, P2D); // Sätt fönsterstorlek, och välj renderare P2D, eftersom det är 2d-grafik som skall renderas.
  surface.setTitle("T&A - Mandelbrot Explorer"); // Lägg till titel på fönstret.
  surface.setResizable(false); // Ska inte kunna ändra storlek / maximeras.

  instructionImg = loadImage("instructions.png"); // Läs in bilden för instruktioner i objektet.

  rectPosX = ((width / zoom) / 2); // Gör så zoom-rektangeln börjar i västra hörnet uppe. (x-värdet)
  rectPosY = ((height / zoom) / 2); // Gör så zoom-rektangeln börjar i västra hörnet uppe. (y-värdet)


  // Färgschema 1:
  // Sparas i en vektor med färger.
  // Detta schema (inte kod, utan färgvalen) har använts av många andra som gjort mandelbrot.
  mapping1[0] = color(66, 30, 15);
  mapping1[1] = color(25, 7, 26);
  mapping1[2] = color(9, 1, 47);
  mapping1[3] = color(4, 4, 73);
  mapping1[4] = color(0, 7, 100);
  mapping1[5] = color(12, 44, 138);
  mapping1[6] = color(24, 82, 177);
  mapping1[7] = color(57, 125, 209);
  mapping1[8] = color(134, 181, 229);
  mapping1[9] = color(211, 236, 248);
  mapping1[10] = color(241, 233, 191);
  mapping1[11] = color(248, 201, 95);
  mapping1[12] = color(255, 170, 0);
  mapping1[13] = color(204, 128, 0);
  mapping1[14] = color(153, 87, 0);
  mapping1[15] = color(106, 52, 3);

  // Annas färger!
  // Vi ville göra en helt egen, men med möjligheten att köra "standard"-färgerna också.
  // Detta är vår egen:
  mapping2[0] = color(66, 30, 15);
  mapping2[1] = color(39, 0, 8);
  mapping2[2] = color(67, 4, 146);
  mapping2[3] = color(99, 9, 210);
  mapping2[4] = color(126, 21, 255);
  mapping2[5] = color(170, 21, 255);
  mapping2[6] = color(241, 21, 255);
  mapping2[7] = color(255, 21, 131);
  mapping2[8] = color(255, 15, 21);
  mapping2[9] = color(184, 1, 74);
  mapping2[10] = color(0, 255, 138);
  mapping2[11] = color(0, 216, 117);
  mapping2[12] = color(1, 161, 148);
  mapping2[13] = color(0, 133, 226);
  mapping2[14] = color(0, 0, 255);
  mapping2[15] = color(0, 0, 155);


  mapping3[0] = color(50, 0, 50);
  mapping3[1] = color(100, 0, 50);
  mapping3[2] = color(150, 0, 50);
  mapping3[3] = color(200, 0, 50);
  mapping3[4] = color(255, 50, 50);
  mapping3[5] = color(255, 100, 50);
  mapping3[6] = color(255, 150, 50);
  mapping3[7] = color(255, 200, 50);
  mapping3[8] = color(255, 255, 50);
  mapping3[9] = color(255, 255, 100);
  mapping3[10] = color(255, 255, 150);
  mapping3[11] = color(255, 255, 200);
  mapping3[12] = color(255, 255, 255);
  mapping3[13] = color(200, 200, 200);
  mapping3[14] = color(150, 150, 150);
  mapping3[15] = color(100, 100, 100);
  

  for (int h = 0; h <= 15; h++) {
    mapping4[h] = color(random(255), random(255), random(255));
  }


  loadPixels(); // Måste anropas för att läsa av pixlarna (läsa in pixlarna i arbetsminnet) och kunna arbeta med objektet pixels, vilket draw()-metoden gör.
}



void draw() {

  try {
  // Gå igenom pixlarna i programytan, skicka in pixelns motsvarighet i nummerrymden till funktionen.
  // Det n-värde som returneras, ligger till grund för vilken färg pixeln skall ha. 
  

  
  for (int xPos = 0; xPos < width; xPos++) {
    for (int yPos = 0; yPos < height; yPos++) {

      // Läs av n-värdet för aktuell position.
      n = iterate(dMap(float(xPos), 0, width, x1, x2), dMap(float(yPos), 0, height, y1, y2)); // dMap() gör ju om pixelns relativa värde inom skalan 0 - fönstrets bredd, till pixelns relativa position mellan x1 och x2. 
      
      // Rita ut n-värdet i färgkod:
      switch(colorId) {
      case 1:
        pixels[xPos + (yPos * width)] = mapping1[(n % 15)]; // det finns 15 färger. Genom att köra n MOD 15, så kommer n alltid att hålla sig inom rätt värden.
        break;
      case 2:
        pixels[xPos + (yPos * width)] = mapping2[(n % 15)];  // det finns 15 färger. Genom att köra n MOD 15, så kommer n alltid att hålla sig inom rätt värden.
        break;
      case 3:
        pixels[xPos + (yPos * width)] = color(map(n, 0, maxIterations, 0, 255)); // Monokrom färgsättning. Låt isället n styra 0-255 (svart till vit).
        break;
      case 4:
        pixels[xPos + (yPos * width)] = mapping3[(n % 15)];  // det finns 15 färger. Genom att köra n MOD 15, så kommer n alltid att hålla sig inom rätt värden.
        break;
      case 5:
        pixels[xPos + (yPos * width)] = mapping4[(n % 15)];  // det finns 15 färger. Genom att köra n MOD 15, så kommer n alltid att hålla sig inom rätt värden.
        break;
      }
    }
  }
  } catch (Exception e) {
    loadPixels(); // Ibland har den inte hunnit laddat pixlarna, framförallt vid fönsterstorleksändring. Detta förhindrar att programmet krashar isåfall.
    redraw(); // Rendera igen.
  }



  // Rita ut zoomrektangeln!
  noFill(); // Ingen fyllnad.
  stroke(255, 200); // Vit, men med lite transparens.
  strokeWeight(4); // Kantens tjocklek i pixlar (2 ut och 2 in från kanten).
  rect(rectPosX - (width / zoom) / 2, rectPosY - (height / zoom) / 2, width / zoom, height / zoom); // Variabeln zoom står för skalan i heltal, t.ex 2 (för 1 / 2). Det är också därför zoomrektangelns totala bredd och höjd, genoma tt dela fönstret bredd med zoomskalan.
  




  // Kolla om infopanelen skall renderas:
  if (showInfo) {

    // Panelen lägger sig längst ned på rutan, och är uppdelad i 3 kolumner.
    
    fill(#222222, 255); // Gör en mörkgrå bakgrund.
    noStroke(); // Ingen stroke.
    rect(0, height - 100, width, 100); // Rita ut bakgrunden till panelen.
    fill(#ffffff, 255); // Vit textfärg.

    // Följande är första kolumnen. Den visar koordinaterna för den nummerrymd som visas just nu. Variablerna uppdateras vid zooming.
    // Så för mer info om strX1 o.s.v, gå ned till MousePress-metoden, och kolla längst ned.
    text("Koordinater\nx1: ~" + strX1 + "\nx2: ~" + strX2 + "\ny1: ~" + strY1+ "\ny2: ~" + strY2, 15, height - 80);

    // Renderna kolumn 2. Stringformat anpassar hur siffran skall skrivas ut. I detta fall avrundas Numspace (x2-x1) till 6 decimaler, och i vetenskaplig form (e^(a))
    text("Grafisk info\nResolution: " + width + "x" + height + "\nNumspace (x2-x1): ~" + String.format("%.6e", dAbs(x2-x1)) + "\nZoom: " + zoomAmount + "\nIterations: " + maxIterations, (width / 3) + 15, height - 80);

    // Kolumn 3. Ersätt "true" och "false" med på / av istället. 
    text("Extra\nFicklampa: " + str(flashLight).replace("true", "På").replace("false", "Av") + "\nRymdskepp: " + str(showShip).replace("true", "På").replace("false", "Av") + "\nFärgval: " + colorId + " (om 5, tryck V för nya färger)", 2 * (width / 3) + 15, height - 80);
  }


  // Kolla om ficklampan är påslagen:
  if (flashLight) {

    
    try {
    // Den går igenom samtliga pixlar, och ställer in varje färgkanal (r, g, b) genom att öka, eller minska den kanalen, beroende på avståndet till muspekaren.
    // maxDist (dist för distans) styrs av zoomlevel (rektangeln).

      float r; // Variabel för röd kanal
      float g; // Variabel för grön kanal
      float b; // Variabel för blå kanal
      float maxDist = (width / zoom);
      float d;
      float adjBright ;
      for (int xPos = 0; xPos < width; xPos++) {
      // Loopa alla pixlar i x-led (upp till bredden).
        for (int yPos = 0; yPos < height; yPos++ ) {
        // Loopa alla pixlar i y-led.

          r = red (pixels[xPos + (yPos * width)]); // Hämta rött värde. pixels[] är en endimensionell array (som att plocka ned samtliga rader av pixlar i vårt fönster och lägga de bredvid varandra, fylls på åt höger.). Därför måste vi lägga till en hel rad (width) vid varje y-steg.
          g = green (pixels[xPos + (yPos * width)]); // Samma princip. Hämta grönt värde.
          b = blue (pixels[xPos + (yPos * width)]); // Samma princip. Hämta blått värde.

          d = dist(xPos, yPos, mouseX, mouseY); // Räkna ut distansen mellan pixeln: (xPos, yPos) och muspekaren.
          adjBright = 255*(maxDist-d)/maxDist; // Räkna ut hur ljus den skall vara, i proportion till avståndet d.
          r += adjBright; // Lägg till nya värdet. (negativt värde om avståndet är tillräcligt långt ifrån).
          g += adjBright; // Lägg till nya värdet. (negativt värde om avståndet är tillräcligt långt ifrån).
          b += adjBright; // Lägg till nya värdet. (negativt värde om avståndet är tillräcligt långt ifrån).
          pixels[yPos*width + xPos] = color(r, g, b); // Sätt pixeln till den uträknade rgb-färgen.
        }
      }
    
    
  } catch (Exception e) {
    loadPixels(); // Ibland har den inte hunnit laddat pixlarna, framförallt vid fönsterstorleksändring. Detta förhindrar att programmet krashar isåfall.
    redraw(); // Rendera igen.
  }
    
  }
  

  // Om skeppet skall visas:
  if (showShip) {
    ritaEnGrej(mouseX, mouseY); // Anropa metoden som renderar skeppet. Se mer information i ritaEnGrej();
  }

  // Ominstruktionerna skall visas:
  if (showInstructions) {
    image(instructionImg, width/2 - instructionImg.width / 2, height/2 - instructionImg.height / 2, instructionImg.width, instructionImg.height); // centrerad.
  }
  

  updatePixels(); // Uppdatera pixlarna.
}




// Händelsemetod som triggas ifall muspekaren har rört sig:
void mouseMoved() {

  // Flytta zoom-siktet (rektangeln) efter musen. Den skall dock inte hamna utanför skärmen!
  
  // Kolla så att musens x-värde inte är mindre än halva triangelns bredd (inkl strokeWeight på 4/2). Sätt annars rektangelns position till just det gränsvärdet.
  // Samma princip fast åt höger (dvs fönstrets bredd - halva triangelns bredd).
  if (mouseX >= ((width / zoom) / 2) && mouseX <= (width - ((width / zoom) / 2) + 2)) {
    // Musen är inom gränserna, så vi låter zoomsiktet följa med:
    rectPosX = mouseX;
  } else {
    // Muspekaren är UTANFÖR gränserna. Sätt minsta och högsta tillåtna värde:
    
    if (mouseX <= ((width / zoom) / 2) ) {
      // Längst till vänster
      rectPosX =  ((width / zoom) / 2);
    }

    if (mouseX >= width - (((width / zoom) / 2))) {
      // Längst till höger.
      rectPosX = width - (((width / zoom) / 2));
    }
  }

  // Samma princip gäller här, fast i y-led. Se detaljerad beskrivning ovan för x-värdet, detta är exakt samma kod fast för höjd istället.
  if (mouseY >= (((height / zoom) / 2)) && mouseY <= (height - (((height / zoom) / 2)))) {
    rectPosY = mouseY;
  } else {
    if (mouseY <= ((height / zoom) / 2)) {
      rectPosY =  ((height / zoom) / 2);
    }

    if (mouseY >= height - (((height / zoom) / 2))) {
      rectPosY = height - (((height / zoom) / 2));
    }
  }
}





// Denna händelsemetod triggas av om man snurrar på mushjulet (eller drar två fingrar på pad):
// Användaren ställer in zoommängden på detta vis:
void mouseWheel(MouseEvent event) {
  
  float e = -event.getCount(); // lagra scrollningsmängden (negativ för att vi vill ha inverterat. Scrollhjul uppåt blir då "högre zoom" (mindre zoomruta), och tvärtom. Kändes mer naturligt.
  
// Man ska inte zooma mer än 0.9 av fönstrets bredd, eller mindre än 0.1 av fönstrets bredd:
  if ((width / (zoom + e)) <= (0.9 * width) && (width / (zoom + e)) >= (0.1 * width)) {
    zoom = zoom + e; // Om det nya värdet inte översteg gränserna, så lägger vi till scrollvärdet!
  }


}


// Denna händelsemetod triggas av om man trycker på en av musknapparna.
// I detta program så ska man då zooma in /ut.
void mousePressed() {

  
  // Vänster musknapp (kod för den är 37)
  if (mouseButton == 37) {


    zoomAmount += zoom; // Öka mängden zoom med så mycket som man zoomar.


    // Beräkna nya skalan (vänster sida av rektangeln till höger sida av rektangeln, och deras motsvarande koordinater). 
    // Alltså rektangelns bredd! Vilket är width / zoom. 

    // Tillsätt nya x&y värden.
    // Det görs med dMap-metoden som vi skrivit (motsvarande map() i processing).
    // på det sättet får vi veta vilka koordinater som zoomrutan motsvarar:
    x1 = dMap(rectPosX - ((width / zoom) / 2), 0, width, x1, x2); // Hämta vänstra kantens nya x-värde.
    x2 = dMap(rectPosX - ((width / zoom) / 2) + (width / zoom), 0, width, x1, x2); // högra kantens nya x-värde.
    y1 = dMap(rectPosY - ((height / zoom) / 2), 0, height, y1, y2); // övre kantents nya y-värde
    y2 = dMap(rectPosY - ((height / zoom) / 2) + (height / zoom), 0, height, y1, y2); // nedre kantens nya y-värde.
  }


  // Högerklick (kod 39).
  if (mouseButton == 39) {

    
    zoomAmount -= zoom;// Minska mängden zoom med så mycket som man zoomar.

    // Försök 2.

    // Zoom ex: 10:1
    // Skalan skall ökas med 10 isåfall.
    // Om rektangel P har sidorna A och B, 
    // och rektangel Q är en exakt kopia 
    // av P, men skalad med en faktor av 1/10, 
    // så skall basen vara 1/10 av A och höjden
    // skall också vara en 10-del av B.
    
    // Utzoomningen fyller alltså på t.ex x1 med så många nummer som får plats mellan t.ex vänsterkant på fönstret till zoomrutans vänsterkant, och sedan 
    // gångrar den mängden med 10 (om 10 är zoomnivån man zoomar med.).
    // Sen gör vi så även uppifrån på fönstret och ned till övre kanten på rektangeln. Likaså högerkant och underkant.
    // Då hamnar "den gamla bilden" i rektangeln (som att man zoomat ut hela den bilden), vilket är den typ av zoomning vi ville ha.


    double densityX = dAbs(x2 - x1); // Räkna ut "densiteten", dvs så månnga nummer som representeras på fönstret mellan x1 och x2.
    double densityY = dAbs(y2 - y1); // Samma sak för y-led. (Bör vara samma eftersom fönstret är kvadratiskt. Men om man t.ex har maximerat fönstret, vilket går ibland, så är det lika bra att behandla x och y-led separat.
 
    
    double diffX1 = zoom * (dMap(rectPosX-((width/zoom)/2), 0, width, 0, densityX)); // Räkna ut antal nummer som finns från vänsterkant av fönstret till zoomrektangelns vänsterkant. Gångra med zoom.
    double diffX2 = zoom * (densityX - dMap(rectPosX+((width/zoom)/2), 0, width, 0, densityX)); // Räkna ut antal nummer som finns från högerkant av fönstret till zoomrektangelns högerkant. Gångra med zoom.
    double diffY1 = zoom * (dMap(rectPosY-((height/zoom)/2), 0, height, 0, densityY));  // Räkna ut antal nummer som finns från överkant på fönstret till zoomrektangelns överkant. Gångra med zoom.
    double diffY2 = zoom * (densityY - dMap(rectPosY+((height/zoom)/2), 0, height, 0, densityY)); // Räkna ut antal nummer som finns från nederkant på fönstret till zoomrektangelns nederkant. Gångra med zoom.

    x1 -= diffX1; // Minska x1 med diffX1-värdet. (Minska eftersom det då ökar antalet siffror åt vänster).
    x2 += diffX2; // Öka x2 med diffX2-värdet. (Öka eftersom det då ökar antalet siffror åt höger).
    y1 -= diffY1; // Minska y1 med diffY1-värdet. Samma princip.
    y2 += diffY2; // Minska y2 med diffY1-värdet. Samma princip.

    // Spärra så man inte zoomarsatan!
    densityX = dAbs(x2 - x1); // Hämta nya "densiteten" i x-led
    densityY = dAbs(y2 - y1); // Hämta nya "densiteten" i y-led


    if (x1 < -2) {
      x1 = -2;
      x2 = x1 + densityX;
      if (x2 > 2) {
        x2 = 2;
      }
    }

    if (x2 > 2) {
      x2 = 2;
      x1 = x2 - densityX;
      if (x1 < -2) {
        x1 = -2;
      }
    }


    if (y1 < -2) {
      y1 = -2;
      y2 = y1 + densityY;
      if (y2 > 2) {
        y2 = 2;
      }
    }

    if (y2 > 2) {
      y2 = 2;
      y1 = y2 - densityY;
      if (y1 < -2) {
        y1 = -2;
      }
    }
  }


  // Om man zoomar ut med längre än man tillåts tack vare gränserna i utzoomning, så måste vi säkra att zoomAmount hamnar på 0 igen för att vara korrekt.
  if (zoomAmount < 0)
    zoomAmount = 0;

  // Eftersom densiteten förändrats vid zoomningen, så uppdaterar vi strängvariablerna för x1 - y2. (de som visas i infopanelen). 
  // Formateras att visa en avrundning på 6 decimaler för att få plats i kolumnen.
  strX1 = String.format("%.8e", x1); // Spara och formatera x1
  strX2 = String.format("%.8e", x2); // Spara och formatera x2
  strY1 = String.format("%.8e", y1); // Spara och formatera y1
  strY2 = String.format("%.8e", y2); // Spara och formatera y2
  
}








// Detta är en kvarleva från när vi började uppgiften, där vi gick igenom stegen i beskrivningen.
// För att visa vår anknytning till uppgiften mer, så behåller vi denna som en extra-funktion man kan starta.
void ritaEnGrej(float xPos, float yPos) {

  // Denna metod kommer rita ut ett rymdskepp, som roterar efter, och "jagar" muspekaren. hastigheten är snabbare ju längre den är ifrån muspekaren.
  
  // Variabler som kommer lägga in random-nummer. Dessa används för animeringen av motorn (det kommer lite eld och rök baktillpå rymdskeppet).
  int rnd = 0;
  int rnd2 = 0;
  int rnd3 = 0;
  int rnd4 = 0;
  int rnd5 = 0;
  int rnd6 = 0;
  
  
  
  // Gör så skeppet åker mot dig, snabbare ju längre den är ifrån dig. 
  
  // Kolla om avståndet till x är mer än 20 pixlar. 
  if (abs(currShipX - xPos) >= 20 && currShipX < xPos) {
    currShipX += (0.1 + ((abs(mouseX - currShipX)/(width))*6)); //Avtåndet kanske får styra. Max avstånd borde vara en hel fönsterbredd! Vi sätter 10 som maxFart.
  }
  if (abs(currShipX - xPos) >= 20 && currShipX > xPos) {
    currShipX -= (0.1 + ((abs(mouseX - currShipX)/(width))*6)); //Avtåndet kanske får styra. Max avstånd borde vara en hel fönsterbredd! Vi sätter 10 som maxFart.
  }

  if (abs(currShipY - yPos) >= 20 && currShipY < yPos) {
    currShipY += (0.1 + ((abs(mouseY - currShipY)/(height))*6)); //Avtåndet kanske får styra. Max avstånd borde vara en hel fönsterhöjd! Vi sätter 10 som maxFart.
  }
  if (abs(currShipY - xPos) >= 20 && currShipY > yPos) {
    currShipY -= (0.1 + ((abs(mouseY - currShipY)/(height))*6)); //Avtåndet kanske får styra. Max avstånd borde vara en hel fönsterhöjd! Vi sätter 10 som maxFart.
  }


  pushMatrix(); // Anropet behövs för att låta datorn "kopiera he grid" till minnet och leka med det (rotera och flytta osv.).
  translate(currShipX, currShipY); // Flytta origo till mittpunkten av skeppet.
  
  // Rotera utefter vinkeln (+ 90grader) som är mellan skeppets utgångspunkter och muspekaren. Vinkeln beräknas med atan2-metoden, och baserat på delta-y och delta-x tar fram rätt vinkel.
  rotate(atan2((mouseY - currShipY), (mouseX - currShipX)) + (PI / 2)); // PI/2 är alltså ett halv varv (i radianer), vilket behövs adderas eftersom skeppet är skapat "med framsidan av skeppet uppåt".


  strokeWeight(1); // 1 pixel kantlinje.
  stroke(#ffffff, 255); // fullt synlig, vit kantlinje.
  
  // Rita ut de gråa cylindrarna bakpå vingarna.
  fill(#d3d3d3, 255); 
  rect(0 - 23, 20, 5, 30);
  rect(0 + 17, 20, 5, 30);


  // Rita ut de gula grejerna längst ut bakåt på de gråa "cylindrarna".
  fill(#ffff00, 180);
  rect(0 - 25, 35, 9, 5);
  rect(0 + 15, 35, 9, 5);

  //  Vänstra vingen.
  stroke(#ffffff, 255);
  fill(#ffffff, 255);
  quad(0 - 18, 0, 0, 0 - 28, 0, 0 + 28, 0 - 28, 0 + 38);

  // Högra vingen.
  quad(0, 0 - 28, 0 + 18, 0, 0 + 28, 0 + 38, 0, 0 + 28);
  fill(#666666, 255);
  rect( 0 - 5, 0, 10, 35);
  
  // Blåa "fönstret"-rektangeln (med grått bakåt).
  noStroke();
  fill(#444444, 255); 
  triangle(-10, 0, 0, 15, 10, 0);
  fill(#1111ff, 255); 
  triangle(-10, 0, 0, -20, 10, 0);


  
  // "motor". Fungerar genom att göra antingen gula streck, eller röda, som är 1 pixlar stora, men uppstår slumpmässigt på en 10 pixel bred yta (fem pixlar +- från mitten av skeppet).
  // Röken är 8 pixlar stora, varierar mellan -5 och 5 också i sidled från mitten av skeppets "motor", men också i y-led 0 - 25 px. även opacity är slumpmässigt.
  
  for (int i = 1; i < 5; i++) {
    // Rita ut fem stycken per frame, därför har vi for-loopen.

    // Randomnummer.
    rnd = int(random(0, 2));
    rnd2 = int(random(-5, 5));
    rnd3 = int(random(-5, 5));
    rnd4 = int(random(150, 255));
    rnd5 = int(random(-5, 5));
    rnd6 = int(random(0, 25));

    if (rnd == 1) {
      // Rött streck!
      fill(#ff0000);
      rect(rnd2, 35, 1, 10);
    } else {
      // Gult streck!
      fill(#fff833);
      rect(rnd3, 35, 1, 10);
    }

    // Rök:
    fill(#d3d3d3, rnd4);
    ellipse(rnd5, 35 + rnd6, 8, 8);
  }

  popMatrix(); // Släpp kopian av "the grid" (koordinaterna blir då vanliga igen).
  
}




// Denna händelsemetod triggas av om man trycken på tangentbordet.
void keyPressed() {

  // Knappen I. Visa / dölj instruktioner.
  if (keyCode == 73) {

    if (showInstructions) {
      showInstructions = false;
    } else {
      showInstructions = true;
    }
  }

  // Knappen enter. Stäng instruktionsrutan.
  if (keyCode == 10) {

    // Kan kännas naturligt att trycka på enter för att stänga instruktionsrutan:
    showInstructions = false;
  }


  // Knappen 1. Visar / döljer rymdskeppet.
  if (keyCode == 49) {
    if (showShip) {
      showShip = false;
    } else {
      showShip = true;
    }
  }



  // Knappen 2. Tänder / släcker "ficklampan".
  if (keyCode == 50) {
    if (flashLight) {
      flashLight = false;
    } else {
      flashLight = true;
    }
  }

  // + ovanför bokstäverna, eller på numpaden. Ökar detaljnivån (maxIterations).
  if (keyCode == 45 || keyCode == 139) {
    maxIterations += 1;
  }

// - ovanför bokstäverna, eller på numpaden. Minskar detaljnivån (maxIterations). Minsta tillåtna värde är 30.
  if (keyCode == 47 || keyCode == 140) {
    if (maxIterations - 10 >= 20) {
      maxIterations -= 1;
    }
  }

  // F1. Minskar fönsterrutan med 100 px (till minst 400 x 400).
  if (keyCode == 97) {
    if (width - 100 >= 400) {
      surface.setSize(width - 100, height - 100);
    }
    

    
  }

  // F2. Ökar fönsterrutan med 100 px (till max 900 x 900).
  if (keyCode == 98) {

    if (width + 100 <= 1000) {
      surface.setSize(width + 100, height + 100);
    }
    
  }

  // Knappen M. Visar eller döljer infopanelen.
  if (keyCode == 77) {

    if (showInfo == true) {
      showInfo = false;
    } else {
      showInfo = true;
    }
    
  }


  // Knappen C. Byter färgschema.
  if (keyCode == 67) {
    colorId++;
    if (colorId == 6) {
      colorId = 1;
    }
  }
  

  // Om colorId = 5 (random colors), re-assign new colors with "v".
  if (keyCode == 86) {     
  for (int h = 0; h <= 15; h++) {
    mapping4[h] = color(random(255), random(255), random(255));
  }
  
  }


}





// Funktion som skall iterera funktionen, och ge tillbaka antal iterationer till den variabel som anropar funktionen.
int iterate(double a, double b) {
  int n = 0;

  // a och b innehåller usprungliga koordinaterna. 
  // aa och bb kommer ändras enligt iterationen. Vi kollar om avståndet överstiger 25, isåfall kommer det iterera för evigt!

  double aa = 0; // Variabel för a^2
  double bb = 0; //Variabel för b^2

  double ca = a;// Current a. Just save the first a that was passed, because a will be manipulated.
  double cb = b;// Current b. Just save the first b that was passed, because b will be manipulated.

  // Förklaring av matten: (a+bi)^2 + a + bi:
  // (a + bi) (a + bi)
  // = a^2 + abi + bia + b^2+i^2 
  // = a^2 + 2abi - b^2 (eftersom i = sqrt(-1), i * i = -1 ;) )
  // Vi flyttar om för att få typsikt komplext tal:

  // = a^2-b^2 + 2abi.
  // reella komponenten blir alltså: a^2-b^2, och den imaginära komponenten blir 2ab!


  // Kör loopen till maximalt antal iterationer (maxIterations). Låt variabeln n representera iterationsräkningen.
  for (n = 0; n <= maxIterations; n++) {

    aa = a*a - b*b; // Detta är alltså första termen (z^2).
    bb = 2 * a * b; // Detta är den andra termen.

    a = aa + ca; // sätt ihop termerna. 
    b = bb + cb; // Sätt ihop termerna.

    // Kontrollera om avståndet till origo för talet är mer än max-gränsen. isåfall, bryt loopen.
    if (dAbs(a+b) >= maxDistance)
      break;
  }



  // Vet inte exakt varför följande kod fungerar för att lösa detta, men genom att ta det högsta iterationsvärdet som kan tas INNAN maxvärdet för iterationer, 
  // så får vi svart färg där det skall vara svart färg -annars blir det ofta färglagt! Detta har vi provat oss fram till, men vet egentligen inte kärnan till
  // problemet. Vi ska försöka komma på varför, men teorin är att det har något med jämna 10-tal att göra, och hur de hamnar med modulo 16 (för färgläggning).
  // Detta förskjuter förmodligen bara färgkodningen, så att det blir som vi vill ha det. (Och minskar detaljnivån, det vet vi, men det är så lite
  // att det blir försumbart.
  if (n >= maxIterations - 1)
    n = 0;
    
    
    
  return n; // Returnera antal iterationer.
  
  
}








/*  
FRÅGOR OCH REFLEKTION
* Förklara varför det står void innan deklarationen av metoden ritaEngrej. Hade det kunnat stå något annat? Till exempel vad, och vad hade det inneburit?

En metod som har datatypen void innebär att det är en ren “procedur” som körs, och den kräver inte att metoden returnerar ett värde av en viss datatyp. Vi hade exempelvis kunnat byta ut det till boolean, men då måste vi också returnera ett värde när metoden körts klart. Det hade kunnat inneburit att vi kapslar in koden i en try-catch sats, och om hela koden körs utan uppstådda fel så hade metoden returnerat true, och om fel uppstått hade vi kunnat returnerat false. I det läget hade vi kunnat fånga upp om det inte gick att köra metoden, och isåfall hantera det ifrån där den anropats.



* Förklara vad som är intressant med Ert uttryck. Hur knyter det t.ex. an till andra uttryck från konst, film eller spel? Har ni inspirerats av något? Kan ni hitta ord eller begrepp som är lämpliga för att beskriva ert uttryck?

Vi spann vidare på förra uppgiften, där vi skapade ett undervattenslandskap, och skapade istället en Mandelbrot värld.  Mandelbrot är, den korta versionen, en fraktal och ett självliktformigt mönster med struktur i alla skalor och därmed en matematisk formel som utgår från -2 till 2 från x respektive y axeln (y-led är dock imaginära tal, dvs det är det komplexa talplanet). Funktionen som varje koordinat i planet körs igenom och itereras i är: f(z) = z^2 + c, där c är startvärdet innan iterationen började (se mer information i källkoden).
Vi ville ge användaren en unik upplevelse där känslan var att de befann sig inuti Mandelbrot Explorer världen. Liknelser vi tänkte på vid skapandet av världen var grotta, nattdyk, organiskt och flytande. Genom att lägga till en kontrollpanel där användaren själv fick styra över x-antal funktioner skedde en interaktion med användaren samt skapade att eget tycke fick ta plats i form av färgval, ljus alternativ (på eller av) och vart användaren vill röra sig i Mandelbrot världen.
Vi har inte haft någon förlaga eller förebild i vårt skapande utan har således producerat uttrycket genom ett genuint intresse i att vilja lära sig vissa funktioner och programkod. Uppgiften har på så sätt vuxit sig större i takt med vår utveckling i själva skapandet. Vi vill påstå att vi har skapat ett intressant och interaktivt uttryck med de resurser vårt team hade att tillgå. Orden vi skulle vilja använda för produkten är DEN MAGISKA FRAKTAL GROTTANS VÄRLD.


* Reflektera kort över processen med uppgiften. Om ni körde fast, hur kom ni vidare? Har ni tittat i huvudsak på exempel, videotutorials, eller i boken? Vad hade ni problem med? Vad ägnade ni den mesta tiden åt?

Vi har haft ett relativt bra flyt där ett visst frågetecken uppstod i hur ut zoomningen skulle beräknas för att bli korrekt. Vi kom vidare genom att skissa matematiska lösningar och testa oss fram.
Ett annat problem vi stötte på var begränsningen i datatypen float i Processing. I och med begränsningen kunde vi inte zooma in så pass mycket som vi från början hade planerat att göra. Vi kom runt det genom att använda oss av datatypen double och skriva egna versioner av Processings funktioner, så att de kunde hantera double.
Merparten av research och undersökande har gjorts genom att titta på videotutorials om den matematiska aspekten kring mandelbrot. Eftersom all kod är egen kod så ägnade vi mest tid till att skriva kod, samt att kommentera den och försöka optimera den.

* Reflektera kort över kommentarer ni fick från designkritiken - vad har ni gjort för ändringar baserat på kritiken?
KÄNSLA
Inception
Nyfikenhet inför det oändliga
Supercool upplevelse
Unik och intressant
Magiskt
Fraktal-grotta
Komplext och häftigt

FÖRBÄTTRING
Vill se på helskärm (alltså STOR skärm)
Stoppa zoomen innan det laggar och blir pixligt
Otydlig infopanel

EXTRA BRA
Bra val av färger
Superbra idé
Mycket variation
Känslan av att få utforska
Håll nästa föreläsning


Sammanfattning av Designkritik:
Vi har valt att inte genomföra några förändringar med hänvisning till att vi behövde kommentera klart mängden kod inför inlämningen. Dock har vi under designkritiken funnit egna möjliga förbättringar som vi vid mer tid gärna hade velat genomföra. Förbättringarna vi såg skulle kunna göra vår produkt bättre var följande;
Ta bort att infopanelen ligger i första fönstret och exempelvis skriva  “Välkommen till Mandelbrot Explorer Världen” som en introduktion till programmet.
Lägga till en titel på infopanelen exempelvis “Kontrollpanelen” för att förtydliga vad det är.
Flytta infopanelen till högra hörnet av grottan och göra den mindre så att den, vid behov, alltid kan synas.
Lägga till UX funktion i infopanelen så att den funktion som är aktiverad är grön och de andra röda. För att på så sätt tydliggöra för användaren vilka funktioner som körs.
Göra mandelbrot:en mindre statisk genom att lägga till en liten in-/utzoomning så att det känns som att användaren flyger fram.


*/
