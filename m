From: "Wim Colgate" <Wim.Colgate@xensource.com>
Subject: different mounts to the same server export
Date: Thu, 4 Oct 2007 14:24:33 -0700
Message-ID: <A9AD3C3BCF83FD4182B7D4D99E37FAD84A2F88@exchrdm.ad.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1066376869=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdYBc-0006nA-1k
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 14:24:48 -0700
Received: from webmailrdm.xensource.com ([66.228.214.202])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdYBf-0004ry-S0
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 14:24:53 -0700
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

--===============1066376869==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C806CC.FFBBF242"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C806CC.FFBBF242
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I have a question/issue relating to different mounts to the same server
export with different attributes.=20

=20

My client is an Ubuntu distro (Linux wimc 2.6.20-16-generic #2 SMP Fri
Aug 31 00:55:27 UTC 2007 i686 GNU/Linux)

=20

Suppose from the same linux client I want to have two different accesses
of the same export, but with different attributes. For example:

=20

$ mount rdmx2:/public /mnt/public -o hard,rw

=20

and

=20

$ mount rdmx2:/public /mnt/scratch -o soft,ro

=20

And also:

=20

# mount rdmx2:/public/wim /mnt/wim -o soft,ro

=20

Obviously, depending on which path I take to get at the underlying files
(/mnt/public vs. /mnt/scratch) I'd expect the attributes to be honored
and the behavior as specified.

=20

However, what I'm seeing is that this is not the case. Dumping
information with the mount command shows the attributes as specified.
But cat'ing /proc/mounts shows the first attributes for all mounts.=20

=20

$mount=20

rdmx2:/public on /mnt/public type nfs (rw,addr=3D172.24.0.71)

rdmx2:/public on /mnt/scratch type nfs (ro,soft,addr=3D172.24.0.71)

rdmx2:/public/wim on /mnt/wim type nfs (ro,soft,addr=3D172.24.0.71)

=20

$ cat /proc/mounts

rdmx2:/public /mnt/public nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D
2,sec=3Dsys,addr=3Drdmx2 0 0

rdmx2:/public /mnt/scratch nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D
2,sec=3Dsys,addr=3Drdmx2 0 0

rdmx2:/public/wim /mnt/wim nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D
2,sec=3Dsys,addr=3Drdmx2 0 0

=20

and even though mounted as a read-only file system I can create a file
on it..:

=20

$ echo junk > /mnt/wim/foo

$ cat /mnt/wim/foo

junk

$

=20

Is there a known issue/problem or is this as designed?

=20

Thanks,

=20

Wim


------_=_NextPart_001_01C806CC.FFBBF242
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
font-family:Arial'>I have a question/issue relating to different mounts =
to the
same server export with different attributes. =
<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>My client is an Ubuntu distro (Linux wimc =
2.6.20-16-generic
#2 SMP Fri Aug 31 00:55:27 UTC 2007 i686 =
GNU/Linux)<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Suppose from the same linux client I want to have two =
different
accesses of the same export, but with different attributes. For =
example:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$ mount rdmx2:/public /mnt/public &#8211;o =
hard,rw<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>and<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$ mount rdmx2:/public /mnt/scratch &#8211;o =
soft,ro<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>And also:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'># mount rdmx2:/public/wim /mnt/wim &#8211;o =
soft,ro<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Obviously, depending on which path I take to get at =
the
underlying files (/mnt/public vs. /mnt/scratch) I&#8217;d expect the =
attributes
to be honored and the behavior as =
specified.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>However, what I&#8217;m seeing is that this is not =
the case.
Dumping information with the mount command shows the attributes as =
specified. But
cat&#8217;ing /proc/mounts shows the first attributes for all mounts. =
<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$mount <o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public on /mnt/public type nfs =
(rw,addr=3D172.24.0.71)<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public on /mnt/scratch type nfs
(ro,soft,addr=3D172.24.0.71)<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public/wim on /mnt/wim type nfs
(ro,soft,addr=3D172.24.0.71)<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$ cat /proc/mounts<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public /mnt/public nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D2,sec=3Dsys,addr=3Drdmx2
0 0<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public /mnt/scratch nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D2,sec=3Dsys,addr=3Drdmx2
0 0<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rdmx2:/public/wim /mnt/wim nfs
rw,vers=3D3,rsize=3D32768,wsize=3D32768,hard,intr,proto=3Dtcp,timeo=3D600=
,retrans=3D2,sec=3Dsys,addr=3Drdmx2
0 0<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>and even though mounted as a read-only file system I =
can
create a file on it..:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$ echo junk &gt; =
/mnt/wim/foo<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$ cat /mnt/wim/foo<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>junk<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>$<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Is there a known issue/problem or is this as =
designed?<o:p></o:p></span></font></p>

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

------_=_NextPart_001_01C806CC.FFBBF242--


--===============1066376869==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1066376869==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1066376869==--
