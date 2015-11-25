Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:49804 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752031AbbKYM51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2015 07:57:27 -0500
Date: Wed, 25 Nov 2015 13:57:23 +0100
From: William Dauchy <william@gandi.net>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>, netdev@vger.kernel.org
Subject: kmemleak report with nfs3/4 activity on v4.1.x
Message-ID: <20151125125723.GY21147@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OEa2bCMk+rg6xBXy"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--OEa2bCMk+rg6xBXy
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'm seeing some kmemleak reports while I'm using nfsv3/4=A0as a client on
linux v4.1.13;

unreferenced object 0xffff880c22a97ad0 (size 16):
=A0 comm "softirq", pid 0, jiffies 4294896089 (age 43927.436s)
=A0 hex dump (first 16 bytes):
=A0 =A0 00 00 00 00 00 00 00 00 00 45 1e 24 06 88 ff ff =A0.........E.$....
=A0 backtrace:
=A0 =A0 [<ffffffff811255fd>] create_object+0x152/0x280
=A0 =A0 [<ffffffff81529c04>] kmemleak_alloc+0x20/0x42
=A0 =A0 [<ffffffff811136dd>] slab_post_alloc_hook+0x2a/0x45
=A0 =A0 [<ffffffff81115c48>] kmem_cache_alloc+0xbc/0xd1
=A0 =A0 [<ffffffff81254cef>] gr_update_task_in_ip_table+0x2e/0xc3
=A0 =A0 [<ffffffff814701bc>] __inet_hash_connect+0x241/0x30e
=A0 =A0 [<ffffffff814702b8>] inet_hash_connect+0x2f/0x3a
=A0 =A0 [<ffffffff81484c41>] tcp_v4_connect+0x31f/0x470
=A0 =A0 [<ffffffff81499a2b>] __inet_stream_connect+0x9f/0x2c3
=A0 =A0 [<ffffffff81499c80>] inet_stream_connect+0x31/0x4d
=A0 =A0 [<ffffffff8140d870>] kernel_connect+0x18/0x20
=A0 =A0 [<ffffffff81503cb6>] xs_tcp_setup_socket+0x25c/0x37f
=A0 =A0 [<ffffffff810724c3>] process_one_work+0x1d0/0x30f
=A0 =A0 [<ffffffff81072822>] worker_thread+0x1f0/0x2aa
=A0 =A0 [<ffffffff81077cdc>] kthread+0xcd/0xd5
=A0 =A0 [<ffffffff8153443e>] ret_from_fork+0x3e/0x70

What can I do to help resolve this issue?

Thanks,
--=20
William

--OEa2bCMk+rg6xBXy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZVsDMACgkQ1I6eqOUidQGd8QCgr+awRjs9iCJjTdAj8IRyLPyF
rKEAoKzDTJcALHzwEDVzWrSE9Q4kh8Du
=YZSP
-----END PGP SIGNATURE-----

--OEa2bCMk+rg6xBXy--
