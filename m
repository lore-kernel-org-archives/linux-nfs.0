From: "Kedar Sovani" <kedar@calsoftinc.com>
Subject: padding the fh
Date: Sat, 31 Aug 2002 11:57:52 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003101c250b7$8ad7a220$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_002E_01C250E5.A2917610"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from silver.he.net ([216.218.151.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17l1ig-0000yQ-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 23:26:54 -0700
Received: from Ashwamedha ([203.124.132.202] (may be forged)) by silver.he.net (8.8.6/8.8.2) with SMTP id XAA10681 for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 23:26:47 -0700
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

------=_NextPart_000_002E_01C250E5.A2917610
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

hi,=20
       I have a problem. Does the linux nfs client follow the rule that =
the file handle it recieves is opaque to it(the client).?
        The problem that i have is, i am sitting at the server, and =
trying to pad the file handle being sent back by the exp_rootfh function =
in linux kernel 2.4.18-3. When i do sich a thing, i recevie one more =
MOUNt request by the client,but this is a MOUNTv2 request. Later, the =
client sends the GETATTR, FSTAT & FSINFO commands(this is sent using the =
NFsv3 protocol), and sooon later, it sends the same commands with NFSv2. =

        Can anyone explain this behavior to me. Why might this be =
happening. I want to use a padded version of the file handle for the =
rest of the server activities. How do i go abt it ?


rgds,
Kedar.

------=_NextPart_000_002E_01C250E5.A2917610
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
<DIV><FONT face=3DArial size=3D2>hi, </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; I =
have a=20
problem.&nbsp;Does the linux nfs client follow the rule that the file =
handle it=20
recieves is opaque to it(the client).?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
The problem=20
that i have is, i am sitting at the server, and trying to pad the file =
handle=20
being sent back by the exp_rootfh function in linux kernel 2.4.18-3. =
When i do=20
sich a thing, i recevie one more MOUNt request by the client,but this is =
a=20
MOUNTv2 request. Later, the client sends the GETATTR, FSTAT &amp; FSINFO =

commands(this is sent using the NFsv3 protocol), and sooon later, it =
sends the=20
same commands with NFSv2. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
Can anyone=20
explain this behavior to me. Why might this be happening. I want to use =
a padded=20
version of the file handle for the rest of the server activities. How do =
i go=20
abt it ?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>rgds,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Kedar.</FONT></DIV></BODY></HTML>

------=_NextPart_000_002E_01C250E5.A2917610--



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
