From: "Tina Arora" <tinaarora@hotmail.com>
Subject: NFS not running !!!
Date: Wed, 24 Apr 2002 13:08:54 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <DAV48guA8M6XQQez1en000011fe@hotmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0011_01C1EB91.2FBC4F20"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dav48.law15.hotmail.com ([64.4.22.20] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170HUB-0001nq-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 00:46:43 -0700
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

------=_NextPart_000_0011_01C1EB91.2FBC4F20
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello friends thanx so much 4 replying to my yesterday's  query.
heres 1 more..
I downloaded nfs-utils-0.3.3 and executed all the four commands
 #./configure
# make
#make install
#rpm -ta nfs-utils-0.3.3.tar.gz
everything went fine but when i tried to verify NFS with rpcinfo -p =
command I got only 4 lines in the output (2 for portmap and 2 for =
status)
and none for rquotad or mountd or nfs or amd or nlockmgr..
Readme of this nfs utility says that to build the source & binary RPMs, =
mount in util-linux 2.11f or above is required ..
I have a mount version of 2.11b ...
Can the above problem be caused coz of mount version problem..
please help me out..
other nfs-utilities say u shud not have a too old mount version ...what =
is meant by too old mount version.. please try to be specific..
thanx n bye
Tina

------=_NextPart_000_0011_01C1EB91.2FBC4F20
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
<DIV><FONT face=3DArial size=3D2>Hello friends thanx so much 4 replying =
to my=20
yesterday's&nbsp; query.<BR>heres 1 more..<BR>I downloaded =
nfs-utils-0.3.3 and=20
executed all the four commands<BR>&nbsp;#./configure<BR># make<BR>#make=20
install<BR>#rpm -ta nfs-utils-0.3.3.tar.gz<BR>everything went fine but =
when i=20
tried to verify NFS with rpcinfo -p command I got only 4 lines in the =
output (2=20
for portmap and 2 for status)<BR>and none for rquotad or mountd or nfs =
or amd or=20
nlockmgr..<BR>Readme of this nfs utility says that to build the source =
&amp;=20
binary RPMs, mount in util-linux 2.11f or above is required ..<BR>I have =
a mount=20
version of 2.11b ...<BR>Can the above problem be caused coz of mount =
version=20
problem..<BR>please help me out..<BR>other nfs-utilities say u shud not =
have a=20
too old mount version ...what is meant by too old mount version.. please =
try to=20
be specific..<BR>thanx n bye<BR>Tina</FONT></DIV></BODY></HTML>

------=_NextPart_000_0011_01C1EB91.2FBC4F20--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
