From: "Yogesh Pahilwan" <Yogesh.Pahilwan@symphonysv.com>
Subject: Oops in rpciod when building procmail from an NFS client
Date: Tue, 13 Nov 2007 21:21:52 +0530
Message-ID: <83FE585A3944624683D9A3F69BA108EB021D5961@PUN2K3EXCL01.symphonysv.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1113128381=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iry3T-00063o-N6
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:52:00 -0800
Received: from pun2k3exfe01.symphonysv.com ([220.225.41.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iry3Y-0008RV-9a
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:52:05 -0800
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

--===============1113128381==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C8260D.1AB96A89"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8260D.1AB96A89
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Hi Folks,

=20

I am getting following oops while building procmail utility from the NFS
mounted share when build from the NFS client.

The NFS server oopses in rpciod during the "Benchmarking your system's
strstr () implementation" step.

=20

I am using the following configurations for NFS client and server:

NFS client configuration: kernel version - 2.6.11-1.1369_FC4

NFS server configuration: kernel version - 2.4.19

Procmail version: v3.22

=20

When I encountered the following oops I didn't kill the build process on
the client, and when I rebooted the server the build progressed a little
bit beyond where it was when the server crashed, and then the NFS server
oopsed again. I tried to kill the process again on the client (via
ctrl-c, ctrl-z), since it was unresponsive due to running off a mount to
the server while the server was unavailable; so instead I just killed
the console in the hopes that would kill the process tree including the
one stuck on the server mount. I rebooted the server again, and within a
minute or so it crashed yet again, seemingly spontaneously; and this
occurred again after another reboot. I checked the processes on the
client and found several stuck "_locktst /tmp/_locktest ./_locktest"
processes. These processes were in clusters of about 6 processes with
contiguous PIDs, and there were about the same number of these clusters
as the number of times I'd run the procmail make and oopsed the server.
Once I killed all these _locktst processes and rebooted the server
again, the oopsing stopped.

=20

The oops:

=20

Oops: 0000

CPU:    0

EIP:    0010:[<40313474>]    Not tainted

Using defaults from ksymoops -t elf32-i386 -a i386

EFLAGS: 00010246

eax: 00000000   ebx: 4e38dd20   ecx: 00000000   edx: 00000004

esi: 4e38c000   edi: 4e38dd20   ebp: 00000001   esp: 4fc41f20

ds: 0018   es: 0018   ss: 0018

Process rpciod (pid: 28706, stackpage=3D4fc41000)

Stack: 00000216 5408ac94 4e38c000 5a8a4720 4e38c000 5a8a4720 4031552d
4e38c000

       4e38dd20 40313967 4e38c000 4e38dd20 40313c70 00000000 00000000
4e38dd74

       4e38dd20 4fc40000 00000001 403165ca 4e38dd20 403aa000 4fc40000
410e09a0

Call Trace:    [<4031552d>] [<40313967>] [<40313c70>] [<403165ca>]
[<40113dac>]

  [<403168cd>] [<403170b1>] [<40317010>] [<4010757e>] [<40317010>]

Code: 8b 80 88 00 00 00 85 c0 74 39 c7 44 24 0c 00 00 00 00 8d 46

Error (pclose_local): Oops_decode pclose failed 0x7f00

Error (Oops_decode): no objdump lines read for /tmp/ksymoops.UQoI1x

=20

>>EIP; 40313474 <__xprt_lock_write+54/f0>   <=3D=3D=3D=3D=3D

=20

>>ebx; 4e38dd20 <_end+df5ef5c/203d329c>

>>esi; 4e38c000 <_end+df5d23c/203d329c>

>>edi; 4e38dd20 <_end+df5ef5c/203d329c>

>>esp; 4fc41f20 <_end+f81315c/203d329c>

=20

Trace; 4031552d <xprt_lock_write+1d/50>

Trace; 40313967 <xprt_reconnect+a7/3b0>

Trace; 40313c70 <xprt_reconn_status+0/80>

Trace; 403165ca <__rpc_execute+10a/2f0>

Trace; 40113dac <schedule+20c/350>

Trace; 403168cd <__rpc_schedule+8d/120>

Trace; 403170b1 <rpciod+a1/220>

Trace; 40317010 <rpciod+0/220>

Trace; 4010757e <kernel_thread+2e/40>

Trace; 40317010 <rpciod+0/220>

=20

There is also a kernel panic that follows this.

=20

Is there any patch available which fixes this nfs issue??? I would
appreciate if anyone tells me=20

where should I get the patch (if available) to resolve this issue.=20

=20

=20

Regards,

Yogesh

=20

=20

=20


------_=_NextPart_001_01C8260D.1AB96A89
Content-Type: text/html;
	charset="US-ASCII"
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
 /* Font Definitions */
 @font-face
	{font-family:Helv;
	panose-1:2 11 6 4 2 2 2 3 2 4;}
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
p.MsoPlainText, li.MsoPlainText, div.MsoPlainText
	{mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman";}
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

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>Hi Folks,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>I am getting following oops while building procmail =
utility
from the NFS mounted share when build from the NFS =
client.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>The NFS server oopses in rpciod during the
&quot;Benchmarking your system's strstr () implementation&quot; =
step.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>I am using the following configurations for NFS =
client and
server:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>NFS client configuration: kernel version - =
2.6.11-1.1369_FC4<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>NFS server configuration: kernel version &#8211; =
2.4.19<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>Procmail version: v3.22<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'>When I encountered the following oops I didn't kill =
the
build process on the client, and when I rebooted the server the build
progressed a little bit beyond where it was when the server crashed, and =
then
the NFS server oopsed again. I tried to kill the process again on the =
client
(via ctrl-c, ctrl-z), since it was unresponsive due to running off a =
mount to
the server while the server was unavailable; so instead I just killed =
the
console in the hopes that would kill the process tree including the one =
stuck
on the server mount. I rebooted the server again, and within a minute or =
so it
crashed yet again, seemingly spontaneously; and this occurred again =
after
another reboot. I checked the processes on the client and found several =
stuck
&quot;_locktst /tmp/_locktest ./_locktest&quot; processes. These =
processes were
in clusters of about 6 processes with contiguous PIDs, and there were =
about the
same number of these clusters as the number of times I'd run the =
procmail make
and oopsed the server. Once I killed all these _locktst processes and =
rebooted
the server again, the oopsing stopped.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DArial><span =
style=3D'font-size:9.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>The =
oops:<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></fon=
t></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Oops: =
0000<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>CPU:&nbsp;&nbsp;&nbsp; =
0<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>EIP:&nbsp;&nbsp;&nbsp;
0010:[&lt;40313474&gt;]&nbsp;&nbsp;&nbsp; Not =
tainted<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Using defaults from ksymoops =
-t
elf32-i386 -a i386<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>EFLAGS: =
00010246<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>eax: 00000000&nbsp;&nbsp; =
ebx:
4e38dd20&nbsp;&nbsp; ecx: 00000000&nbsp;&nbsp; edx: =
00000004<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>esi: 4e38c000&nbsp;&nbsp; =
edi:
4e38dd20&nbsp;&nbsp; ebp: 00000001&nbsp;&nbsp; esp: =
4fc41f20<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>ds: 0018&nbsp;&nbsp; es:
0018&nbsp;&nbsp; ss: 0018<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Process rpciod (pid: 28706,
stackpage=3D4fc41000)<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Stack: 00000216 5408ac94 =
4e38c000
5a8a4720 4e38c000 5a8a4720 4031552d =
4e38c000<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;
4e38dd20 40313967 4e38c000 4e38dd20 40313c70 00000000 00000000 =
4e38dd74<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;
4e38dd20 4fc40000 00000001 403165ca 4e38dd20 403aa000 4fc40000 =
410e09a0<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Call =
Trace:&nbsp;&nbsp;&nbsp;
[&lt;4031552d&gt;] [&lt;40313967&gt;] [&lt;40313c70&gt;] =
[&lt;403165ca&gt;]
[&lt;40113dac&gt;]<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&nbsp; [&lt;403168cd&gt;]
[&lt;403170b1&gt;] [&lt;40317010&gt;] [&lt;4010757e&gt;] =
[&lt;40317010&gt;]<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Code: 8b 80 88 00 00 00 85 =
c0 74 39
c7 44 24 0c 00 00 00 00 8d 46<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Error (pclose_local): =
Oops_decode
pclose failed 0x7f00<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Error (Oops_decode): no =
objdump lines
read for /tmp/ksymoops.UQoI1x<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></fon=
t></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&gt;&gt;EIP; 40313474
&lt;__xprt_lock_write+54/f0&gt;&nbsp;&nbsp; =
&lt;=3D=3D=3D=3D=3D<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></fon=
t></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&gt;&gt;ebx; 4e38dd20
&lt;_end+df5ef5c/203d329c&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&gt;&gt;esi; 4e38c000
&lt;_end+df5d23c/203d329c&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&gt;&gt;edi; 4e38dd20
&lt;_end+df5ef5c/203d329c&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>&gt;&gt;esp; 4fc41f20
&lt;_end+f81315c/203d329c&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></fon=
t></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 4031552d =
&lt;xprt_lock_write+1d/50&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 40313967
&lt;xprt_reconnect+a7/3b0&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 40313c70
&lt;xprt_reconn_status+0/80&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 403165ca
&lt;__rpc_execute+10a/2f0&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 40113dac
&lt;schedule+20c/350&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 403168cd
&lt;__rpc_schedule+8d/120&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 403170b1 =
&lt;rpciod+a1/220&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 40317010 =
&lt;rpciod+0/220&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'line-height:12.0pt'><font size=3D1 =
face=3DArial><span
style=3D'font-size:9.0pt;font-family:Arial'>Trace; 4010757e
&lt;kernel_thread+2e/40&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>Trace; 40317010 =
&lt;rpciod+0/220&gt;<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>There is also a kernel panic that follows =
this.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>Is there any patch available which fixes this nfs =
issue??? I
would appreciate if anyone tells me <o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>where should I get the patch (if available) to resolve =
this
issue. <o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>Regards,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 face=3DHelv><span =
style=3D'font-size:9.0pt;
font-family:Helv'>Yogesh<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D1 color=3Dnavy face=3DArial><span =
style=3D'font-size:
9.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'><o:p>&nbsp;</o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C8260D.1AB96A89--


--===============1113128381==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1113128381==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1113128381==--
