From: "Matt Heaton" <admin@0catch.com>
Subject: Kernel bug problem.
Date: Mon, 6 Oct 2003 23:13:57 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <04c801c38c91$d020c160$6401a8c0@Matt>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_04C5_01C38C5F.850A6AA0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A6kAb-00073u-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Oct 2003 22:14:01 -0700
Received: from [216.190.237.135] (helo=cvs.0catch.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.22)
	id 1A6kAZ-0004BR-N9
	for nfs@lists.sourceforge.net; Mon, 06 Oct 2003 22:13:59 -0700
Received: from Matt (12-255-25-93.client.attbi.com [12.255.25.93])
	by cvs.0catch.com (8.12.8/8.12.8) with SMTP id h975DxFt019854
	for <nfs@lists.sourceforge.net>; Mon, 6 Oct 2003 23:13:59 -0600
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_04C5_01C38C5F.850A6AA0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Howdy all, I am running Redhat 8.0 with a customer 2.4.20 kernel, with a =
3ware 7500-8 controller formatted using the XFS Filesystem.
My Raid array (Raid 1+0) (8 Drives total) is 720 Gigs. =20

I keep getting the following kernel bug.

Oct  4 06:29:18 catchusers2 kernel: kernel BUG at ll_rw_blk.c:1192!
Oct  4 06:29:18 catchusers2 kernel: invalid operand: 0000
Oct  4 06:29:18 catchusers2 kernel: CPU:    0
Oct  4 06:29:18 catchusers2 kernel: EIP:    0010:[<c024b027>]    Not =
tainted
Oct  4 06:29:18 catchusers2 kernel: EFLAGS: 00010206
Oct  4 06:29:18 catchusers2 kernel: eax: 00000410   ebx: 00000008   ecx: =
d9ec12a0   edx: d9ec12a0
Oct  4 06:29:18 catchusers2 kernel: esi: 00000001   edi: d9ec12a0   ebp: =
c2229360   esp: f7bfdefc
Oct  4 06:29:18 catchusers2 kernel: ds: 0018   es: 0018   ss: 0018
Oct  4 06:29:18 catchusers2 kernel: Process kswapd (pid: 4, =
stackpage=3Df7bfd000)
Oct  4 06:29:18 catchusers2 kernel: Stack: d9ec12a0 00000001 d9ec12a0 =
00000001 c0145a10 00000001 d9ec12a0 d9ec12a0=20
Oct  4 06:29:18 catchusers2 kernel:        c2229360 d9ec12a0 c0145b60 =
d9ec12a0 00000000 c2229360 0000968e c03af668=20
Oct  4 06:29:18 catchusers2 kernel:        c0137c71 c2229360 000001d0 =
f7bfc000 00000200 000001d0 00000015 00000020=20
Oct  4 06:29:18 catchusers2 kernel: Call Trace:    [<c0145a10>] =
[<c0145b60>] [<c0137c71>] [<c0137eb3>] [<c0137f26>]
Oct  4 06:29:18 catchusers2 kernel:   [<c013803c>] [<c01380b8>] =
[<c01381ed>] [<c0105000>] [<c010747e>] [<c0138150>]
Oct  4 06:29:18 catchusers2 kernel:=20
Oct  4 06:29:18 catchusers2 kernel: Code: 0f 0b a8 04 99 ff 36 c0 b8 03 =
00 00 00 f0 0f ab 42 18 b8 08


I am wondering if this is NFS related?  I only have about 50 gigs free =
on the raid array now.  Whenever I get down to about 25 gigs I get
this kernel bug?   It is killing me.  If I keep it above 50 gigs free =
then this NEVER happens?  Any ideas?  I would be VERY grateful.

Thanks,
Matt

------=_NextPart_000_04C5_01C38C5F.850A6AA0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1264" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Howdy all, I am running Redhat 8.0 with =
a customer=20
2.4.20 kernel, with a 3ware 7500-8 controller formatted using the XFS=20
Filesystem.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>My Raid array (Raid 1+0) (8 Drives =
total) is 720=20
Gigs.&nbsp; </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I keep getting the following kernel=20
bug.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Oct&nbsp; 4 06:29:18 catchusers2 =
kernel: kernel BUG=20
at ll_rw_blk.c:1192!<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: invalid =

operand: 0000<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: =
CPU:&nbsp;&nbsp;&nbsp;=20
0<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: EIP:&nbsp;&nbsp;&nbsp;=20
0010:[&lt;c024b027&gt;]&nbsp;&nbsp;&nbsp; Not tainted<BR>Oct&nbsp; 4 =
06:29:18=20
catchusers2 kernel: EFLAGS: 00010206<BR>Oct&nbsp; 4 06:29:18 catchusers2 =
kernel:=20
eax: 00000410&nbsp;&nbsp; ebx: 00000008&nbsp;&nbsp; ecx: =
d9ec12a0&nbsp;&nbsp;=20
edx: d9ec12a0<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: esi:=20
00000001&nbsp;&nbsp; edi: d9ec12a0&nbsp;&nbsp; ebp: c2229360&nbsp;&nbsp; =
esp:=20
f7bfdefc<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: ds: =
0018&nbsp;&nbsp; es:=20
0018&nbsp;&nbsp; ss: 0018<BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: =
Process=20
kswapd (pid: 4, stackpage=3Df7bfd000)<BR>Oct&nbsp; 4 06:29:18 =
catchusers2 kernel:=20
Stack: d9ec12a0 00000001 d9ec12a0 00000001 c0145a10 00000001 d9ec12a0 =
d9ec12a0=20
<BR>Oct&nbsp; 4 06:29:18 catchusers2=20
kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; c2229360 d9ec12a0 =
c0145b60=20
d9ec12a0 00000000 c2229360 0000968e c03af668 <BR>Oct&nbsp; 4 06:29:18=20
catchusers2 kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; c0137c71 =
c2229360=20
000001d0 f7bfc000 00000200 000001d0 00000015 00000020 <BR>Oct&nbsp; 4 =
06:29:18=20
catchusers2 kernel: Call Trace:&nbsp;&nbsp;&nbsp; [&lt;c0145a10&gt;]=20
[&lt;c0145b60&gt;] [&lt;c0137c71&gt;] [&lt;c0137eb3&gt;]=20
[&lt;c0137f26&gt;]<BR>Oct&nbsp; 4 06:29:18 catchusers2 =
kernel:&nbsp;&nbsp;=20
[&lt;c013803c&gt;] [&lt;c01380b8&gt;] [&lt;c01381ed&gt;] =
[&lt;c0105000&gt;]=20
[&lt;c010747e&gt;] [&lt;c0138150&gt;]<BR>Oct&nbsp; 4 06:29:18 =
catchusers2=20
kernel: <BR>Oct&nbsp; 4 06:29:18 catchusers2 kernel: Code: 0f 0b a8 04 =
99 ff 36=20
c0 b8 03 00 00 00 f0 0f ab 42 18 b8 08</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I am wondering&nbsp;if this is NFS =
related?&nbsp; I=20
only have about 50 gigs free on the raid array now.&nbsp; Whenever I get =
down to=20
about 25 gigs I get</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>this kernel bug?&nbsp;&nbsp; It is =
killing=20
me.&nbsp; If I keep it above 50 gigs free then this NEVER happens?&nbsp; =
Any=20
ideas?&nbsp; I would be VERY grateful.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Matt</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_04C5_01C38C5F.850A6AA0--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
