From: "Dominic Daninger" <ddaninger@reasonco.com>
Subject: Tuning NFS for Maximum Thought put?
Date: Mon, 6 Feb 2006 16:20:22 -0600
Message-ID: <DDBAA550DD134B4197BEC287924809604F29FF@SBS-REASON.REASON.OFFICE>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C62B6B.852C97A8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6Ell-0003bb-8G
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 14:23:37 -0800
Received: from exchange.reasonco.com ([65.240.31.93] helo=reasonco.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6Elj-00050M-Gb
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 14:23:37 -0800
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

------_=_NextPart_001_01C62B6B.852C97A8
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

We are working on trying to get maximum throughput from and NFS server
for both Read and Write over bonded dual GigE NIC's.
=20
The configuration is:

SuperMicro H8DAE Motherboard

Dual Opteron 248's

4GB of DDR400

Areca 1130 PCI-X 12-port RAID 6 Controller

Fedora Core 4 OS

Dual integrated Broadcom 5704C 1Gbit NICs with Linux round robin
bonding, and 9KB jumbo frames.

12 WD RAID Edition II 400GB SATA Drives

The basic problem is we have what appears to be an I/O bottleneck that
is preventing us from serving over the network more that 100MB/s via NFS
using either TCP or UDP. What I would like to know if 150MB/s sequential
read or 150MB/s sequential write or greater is possible with this OS &
HW combination . I know that it should be based on theoretical bandwidth
of the buses, but we are only seeing about 1/3 of the theoretical right
now. Local write and read tests of 10GB files consistently show file
write rates of 300+MB/s and file reads of 260+MB/s. We had also tried a
single Areca 1170 24-port controller earlier and we go local reads of
300MB/s and local writes of 150MB/s.

 Results of netperf testing 8k message size and with linux kernel
parameters tuned

Test using 1 Gigabit Ethernet connection

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3=20

(192.168.1.3) port 0 AF_INET

Recv     Send     Send

Socket  Socket     Message     Elapsed

Size     Size     Size     Time     Throughput

bytes bytes bytes secs.         10^6bits/sec

87380 65536 65536 10.10         908.66

=20

Test using 2 Gigabit Ethernet connection (bonded)

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3

(192.168.1.3) port 0 AF_INET

Recv Send Send Socket Socket Message Elapsed

Size Size Size Time Throughput

bytes bytes bytes secs. 10^6bits/sec

256000 128000 128000 10.01 1580.06

Other test results are indicative of bottlenecks on the motherboard,
although that wasn't immediately apparent. Combined throughput from
client machines never exceeded 100 MB/s write through NFS. However,
while the network test is taking place, a local test can be run and
reach write speeds of 180 MB/s while the network speeds stay the same.
Throughput has remained roughly the same whether the clients connect to
the same bond, to different IPs on different cards, point-to-point with
cross-over or using switches.

Testing of the two GigE bond connections complete successfully and a
sustained throughput of 1580 Mbps.

We have done a lot of work with Broadcom's BCM5700 driver to moderate
the NIC interrupts and tune various buffers. We have been able to cut
interrupts from over 20,000/s to about 6000/s. Context switches are
still high however and our maximum NFS throughput is still about
100MB/sec.

Any ideas out there regarding how to tune NFS for better throughput?

 Dominic Daninger

VP of Engineering for Reason
One Main St SE #85
Minneapolis, MN 55414
Tel. 612 331 9495 x103#, Fax 612 331 9237
Email: ddaninger@reasonco.com
Web: www.reasonco.com <http://www.reasonco.com/> =20
=20
=20

------_=_NextPart_001_01C62B6B.852C97A8
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2802" name=3DGENERATOR></HEAD>
<BODY>
<DIV>
<DIV><SPAN style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial"><SPAN=20
class=3D343151421-06022006>We are working on trying to get maximum =
throughput from=20
and NFS server for both Read and Write over bonded&nbsp;dual GigE=20
NIC's.</SPAN></SPAN></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial"></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">The configuration=20
is:</SPAN></FONT><?xml:namespace prefix =3D o ns =3D=20
"urn:schemas-microsoft-com:office:office" /><o:p></o:p></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3D"Times New Roman" size=3D3><SPAN=20
style=3D"FONT-SIZE: 12pt"><o:p></o:p></SPAN></FONT></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">SuperMicro&nbsp;H8DAE=20
Motherboard</SPAN></FONT><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">Dual Opteron=20
248's</SPAN></FONT><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">4GB of=20
DDR400</SPAN></FONT><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">Areca&nbsp;1130 PCI-X =
12-port RAID 6=20
Controller</SPAN></FONT></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">Fedora Core 4=20
OS</SPAN></FONT><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><SPAN style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><SPAN=20
class=3D343151421-06022006>D</SPAN>ual integrated<SPAN =
class=3D343151421-06022006>=20
Broadcom 5704C</SPAN>&nbsp;1Gbit NICs<SPAN class=3D343151421-06022006> =
</SPAN>with=20
Linux round robin<SPAN class=3D343151421-06022006> bonding</SPAN>, and =
9KB jumbo=20
frames.</SPAN><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><SPAN style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><SPAN=20
class=3D343151421-06022006>12</SPAN>&nbsp;WD RAID Edition =
II&nbsp;400GB&nbsp;SATA=20
Drives</SPAN><o:p></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><SPAN style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial">The basic=20
problem is we have what appears to be an I/O bottleneck that is =
preventing us=20
from serving<SPAN class=3D343151421-06022006> over the network</SPAN> =
more that=20
100MB/s via NFS&nbsp;using&nbsp;either TCP or UDP.&nbsp;</SPAN><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">What I would like to know=20
if&nbsp;<SPAN class=3D343151421-06022006>15</SPAN>0MB/s sequential read=20
or&nbsp;<SPAN class=3D343151421-06022006>15</SPAN>0MB/s sequential =
write<SPAN=20
class=3D343151421-06022006> or greater</SPAN>&nbsp;is<SPAN=20
class=3D343151421-06022006> possible with this OS &amp;=20
HW&nbsp;combination</SPAN>&nbsp;. I&nbsp;know that it should be based on =

theoretical bandwidth of the buses, but we are only seeing about 1/3 of =
the=20
theoretical right now. Local write and read tests of 10GB files =
consistently=20
show file write rates of 300+MB/s and file reads of 260+MB/s. We had =
also tried=20
a single Areca 1170 24-port controller earlier and we go local reads of =
300MB/s=20
and local writes of 150MB/s.</SPAN></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT size=3D3><SPAN=20
style=3D"FONT-SIZE: 12pt">&nbsp;</SPAN></FONT><STRONG><B><FONT =
size=3D2><SPAN=20
style=3D"FONT-SIZE: 10pt">Results of netperf testing 8k message size and =
with=20
linux kernel parameters =
tuned</SPAN></FONT></B></STRONG><o:p></o:p></P></DIV>
<DIV>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Test using 1 Gigabit =
Ethernet=20
connection</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">TCP STREAM TEST from =
0.0.0.0=20
(0.0.0.0) port 0 AF_INET to 192.168.1.3 </SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">(192.168.1.3) port 0=20
AF_INET</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: =
10pt">Recv&nbsp;&nbsp;&nbsp;&nbsp;=20
Send&nbsp;&nbsp;&nbsp;&nbsp; Send</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Socket&nbsp;=20
Socket&nbsp;&nbsp;&nbsp;&nbsp; Message&nbsp;&nbsp;&nbsp;&nbsp;=20
Elapsed</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: =
10pt">Size&nbsp;&nbsp;&nbsp;&nbsp;=20
Size&nbsp;&nbsp;&nbsp;&nbsp; Size&nbsp;&nbsp;&nbsp;&nbsp;=20
Time&nbsp;&nbsp;&nbsp;&nbsp; Throughput</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">bytes bytes bytes=20
secs.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
10^6bits/sec</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">87380 65536 65536=20
10.10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
908.66</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D3><SPAN=20
style=3D"FONT-SIZE: 12pt">&nbsp;<o:p></o:p></SPAN></FONT></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Test using 2 Gigabit =
Ethernet=20
connection (bonded)</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">TCP STREAM TEST from =
0.0.0.0=20
(0.0.0.0) port 0 AF_INET to 192.168.1.3</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">(192.168.1.3) port 0=20
AF_INET</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Recv Send Send Socket =
Socket=20
Message Elapsed</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Size Size Size Time=20
Throughput</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">bytes bytes bytes =
secs.=20
10^6bits/sec</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">256000 128000 128000 =
10.01=20
1580.06</SPAN></FONT><o:p></o:p></P>
<P><FONT size=3D2><SPAN style=3D"FONT-SIZE: 10pt">Other test results are =
indicative=20
of bottlenecks on the motherboard, although that wasn't immediately =
apparent.=20
Combined throughput from client machines never exceeded 100 MB/s write =
through=20
NFS. However, while the network test is taking place, a local test can =
be run=20
and reach write speeds of 180 MB/s while the network speeds stay the =
same.=20
Throughput has remained roughly the same whether the clients connect to =
the same=20
bond, to different IPs on different cards, point-to-point with =
cross-over or=20
using switches.</SPAN></FONT><o:p></o:p></P>
<P><SPAN style=3D"FONT-SIZE: 10pt"><SPAN =
class=3D343151421-06022006>Testing of the=20
two&nbsp;GigE</SPAN> bond&nbsp;<SPAN =
class=3D343151421-06022006>connections</SPAN>=20
complete successfully and a sustained throughput of 1580 =
Mbps.</SPAN></P>
<P><SPAN style=3D"FONT-SIZE: 10pt"></SPAN><o:p><SPAN=20
class=3D343151421-06022006><FONT face=3DArial size=3D2>We have done a =
lot of work with=20
Broadcom's BCM5700 driver to moderate the NIC interrupts and tune =
various=20
buffers. We have been able to cut interrupts from over 20,000/s to about =
6000/s.=20
Context switches are still high however and our maximum NFS throughput =
is still=20
about 100MB/sec.</FONT></SPAN></o:p></P>
<P><o:p><SPAN class=3D343151421-06022006><FONT face=3DArial size=3D2>Any =
ideas out=20
there regarding how to tune NFS for better=20
throughput?</FONT></SPAN></o:p></P></DIV>
<DIV>
<P class=3DMsoNormal><FONT size=3D3><SPAN=20
style=3D"FONT-SIZE: 12pt">&nbsp;</SPAN></FONT><FONT =
face=3DScript>Dominic=20
Daninger</FONT></P></DIV></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>VP of Engineering for=20
Reason</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>One Main St SE =
#85</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>Minneapolis, MN =
55414</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>Tel. 612 331 9495 x103#, =
Fax 612 331=20
9237</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>Email: <A=20
href=3D"mailto:ddaninger@reasonco.com">ddaninger@reasonco.com</A></FONT><=
/DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D1>Web: <A=20
href=3D"http://www.reasonco.com/">www.reasonco.com</A> </FONT></DIV>
<DIV align=3Dleft>&nbsp;</DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C62B6B.852C97A8--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
