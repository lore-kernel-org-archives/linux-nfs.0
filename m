From: "Mahesh" <mahesh@calsoftinc.com>
Subject: Asynchronous read write calls
Date: Thu, 24 Oct 2002 17:44:43 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000c01c27b56$ef538fb0$9b0010ac@airavata>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0009_01C27B85.08F97C30"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [203.124.132.202] (helo=hydra.intranet.calsoftinc.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184goG-0000mP-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Oct 2002 05:09:57 -0700
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

------=_NextPart_000_0009_01C27B85.08F97C30
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi=20

I was wondering that since NFS read and write calls are blocking, how =
does one implement striping on an NFS client. For example assume =
multiple servers across which i would like to stripe a file. Now in =
order to get maximum performance out of striping i would have to issue =
read/write calls to all of the servers involved in the striping process =
at about the same time. Then i would benefit from concurrent reads on =
many servers. So basically how are these non blocking calls implemented =
... i mean can it be done using rpc_call_async. If so could someone =
please explain this !!! :-)

Thanks a ton in anticipation of a reply,


Regards
Mahesh

------=_NextPart_000_0009_01C27B85.08F97C30
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.2920.0" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I was wondering that since NFS read and =
write calls=20
are blocking, how does one implement striping on an NFS client. For =
example=20
assume multiple servers across which i would like to stripe a file. Now =
in order=20
to get maximum performance out of striping i would have to issue =
read/write=20
calls to all of the servers involved in the striping process at about =
the same=20
time. Then i would benefit from concurrent reads on many servers. So =
basically=20
how are these non blocking calls implemented ... i mean can it be done =
using=20
rpc_call_async. If so could someone please explain this !!! =
:-)</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks a ton in anticipation of a=20
reply,</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Regards</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Mahesh</FONT></DIV></BODY></HTML>

------=_NextPart_000_0009_01C27B85.08F97C30--



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4729346;7592162;s?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
