From: "Duv  Dek" <onur@ee.bilkent.edu.tr>
Subject: NFS response time
Date: Tue, 25 Jan 2005 23:40:12 +0200
Message-ID: <003a01c50326$73182550$7889b38b@alpin>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0037_01C50337.3675EDB0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtYQL-0000B0-LE
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 13:40:33 -0800
Received: from dalyan.ee.bilkent.edu.tr ([139.179.12.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CtYQK-00012g-Ef
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 13:40:33 -0800
Received: from alpin (d79012c.dorm.bilkent.edu.tr [139.179.137.120])
	by dalyan.ee.bilkent.edu.tr (8.12.9/8.12.9) with SMTP id j0PLeFtf020511
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 23:40:15 +0200 (EET)
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

------=_NextPart_000_0037_01C50337.3675EDB0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi

We have a problem with our NFS server on Redhat 9. In case a program on =
the server uses high CPU, the NFS clients almost lock and nfs stops =
giving response until that program lowers its CPU usage.  We tried to =
increase the priority of nfsd deamons with renice, and also tried to =
increase the number of nfsd threads, decreased the priority of the =
program using high CPU with renice, but none of them worked. How can we =
solve this problem so that nfs does not lock?

------=_NextPart_000_0037_01C50337.3675EDB0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2900.2523" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>We have a problem with our NFS server =
on Redhat 9.=20
In case a program&nbsp;on the server&nbsp;uses high CPU,&nbsp;the=20
NFS&nbsp;clients almost lock and nfs stops giving response until that =
program=20
lowers its CPU usage.&nbsp;&nbsp;We tried to increase the priority of =
nfsd=20
deamons with renice, and also tried to increase the number of nfsd =
threads,=20
decreased the priority of the program using high CPU with =
renice,&nbsp;but none=20
of them worked. How can we&nbsp;solve this problem so that nfs does not=20
lock?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0037_01C50337.3675EDB0--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
