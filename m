From: "Slawomir Orlowski \(Cympak\)" <sorlowski@cympak.com>
Subject: Cannot start nfsd deamon.
Date: Thu, 11 Jul 2002 16:13:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <006f01c22917$7b807d00$4900a8c0@cympak.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_006C_01C228F5.F45E1420"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.138.227.126] (helo=server.cympak.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SkLf-00077P-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 13:15:35 -0700
Received: from slawek.cympak.com ([192.168.0.73] helo=Slawek)
	by server.cympak.com with smtp (Exim 3.13 #1)
	id 17SkJY-0005GR-00
	for nfs@lists.sourceforge.net; Thu, 11 Jul 2002 16:13:24 -0400
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_006C_01C228F5.F45E1420
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I have untared and compilled  nfs-utils-0.1.9.1.tar.gz on my server with =
RedHat6.1 (2.2.16 kernel).

After launching as root:=20

root@server download]# /etc/rc.d/init.d/nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
Starting NFS daemon: nfssvc: Function not implemented                    =
         [FAILED]

Could somebody help me, what should I do to get nfs server working??????

Best regards
Slawomir Orlowski

------=_NextPart_000_006C_01C228F5.F45E1420
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.2919.6307" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>I have untared and compilled&nbsp;=20
nfs-utils-0.1.9.1.tar.gz on my server with RedHat6.1 (2.2.16=20
kernel).</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>After&nbsp;launching as root: =
</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>root@server download]# =
/etc/rc.d/init.d/nfs=20
start<BR>Starting NFS=20
services:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;=20
[&nbsp; OK&nbsp; ]<BR>Starting NFS=20
quotas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;=20
[&nbsp; OK&nbsp; ]<BR>Starting NFS=20
mountd:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;=20
[&nbsp; OK&nbsp; ]<BR>Starting NFS daemon: nfssvc: Function not=20
implemented&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
[FAILED]<BR></FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Could somebody help me, what should I =
do to get nfs=20
server working??????</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Best regards</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Slawomir =
Orlowski</DIV></FONT></BODY></HTML>

------=_NextPart_000_006C_01C228F5.F45E1420--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
