From: "Alex Kelly" <alex@oxygencomputers.co.uk>
Subject: NFS root with ethernet bonding freezes on 2.4
Date: Tue, 27 Jun 2006 11:07:48 +0100
Message-ID: <20060627100741.B399F13F5A@guybrush.innercrew.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1025308664=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FvAU3-00049N-N7
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 03:07:51 -0700
Received: from mcr-smtp-002.bulldogdsl.com ([212.158.248.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FvAU3-0004u6-4A
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 03:07:51 -0700
Received: from guybrush.innercrew.co.uk (host-84-9-58-78.bulldogdsl.com
	[84.9.58.78])
	by mcr-smtp-002.bulldogdsl.com (Postfix) with ESMTP id E6163846B1B
	for <nfs@lists.sourceforge.net>; Tue, 27 Jun 2006 11:07:41 +0100 (BST)
Received: from orinoco (unknown [172.16.0.104])
	by guybrush.innercrew.co.uk (Postfix) with ESMTP id B399F13F5A
	for <nfs@lists.sourceforge.net>; Tue, 27 Jun 2006 11:07:41 +0100 (BST)
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--===============1025308664==
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0043_01C699D9.EC97C480"

This is a multi-part message in MIME format.

------=_NextPart_000_0043_01C699D9.EC97C480
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

 

I've recently been trying to set up Ethernet bonding for failover on a
system which has a host NFS system from which thin clients Etherboot. I am
trying to set up the bonding on the thin client end.

 

Initially everything works ok. However if I run an iperf server ('iperf -s')
at one end and then loop through iperf bidirectional tests from the other
('for i in $(seq 1 10000); do echo $i; iperf -c host -d; done') the
networking on the client locks up after around 900 iterations (+- ~20). A
similar result is achieved by generating large amounts of traffic by
continually sshing a file from one machine to /dev/null on the other too, so
it would seem that the problem is not in the method of testing.

 

The bonding is set up with the parameters 'mode=1 arp_ip_target=192.168.0.1
arp_interval=100' where 192.168.0.1 is the IP of the NFS/Etherboot host.
While running the tests I have only been connecting one of the Ethernet
devices to simplify things. The same problem occurs with both connected
though. I have also tried connecting client and server directly with a
crossover to eliminate switching problems. I have also tried running the
bandwidth tests to a 3rd machine and using a 3rd machine as the
arp_ip_target.

 

This has been tested using kernels 2.4.18, 2.4.24 & 2.4.32 on both server
and client. The hardware tested is a PC104 embedded board (Compulab 786
Base) with dual Intel 82559ER chips using the e100 driver. I have also tried
with also with a 3Com 3C905B-TX. The 3Com board has also been tested in an
ASRock K7S41GX motherboard with the same result.

 

Using Etherboot to load the kernel on the client but then mounting all
filesystems from a local disk works fine. The filesystem used to test this
was an identical copy of that being exported via NFS with the exception of
the fstab.

 

In my most recent tests there seems to be no problem running 2.6.17.1 on the
host and 2.6.12 on the client machines. I have had to upgrade modutils and
add module-init-tools to run a 2.6 kernel though so am in the process of
re-testing using 2.4 to ensure that the original problem still occurs after
these changes. Unfortunately each run of this test takes some time :-)

 

Anyone with any experience of this, or just any suggestions, would be much
appreciated.

 

Thanks

 

Alex


------=_NextPart_000_0043_01C699D9.EC97C480
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
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
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Hi,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>I&#8217;ve recently been trying to set up =
Ethernet bonding
for failover on a system which has a host NFS system from which thin =
clients
Etherboot. I am trying to set up the bonding on the thin client =
end.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Initially everything works ok. However if I =
run an
iperf server (&#8216;iperf &#8211;s&#8217;) at one end and then loop =
through
iperf bidirectional tests from the other (&#8216;for i in $(seq 1 =
10000); do echo
$i; iperf &#8211;c host &#8211;d; done&#8217;) the networking on the =
client
locks up after around 900 iterations (+- ~20). A similar result is =
achieved by
generating large amounts of traffic by continually sshing a file from =
one
machine to /dev/null on the other too, so it would seem that the problem =
is not
in the method of testing.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>The bonding is set up with the parameters =
&#8216;mode=3D1
arp_ip_target=3D192.168.0.1 arp_interval=3D100&#8217; where 192.168.0.1 =
is the IP
of the NFS/Etherboot host. While running the tests I have only been =
connecting
one of the Ethernet devices to simplify things. The same problem occurs =
with
both connected though. I have also tried connecting client and server =
directly
with a crossover to eliminate switching problems. I have also tried =
running the
bandwidth tests to a 3<sup>rd</sup> machine and using a 3<sup>rd</sup> =
machine
as the arp_ip_target.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>This has been tested using kernels 2.4.18, =
2.4.24
&amp; 2.4.32 on both server and client. The hardware tested is a PC104 =
embedded
board (Compulab 786 Base) with dual Intel 82559ER chips using the e100 =
driver.
I have also tried with also with a 3Com 3C905B-TX. The 3Com board has =
also been
tested in an ASRock K7S41GX motherboard with the same =
result.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Using Etherboot to load the kernel on the =
client but
then mounting all filesystems from a local disk works fine. The =
filesystem used
to test this was an identical copy of that being exported via NFS with =
the
exception of the fstab.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>In my most recent tests there seems to be no =
problem
running 2.6.17.1 on the host and 2.6.12 on the client machines. I have =
had to
upgrade modutils and add module-init-tools to run a 2.6 kernel though so =
am in
the process of re-testing using 2.4 to ensure that the original problem =
still
occurs after these changes. Unfortunately each run of this test takes =
some time
</span></font><font size=3D2 face=3DWingdings><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Wingdings'>J</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Anyone with any experience of this, or just =
any
suggestions, would be much appreciated.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Thanks</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Alex</span></font></p>

</div>

</body>

</html>

------=_NextPart_000_0043_01C699D9.EC97C480--



--===============1025308664==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1025308664==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1025308664==--
