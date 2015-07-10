Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35260 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbbGJLYx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 07:24:53 -0400
Received: by ykee186 with SMTP id e186so60149744yke.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 04:24:53 -0700 (PDT)
Date: Fri, 10 Jul 2015 07:24:38 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: William Dauchy <william@gandi.net>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710072438.08b3417a@tlielax.poochiereds.net>
In-Reply-To: <20150710092910.GI15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/SXa0Vw44.rYlue09deOLl94"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SXa0Vw44.rYlue09deOLl94
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Jul 2015 11:29:10 +0200
William Dauchy <william@gandi.net> wrote:

> Hello,
>=20
> We have been testing the two following patches on top of the last 3.14.x.
> (they have been queued up for stable releases)
>=20
> commit db2efec0caba4f81a22d95a34da640b86c313c8e
> Author: Jeff Layton <jlayton@poochiereds.net>
> Date: =C2=A0 Tue Jun 30 14:12:30 2015 -0400
>=20
> =C2=A0 =C2=A0 nfs: take extra reference to fl->fl_file when running a LOC=
KU operation
>=20
> commit feaff8e5b2cfc3eae02cf65db7a400b0b9ffc596
> Author: Jeff Layton <jlayton@poochiereds.net>
> Date: =C2=A0 Tue May 12 15:48:10 2015 -0400
>=20
> =C2=A0 =C2=A0 nfs: take extra reference to fl->fl_file when running a set=
lk
>=20
>=20
> It resulted in random instabilities; we are unable to reproduce it reliab=
ly for now;
> the only trace we got was the one below.
>=20
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 8 at kernel/rcu/tree.c:2191 rcu_do_batch.isra.51+0x3=
84/0x3d0()
> CPU: 0 PID: 8 Comm: rcuc/0 Not tainted 3.14 #1
> 0000000000000009 ffff88061e5dfd10 ffffffff815f5143 0000000000000000
> ffff88061e5dfd48 ffffffff8105eece 000000000000002f ffff880627c0b600
> 000000000000002f 0000000000000246 0000000000000000 ffff88061e5dfd58
> Call Trace:
> [<ffffffff815f5143>] dump_stack+0x4d/0x81
> [<ffffffff8105eece>] warn_slowpath_common+0x6e/0x90
> [<ffffffff8105efd5>] warn_slowpath_null+0x15/0x20
> [<ffffffff810bc634>] rcu_do_batch.isra.51+0x384/0x3d0
> [<ffffffff810bc42a>] ? rcu_do_batch.isra.51+0x17a/0x3d0
> [<ffffffff810bc9ed>] rcu_cpu_kthread+0xed/0x130
> [<ffffffff8108aabe>] smpboot_thread_fn+0x18e/0x2e0
> [<ffffffff8108a930>] ? in_egroup_p+0x40/0x40
> [<ffffffff8108358c>] kthread+0xec/0x110
> [<ffffffff810834a0>] ? __kthread_parkme+0x80/0x80
> [<ffffffff815fcb39>] ret_from_fork+0x49/0x80
> [<ffffffff810834a0>] ? __kthread_parkme+0x80/0x80
> ---[ end trace 27f9589ec4225b03 ]---

Huh. I'm stumped...

These patches are pretty straightforward. We're just taking an extra
reference to the filp when running lock operations so that it doesn't
disappear before the replies can be processed (typically in the event
that a signal comes in while waiting on the reply). Given the odd stack
trace above, I have to wonder if there's some sort of memory scribble
going on.

Just to be clear...you are mounting with NFSv4 and running something on
the mount when you see this, right? If you don't use NFSv4, then is
everything fine?

Thanks,
--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/SXa0Vw44.rYlue09deOLl94
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVn6t4AAoJEAAOaEEZVoIViw4P/AisnzuPmYOo7mcYuipMCcOG
pmGKbHPt2NokzFs4JXvzLWlcDEanHyu20Fow7Zaa2RuPnAlMvQj1YjUXmw9FE8Q4
40LqJd88YwIUWW6L4Y3NDQytUZd9vC/eDOfhFfjhV8W74qThFEZaVAcXJ15aYOpa
Ti1q9D1CCfY3j07x9xmeiRMqvygqMhvxl3MxSEI6rPATPW3qmhhpflO+NvxWvyIl
1my6yOsaobD4dDJv9GGFMvnB5rJM+b5oSyy7QUq+ewWaPj0spBuCYAC5n663vfZq
Oa0WAArSPQJIxDa1RHjHJs0rgpMVlLDs6wkj9bwwzm1T9sOh2xrP4z5wDX0HAuTV
8x/fLLpR6oPhuuU/R7N+ThA6rn2rjUFUKdQXnNBzOwJ0wqAABg3wqw+2v5wW7CcD
if4cDNPdDcJh5w34gDOHt+4WDkFQZVcGUnblpdtgOhTcVW82FpwJ615NrLEi4w6u
RO7v1PbHx5ilyZILSPFLR77AHv7l1uR7JVDDOyR3FIl0e1KGHtcIcu6jLXADS9yq
9XnpIzPPbm+Iq7ph6MuHppO3AGPiRW3o1zNXNkrSIO8rvRBMbyBflrDWw9Sa9mM+
KwYdABmbjTWqQ87QRk+5rfIumk75ebDb4P8hn2DrXUhoOUyFFerGOM0dehvZ6qVi
DW69PYn0cvns/b0bjqzL
=a6Rx
-----END PGP SIGNATURE-----

--Sig_/SXa0Vw44.rYlue09deOLl94--
