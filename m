From: "Fabiano Reis" <silos.reis@ig.com.br>
Subject: NFS 2.6.3smp-client <-> 2.4.20-24.9smp-server problem
Date: Tue, 9 Mar 2004 09:47:26 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <03e601c405d4$accdf180$3f32a8c0@ds.ig.com.br>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_03E3_01C405BB.8772FDE0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0goq-0000Lb-VZ
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 04:58:48 -0800
Received: from smtp-29.ig.com.br ([200.226.132.157])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B0gg3-0008C0-LM
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 04:49:43 -0800
To: "NFS Mail List" <nfs@lists.sourceforge.net>
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

------=_NextPart_000_03E3_01C405BB.8772FDE0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi list,

I upgraded a RH9 box from 2.4.20-24.9smp to Vanilla kernel 2.6.3 (using =
smp as well). It look to be  working fine except for the messages i=B4m =
receiving from dmesg command. After mounting a nfs server (wich is =
running 2.4.20-28.8smp , RH8 kernel) I started to get these messages on =
dmesg:


----cut here---
nfs: server 10.0.3.1 not responding, still trying
nfs: server 10.0.3.1 OK
nfs: server 10.0.3.1 not responding, still trying
nfs: server 10.0.3.1 OK

... and much much more like the above ...
---cut here---

Even with the messages I can do operations using the mountpoint from the =
client. I can save files, list directories and files, etc.


The question that arises after seeing these messages:

1) do the nfs code from 2.6 kernel is compatible with 2.4 kernel ?=20

2) what can I do to try to solve this problem?

I would appreciate any help.

-
Fabiano
------=_NextPart_000_03E3_01C405BB.8772FDE0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1226" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>
<DIV>
<DIV><FONT face=3DArial size=3D2>Hi list,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I&nbsp;upgraded a RH9 box from =
2.4.20-24.9smp to=20
Vanilla kernel 2.6.3 (using smp as well). It look to be&nbsp; working =
fine=20
except for the messages i=B4m receiving from dmesg command. After =
mounting a nfs=20
server (wich is running 2.4.20-28.8smp , RH8 kernel)&nbsp;I started =
to&nbsp;get=20
these messages on dmesg:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>----cut here---</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>nfs: server 10.0.3.1 not responding, =
still=20
trying</FONT><FONT face=3DArial size=3D2><BR>nfs: server 10.0.3.1 =
OK<BR>nfs: server=20
10.0.3.1 not responding, still trying</FONT></DIV>
<DIV>nfs: server 10.0.3.1 OK</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>... and much much more like the=20
above&nbsp;...</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>---cut here---</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Even with the messages I can do =
operations using=20
the mountpoint from the client. I can save files, list directories and =
files,=20
etc.</DIV>
<DIV><BR></DIV></FONT>
<DIV><FONT face=3DArial size=3D2>The question that arises after seeing =
these=20
messages:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>1) do the nfs code from 2.6 kernel is=20
compatible&nbsp;with 2.4 kernel ? </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>2) what can I do to try to solve this=20
problem?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I&nbsp;would appreciate any =
help.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>-</FONT></DIV>
<DIV><FONT face=3DArial=20
size=3D2>Fabiano</DIV></FONT></DIV></FONT></DIV></BODY></HTML>

------=_NextPart_000_03E3_01C405BB.8772FDE0--



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
