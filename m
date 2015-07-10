Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:41015 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753642AbbGJJfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 05:35:24 -0400
Date: Fri, 10 Jul 2015 11:29:10 +0200
From: William Dauchy <william@gandi.net>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: extra reference to fl->fl_file, possible regression
Message-ID: <20150710092910.GI15144@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jQIvE3yXcK9X9HBh"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--jQIvE3yXcK9X9HBh
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

We have been testing the two following patches on top of the last 3.14.x.
(they have been queued up for stable releases)

commit db2efec0caba4f81a22d95a34da640b86c313c8e
Author: Jeff Layton <jlayton@poochiereds.net>
Date: =A0 Tue Jun 30 14:12:30 2015 -0400

=A0 =A0 nfs: take extra reference to fl->fl_file when running a LOCKU opera=
tion

commit feaff8e5b2cfc3eae02cf65db7a400b0b9ffc596
Author: Jeff Layton <jlayton@poochiereds.net>
Date: =A0 Tue May 12 15:48:10 2015 -0400

=A0 =A0 nfs: take extra reference to fl->fl_file when running a setlk


It resulted in random instabilities; we are unable to reproduce it reliably=
 for now;
the only trace we got was the one below.

------------[ cut here ]------------
WARNING: CPU: 0 PID: 8 at kernel/rcu/tree.c:2191 rcu_do_batch.isra.51+0x384=
/0x3d0()
CPU: 0 PID: 8 Comm: rcuc/0 Not tainted 3.14 #1
0000000000000009 ffff88061e5dfd10 ffffffff815f5143 0000000000000000
ffff88061e5dfd48 ffffffff8105eece 000000000000002f ffff880627c0b600
000000000000002f 0000000000000246 0000000000000000 ffff88061e5dfd58
Call Trace:
[<ffffffff815f5143>] dump_stack+0x4d/0x81
[<ffffffff8105eece>] warn_slowpath_common+0x6e/0x90
[<ffffffff8105efd5>] warn_slowpath_null+0x15/0x20
[<ffffffff810bc634>] rcu_do_batch.isra.51+0x384/0x3d0
[<ffffffff810bc42a>] ? rcu_do_batch.isra.51+0x17a/0x3d0
[<ffffffff810bc9ed>] rcu_cpu_kthread+0xed/0x130
[<ffffffff8108aabe>] smpboot_thread_fn+0x18e/0x2e0
[<ffffffff8108a930>] ? in_egroup_p+0x40/0x40
[<ffffffff8108358c>] kthread+0xec/0x110
[<ffffffff810834a0>] ? __kthread_parkme+0x80/0x80
[<ffffffff815fcb39>] ret_from_fork+0x49/0x80
[<ffffffff810834a0>] ? __kthread_parkme+0x80/0x80
---[ end trace 27f9589ec4225b03 ]---
--=20
William

--jQIvE3yXcK9X9HBh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWfkGYACgkQ1I6eqOUidQGpmQCePYz6cJy+KJQtt9WDPOhwPNAc
jsIAn20X4pedmXWuwLLPBOS7N8DJ13Qt
=vpJj
-----END PGP SIGNATURE-----

--jQIvE3yXcK9X9HBh--
