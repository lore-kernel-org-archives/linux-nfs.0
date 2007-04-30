From: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Subject: Rpc.mountd growing 6 MB/day
Date: Mon, 30 Apr 2007 10:41:07 -0700
Message-ID: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0317008836=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiZs8-0008Ql-P8
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 10:41:13 -0700
Received: from mail.windriver.com ([147.11.1.11] helo=mail.wrs.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiZsB-0000gJ-3R
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 10:41:15 -0700
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id l3UHf9QG010864
	for <nfs@lists.sourceforge.net>; Mon, 30 Apr 2007 10:41:09 -0700 (PDT)
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

--===============0317008836==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C78B4E.BBE16FF0"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C78B4E.BBE16FF0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I have a situation where rpc.mountd is growing continuously and I am not
sure if it's a memory leak or expected behavior that can be controlled
with some configuration option.
=20
Top is used to watch rpc.mountd over time and I can see Virtual size
continually growing. In this environment there is no swap space so RSS
is growing also. When RSS gets close to Virtual size,  Virtual size
jumps up by 128K until RSS again "catches up" to VIRTUAL which then
jumps up by 128K again:
=20
=20
                              VIRT  RES
9951 root      16   0  1812 1052  668 S  0.0  0.0   0:20.07 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  1812 1052  668 S  0.0  0.0   0:20.19 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      15   0  1812 1052  668 S  0.0  0.0   0:20.44 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      15   0  1940 1056  668 S  0.0  0.0   0:20.57 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  1940 1056  668 S  0.0  0.0   0:20.69 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  1940 1056  668 S  0.0  0.0   0:20.70 rpc.mountd
--nfs-version 2 --nfs-version 3
=20
RES keeps incrementing every so often and eventually:
=20
                               VIRT RES
 9951 root      16   0  1940 1180  668 S  0.0  0.0   0:38.85 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  1940 1180  668 S  0.0  0.0   0:38.99 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  2068 1184  668 S  0.0  0.0   0:39.14 rpc.mountd
--nfs-version 2 --nfs-version 3
 9951 root      16   0  2068 1184  668 S  0.0  0.0   0:39.33 rpc.mountd
--nfs-version 2 --nfs-version 3
=20
This pattern continues.
=20
I added some xlog() statements in rpc.mountd to try and show me if there
were some malloc's without free's. I didn't see anything, but here are
the routines that seemed to get called frequently:
=20
Apr 26 18:55:13 unit0 mountd[24268]: auth_unix_ip client alloced
0x80695e0
Apr 26 18:55:13 unit0 mountd[24268]: auth_unix_ip client freed 0x80695e0
Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export alocated dom 0x80695e0=20
Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export alocated path 0x80695f0

Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export : free dom 0x80695e0
Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export : free path 0x80695f0
Apr 26 18:55:13 unit0 mountd[24268]: nfsd_fh : dom allocated 0x8069600
Apr 26 18:55:13 unit0 mountd[24268]: nfsd_fh : freed dom 0x8069600
Apr 26 19:10:33 unit0 mountd[24268]: auth_unix_ip client alloced
0x8069618
Apr 26 19:10:33 unit0 mountd[24268]: auth_unix_ip client freed 0x8069618
Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export alocated dom 0x8069618=20
Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export alocated path 0x8069628

Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export : free dom 0x8069618
Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export : free path 0x8069628
Apr 26 19:10:33 unit0 mountd[24268]: nfsd_fh : dom allocated 0x8069638
Apr 26 19:10:33 unit0 mountd[24268]: nfsd_fh : freed dom 0x8069638
=20
It seems to be these three routines that get called over and over, at
least so far that I have added xlog()'s to. These seem to be making some
interactions with the kernel nfsd via /proc, but I am not real sure how
that would impact rpc.mountd's virtual size.
=20
I am using the kernel NFSD, the kernel version is 2.6.10, the nfs-utils
version is nfs-utils-1.0.7
=20
I don't know if this growth is expected or if it will eventually stop,
over a period of days it has not stopped growing, and if there may be
some configuration option that can control it.
=20
Has anyone seen this behavior before ?
=20
Is it expected and controllable or is there a memory leak here ?
=20
Thanks
=20
Chris Kottaridis
Senior Engineer
Wind River Systems
719-522-9786
=20

------_=_NextPart_001_01C78B4E.BBE16FF0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.3059" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D709182317-30042007>I have =
a situation=20
where rpc.mountd is growing continuously and I am not sure if it's a =
memory leak=20
or expected behavior that can be controlled with some configuration=20
option.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D709182317-30042007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D709182317-30042007>Top is =
used&nbsp;to=20
watch rpc.mountd over time and I can see Virtual size continually =
growing. In=20
this environment there is no swap space so RSS is growing also. When RSS =
gets=20
close to Virtual size, &nbsp;Virtual size jumps up by 128K until RSS =
again=20
"catches up" to VIRTUAL which then jumps up by 128K =
again:</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D709182317-30042007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT><SPAN class=3D709182317-30042007>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =

size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
VIRT&nbsp; RES</FONT></SPAN></DIV>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =
size=3D2>9951=20
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 16&nbsp;&nbsp; 0&nbsp; 1812 =
1052&nbsp; 668=20
S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:20.07 rpc.mountd --nfs-version 2=20
--nfs-version 3<BR>&nbsp;9951 root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
16&nbsp;&nbsp;=20
0&nbsp; 1812 1052&nbsp; 668 S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:20.19 =
rpc.mountd=20
--nfs-version 2 --nfs-version 3<BR>&nbsp;9951 =
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
15&nbsp;&nbsp; 0&nbsp; 1812 1052&nbsp; 668 S&nbsp; 0.0&nbsp; =
0.0&nbsp;&nbsp;=20
0:20.44 rpc.mountd --nfs-version 2 --nfs-version 3<BR>&nbsp;9951=20
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 15&nbsp;&nbsp; 0&nbsp; 1940 =
1056&nbsp; 668=20
S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:20.57 rpc.mountd --nfs-version 2=20
--nfs-version 3<BR>&nbsp;9951 root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
16&nbsp;&nbsp;=20
0&nbsp; 1940 1056&nbsp; 668 S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:20.69 =
rpc.mountd=20
--nfs-version 2 --nfs-version 3<BR>&nbsp;9951 =
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
16&nbsp;&nbsp; 0&nbsp; 1940 1056&nbsp; 668 S&nbsp; 0.0&nbsp; =
0.0&nbsp;&nbsp;=20
0:20.70 rpc.mountd --nfs-version 2 --nfs-version 3</FONT></SPAN></DIV>
<DIV><SPAN class=3D131503419-27042007><SPAN =
class=3D709182317-30042007><FONT=20
face=3DArial color=3D#0000ff size=3D2></FONT></SPAN></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D131503419-27042007><SPAN =
class=3D709182317-30042007><FONT=20
face=3DArial color=3D#0000ff size=3D2>RES keeps incrementing every so =
often and=20
eventually:</FONT></SPAN></SPAN></DIV>
<DIV><SPAN class=3D131503419-27042007><SPAN class=3D709182317-30042007>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =

size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
VIRT RES</FONT></SPAN></DIV>
<DIV><SPAN class=3D131503419-27042007><FONT face=3DArial color=3D#0000ff =

size=3D2>&nbsp;9951 root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 16&nbsp;&nbsp; =
0&nbsp; 1940=20
1180&nbsp; 668 S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:38.85 rpc.mountd=20
--nfs-version 2 --nfs-version 3<BR>&nbsp;9951 =
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
16&nbsp;&nbsp; 0&nbsp; 1940 1180&nbsp; 668 S&nbsp; 0.0&nbsp; =
0.0&nbsp;&nbsp;=20
0:38.99 rpc.mountd --nfs-version 2 --nfs-version 3<BR>&nbsp;9951=20
root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 16&nbsp;&nbsp; 0&nbsp; 2068 =
1184&nbsp; 668=20
S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:39.14 rpc.mountd --nfs-version 2=20
--nfs-version 3<BR>&nbsp;9951 root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
16&nbsp;&nbsp;=20
0&nbsp; 2068 1184&nbsp; 668 S&nbsp; 0.0&nbsp; 0.0&nbsp;&nbsp; 0:39.33 =
rpc.mountd=20
--nfs-version 2 --nfs-version=20
3</FONT></SPAN></DIV></SPAN></SPAN></DIV></SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>This =
pattern=20
continues.</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>I =
added some xlog()=20
statements in rpc.mountd to try and show me if there were some malloc's =
without=20
free's. I didn't see anything, but here are the routines that seemed to =
get=20
called frequently:</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>Apr 26 =
18:55:13=20
unit0 mountd[24268]: auth_unix_ip client alloced 0x80695e0<BR>Apr 26 =
18:55:13=20
unit0 mountd[24268]: auth_unix_ip client freed 0x80695e0<BR>Apr 26 =
18:55:13=20
unit0 mountd[24268]: nfsd_export alocated dom 0x80695e0 <BR>Apr 26 =
18:55:13=20
unit0 mountd[24268]: nfsd_export alocated path 0x80695f0 <BR>Apr 26 =
18:55:13=20
unit0 mountd[24268]: nfsd_export : free dom 0x80695e0<BR>Apr 26 18:55:13 =
unit0=20
mountd[24268]: nfsd_export : free path 0x80695f0<BR>Apr 26 18:55:13 =
unit0=20
mountd[24268]: nfsd_fh : dom allocated 0x8069600<BR>Apr 26 18:55:13 =
unit0=20
mountd[24268]: nfsd_fh : freed dom 0x8069600<BR>Apr 26 19:10:33 unit0=20
mountd[24268]: auth_unix_ip client alloced 0x8069618<BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: auth_unix_ip client freed 0x8069618<BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: nfsd_export alocated dom 0x8069618 <BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: nfsd_export alocated path 0x8069628 <BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: nfsd_export : free dom 0x8069618<BR>Apr 26 19:10:33 unit0 =

mountd[24268]: nfsd_export : free path 0x8069628<BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: nfsd_fh : dom allocated 0x8069638<BR>Apr 26 19:10:33 =
unit0=20
mountd[24268]: nfsd_fh : freed dom 0x8069638</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>It =
seems to be these=20
three routines that get called over and over, at least so far that I =
have added=20
xlog()'s to. These seem to be making some interactions with the kernel =
nfsd via=20
/proc, but I am not real sure how that would impact rpc.mountd's virtual =

size.</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>I am =
using the=20
kernel NFSD, the kernel version is 2.6.10, the nfs-utils version=20
is&nbsp;nfs-utils-1.0.7</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>I =
don't know if this=20
growth is expected or if it will eventually stop, over a period of days =
it has=20
not stopped growing, and if there may be some configuration option that =
can=20
control it.</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>Has =
anyone seen this=20
behavior before ?</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial size=3D2>Is it =
expected and=20
controllable or is there a memory leak here ?</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2>Thanks</FONT></SPAN></DIV>
<DIV><SPAN class=3D709182317-30042007><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>Chris =
Kottaridis</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial =
size=3D2>Senior&nbsp;Engineer</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>Wind River =
Systems</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>719-522-9786</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2><SPAN =
class=3D971590420-14032006><FONT=20
face=3DArial size=3D2></FONT></SPAN></FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C78B4E.BBE16FF0--


--===============0317008836==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0317008836==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0317008836==--
