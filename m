From: "Duv  Dek" <onur@ee.bilkent.edu.tr>
Subject: NFS response time
Date: Tue, 25 Jan 2005 19:19:12 +0200
Message-ID: <007a01c50301$fd199510$7889b38b@alpin>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0077_01C50312.C05619D0"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtULl-0003uK-Ua
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 09:19:33 -0800
Received: from dalyan.ee.bilkent.edu.tr ([139.179.12.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CtULj-00039R-JV
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 09:19:33 -0800
Received: from alpin (d79012c.dorm.bilkent.edu.tr [139.179.137.120])
	by dalyan.ee.bilkent.edu.tr (8.12.9/8.12.9) with SMTP id j0PHJFtf017691
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 19:19:15 +0200 (EET)
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

------=_NextPart_000_0077_01C50312.C05619D0
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
decrease this problem so that nfs does not lock?
------=_NextPart_000_0077_01C50312.C05619D0
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
of them worked. How can we&nbsp;decrease this problem so that nfs does =
not=20
lock?</FONT></DIV></BODY></HTML>

------=_NextPart_000_0077_01C50312.C05619D0--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
