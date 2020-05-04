# 2019 RES Politika Senaryoları Shiny Uygulaması

Bu kod deposu 2019 yılında rüzgar enerji santrallerinin (RES) yaptıkları üretim tahminlerindeki hata payları sebebi ile mevzuat gereği ödedikleri bedelleri (dengesizlik net maliyeti ve KÜPST) EPİAŞ Şeffaflık Platformu'ndan alınan verilerle simüle eden bir R Shiny uygulamasını ve ilgili veri setini içermektedir. 

Uygulama içerisinde 5 kriteri değiştirerek farklı senaryoları deneyebilirsiniz. Varsayılan değerler (DSG sönümleme oranı hariç) EPDK tarafından belirlenen katsayı değerleridir.

+ **KÜPST Tolerans**: Kesinleşmiş Üretim Planından Sapma Miktarı (tahmin-gerçekleşen üretim farkı), gerçekleşen üretime göre belli bir oranı (10%) geçmediği sürece KÜPST maliyeti oluşmamaktadır. Bu alandan tolerans seviyesini değiştirebilirsiniz.
+ **KÜPST Bedel Katsayısı**: Ancak ilgili toleransın üzerindeki her sapma miktarı PTF ve SMF'den yüksek olanın %3'ü kadar bir bedel katsayısı ile çarpılarak KÜPST maliyeti ortaya çıkarılmaktadır. Bu alandan bedel katsayısını değiştirebilirsiniz.
+ **Dengesizlik PTF Toleransı**: Ayrıca j katsayısı olarak da bilinen bu tolerans, RESlerin dengesizlik maliyetlerini hafifletme amacıyla tasarlanmıştır. PTF'nin %3 (1-j) kadarlık bir kısmı ek destek olarak verilmektedir.
+ **Dengesizlik Maliyet Katsayısı**: Aslen dengesizliğe düşen bütün katılımcılara çıkarılan ek maliyet katsayısıdır. Negatif dengesizlikteki 1.03 ve pozitif dengesizlikteki 0.97 katsayıları buradan gelmektedir. Bu senaryo sistemi için dengesizlik maliyet katsayısı simetrik olarak değiştirilebilmektedir. Örneğin 0.05 değeri için negatif dengesizlik katsayısı 1.05, pozitif dengesizlik katsayısı 0.95 olmaktadır. [EPİAŞ](https://www.epias.com.tr/uzlastirma/enerji-dengesizliklerinin-uzlastirmasi/) üzerinden detaylı hesaplamaya ulaşılabilir.
+ **DSG Dengesizlik Sönümleme Oranı**: Bir RES santrali Dengeden Sorumlu Grup (DSG) altına girdiğinde dengesizlik miktarları gruptaki diğer katılımcıların ters yöndeki dengesizlikleri ile sönümlenir. Örneğin iki katılımcıdan oluşan bir DSG'de RES 15 MWh pozitif dengesizlik yaptığında, diğer katılımcı 5 MWh negatif dengesizlik yaparsa DSG'nin net dengesizliği pozitif tarafta 10 MWh olmaktadır. Genelde fayda katılımcılara oransal olarak dağıtıldığından RES belli bir oranda dengesizliğini sönümlemektedir. Bu uygulama dengesizlik maliyetinin azaltılmasında önemli bir katkı sağlamaktadır. Doğal olarak her RES için ve zamana bağlı olarak farklılaşmaktadır. Ancak ortalama bir oran (örneğin %35) senaryoya eklendiğinde DSG'nin faydası net olarak görülebilir.

Uygulama 2019 yılı verisini içerip farklı katsayı senaryolarında RESlerin ne kadar ek maliyete katlanacaklarına dair öngörüler içermektedir. Bütün veriler [EPİAŞ Şeffaflık Platformu](https://seffaflik.epias.com.tr/transparency/)'ndan alınmıştır. Uygulamayı oluştururken verilerin ve hesaplamaların doğruluğuna dair son derece dikkatli davranılmıştır ancak buradaki verilerin ve sistemin kullanılması durumunda herhangi bir sorumluluk kabul edilmemektedir

Shinyapps.io üzerinde çalışan versiyon için [tıklayın](https://acikenerji.shinyapps.io/res_senaryo/).

```r
# ilgili paketleri yükleme. eğer paketler yüklüyse atlayabilirsiniz
pti = c("tidyverse","lubridate","shiny","DT")
pti = pti[!(pti %in% installed.packages())]
if(length(pti) > 0) install.packages(pti,repos="https://cran.r-project.org")

# bu kod deposu üzerinden uygulamayı çalıştırabilirsiniz
shiny::runGitHub("acikenerji/res_senaryo")
```
