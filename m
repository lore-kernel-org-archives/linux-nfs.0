From: Enils Bashi <EBashi@chesapeakebay.net>
Subject: nfs over tcp problem on Redhat 9
Date: Wed, 2 Jun 2004 14:43:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2B51611764AC0A4DB3A15200DD51E8E6090783@mail2.chesapeakebay.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C448D1.70B6A800"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVaiO-0002jE-EW
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:43:52 -0700
Received: from mail2.chesapeakebay.net ([208.255.155.18])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVaiN-0007Aq-Pu
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:43:51 -0700
To: nfs@lists.sourceforge.net
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C448D1.70B6A800
Content-Type: text/plain

Hi All,

 

I have done a lot of reading about this but could not find a solution. Maybe
I will find a solution here. Here is what the problem is.

I want to establish nfs over tcp. Here is my auto.nfs file:

 

#/etc/auto.nfs

model
-fstype=nfs,rw,hard,sync,intr,rsize=32768,wsize=32768,nfsvers=3,proto=tcp
server:/model

home
-fstype=nfs,rw,hard,sync,intr,rsize=32768,wsize=32768,nfsvers=3,proto=tcp
server:/home

usr_local_bin
-fstype=nfs,rw,hard,sync,intr,rsize=32768,wsize=32768,nfsvers=3,proto=tcp
server:/usr/local/bin

usr_opt
-fstype=nfs,rw,hard,sync,intr,rsize=32768,wsize=32768,nfsvers=3,proto=tcp
server:/usr/opt

 

here is the auto.master file:

# auto.master

/nfs    /etc/auto.nfs   --timeout 600

 

Here is the message from the log files:

 

May 28 08:30:54 <clientName> automount[8709]: attempting to mount entry
/nfs/home

May 28 08:30:54 <clientName> automount[8719]: >> nfs server reported service
unavailable: Address already in use

May 28 08:30:54 <clientName> automount[8719]: mount(nfs): nfs: mount failure
tautog:/home on /nfs/home

May 28 08:33:02 <clientName> automount[8709]: shutting down, path = /nfs

 

I am running Redhat 9 Kernel  2.4.20-31.9 smp and nfs-utils-1.0.1-3.9. I
have done all updates. 

I am assuming that there is tcp support for the kernel and version of nfs I
am using, since I get the following from rcpinfo:

 

[root@client ~]# rpcinfo -p server

   program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100024    1   udp  32768  status

    100024    1   tcp  32768  status

    391002    2   tcp  32769  sgi_fam

    100011    1   udp    748  rquotad

    100011    2   udp    748  rquotad

    100011    1   tcp    751  rquotad

    100011    2   tcp    751  rquotad

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100021    1   udp  32875  nlockmgr

    100021    3   udp  32875  nlockmgr

    100021    4   udp  32875  nlockmgr

    100005    1   udp  32877  mountd

    100005    1   tcp  38996  mountd

    100005    2   udp  32877  mountd

    100005    2   tcp  38996  mountd

    100005    3   udp  32877  mountd

    100005    3   tcp  38996  mountd

 

 

Any and all help would be greatly appreciated.

 

 

--

Enils Bashi

Programmer

Chesapeake Bay Program

Annapolis MD 21403

410-267-9833


------_=_NextPart_001_01C448D1.70B6A800
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:st1=3D"urn:schemas-microsoft-com:office:smarttags" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">


<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"PostalCode"/>
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"State"/>
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"City"/>
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"place"/>
<!--[if !mso]>
<style>
st1\:*{behavior:url(#default#ieooui) }
</style>
<![endif]-->
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
	{mso-style-type:personal;
	font-family:Arial;
	color:windowtext;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	font-family:Arial;
	color:navy;}
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
font-family:Arial'>Hi All,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I have done a lot of reading about this but could =
not find a
solution. Maybe I will find a solution here. Here is what the problem =
is.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I want to establish nfs over tcp. Here is my =
auto.nfs file:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>#/etc/auto.nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>model&nbsp;&nbsp;&nbsp; =
-fstype=3Dnfs,rw,hard,sync,intr,rsize=3D32768,wsize=3D32768,nfsvers=3D3,=
proto=3Dtcp
server:/model<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>home&nbsp;&nbsp;&nbsp;
-fstype=3Dnfs,rw,hard,sync,intr,rsize=3D32768,wsize=3D32768,nfsvers=3D3,=
proto=3Dtcp&nbsp;
server:/home<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>usr_local_bin&nbsp;&nbsp;&nbsp;
-fstype=3Dnfs,rw,hard,sync,intr,rsize=3D32768,wsize=3D32768,nfsvers=3D3,=
proto=3Dtcp&nbsp;
server:/usr/local/bin<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>usr_opt&nbsp;&nbsp;&nbsp;
-fstype=3Dnfs,rw,hard,sync,intr,rsize=3D32768,wsize=3D32768,nfsvers=3D3,=
proto=3Dtcp
server:/usr/opt<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>here is the auto.master =
file:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'># auto.master<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>/nfs&nbsp;&nbsp;&nbsp; /etc/auto.nfs&nbsp;&nbsp; =
--timeout
600<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Here is the message from the log =
files:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>May 28 08:30:54 &lt;clientName&gt; automount[8709]:
attempting to mount entry /nfs/home<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>May 28 08:30:54 &lt;clientName&gt; automount[8719]: =
&gt;&gt;
nfs server reported service unavailable: Address already in =
use<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>May 28 08:30:54 &lt;clientName&gt; automount[8719]: =
mount(nfs):
nfs: mount failure tautog:/home on =
/nfs/home<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>May 28 08:33:02 &lt;clientName&gt; automount[8709]: =
shutting
down, path =3D /nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I am running Redhat 9 Kernel &nbsp;2.4.20-31.9 smp =
and
nfs-utils-1.0.1-3.9. I have done all updates. =
<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I am assuming that there is tcp support for the =
kernel and
version of nfs I am using, since I get the following from =
rcpinfo:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@client ~]# rpcinfo -p =
server<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp; program vers proto&nbsp;&nbsp; =
port<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100024&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp; 32768&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100024&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 32768&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 391002&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp; 32769&nbsp; sgi_fam<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 748&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 748&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 751&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 751&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp; 32875&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp; 32875&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp; 32875&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp; 32877&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 38996&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp; 32877&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp; 38996&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp; 32877&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp; 38996&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Any and all help would be greatly =
appreciated.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>--<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Enils Bashi<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-siz=
e:10.0pt;
font-family:Arial'>Programmer<o:p></o:p></span></font></p>

<p class=3DMsoNormal><st1:place w:st=3D"on"><font size=3D2 =
face=3DArial><span
 style=3D'font-size:10.0pt;font-family:Arial'>Chesapeake =
Bay</span></font></st1:place><font
size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;font-family:Arial'> =
Program<o:p></o:p></span></font></p>

<p class=3DMsoNormal><st1:place w:st=3D"on"><st1:City w:st=3D"on"><font =
size=3D2
  face=3DArial><span =
style=3D'font-size:10.0pt;font-family:Arial'>Annapolis</span></font></st=
1:City><font
 size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;font-family:Arial'> <st1:State
 w:st=3D"on">MD</st1:State> <st1:PostalCode =
w:st=3D"on">21403</st1:PostalCode></span></font></st1:place><font
size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;font-family:Arial'><o:p></o:p></span></font></=
p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>410-267-9833<o:p></o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C448D1.70B6A800--


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
