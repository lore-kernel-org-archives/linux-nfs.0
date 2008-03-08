From: Timo Sirainen <tss@iki.fi>
Subject: NFS server waking up sleeping disks
Date: Sat, 08 Mar 2008 11:45:22 +0200
Message-ID: <1204969522.11220.680.camel@hurina>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HYswaVjtjqAHnuyPeS+P"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:41053 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbYCHKLt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2008 05:11:49 -0500
Received: from [192.168.10.2] (82-203-162-146.dsl.gohome.fi [82.203.162.146])
	by dovecot.org (Postfix) with ESMTP id 9813E16471F9
	for <linux-nfs@vger.kernel.org>; Sat,  8 Mar 2008 11:45:22 +0200 (EET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-HYswaVjtjqAHnuyPeS+P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

My Linux 2.6.24.1 NFS server has two disks. One of them is rarely used,
so it's normally sleeping and is not even mounted anywhere. But after
the NFS mount hasn't been used for a while (some hours?) doing just a
"ls" on NFS client causes the sleeping disk to wake up and the "ls"
reply is delayed a few seconds until the wakeup is finished.

Any ideas why it's waking up the disk that has nothing to do with NFS,
and how to prevent it from doing this?

Using NFSv3 with export options *(ro,insecure,no_subtree_check)


--=-HYswaVjtjqAHnuyPeS+P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0mAyyUhSUUBViskRAk5MAJ9wazuKFHaTc5+LUt/kUD0eotE6ggCfQKf3
mbj+1luEroPsWEIYvtNJnSg=
=SkNc
-----END PGP SIGNATURE-----

--=-HYswaVjtjqAHnuyPeS+P--

