From: "Nataraj" <ample@yukthi.com>
Subject: help
Date: Fri, 11 Oct 2002 16:08:06 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000b01c27112$5a4e5bf0$110b16ac@connoi>
Reply-To: "Nataraj" <ample@yukthi.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0006_01C27140.6250E6F0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.amplecomm.com ([216.15.9.70])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zxEn-0000Ph-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 03:41:45 -0700
Received: from connoi ([203.124.140.226])
	by mail.amplecomm.com (8.11.6/8.11.6) with SMTP id g9BAOo609679
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 03:24:50 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0006_01C27140.6250E6F0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

I have Redhat linux 7.2 and NFS V3 working on it. it puts too much load =
on network which slows down all network operations.
Also I am running NFS on Solaris 7. I just want to know the who is cause =
the problem.

both side NFS working on UDP.

  a.. the version of nfs-utils Iam  are using (nfs-utils-0.3.1-13.7.2.1)

  b.. the version of the kernel and any non-stock applied kernels. is =
(2.4.7-10)

  c.. the distribution of linux you are using (REDHAT )

  d.. the version(s) of other operating systems involved. ( Linux 7.2)

It is also useful to know the networking configuration connecting the =
hosts ( cat 5 with 10/100 switch network).

Linux NFS server.


  a.. the output of rpcinfo -p localhost run on the server out put is=20

program vers proto   port
100000    2   tcp    111  portmapper
100000    2   udp    111  portmapper
100024    1   udp  32768  status
100024    1   tcp  32768  status
100004    2   udp    624  ypserv
100004    1   udp    624  ypserv
100004    2   tcp    627  ypserv
100004    1   tcp    627  ypserv
100007    2   udp    644  ypbind
100007    1   udp    644  ypbind
100007    2   tcp    647  ypbind
100007    1   tcp    647  ypbind
100003    2   udp   2049  nfs
100003    3   udp   2049  nfs
100021    1   udp  32771  nlockmgr
100021    3   udp  32771  nlockmgr
100021    4   udp  32771  nlockmgr
100009    1   udp    830  yppasswdd
100011    1   udp    685  rquotad
100011    2   udp    685  rquotad
100011    1   tcp    688  rquotad
100011    2   tcp    688  rquotad
100005    1   udp  32774  mountd
100005    1   tcp  32770  mountd
100005    2   udp  32774  mountd
100005    2   tcp  32770  mountd
100005    3   udp  32774  mountd
100005    3   tcp  32770  mountd



for Solaris is

  a.. the output of rpcinfo -p localhost out put is

program vers proto   port
100000    4   tcp    111  portmapper
100000    3   tcp    111  portmapper
100000    2   tcp    111  portmapper
100000    4   udp    111  portmapper
100000    3   udp    111  portmapper
100000    2   udp    111  portmapper
100004    2   udp    728  ypserv
100004    1   udp    728  ypserv
100004    1   tcp    729  ypserv
100004    2   tcp  32771  ypserv
1073741824    2   udp  32772
100007    3   udp  32778  ypbind
100007    2   udp  32778  ypbind
100007    1   udp  32778  ypbind
100007    3   tcp  32772  ypbind
100007    2   tcp  32772  ypbind
100007    1   tcp  32772  ypbind
100024    1   udp  32783  status
100024    1   tcp  32773  status
100133    1   udp  32783
100133    1   tcp  32773
100021    1   udp   4045  nlockmgr
100021    2   udp   4045  nlockmgr
100021    3   udp   4045  nlockmgr
100021    4   udp   4045  nlockmgr
100232   10   udp  32785  sadmind
100011    1   udp  32786  rquotad
100002    2   udp  32787  rusersd
100002    3   udp  32787  rusersd
100002    2   tcp  32774  rusersd
100002    3   tcp  32774  rusersd
100012    1   udp  32788  sprayd
100008    1   udp  32789  walld
100001    2   udp  32790  rstatd
100001    3   udp  32790  rstatd
100001    4   udp  32790  rstatd
100083    1   tcp  32775
100221    1   tcp  32776
100235    1   tcp  32777
100068    2   udp  32791
100068    3   udp  32791
100068    4   udp  32791
100068    5   udp  32791
300326    4   tcp  32778
100021    1   tcp   4045  nlockmgr
100021    2   tcp   4045  nlockmgr
100021    3   tcp   4045  nlockmgr
100021    4   tcp   4045  nlockmgr
100005    1   udp  32803  mountd
100005    2   udp  32803  mountd
100005    3   udp  32803  mountd
100005    1   tcp  32779  mountd
100005    2   tcp  32779  mountd
100005    3   tcp  32779  mountd
100003    2   udp   2049  nfs
100003    3   udp   2049  nfs
100227    2   udp   2049  nfs_acl
100227    3   udp   2049  nfs_acl
100003    2   tcp   2049  nfs
100003    3   tcp   2049  nfs
100227    2   tcp   2049  nfs_acl
100227    3   tcp   2049  nfs_acl
300598    1   udp  32805
300598    1   tcp  32781
805306368    1   udp  32805
805306368    1   tcp  32781
100249    1   udp  32807
100249    1   tcp  32782
1289637087    4   tcp  32859
1289637087    1   tcp  32859
1289637087    3   tcp  32859
1289637087    2   tcp  32859
1289637086    4   tcp  35213
1289637086    1   tcp  35213
1289637086    3   tcp  35213
1289637086    2   tcp  35213

Help on this will be greatful

Thanks=20

Yukthi




------=_NextPart_000_0006_01C27140.6250E6F0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.3315.2870" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I have Redhat linux 7.2 and NFS V3 =
working on it.=20
it puts too much load on network which slows down all network=20
operations.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Also I am running NFS on Solaris 7. I =
just want to=20
know the who is cause the problem.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>both side NFS working on =
UDP.</FONT></DIV>
<DIV>&nbsp;</DIV>
<UL>
  <LI>
  <P><FONT face=3DArial size=3D2>the version of <SPAN=20
  class=3DAPPLICATION>nfs-utils</SPAN> Iam&nbsp; are using=20
  (nfs-utils-0.3.1-13.7.2.1)</FONT></P>
  <LI>
  <P><FONT face=3DArial size=3D2>the version of the kernel and any =
non-stock applied=20
  kernels. is (2.4.7-10)</FONT></P>
  <LI>
  <P><FONT face=3DArial size=3D2>the distribution of linux you are using =
(REDHAT=20
  )</FONT></P>
  <LI>
  <P><FONT face=3DArial size=3D2>the version(s) of other operating =
systems involved.=20
  ( Linux 7.2)</FONT></P></LI></UL>
<P><FONT face=3DArial size=3D2>It is also useful to know the networking=20
configuration connecting the hosts ( cat 5 with 10/100 switch=20
network).</FONT></P>
<P><FONT face=3DArial size=3D2>Linux NFS server.</FONT></P>
<P></P>
<UL>
  <LI>
  <P><FONT face=3DArial size=3D2>the output of <B =
class=3DCOMMAND>rpcinfo -p</B>=20
  <EM>localhost</EM> run on the server&nbsp;out put is =
</FONT></P></LI></UL>
<P><FONT face=3DArial size=3D2>program vers proto&nbsp;&nbsp;=20
port<BR>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; =
111&nbsp;=20
portmapper<BR>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; =
udp&nbsp;&nbsp;&nbsp;=20
111&nbsp; portmapper<BR>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; =

32768&nbsp; status<BR>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32768&nbsp; status<BR>100004&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;=20
udp&nbsp;&nbsp;&nbsp; 624&nbsp; ypserv<BR>100004&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;=20
udp&nbsp;&nbsp;&nbsp; 624&nbsp; ypserv<BR>100004&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 627&nbsp; ypserv<BR>100004&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 627&nbsp; ypserv<BR>100007&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;=20
udp&nbsp;&nbsp;&nbsp; 644&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;=20
udp&nbsp;&nbsp;&nbsp; 644&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 647&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 647&nbsp; ypbind<BR>100003&nbsp;&nbsp;&nbsp; =
2&nbsp;&nbsp;=20
udp&nbsp;&nbsp; 2049&nbsp; nfs<BR>100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; =

udp&nbsp;&nbsp; 2049&nbsp; nfs<BR>100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; =

udp&nbsp; 32771&nbsp; nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; =

udp&nbsp; 32771&nbsp; nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; =

udp&nbsp; 32771&nbsp; nlockmgr<BR>100009&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; =

udp&nbsp;&nbsp;&nbsp; 830&nbsp; yppasswdd<BR>100011&nbsp;&nbsp;&nbsp;=20
1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 685&nbsp;=20
rquotad<BR>100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp;=20
685&nbsp; rquotad<BR>100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 688&nbsp; rquotad<BR>100011&nbsp;&nbsp;&nbsp;=20
2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 688&nbsp;=20
rquotad<BR>100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32774&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 32770&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp; 32774&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp; 32770&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 32774&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 32770&nbsp;=20
mountd</FONT></P>
<P>&nbsp;</P>
<P><FONT face=3DArial size=3D2>for Solaris is</FONT></P>
<UL>
  <LI>
  <P><FONT size=3D2><FONT face=3DArial>the output of <B =
class=3DCOMMAND>rpcinfo -p</B>=20
  <EM>localhost out put is</EM></FONT></FONT></P></LI></UL>
<P><FONT face=3DArial size=3D2><EM>program vers proto&nbsp;&nbsp;=20
port<BR>100000&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; =
111&nbsp;=20
portmapper<BR>100000&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; =
tcp&nbsp;&nbsp;&nbsp;=20
111&nbsp; portmapper<BR>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;=20
tcp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper<BR>100000&nbsp;&nbsp;&nbsp;=20
4&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 111&nbsp;=20
portmapper<BR>100000&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; =
udp&nbsp;&nbsp;&nbsp;=20
111&nbsp; portmapper<BR>100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;=20
udp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper<BR>100004&nbsp;&nbsp;&nbsp;=20
2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 728&nbsp; =
ypserv<BR>100004&nbsp;&nbsp;&nbsp;=20
1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 728&nbsp; =
ypserv<BR>100004&nbsp;&nbsp;&nbsp;=20
1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 729&nbsp; =
ypserv<BR>100004&nbsp;&nbsp;&nbsp;=20
2&nbsp;&nbsp; tcp&nbsp; 32771&nbsp; =
ypserv<BR>1073741824&nbsp;&nbsp;&nbsp;=20
2&nbsp;&nbsp; udp&nbsp; 32772<BR>100007&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;=20
udp&nbsp; 32778&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; =
udp&nbsp;=20
32778&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32778&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;=20
32772&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;=20
32772&nbsp; ypbind<BR>100007&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32772&nbsp; ypbind<BR>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32783&nbsp; status<BR>100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32773&nbsp; status<BR>100133&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32783<BR>100133&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32773<BR>100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100232&nbsp;&nbsp; 10&nbsp;&nbsp; udp&nbsp; 32785&nbsp;=20
sadmind<BR>100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32786&nbsp;=20
rquotad<BR>100002&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp; 32787&nbsp;=20
rusersd<BR>100002&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 32787&nbsp;=20
rusersd<BR>100002&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp; 32774&nbsp;=20
rusersd<BR>100002&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 32774&nbsp;=20
rusersd<BR>100012&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32788&nbsp;=20
sprayd<BR>100008&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32789&nbsp;=20
walld<BR>100001&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp; 32790&nbsp;=20
rstatd<BR>100001&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 32790&nbsp;=20
rstatd<BR>100001&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp; 32790&nbsp;=20
rstatd<BR>100083&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32775<BR>100221&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32776<BR>100235&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32777<BR>100068&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;=20
32791<BR>100068&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;=20
32791<BR>100068&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp;=20
32791<BR>100068&nbsp;&nbsp;&nbsp; 5&nbsp;&nbsp; udp&nbsp;=20
32791<BR>300326&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;=20
32778<BR>100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;&nbsp; =
4045&nbsp;=20
nlockmgr<BR>100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32803&nbsp; =

mountd<BR>100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp; 32803&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 32803&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 32779&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp; 32779&nbsp;=20
mountd<BR>100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 32779&nbsp;=20
mountd<BR>100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; =
2049&nbsp;=20
nfs<BR>100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =

nfs<BR>100227&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =

nfs_acl<BR>100227&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; =
2049&nbsp;=20
nfs_acl<BR>100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; =
2049&nbsp;=20
nfs<BR>100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =

nfs<BR>100227&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =

nfs_acl<BR>100227&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; =
2049&nbsp;=20
nfs_acl<BR>300598&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32805<BR>300598&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32781<BR>805306368&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32805<BR>805306368&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32781<BR>100249&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;=20
32807<BR>100249&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32782<BR>1289637087&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;=20
32859<BR>1289637087&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
32859<BR>1289637087&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;=20
32859<BR>1289637087&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;=20
32859<BR>1289637086&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;=20
35213<BR>1289637086&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;=20
35213<BR>1289637086&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;=20
35213<BR>1289637086&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;=20
35213</EM></FONT></P>
<P><FONT face=3DArial size=3D2>Help on this will be greatful</FONT></P>
<P><FONT face=3DArial size=3D2>Thanks </FONT></P>
<P><FONT face=3DArial size=3D2>Yukthi</FONT></P>
<P>&nbsp;</P></BODY></HTML>

------=_NextPart_000_0006_01C27140.6250E6F0--




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
