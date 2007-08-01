From: "Wim Colgate" <Wim.Colgate@xensource.com>
Subject: question (perhaps unaswerable)
Date: Wed, 1 Aug 2007 11:13:37 -0700
Message-ID: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BB1B@exchrdm.ad.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1964467414=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGIiV-0002Ju-Tt
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:14:40 -0700
Received: from webmailrdm.xensource.com ([66.228.214.202])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGIiU-0007uC-DJ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:14:38 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--===============1964467414==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C7D467.D223815F"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7D467.D223815F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

I'm looking into a potential problem. The setup is a little arcane; so
please bear with me.

=20

I have an NFS mount (soft, timeo=3D66, retrans=3D1, tcp) to a NAS filer. =
The
client is linux 2.6.18-8 derived.=20

=20

The client user-mode application uses O_DIRECT and kernel aio support
(io_submit io_getevents) to perform IO. On EIO's the data is retried by
the application.

=20

While running a test program to write a specific pattern to a file, I
will manually bring down, bring up, bring down, etc... the nfs service
on the filer.

=20

Some of the time, everything is as it should be; on an occasion, I will
have "corrupt" data - and by corrupt, I mean the data doesn't actually
get written on disk (the application will read back the file after all
writes are completed and compare the contents to an expected value).

=20

I've run a wireshark (used to be ethereal) trace and discovered that the
file offset to the non-written data never hits the wire. However, with
adequate tracing in the application, I have determined that the aio
writes are returned as succeeded; subsequent IO's just after the one in
question are returned as EIO's, until sometime in the future when I have
the NFS server service restarted.

=20

Firstly, since I'm on 2.6.18 ... does anyone know if there is a later
patch that might address this?

=20

Second, if not, I'm not afraid of kernel hacking to ferret the problem
out - and suggestions on where the "light looks good" for examination
are readily accepted.

=20

Thanks,

=20

Wim


------_=_NextPart_001_01C7D467.D223815F
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<style>
<!--
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
span.EmailStyle17
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

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Hi,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I&#8217;m looking into a potential problem. The setup =
is a
little arcane; so please bear with me.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I have an NFS mount (soft, timeo=3D66, retrans=3D1, =
tcp) to a
NAS filer. The client is linux 2.6.18-8 derived. =
<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>The client user-mode application uses O_DIRECT and =
kernel
aio support (io_submit io_getevents) to perform IO. On EIO&#8217;s the =
data is
retried by the application.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>While running a test program to write a specific =
pattern to
a file, I will manually bring down, bring up, bring down, etc&#8230; the =
nfs
service on the filer.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Some of the time, everything is as it should be; on =
an
occasion, I will have &#8220;corrupt&#8221; data &#8211; and by corrupt, =
I mean
the data doesn&#8217;t actually get written on disk (the application =
will read back
the file after all writes are completed and compare the contents to an =
expected
value).<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I&#8217;ve run a wireshark (used to be ethereal) =
trace and
discovered that the file offset to the non-written data never hits the =
wire.
However, with adequate tracing in the application, I have determined =
that the
aio writes are returned as succeeded; subsequent IO&#8217;s just after =
the one
in question are returned as EIO&#8217;s, until sometime in the future =
when I
have the NFS server service restarted.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Firstly, since I&#8217;m on 2.6.18 &#8230; does =
anyone know
if there is a later patch that might address =
this?<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Second, if not, I&#8217;m not afraid of kernel =
hacking to
ferret the problem out &#8211; and suggestions on where the &#8220;light =
looks
good&#8221; for examination are readily =
accepted.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Wim<o:p></o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C7D467.D223815F--


--===============1964467414==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1964467414==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1964467414==--
