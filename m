From: "Dave Frost" <Dave.Frost@Project-Network.com>
Subject: rpc timeout problems
Date: Fri, 16 Sep 2005 14:45:20 +0100
Message-ID: <9EFC04356BBC4745B67A41B106F4A47A271C43@TPN-EX01.PROJECT-NETWORK.COM>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5BAC4.D3A05AEE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EGGXB-0004R6-Kx
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 06:45:45 -0700
Received: from mail.project-network.com ([217.144.149.34] helo=TPN-EX01.PROJECT-NETWORK.COM)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EGGX8-0006kA-6m
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 06:45:45 -0700
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

------_=_NextPart_001_01C5BAC4.D3A05AEE
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi there all, im having a few problems getting nfs to share a directory.
Her is some background.

=20

Rpcinfo on the server reports.

[root@oraclesvr01 ~]# rpcinfo -p

   program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100024    1   udp   1024  status

    100024    1   tcp  32770  status

    100011    1   udp    659  rquotad

    100011    2   udp    659  rquotad

    100011    1   tcp    662  rquotad

    100011    2   tcp    662  rquotad

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100003    4   udp   2049  nfs

    100003    2   tcp   2049  nfs

    100003    3   tcp   2049  nfs

    100003    4   tcp   2049  nfs

    100021    1   udp   1026  nlockmgr

    100021    3   udp   1026  nlockmgr

    100021    4   udp   1026  nlockmgr

    100021    1   tcp  32771  nlockmgr

    100021    3   tcp  32771  nlockmgr

    100021    4   tcp  32771  nlockmgr

    100005    1   udp    675  mountd

    100005    1   tcp    678  mountd

    100005    2   udp    675  mountd

    100005    2   tcp    678  mountd

    100005    3   udp    675  mountd

    100005    3   tcp    678  mountd

=20

Rpcinfo, from the client to the server reports

=20

rpcinfo -p 192.168.102.2

   program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100024    1   udp   1024  status

    100024    1   tcp  32770  status

    100011    1   udp    659  rquotad

    100011    2   udp    659  rquotad

    100011    1   tcp    662  rquotad

    100011    2   tcp    662  rquotad

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100003    4   udp   2049  nfs

    100003    2   tcp   2049  nfs

    100003    3   tcp   2049  nfs

    100003    4   tcp   2049  nfs

    100021    1   udp   1026  nlockmgr

    100021    3   udp   1026  nlockmgr

    100021    4   udp   1026  nlockmgr

    100021    1   tcp  32771  nlockmgr

    100021    3   tcp  32771  nlockmgr

    100021    4   tcp  32771  nlockmgr

    100005    1   udp    675  mountd

    100005    1   tcp    678  mountd

    100005    2   udp    675  mountd

    100005    2   tcp    678  mountd

    100005    3   udp    675  mountd

    100005    3   tcp    678  mountd

=20

The /etc/exports file seems ok, as I get

[root@oraclesvr01 ~]# cat /proc/fs/nfsd/exports

# Version 1.1

# Path Client(Flags) # IPs

/nfs_test       192.168.102.3(rw,no_root_squash,sync,wdelay)

=20

Ip addresses etc are ok.

=20

Iptables etc is definatelyt down (these boxes are already behind 2
firewalls so its ok)=20

=20

[root@oraclesvr01 ~]# chkconfig iptables --list

iptables        0:off   1:off   2:off   3:off   4:off   5:off   6:off

=20

this is the sdame for the client as well.

=20

This is on redhat enterprise version 4,=20

[root@oraclesvr01 ~]# uname -r

2.6.9-5.ELsmp

=20

When I try and mount the nfs dir that has been configured this happens=20

=20

[root@oraclesvr02 ~]# mount -t nfs 192.168.102.2:/nfs_test rmt/

mount: RPC: Timed out

=20

Any help is very much appreciated.

=20

Thanks

=20

Dave

=20


------_=_NextPart_001_01C5BAC4.D3A05AEE
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
	{mso-style-type:personal-compose;
	font-family:Arial;
	color:windowtext;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-GB link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Hi there all, im having a few problems getting nfs to =
share
a directory.&nbsp; Her is some background.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Rpcinfo on the server =
reports.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@oraclesvr01 ~]# rpcinfo =
-p<o:p></o:p></span></font></p>

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
udp&nbsp;&nbsp; 1024&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100024&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 32770&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 659&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 659&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 662&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 662&nbsp; rquotad<o:p></o:p></span></font></p>

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
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp; 1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp; &nbsp;&nbsp;100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp;&nbsp; 1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp;&nbsp; 1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Rpcinfo, from the client to the server =
reports<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>rpcinfo -p 192.168.102.2<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp; program vers proto&nbsp;&nbsp; =
port<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; 2&nbsp; =
&nbsp;tcp&nbsp;&nbsp;&nbsp;
111&nbsp; portmapper<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100024&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp; 1024&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100024&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 32770&nbsp; status<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 659&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 659&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 662&nbsp; rquotad<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp; &nbsp;100011&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 662&nbsp; rquotad<o:p></o:p></span></font></p>

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
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
tcp&nbsp;&nbsp; 2049&nbsp; nfs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; 1&nbsp; =
&nbsp;udp&nbsp;&nbsp;
1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp;&nbsp; 1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
udp&nbsp;&nbsp; 1026&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; =
4&nbsp;&nbsp;
tcp&nbsp; 32771&nbsp; nlockmgr<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 675&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; =
3&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 678&nbsp; mountd<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>The /etc/exports file seems ok, as I =
get<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@oraclesvr01 ~]# cat =
/proc/fs/nfsd/exports<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'># Version 1.1<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'># Path Client(Flags) # =
IPs<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>/nfs_test&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
192.168.102.3(rw,no_root_squash,sync,wdelay)<o:p></o:p></span></font></p>=


<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Ip addresses etc are ok.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Iptables etc is definatelyt down (these boxes are =
already
behind 2 firewalls so its ok)</span></font> <o:p></o:p></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@oraclesvr01 ~]# chkconfig iptables =
--list<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>iptables&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0:off&nbsp;&nbsp; 1:off&nbsp;&nbsp; 2:off&nbsp;&nbsp; 3:off&nbsp;&nbsp;
4:off&nbsp;&nbsp; 5:off&nbsp;&nbsp; 6:off<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>this is the sdame for the client as =
well.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>This is on redhat enterprise version 4, =
<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@oraclesvr01 ~]# uname =
-r<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>2.6.9-5.ELsmp<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>When I try and mount the nfs dir that has been =
configured
this happens <o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>[root@oraclesvr02 ~]# mount -t nfs =
192.168.102.2:/nfs_test
rmt/<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>mount: RPC: Timed out<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Any help is very much =
appreciated.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Dave<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C5BAC4.D3A05AEE--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
