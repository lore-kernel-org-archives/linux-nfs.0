From: "Joeri Belis" <joeri.belis@nollekens.be>
Subject: Re: [FIXED]nfs crashes the df command and cannot be unmounted
Date: Tue, 3 Jan 2006 14:04:07 +0100
Message-ID: <032f01c61066$2e585f90$15c809c6@PCJOERI01>
References: <032501c61063$941c09b0$15c809c6@PCJOERI01>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_032C_01C6106E.9008F170"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Etlou-0005uK-V3
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 05:03:20 -0800
Received: from [194.78.89.210] (helo=linuxnol2004.nollekens.be)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Etlor-0002xQ-Iu
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 05:03:20 -0800
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

------=_NextPart_000_032C_01C6106E.9008F170
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Oops,

the service nfs was stopped on redhat

fix it.
  ----- Original Message -----=20
  From: Joeri Belis=20
  To: NFS@lists.sourceforge.net=20
  Sent: Tuesday, January 03, 2006 1:45 PM
  Subject: [NFS] nfs crashes the df command and cannot be unmounted


  Hi,

  We have a nfs filesystem on a redhat es4 mounted on our aix 4.3.
  After a powerloss and a rebout of the redhat es4 ( aix was not down ). =
the nfs filesystem can not be seen anymore on the aix.

  trying to umount gives:
  /bunolleken/users/joeri> umount /linuxnol2004/dump
  umount: 1831-015 16 error while unmounting =
198.9.200.232:/nollekens/progress/dump -
  The requested resource is busy.

  any ideas how to unmount this or get it going again. the redhat es4 is =
back online.

  Joeri
------=_NextPart_000_032C_01C6106E.9008F170
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1106" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Oops,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>the service nfs was stopped on =
redhat</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>fix it.</FONT></DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-RIGHT: 0px; PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #000000 2px solid; MARGIN-RIGHT: 0px">
  <DIV style=3D"FONT: 10pt arial">----- Original Message ----- </DIV>
  <DIV=20
  style=3D"BACKGROUND: #e4e4e4; FONT: 10pt arial; font-color: =
black"><B>From:</B>=20
  <A title=3Djoeri.belis@nollekens.be =
href=3D"mailto:joeri.belis@nollekens.be">Joeri=20
  Belis</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>To:</B> <A =
title=3DNFS@lists.sourceforge.net=20
  =
href=3D"mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</A> =
</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Sent:</B> Tuesday, January 03, 2006 =
1:45=20
  PM</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Subject:</B> [NFS] nfs crashes the =
df command=20
  and cannot be unmounted</DIV>
  <DIV><BR></DIV>
  <DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
  <DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>We have a nfs filesystem on a redhat =
es4 mounted=20
  on our aix 4.3.</FONT></DIV>
  <DIV><FONT face=3DArial size=3D2>After a powerloss and a rebout of the =
redhat es4=20
  ( aix was not down ). the nfs filesystem can not be seen anymore on =
the=20
  aix.</FONT></DIV>
  <DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
  <DIV><FONT face=3DArial size=3D2>trying to umount gives:</FONT></DIV>
  <DIV><FONT face=3DArial size=3D2>/bunolleken/users/joeri&gt; umount=20
  /linuxnol2004/dump<BR>umount: 1831-015 16 error while unmounting=20
  198.9.200.232:/nollekens/progress/dump -<BR>The requested resource is=20
  busy.<BR></FONT></DIV>
  <DIV><FONT face=3DArial size=3D2>any ideas how to unmount this or get =
it going=20
  again. the redhat es4 is back online.</FONT></DIV>
  <DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
  <DIV><FONT face=3DArial =
size=3D2>Joeri</DIV></BLOCKQUOTE></FONT></BODY></HTML>

------=_NextPart_000_032C_01C6106E.9008F170--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
