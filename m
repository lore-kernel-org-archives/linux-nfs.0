From: "Kiernan, Michael" <mkiernan@netapp.com>
Subject: RE: do_IRQ: stack overflow
Date: Thu, 16 Oct 2003 23:45:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <765B6B38B4D29D498077F8E644E23B7F023C1207@nlhoe2k02.europe.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C3947C.6520A680"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAOtj-0007Mi-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 00:19:43 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAOtF-00085m-5s
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 00:19:13 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.10/8.12.10/NTAP-1.4) with ESMTP id h9H7Fg4Z020483
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 00:15:42 -0700 (PDT)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.10.22.171])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h9H7FYCt016165
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 00:15:42 -0700 (PDT)
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

------_=_NextPart_001_01C3947C.6520A680
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

For the record; Steve's patch resolved this.=20

-----Original Message-----=20
From: Steve Dickson [mailto:SteveD@RedHat.com]=20
Sent: 06 October 2003 13:58=20
To: Kiernan, Michael=20
Cc: nfs@lists.sourceforge.net=20
Subject: Re: [NFS] do_IRQ: stack overflow=20


Kiernan, Michael wrote:=20

>Can anyone help me debug/(fix!) a stack overflow? (see attachment).=20
>=20
>redhat 7.3, dual xeon 2.8GHz=20
>2.4.20-20.7bigmem, but also occurs with 2.4.18-27.7bigmem and=20
>non-bigmem versions.=20
> =20
>=20
See if this helps....=20

SteveD.=20


------_=_NextPart_001_01C3947C.6520A680
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">






























<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.0.6249.1">
<TITLE>RE: [NFS] do_IRQ: stack overflow</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>For the record; Steve's patch resolved this. </FONT>
</P>

<P><FONT SIZE=3D2>-----Original Message-----</FONT>

<BR><FONT SIZE=3D2>From: Steve Dickson [<A =
HREF=3D"mailto:SteveD@RedHat.com">mailto:SteveD@RedHat.com</A>]</FONT>

<BR><FONT SIZE=3D2>Sent: 06 October 2003 13:58</FONT>

<BR><FONT SIZE=3D2>To: Kiernan, Michael</FONT>

<BR><FONT SIZE=3D2>Cc: nfs@lists.sourceforge.net</FONT>

<BR><FONT SIZE=3D2>Subject: Re: [NFS] do_IRQ: stack overflow</FONT>
</P>
<BR>

<P><FONT SIZE=3D2>Kiernan, Michael wrote:</FONT>
</P>

<P><FONT SIZE=3D2>&gt;Can anyone help me debug/(fix!) a stack overflow? =
(see attachment). </FONT>

<BR><FONT SIZE=3D2>&gt;</FONT>

<BR><FONT SIZE=3D2>&gt;redhat 7.3, dual xeon 2.8GHz</FONT>

<BR><FONT SIZE=3D2>&gt;2.4.20-20.7bigmem, but also occurs with =
2.4.18-27.7bigmem and </FONT>

<BR><FONT SIZE=3D2>&gt;non-bigmem versions. </FONT>

<BR><FONT SIZE=3D2>&gt;&nbsp; </FONT>

<BR><FONT SIZE=3D2>&gt;</FONT>

<BR><FONT SIZE=3D2>See if this helps....</FONT>
</P>

<P><FONT SIZE=3D2>SteveD.</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C3947C.6520A680--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
