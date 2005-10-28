From: "Shane Warren" <shanew@innovsys.com>
Subject: NFS: Access Denied after Sever Reboot (on 2.6)
Date: Fri, 28 Oct 2005 09:17:03 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93BA3007B@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5DBCA.450B415D"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVV2e-0005jP-Vi
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:17:12 -0700
Received: from smtp.innovsys.com ([66.115.232.196] helo=mail.innovsys.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EVV2c-0008Pk-Es
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:17:12 -0700
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
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

------_=_NextPart_001_01C5DBCA.450B415D
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I have a network with 2 computers one a nfs server and the other a nfs =
client.  Both are running kernel 2.6.12 and running nfs-utils 1.0.7.  =
When the server reboots the client's share to the server still exists =
(and will block on any commands like ls on the share dir, because the =
hard option is used), but after the server comes back up and nfs is =
started the client now says the share is "access denied". =20
=20
To determine if this was a client or a server problem I connected the =
same client to another server (running 2.6.10 and nfs-utils 1.0.6) and =
rebooted that server with the client connected.  This time after the =
server comes back up the client is fine and share still works.
=20
Ok so now I'm sure its the server thats the problem, I have tried =
everything I can think of, from patching the server with every nfs patch =
I could find for 2.6.12 (from =
http://client.linux-nfs.org/Linux-2.6.x/2.6.12/).  Also I tried messing =
with the export options for the share I current have this as the export =
line that messes up:
=20
/share *(rw,no_root_squash,sync)
=20
I have packet sniffed (w/ tcpdump and loading the dump in ethereal) the =
messages the server gets/sends when the client gets the "access denied" =
(when listing the shared directory), the exchange is something like:
=20
client sends: GETATTR on a certain inode with authentication set to: =
none
server responds: reject state set to: AUTH_ERROR, auth state set to: Bad =
Credential (seal broken)
=20
I played with this for a couple days trying everything but to no avail.  =
Does anyone have any suggestions as to what might be going on here, or =
what I could try?
=20
=20

------_=_NextPart_001_01C5DBCA.450B415D
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">


<META content=3D"MSHTML 6.00.2900.2769" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>I have =
a network=20
with 2 computers one a nfs server and the other a nfs client.&nbsp; Both =
are=20
running kernel 2.6.12 and running nfs-utils 1.0.7.&nbsp; When the server =
reboots=20
the client's share to the&nbsp;server still exists (and will block on =
any=20
commands like ls on the share dir, because the hard option is used), but =
after=20
the server comes back up and nfs is started the client now says the =
share is=20
"access denied".&nbsp; </FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>To =
determine if this=20
was a client or a server problem I connected the same client to another =
server=20
(running 2.6.10 and nfs-utils 1.0.6) and rebooted that server with the =
client=20
connected.&nbsp; This time after the server comes back up the client is =
fine and=20
share still works.</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>Ok so =
now I'm sure=20
its the server thats the problem, I have tried everything I can think =
of, from=20
patching the server with every nfs patch I could find for 2.6.12 (from =
<A=20
href=3D"http://client.linux-nfs.org/Linux-2.6.x/2.6.12/">http://client.li=
nux-nfs.org/Linux-2.6.x/2.6.12/</A>).&nbsp;=20
Also I tried messing with the export options for the share I current =
have this=20
as the export line that messes up:</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005></SPAN><SPAN =
class=3D381553713-28102005><FONT=20
face=3DArial size=3D2>/share =
*(rw,no_root_squash,sync)</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>I have =
packet=20
sniffed (w/ tcpdump and loading the dump in ethereal) the messages the =
server=20
gets/sends when the client gets the "access denied" (when listing the =
shared=20
directory), </FONT></SPAN><SPAN class=3D381553713-28102005><FONT =
face=3DArial=20
size=3D2>the exchange is something like:</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>client =
sends:=20
GETATTR on a certain inode with authentication set to: =
none</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>server =
responds:=20
reject state set to: AUTH_ERROR, auth state set to: Bad Credential (seal =

broken)</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial size=3D2>I =
played with this=20
for a couple days trying everything but to no avail.&nbsp; Does anyone =
have any=20
suggestions as to what might be going on here, or what I could=20
try?</FONT></SPAN></DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D381553713-28102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C5DBCA.450B415D--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
