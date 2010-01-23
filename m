From: Ivan Shmakov <ivan-tPYS1JDixHzCyp4qypjU+w@public.gmane.org>
Subject: NFS/IPv6 servers on GNU/Linux?
Date: Sat, 23 Jan 2010 18:54:39 +0600
Message-ID: <87y6jp56cw.fsf@violet.siamics.net>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:35800 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755028Ab0AWMzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jan 2010 07:55:06 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1NYfW3-0004YT-4T
	for linux-nfs@vger.kernel.org; Sat, 23 Jan 2010 13:55:03 +0100
Received: from 81.201.254.124 ([81.201.254.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2010 13:55:03 +0100
Received: from ivan by 81.201.254.124 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2010 13:55:03 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Transfer-Encoding: quoted-printable

>>>>> "JL" =3D=3D Jeff Layton <jlayton...> writes:

 JL> We're poised to enable IPv6 in nfs-utils in distros. There is a
 JL> potential problem however. mount.nfs will prefer IPv6 addrs.

 JL> If someone has a working IPv4 server today that has an IPv6
 JL> address, then clients may start trying to mount over that
 JL> address. If the server doesn't support NFS serving over IPv6 (and
 JL> virtually no linux servers currently do),

	Huh?  Are there any GNU/Linux-based servers that do?  What are
	the prerequisites?

	(Sorry, I wasn't following the topic recently.)

 JL> then the mount will start failing.

[...]

=2D-=20
FSF associate member #7257

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkta8ZEACgkQMBO2oCMOM0rvvgCfT7tUFZRNo/RDsfuhUxHDdMAw
opgAn0/LFUaydPGyyXMdSi7ySOVYl4Fn
=I/QJ
-----END PGP SIGNATURE-----
--=-=-=--

