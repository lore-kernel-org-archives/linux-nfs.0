From: "Kedar Sovani" <kedar@calsoftinc.com>
Subject: isolation of NFS threads  ?
Date: Tue, 17 Sep 2002 12:56:45 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000f01c25e1b$961ac560$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_000C_01C25E49.ADB614D0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from silver.he.net ([216.218.151.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rCjo-000579-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 00:25:36 -0700
Received: from Ashwamedha ([203.124.132.202] (may be forged)) by silver.he.net (8.8.6/8.8.2) with SMTP id AAA32417 for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 00:25:32 -0700
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

------=_NextPart_000_000C_01C25E49.ADB614D0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hey,
        How does nfs maintain the isolation between multiple =
threads.That is when one nfs thread is running how does it avoid other =
nfs threads from running. This is achieved in BSD using the splxxx() =
functions. But in LINUX i do not see any similare function which handles =
this.
        Or more generally how does the LINUX kernel, lower and raise the =
interrupt level it is currently working on? How does it apply to NFS ?

Waiting for reply,

rgds,
Kedar.

------=_NextPart_000_000C_01C25E49.ADB614D0
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
<DIV><FONT face=3DArial size=3D2>Hey,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
How does nfs=20
maintain the isolation between multiple threads.That is when one nfs =
thread is=20
running how does it avoid other nfs threads from running. This is =
achieved in=20
BSD using the splxxx() functions. But in LINUX i do not see any similare =

function which handles this.</FONT></DIV>
<DIV><FONT face=3DArial =
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Or more=20
generally how does the LINUX kernel, lower and raise the interrupt level =
it is=20
currently working on? How does it apply to NFS ?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Waiting for reply,</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>rgds,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Kedar.</FONT></DIV></BODY></HTML>

------=_NextPart_000_000C_01C25E49.ADB614D0--



-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
