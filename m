From: "Nikita V. Youshchenko" <yoush@cs.msu.su>
Subject: Please assist in locating NFS race in old vendor kernel
Date: Thu, 10 May 2007 00:15:57 +0400
Message-ID: <200705100016.04170@sercond.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0303749455=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hlsa6-0000n0-5u
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 13:16:16 -0700
Received: from zigzag.lvk.cs.msu.su ([158.250.17.23])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hlsa7-0008NP-JA
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 13:16:17 -0700
Received: from Debian-exim by zigzag.lvk.cs.msu.su with spam-scanned (Exim
	4.50) id 1HlsZy-0005pf-AY
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 00:16:07 +0400
Received: from ppp23-49.pppoe.mtu-net.ru ([81.195.23.49] helo=blacky)
	by zigzag.lvk.cs.msu.su with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	(Exim 4.50) id 1HlsZy-0005pJ-29
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 00:16:06 +0400
Received: from nikita by blacky with local (Exim 4.63)
	(envelope-from <yoush@cs.msu.su>) id 1HlsZw-0007pf-79
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 00:16:04 +0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0303749455==
Content-Type: multipart/signed; boundary="nextPart1237997.MzXV8mFCdu";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1237997.MzXV8mFCdu
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello.

I'm currently working with an embedded system based on very old,=20
2.4.17-based, vendor kernel.

Among other issues, there is a race in NFS code, that I'm currently trying=
=20
to understand and fix.

The race is the following.
Some i/o is done on a file located on NFS-mounted filesystem. At some=20
moment, ftruncate() is called. And in very rare but still reproducable=20
cases:
=2D first inode->i_size is set to the new value, in process context
=2D then inode->i_size is restored to old value, in rpciod context.
I was able to catch this by adding some logging to the point where=20
__nfs_refresh_inode() updates inode->i_size.

Looks like inode size is being broken (by restore of old value) by=20
completeion handler of RPC operation that was started before ftruncate().

The test on which the race is reproduced more or less reliably,=20
is "fsx-linux" from LTP suite.

System in question is SMP - thus making race happen more often.

I guess the race is long fixed in more modern kernels.
But I'm not familiar with NFS code, and after some attempts to find=20
something I feel lost.

Could someone more familiar with NFS implementaion please point me where to=
=20
look?

Nikita

--nextPart1237997.MzXV8mFCdu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGQiwEv3x5OskTLdsRAvBAAJ0ZqUWBDous/YJAWO7WfCmn9gDJNgCffwky
jxo07PBb+YeZJwAPEWfSb8c=
=eRy2
-----END PGP SIGNATURE-----

--nextPart1237997.MzXV8mFCdu--


--===============0303749455==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0303749455==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0303749455==--
