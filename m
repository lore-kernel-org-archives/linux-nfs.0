From: "Kedar Sovani" <kedar@calsoftinc.com>
Subject: Isolation of nfs threads
Date: Thu, 19 Sep 2002 11:48:47 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005401c25fa4$6c6a8270$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0051_01C25FD2.8383F7B0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from silver.he.net ([216.218.151.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rud7-0004t6-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 23:17:37 -0700
Received: from Ashwamedha ([203.124.132.202] (may be forged)) by silver.he.net (8.8.6/8.8.2) with SMTP id XAA30901 for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 23:17:31 -0700
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

------=_NextPart_000_0051_01C25FD2.8383F7B0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hey,
      I am resending this message, can anyone please comment about the =
problem stated below.

        How does nfs maintain the isolation between multiple=20
threads.That is when one nfs thread is running how does it avoid other=20
nfs threads from running. This is achieved in BSD using the splxxx()=20
functions. But in LINUX i do not see any similare function which handles
this.
        Or more generally how does the LINUX kernel, lower and raise the =

interrupt level it is currently working on? How does it apply to NFS ?

Waiting for reply,

rgds,
Kedar.



------=_NextPart_000_0051_01C25FD2.8383F7B0
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
<BODY bgColor=3D#ffffff>
<DIV>Hey,<BR><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
I am=20
resending this message, can anyone please comment about the problem =
stated=20
below.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; How does nfs maintain =
the=20
isolation between multiple <BR>threads.That is when one nfs thread is =
running=20
how does it avoid other <BR>nfs threads from running. This is achieved =
in BSD=20
using the splxxx() <BR>functions. But in LINUX i do not see any similare =

function which =
handles<BR>this.<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Or=20
more generally how does the LINUX kernel, lower and raise the =
<BR>interrupt=20
level it is currently working on? How does it apply to NFS =
?<BR><BR>Waiting for=20
reply,<BR><BR>rgds,<BR>Kedar.<BR><BR></DIV></BODY></HTML>

------=_NextPart_000_0051_01C25FD2.8383F7B0--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
