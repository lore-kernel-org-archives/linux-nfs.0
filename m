From: Enils Bashi <EBashi@chesapeakebay.net>
Subject: tcp over nfs for redhat 9 kernel 2.4.20-31.9
Date: Mon, 7 Jun 2004 16:04:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2B51611764AC0A4DB3A15200DD51E8E60907D1@mail2.chesapeakebay.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C44CCA.9B0F6A40"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXQLw-00064g-3t
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 13:04:16 -0700
Received: from mail2.chesapeakebay.net ([208.255.155.18])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BXQLv-0003r5-IB
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 13:04:15 -0700
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

------_=_NextPart_001_01C44CCA.9B0F6A40
Content-Type: text/plain

Hi,

 

I had posted something about this earlier one of the responses I received
was that my nfs server does not support tcp over nfs since the output of
rpcinfo -p looked like the following:

 

[root@client linux-2.4]# rpcinfo -p server

   program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100024    1   udp  32768  status

    100024    1   tcp  32768  status

    391002    2   tcp  32769  sgi_fam

    100011    1   udp    705  rquotad

    100011    2   udp    705  rquotad

    100011    1   tcp    708  rquotad

    100011    2   tcp    708  rquotad

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100021    1   udp  33050  nlockmgr

    100021    3   udp  33050  nlockmgr

    100021    4   udp  33050  nlockmgr

    100005    1   udp  33051  mountd

    100005    1   tcp  40931  mountd

    100005    2   udp  33051  mountd

    100005    2   tcp  40931  mountd

    100005    3   udp  33051  mountd

    100005    3   tcp  40931  mountd

 

Just for kicks I installed Fedora Core 2 on one of my nfs client machines. I
mounted all drives with proto=tcp and nfsvers=3 and everything worked great.
I ran some tests and I got very good results. Nfs on Fedora was at least
100% faster than on Redhat. All this done using the same nfs server located
on a Redhat 9 Server. My other Redhat 9 clients all with Kernel 2.4.20-31.9
fail to mount with proto=tcp. From the reading I have done most  kernels
above 2.4.19 are supposed to have nfs over tcp support. I tried recompiling
the kernel on one of the Redhat nfs clients using xconfig; but under the
Network File System options tcp support for nfs was grayed out (disabled). I
am not sure whether this means that is already installed. I have noticed
that other people have had similar problems but I don't see a straight
answer on the forum.

 

Any and all feedback would be greatly appreciated.

 

Enils


------_=_NextPart_001_01C44CCA.9B0F6A40
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
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
font-family:Arial'>I had posted something about this earlier one of the
responses I received was that my nfs server does not support tcp over =
nfs since
the output of rpcinfo &#8211;p looked like the =
following:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@client linux-2.4]# rpcinfo -p =
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
udp&nbsp;&nbsp;&nbsp; 705&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 705&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 708&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 708&nbsp; rquotad<o:p></o:p></span></font></p>

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
udp&nbsp; 33050&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp; 33050&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp; 33050&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp; 33051&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 40931&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp; 33051&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp; 40931&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp; 33051&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp; 40931&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Just for kicks I installed Fedora Core 2 on one of =
my nfs
client machines. I mounted all drives with proto=3Dtcp and nfsvers=3D3 =
and everything
worked great. I ran some tests and I got very good results. Nfs on =
Fedora was
at least 100% faster than on Redhat. All this done using the same nfs =
server
located on a Redhat 9 Server. My other Redhat 9 clients all with Kernel =
2.4.20-31.9
fail to mount with proto=3Dtcp. From the reading I have done most =
&nbsp;kernels
above 2.4.19 are supposed to have nfs over tcp support. I tried =
recompiling the
kernel on one of the Redhat nfs clients using xconfig; but under the =
Network
File System options tcp support for nfs was grayed out (disabled). I am =
not
sure whether this means that is already installed. I have noticed that =
other
people have had similar problems but I don&#8217;t see a straight =
answer on the
forum.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Any and all feedback would be greatly =
appreciated.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Enils<o:p></o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C44CCA.9B0F6A40--


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
