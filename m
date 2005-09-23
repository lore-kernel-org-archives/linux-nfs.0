From: "sharad" <singh.sharad@netsity.com>
Subject: Kernel panic
Date: Fri, 23 Sep 2005 19:07:01 +0530
Message-ID: <005b01c5c043$e0df4e80$5867a8c0@netsity.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0058_01C5C071.FA83B460"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EInjz-0002zx-Rq
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 06:37:27 -0700
Received: from smtp.netsity.com ([61.246.47.138] helo=mail.netsity.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EInjw-0003vB-9i
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 06:37:24 -0700
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

------=_NextPart_000_0058_01C5C071.FA83B460
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi everyone,
 I am using AU1200 board and trying to boot through NFS.Kernel boots but =
shows a panic after some time..
Following is the screen shot of it:-

TCP: Hash tables configured (established 2048 bind 2048)
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
Root-NFS: No NFS server available, giving up.
VFS: Unable to mount root fs via NFS, trying floppy.
VFS: Cannot open root device "nfs" or unknown-block(2,0)
Please append a correct "root=3D" boot option
Kernel panic - not syncing: VFS: Unable to mount root fs on =
unknown-block(2,0)


Can anyone help me please

Thanks in advance
sharad

------=_NextPart_000_0058_01C5C071.FA83B460
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
<DIV><FONT color=3D#000080>Hi everyone,</FONT></DIV>
<DIV><FONT color=3D#000080>&nbsp;I am using AU1200 board and trying to =
boot=20
through NFS.Kernel boots but shows a panic after some =
time..</FONT></DIV>
<DIV><FONT color=3D#000080>Following is the screen shot of =
it:-</FONT></DIV>
<DIV><FONT color=3D#000080></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000080>TCP: Hash tables configured (established 2048 =
bind=20
2048)<BR>NET: Registered protocol family 1<BR>NET: Registered protocol =
family=20
17<BR>NET: Registered protocol family 15<BR>Root-NFS: No NFS server =
available,=20
giving up.<BR>VFS: Unable to mount root fs via NFS, trying =
floppy.<BR>VFS:=20
Cannot open root device "nfs" or unknown-block(2,0)<BR>Please append a =
correct=20
"root=3D" boot option<BR>Kernel panic - not syncing: VFS: Unable to =
mount root fs=20
on unknown-block(2,0)</FONT></DIV>
<DIV><FONT color=3D#000080></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000080></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000080>Can&nbsp;anyone help me please</FONT></DIV>
<DIV><FONT color=3D#000080></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000080>Thanks in advance</FONT></DIV>
<DIV><FONT color=3D#000080>sharad</FONT></DIV></BODY></HTML>

------=_NextPart_000_0058_01C5C071.FA83B460--



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
