From: Jun Zhang <nugulus@yahoo.com>
Subject: How to find what to make "df -jk" hang (redhat)
Date: Fri, 21 Oct 2005 15:02:05 -0700 (PDT)
Message-ID: <20051021220205.410.qmail@web52402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-1964372892-1129932125=:98215"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ET4xv-0005C1-KW
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 15:02:19 -0700
Received: from web52402.mail.yahoo.com ([206.190.48.165])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ET4xt-0004oe-9h
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 15:02:19 -0700
To: nfs@lists.sourceforge.net
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

--0-1964372892-1129932125=:98215
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

=20
Many a time when I type df -k, the prompt will not come back. Went to ano=
ther session, I found the df process is not killable. I then checked each=
 piece in /etc/fstab, each piece is fine (mounted and accessible).
Can somebosy give a clue?
=20
Jun

	=09
---------------------------------
 Yahoo! FareChase - Search multiple travel sites in one click. =20
--0-1964372892-1129932125=:98215
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<DIV>&nbsp;</DIV>
<DIV>Many a time when I type df -k, the prompt will not come back. Went t=
o another session, I found the df process is not killable. I then checked=
 each piece in /etc/fstab, each piece is fine (mounted and accessible).</=
DIV>
<DIV>Can somebosy give a clue?</DIV>
<DIV>&nbsp;</DIV>
<DIV>Jun</DIV><p>
		<hr size=3D1> <a href=3D"http://us.lrd.yahoo.com/_ylc=3DX3oDMTFqODRtdXQ=
4BF9TAzMyOTc1MDIEX3MDOTY2ODgxNjkEcG9zAzEEc2VjA21haWwtZm9vdGVyBHNsawNmYw--=
/SIG=3D110oav78o/**http%3a//farechase.yahoo.com/">Yahoo! FareChase - Sear=
ch multiple travel sites in one click.</a>

=20

=20
--0-1964372892-1129932125=:98215--


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
