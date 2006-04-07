From: "Julio Prada" <julio.prada@idgrup.com>
Subject: nfs over 2tb limitation
Date: Fri, 7 Apr 2006 09:34:30 +0200
Message-ID: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C65A15.B588080A"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FRlTK-0001FW-VE
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:33:34 -0700
Received: from [213.229.190.142] (helo=EINSTEIN.idg.idgrup.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FRlTK-0003zg-Bl
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:33:35 -0700
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C65A15.B588080A
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

=20

The scenario is a Hp clustered gateway that theorically can virtualize =
up to 16TB, and it seems that the limitation it's on NFS client that =
only can reach up to 2TB on large filesystems.

=20

Please, could you confirm whether nfs client cannot see more than 2 TB =
file systems?

=20

There is any workaround?

=20

Julio Prada

Project Manager

=20

ID Grup Support Professional Services

Ronda General Mitre, 67 - 08017 Barcelona

Tel: 933 933 930 / 610 278 007 - Fax: 932 052 033

julio.prada@idgrup.com

=20

ID Grup Services

ID Grup Support Professional Services * ID Grup Customer Services *

Ibernet Telem=E1tica * Method Software * ID Grup Business Solutions

________________________

=20

Este mensaje y todos los ficheros adjuntos que =E9ste contiene son =
confidenciales y est=E1n destinados exclusivamente al uso individual de =
la persona a la que van dirigidos. Si Vd. ha recibido este mensaje por  =
rror, rogamos lo devuelva a la persona que se lo ha enviado. Queda =
estrictamente prohibida la publicaci=F3n, uso, difusi=F3n, impresi=F3n =20

copia no autorizada de este mensaje y de los documentos adjuntos que =
=E9ste contiene. Las ideas y opiniones manifestadas en este mensaje =
corresponden  nicamente a su autor y no representan necesariamente a las =
de Red de Empresas ID Grup

=20


------_=_NextPart_001_01C65A15.B588080A
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:"Arial Black";
	panose-1:2 11 10 4 2 1 2 2 2 4;}
@font-face
	{font-family:Monaco;
	panose-1:0 0 0 0 0 0 0 0 0 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
span.EstiloCorreo17
	{mso-style-type:personal-compose;
	font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Hello,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>The scenario is a Hp clustered gateway that =
theorically can
virtualize up to 16TB, and it seems that the limitation it&#8217;s on =
NFS
client that only can reach up to 2TB on large =
filesystems.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Please, could you confirm whether nfs client cannot =
see more
than 2 TB file systems?<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>There is any workaround?<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><b><font size=3D2 face=3DArial><span lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;font-weight:bold'>Julio =
Prada</span></font></b><font
size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:10.0pt;font-family:Arial'><o:p></o:p></span></font></p=
>

<p class=3DMsoNormal><i><font size=3D2 face=3DArial><span lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;font-style:italic'>Project =
Manager</span></font></i><font
size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:10.0pt;font-family:Arial'><o:p></o:p></span></font></p=
>

<p class=3DMsoNormal><b><font size=3D2 face=3DArial><span lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;font-weight:bold'><o:p>&nbsp;=
</o:p></span></font></b></p>

<p class=3DMsoNormal><b><font size=3D2 face=3DArial><span lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;font-weight:bold'>ID Grup =
Support
Professional Services</span></font></b><font size=3D2 face=3DArial><span
lang=3DEN-GB =
style=3D'font-size:10.0pt;font-family:Arial'><o:p></o:p></span></font></p=
>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span lang=3DES =
style=3D'font-size:8.0pt;
font-family:Arial'>Ronda General Mitre, 67 - 08017 <U1:CITY =
u2:st=3D"on"><U1:PLACE =
u2:st=3D"on">Barcelona</U1:PLACE></U1:CITY><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span lang=3DES =
style=3D'font-size:8.0pt;
font-family:Arial'>Tel: 933 933 930 / 610 278 007&nbsp;- Fax: 932 052 =
033</span></font><span
lang=3DES><o:p></o:p></span></p>

<p class=3DMsoNormal><font size=3D1 color=3Dblack face=3DArial><span =
lang=3DEN-GB
style=3D'font-size:8.0pt;font-family:Arial;color:black'>julio.prada@idgru=
p.com<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 color=3Dred face=3D"Arial =
Black"><span lang=3DEN-GB
style=3D'font-size:9.0pt;font-family:"Arial =
Black";color:red'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 color=3Dred face=3D"Arial =
Black"><span lang=3DEN-GB
style=3D'font-size:8.0pt;font-family:"Arial Black";color:red'>ID Grup =
Services</span></font><font
size=3D1 color=3Dred face=3D"Arial Black"><span lang=3DEN-GB =
style=3D'font-size:9.0pt;
font-family:"Arial Black";color:red'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 color=3Dgray face=3D"Arial =
Black"><span
style=3D'font-size:8.0pt;font-family:"Arial Black";color:gray'>ID Grup =
Support<i><span
style=3D'font-style:italic'> </span></i>Professional Services &#8226; ID =
Grup
Customer Services &#8226;<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 color=3Dgray face=3D"Arial =
Black"><span
style=3D'font-size:8.0pt;font-family:"Arial Black";color:gray'>Ibernet =
Telem=E1tica
&#8226; Method Software &#8226; ID Grup Business =
Solutions</span></font><font
size=3D1 color=3Dblack face=3D"Arial Black"><span =
style=3D'font-size:9.0pt;font-family:
"Arial Black";color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><b><font size=3D2 color=3Dgray face=3DArial><span =
lang=3DES-TRAD
style=3D'font-size:10.0pt;font-family:Arial;color:gray;font-weight:bold'>=
________________________</span></font></b><b><font
size=3D2 color=3Dnavy face=3DTahoma><span lang=3DES-TRAD =
style=3D'font-size:10.0pt;
font-family:Tahoma;color:navy;font-weight:bold'><o:p></o:p></span></font>=
</b></p>

<p class=3DMsoNormal><i><font size=3D1 color=3Dblue face=3DMonaco><span =
lang=3DES-TRAD
style=3D'font-size:8.0pt;font-family:Monaco;color:blue;font-style:italic'=
><o:p>&nbsp;</o:p></span></font></i></p>

<p class=3DMsoNormal style=3D'text-align:justify'><i><font size=3D1 =
color=3Dgray
face=3D"Times New Roman"><span lang=3DES-TRAD =
style=3D'font-size:8.0pt;color:gray;
font-style:italic'>Este mensaje y todos los ficheros adjuntos que =E9ste =
contiene
son confidenciales y est=E1n destinados exclusivamente al uso individual =
de la
persona a la que van dirigidos. Si Vd. ha recibido este mensaje =
por&nbsp; rror,
rogamos lo devuelva a la persona que se lo ha enviado. Queda =
estrictamente
prohibida la publicaci=F3n, uso, difusi=F3n, impresi=F3n&nbsp; =
</span></font></i><span
lang=3DES><o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-align:justify'><i><font size=3D1 =
color=3Dgray
face=3D"Times New Roman"><span lang=3DES-TRAD =
style=3D'font-size:8.0pt;color:gray;
font-style:italic'>copia no autorizada de este mensaje y de los =
documentos
adjuntos que =E9ste contiene. Las ideas y opiniones manifestadas en este =
mensaje
corresponden&nbsp; nicamente a </span></font></i><i><font size=3D1 =
color=3Dgray
face=3DMonaco><span lang=3DES-TRAD =
style=3D'font-size:8.0pt;font-family:Monaco;
color:gray;font-style:italic'>su autor y no representan necesariamente a =
las de
Red de Empresas ID Grup</span></font></i><span =
lang=3DES><o:p></o:p></span></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
lang=3DES-TRAD
style=3D'font-size:12.0pt'><o:p>&nbsp;</o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C65A15.B588080A--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
