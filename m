From: "Randy Paries" <paries@knology.net>
Subject: I feel stupid just asking this question
Date: Wed, 5 May 2004 14:52:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BLSS0-00006E-6d@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0017_01C432B0.A68D2F80"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLSS0-0004Hp-Sb
	for nfs@lists.sourceforge.net; Wed, 05 May 2004 12:53:04 -0700
Received: from smtp.knology.net ([24.214.63.101] helo=smtp2.knology.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BLSS0-00006E-6d
	for nfs@lists.sourceforge.net; Wed, 05 May 2004 12:53:04 -0700
To: <nfs@lists.sourceforge.net>
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

------=_NextPart_000_0017_01C432B0.A68D2F80
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,
 
Please excuse this question, but i really would like to understand this.
 
I am deciding on how many nfsd's to run.
 
All the doc talks about how many clients.
 
here is my question. 
 
What is a client?
 
Is one mount point one client? (ie: if i have one server that mounts a nfs
drive) or if i have one mount point and many processes on the client box
assessing this mount point, is each process that needs access to the files
on the nfs file a client?
 
I hope this question makes sense.
 
thanks

------=_NextPart_000_0017_01C432B0.A68D2F80
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2>Hello,</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>Please =
excuse this=20
question, but i really would like to understand =
this.</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>I am =
deciding on how=20
many nfsd's to run.</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>All =
the doc talks=20
about how many clients.</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>here =
is my question.=20
</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>What =
is a=20
client?</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>Is one =
mount point=20
one client? (ie: if i have one server that mounts a nfs drive)&nbsp;or =
if i have=20
one mount point and many processes on the client box assessing this =
mount point,=20
is each process that needs access to the files on the nfs file a=20
client?</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial size=3D2>I hope =
this question=20
makes sense.</FONT></SPAN></DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D625404819-05052004><FONT face=3DArial=20
size=3D2>thanks</FONT></SPAN></DIV></BODY></HTML>

------=_NextPart_000_0017_01C432B0.A68D2F80--




-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
