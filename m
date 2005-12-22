From: "Henderson, David" <Henderson.David@mail.dc.state.fl.us>
Subject: unable to copy to nfs share
Date: Thu, 22 Dec 2005 15:47:31 -0500
Message-ID: <82DCFB9BFDF35D4A8B2B2C3878121A89428A11@cos93.dc.state.fl.us>
Mime-Version: 1.0
Content-Type: multipart/related;
	boundary="----_=_NextPart_001_01C60738.EDDB1767";
	type="multipart/alternative"
Cc: <dhenderson@digital-pipe.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpXLh-0005Ma-JI
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:47:41 -0800
Received: from mail.dc.state.fl.us ([205.145.233.1] helo=cos94.dc.state.fl.us)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EpXLg-0008L9-5p
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:47:41 -0800
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

------_=_NextPart_001_01C60738.EDDB1767
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_002_01C60738.EDDB1767"


------_=_NextPart_002_01C60738.EDDB1767
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Gang,

            I am having a problem with copying files to an NFS share.  I
can successfully ping all computers and can mount the nfs share from all
client computers (one client can successfully perform all file related
tasks).

=20

Background information

I have a server installed with Debian 3.1 (Sarge) GNU/Linux named (fs1)
that has a file share /mnt/export.  I have two client computers, one
with Debian 3.1 and one that I am trying to boot to a cd I created.  I
can mount the nfs share using the two Debian computers, so I know the
share is setup correctly and it must be something I have left off of the
boot cd.  I will include output from various tests below.  Please let me
know if there is something I am missing.  By the way, the boot cd has no
login authentication, it just boots to a prompt.  I have checked the UID
and USER environment variables and they are '0' and 'root' respectively.

=20

Version Information

Debian doesn't use an nfs-utils package, but has it broken down into
several packages.  All of this computers are using the latest nfs
software released with Debian 3.1.  The kernels used are all 2.6.8.

=20

=20

Showmount -e (on server)

Export list for fs1

/mnt/export        192.168.0.100/255.255.255.0

=20

/etc/exports (on server)

/mnt/export        192.168.0.100/255.255.255.0      <-- tried both ip
addresses of clients, this is the one of the bootcd

=20

rpcinfo -p (on client)

100000    2    tcp    111    portmapper

100000    2    udp    111    portmapper

100024    1    udp    604    status

100024    1    tcp    607    status

=20

=20

mount (on client)

mount -t nfs 192.168.0.11:/mnt/export /mnt/nfs

nfs warning : mount version older than kernel

=20

copy request (on client)

copy /etc/test.doc /mnt/nfs

Unable to handle kernel NULL pointer dereference at virtual address ...

....

Segmentation fault

=20

=20

Does anyone have any ideas as to why this wouldn't be working?  Does nfs
require any additional packages to be installed?

=20

Thanks,

=20

Dave Henderson

=20

MCP, MCSA, MCSE, A+

Distributed Computer Systems Analyst

Florida Department of Corrections

Phone: 407.207.7391            Suncom: 343.7391

=20

=20

=20


------_=_NextPart_002_01C60738.EDDB1767
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 10 (filtered)">

<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
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
	{font-family:Arial;
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
font-family:Arial'>Gang,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; I
am having a problem with copying files to an NFS share. &nbsp;I can
successfully ping all computers and can mount the nfs share from all =
client
computers (one client can successfully perform all file related =
tasks).</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><span =
style=3D'text-decoration:none'>&nbsp;</span></span></font></u></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Background information</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I have a server installed with Debian 3.1 (Sarge) =
GNU/Linux
named (fs1) that has a file share /mnt/export.&nbsp; I have two client
computers, one with Debian 3.1 and one that I am trying to boot to a cd =
I
created. &nbsp;I can mount the nfs share using the two Debian computers, =
so I
know the share is setup correctly and it must be something I have left =
off of
the boot cd.&nbsp; I will include output from various tests below.&nbsp; =
Please
let me know if there is something I am missing.&nbsp; By the way, the =
boot cd
has no login authentication, it just boots to a prompt. &nbsp;I have =
checked
the UID and USER environment variables and they are &#8216;0&#8217; and =
&#8216;root&#8217;
respectively.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Version Information</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Debian doesn&#8217;t use an nfs-utils package, but =
has it
broken down into several packages.&nbsp; All of this computers are using =
the
latest nfs software released with Debian 3.1.&nbsp; The kernels used are =
all
2.6.8.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><span =
style=3D'text-decoration:none'>&nbsp;</span></span></font></u></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Showmount &#8211;e (on server)</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Export list for fs1</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>/mnt/export&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
192.168.0.100/255.255.255.0</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>/etc/exports (on server)</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>/mnt/export&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
192.168.0.100/255.255.255.0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
</span></font><font
size=3D2 face=3DWingdings><span =
style=3D'font-size:10.0pt;font-family:Wingdings'>&szlig;</span></font><fo=
nt
size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;font-family:Arial'> tried both ip
addresses of clients, this is the one of the bootcd</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rpcinfo &#8211;p (on client)</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp; =
tcp&nbsp;&nbsp;&nbsp;
111&nbsp;&nbsp;&nbsp; portmapper</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp; =
udp&nbsp;&nbsp;&nbsp;
111&nbsp;&nbsp;&nbsp; portmapper</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; =
udp&nbsp;&nbsp;&nbsp;
604&nbsp;&nbsp;&nbsp; status</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; =
tcp&nbsp;&nbsp;&nbsp;
607&nbsp;&nbsp;&nbsp; status</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>mount (on client)</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DFR =
style=3D'font-size:10.0pt;
font-family:Arial'>mount &#8211;t nfs 192.168.0.11:/mnt/export =
/mnt/nfs</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>nfs warning&nbsp;: mount version older than =
kernel</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><u><font size=3D2 face=3DArial><span lang=3DFR =
style=3D'font-size:
10.0pt;font-family:Arial'>copy request (on client)</span></font></u></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DFR =
style=3D'font-size:10.0pt;
font-family:Arial'>copy /etc/test.doc /mnt/nfs</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Unable to handle kernel NULL pointer dereference at =
virtual address
...</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&#8230;.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Segmentation fault</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Does anyone have any ideas as to why this =
wouldn&#8217;t be
working?&nbsp; Does nfs require any additional packages to be =
installed?</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><b><font size=3D3 color=3D"#3366ff" face=3D"Times =
New Roman"><span
style=3D'font-size:12.0pt;color:#3366FF;font-weight:bold'>Dave =
Henderson</span></font></b></p>

<p class=3DMsoNormal><b><font size=3D3 face=3D"Times New Roman"><span
style=3D'font-size:12.0pt;font-weight:bold'><img width=3D200 height=3D59
src=3D"cid:image001.jpg@01C6070F.6C6C0440"></span></font></b></p>

<p class=3DMsoNormal><b><font size=3D2 color=3D"#00ccff" face=3D"Times =
New Roman"><span
style=3D'font-size:10.0pt;color:#00CCFF;font-weight:bold'>MCP, MCSA, =
MCSE, A+</span></font></b></p>

<p class=3DMsoNormal><font size=3D2 color=3D"#3366ff" face=3D"Times New =
Roman"><span
style=3D'font-size:10.0pt;color:#3366FF'>Distributed Computer Systems =
Analyst</span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3D"#3366ff" face=3D"Times New =
Roman"><span
style=3D'font-size:10.0pt;color:#3366FF'>Florida Department of =
Corrections</span></font></p>

<p class=3DMsoNormal><b><font size=3D2 color=3D"#3366ff" face=3D"Times =
New Roman"><span
style=3D'font-size:10.0pt;color:#3366FF;font-weight:bold'>Phone:</span></=
font></b><font
size=3D2><span style=3D'font-size:10.0pt'> =
407.207.7391&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; <b><font
color=3D"#3366ff"><span =
style=3D'color:#3366FF;font-weight:bold'>Suncom:</span></font>
</b>343.7391</span></font></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'>&nbsp;</span></font></p>

</div>

</body>

</html>

------_=_NextPart_002_01C60738.EDDB1767--

------_=_NextPart_001_01C60738.EDDB1767
Content-Type: image/jpeg;
	name="image001.jpg"
Content-Transfer-Encoding: base64
Content-ID: <image001.jpg@01C6070F.6C6C0440>
Content-Description: image001.jpg
Content-Location: image001.jpg

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

------_=_NextPart_001_01C60738.EDDB1767--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
