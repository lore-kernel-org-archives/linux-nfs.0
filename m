From: "Wendy Cheng" <wendy.cheng@falconstor.com>
Subject: Re: the inode semaphore
Date: Wed, 12 Feb 2003 13:45:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00ee01c2d2c6$fa2ebdc0$c5e31a42@tamarac>
Reply-To: "Wendy Cheng" <wendy.cheng@falconstor.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_00EB_01C2D29D.11159240"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.105.142.2] (helo=falconstorex.falconstor.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18j1tw-0000tj-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Feb 2003 10:46:32 -0800
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

------=_NextPart_000_00EB_01C2D29D.11159240
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset="iso-8859-1"

Adding fh_put() to release the semaphore after
nfsd_unlink() within nfs3proc.c does make the
hang disappear. Hope we can see this get fixed
in the future code.

wendy
  ----- Original Message -----=20
  From: Wendy Cheng=20
  To: nfs@lists.sourceforge.net=20
  Sent: Tuesday, February 11, 2003 12:17 PM
  Subject: the inode semaphore


  We're working on a high availability experiment
  project for our linux-based server and the nfsds hang=20
  from times to times. It is observed that the version 3=20
  procedure 12/13 (rmdir and remove) obtains an inode=20
  semaphore within fh_lock()/nfsd_unlink() but never=20
  releases it. Theoretically this inode is going to get=20
  released but what can prevent the following two cases=20
  that would end up hanging the nfsd ?

  1. Due to slow network and/or system, the client re-
  sends the same request but using a different xid. The=20
  nfsd that accepts the new request would be stuck in=20
  nfsd_unlink() waiting for the inode semaphore.=20
  2. A "create" immediately follows the "remove" for the=20
  same file.=20

  There is a flag called fh_locked but it is passed in=20
  from each individual nfs request (a local copy, not=20
  from dcache) that doesn't help. I also browse thru=20
  some file system's (say ext3) inode free code but=20
  can't find anywhere this semaphore gets released.=20
  We're still debugging our failover logic but if=20
  someone could confirm the above are indeed a bug (or=20
  explain why it will not happen) would be of great=20
  helps.

  Or should this semaphore get "zero"ed out by file=20
  system (say, ext3) ?=20

  We're on 2.4.19 kernel.

  Thanks for the help.

  Wendy

------=_NextPart_000_00EB_01C2D29D.11159240
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1141" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Adding fh_put()&nbsp;to release the =
semaphore=20
after</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>nfsd_unlink() within nfs3proc.c =
</FONT><FONT=20
face=3DArial size=3D2>does make the</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>hang&nbsp;disappear. Hope we can see =
this get=20
fixed</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>in the future code.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>wendy</FONT></DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-RIGHT: 0px; PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #000000 2px solid; MARGIN-RIGHT: 0px">
  <DIV style=3D"FONT: 10pt arial">----- Original Message ----- </DIV>
  <DIV=20
  style=3D"BACKGROUND: #e4e4e4; FONT: 10pt arial; font-color: =
black"><B>From:</B>=20
  <A title=3Dwendy.cheng@falconstor.com=20
  href=3D"mailto:wendy.cheng@falconstor.com">Wendy Cheng</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>To:</B> <A =
title=3Dnfs@lists.sourceforge.net=20
  =
href=3D"mailto:nfs@lists.sourceforge.net">nfs@lists.sourceforge.net</A> =
</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Sent:</B> Tuesday, February 11, =
2003 12:17=20
  PM</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Subject:</B> the inode =
semaphore</DIV>
  <DIV><BR></DIV>
  <DIV><FONT face=3DArial size=3D2>We=92re working on a high =
availability=20
  experiment<BR>project for our linux-based server and the nfsds hang =
<BR>from=20
  times to times. It is observed that the version 3 <BR>procedure 12/13 =
(rmdir=20
  and remove) obtains an inode <BR>semaphore within =
fh_lock()/nfsd_unlink() but=20
  never <BR>releases it. Theoretically this inode is going to get =
<BR>released=20
  but what can prevent the following two cases <BR>that would end up =
hanging the=20
  nfsd ?</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>1. Due to slow network and/or system, =
the client=20
  re-<BR>sends the same request but using a different xid. The <BR>nfsd =
that=20
  accepts the new request would be stuck in <BR>nfsd_unlink() waiting =
for the=20
  inode semaphore. <BR>2. A =93create=94 immediately follows the =
=93remove=94 for the=20
  <BR>same file. </FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>There is a flag called fh_locked but =
it is passed=20
  in <BR>from each individual nfs request (a local copy, not <BR>from =
dcache)=20
  that doesn=92t help. I also browse thru <BR>some file system=92s (say =
ext3) inode=20
  free code but <BR>can=92t find anywhere this semaphore gets released. =
<BR>We=92re=20
  still debugging our failover logic but if <BR>someone could confirm =
the above=20
  are indeed a bug (or <BR>explain why it will not happen) would be of =
great=20
  <BR>helps.</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>Or should this semaphore get =
=93zero=94ed out by file=20
  <BR>system (say, ext3) ? </FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>We=92re on 2.4.19 =
kernel.</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>Thanks for the help.</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=3DArial =
size=3D2>Wendy<BR></FONT></DIV></BLOCKQUOTE></BODY></HTML>

------=_NextPart_000_00EB_01C2D29D.11159240--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
