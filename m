From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: NFS - Solaris Server/Linux Clients
Date: Fri, 31 May 2002 12:14:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <006c01c208c6$96b36040$66f1a186@OREILLY>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="----=_NextPart_000_0069_01C2089C.ADCC8F60"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from viper.uni.edu ([134.161.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Dpzk-0005Ou-00
	for <nfs@lists.sourceforge.net>; Fri, 31 May 2002 10:15:21 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #39731)
 with SMTP id <01KIDLAUFBCG8Y4Z9X@uni.edu> for nfs@lists.sourceforge.net; Fri,
 31 May 2002 12:15:11 -0500 (CDT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0069_01C2089C.ADCC8F60
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

I have a Sun Ultra-10 running Solaris 8 with current patches as a NFS
server, with 3 identical clients, and 25 Redhat Linux 7.1 clients.  The =
filesystem
mounts and 'stays' fine on the other Sun machines, but the Linux boxes =
mount
is flaky.  On the Linux boxes, it mounts fine on boot, and the data is =
there
and accessible.  After a short time, the data is "gone", while the mount =
is
still apparently there.  Results from 2 "df -k" commands on a Linux box:

[root@xxxxxxx weather]# df
Filesystem 1k-blocks Used Available Use% Mounted on
/dev/hdb6 25205252 10785776 13139100 46% /
/dev/hdb7 13108468 1179272 11263304 10% /usr
xxxxxxx.xxxxx.uni.edu:/space
                12899648 4451328 8319328 35% /mnt/gemdata

5 minutes later.......

[root@xxxxxxx ~]$ df
Filesystem 1k-blocks Used Available Use% Mounted on
/dev/hdb6 25205252 10785760 13139116 46% /
/dev/hdb7 13108468 1179272 11263304 10% /usr
xxxxxxx.xxxx.uni.edu:/space
                0 1 0 0% /mnt/gemdata

As you can see, the mount persists but the data is 'gone'.  My mount =
command
from /etc/dfs/dfstab on the Sun NFS server is shared with "everyone."  =
Additionally, on the linux
boxes, I see these messages in /var/log/messages:

johnstown kernel: nfs_statfs: statfs error =3D 13
johnstown kernel: call_verify: server requires stronger authentication.

Any idea what I may do to keep the NFS mount persistent on my Redhat 7.1
Linux boxes?

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Patrick O'Reilly                               Support Scientist
The STORM Project            patrick.oreilly@uni.edu
208 Latham Hall                             ph: 319-273-3789
University of Northern Iowa
Cedar Falls, IA 50614            =20
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  =20


------=_NextPart_000_0069_01C2089C.ADCC8F60
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2600.0" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#efefef>
<DIV><FONT face=3D"MS Sans Serif" size=3D2>Hello,</FONT></DIV>
<DIV><FONT face=3D"MS Sans Serif" size=3D2></FONT>&nbsp;</DIV>
<DIV>I have a Sun Ultra-10 running Solaris 8 with current patches as a=20
NFS<BR>server, with 3 identical clients, and 25 Redhat Linux 7.1 =
clients.&nbsp;=20
The filesystem<BR>mounts and 'stays' fine on the other Sun machines, but =
the=20
Linux boxes mount<BR>is flaky.&nbsp; On the Linux boxes, it mounts fine =
on boot,=20
and the data is there<BR>and accessible.&nbsp; After a short time, the =
data is=20
"gone", while the mount is<BR>still apparently there.&nbsp; Results from =
2 "df=20
-k" commands on a Linux box:<BR><BR>[root@xxxxxxx weather]# =
df<BR>Filesystem=20
1k-blocks Used Available Use% Mounted on<BR>/dev/hdb6 25205252 10785776 =
13139100=20
46% /<BR>/dev/hdb7 13108468 1179272 11263304 10%=20
/usr<BR>xxxxxxx.xxxxx.uni.edu:/space<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
12899648 4451328 8319328 35% /mnt/gemdata<BR><BR>5 minutes=20
later.......<BR><BR>[root@xxxxxxx ~]$ df<BR>Filesystem 1k-blocks Used =
Available=20
Use% Mounted on<BR>/dev/hdb6 25205252 10785760 13139116 46% =
/<BR>/dev/hdb7=20
13108468 1179272 11263304 10%=20
/usr<BR>xxxxxxx.xxxx.uni.edu:/space<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0 1 0 0% /mnt/gemdata<BR><BR>As you can see, the mount persists but the =
data is=20
'gone'.&nbsp; My mount command<BR>from /etc/dfs/dfstab on the Sun NFS =
server is=20
shared with "everyone."&nbsp; Additionally, on the linux<BR>boxes, I see =
these=20
messages in /var/log/messages:<BR><BR>johnstown kernel: nfs_statfs: =
statfs error=20
=3D 13<BR>johnstown kernel: call_verify: server requires stronger=20
authentication.<BR><BR>Any idea what I may do to keep the NFS mount =
persistent=20
on my Redhat 7.1<BR>Linux boxes?</DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3D"MS Sans Serif"=20
size=3D2>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<BR>Patrick=20
O'Reilly&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
Support Scientist<BR>The STORM=20
Project&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 <A=20
href=3D"mailto:patrick.oreilly@uni.edu">patrick.oreilly@uni.edu</A><BR>20=
8 Latham=20
Hall&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;=20
ph: 319-273-3789<BR>University of Northern Iowa<BR>Cedar Falls, IA=20
50614&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;=20
<BR>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&nbsp;&nbsp;=20
<BR></FONT></DIV></BODY></HTML>

------=_NextPart_000_0069_01C2089C.ADCC8F60--


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
