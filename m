Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:33609 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861Ab2EGANP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 May 2012 20:13:15 -0400
Date: Mon, 7 May 2012 10:13:08 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Fix O_DIRECT compile warnings
Message-Id: <20120507101308.2d0e3278e118728c8dfd01d6@canb.auug.org.au>
In-Reply-To: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__7_May_2012_10_13_08_+1000_t1Vb739zoQJq+FEY"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Mon__7_May_2012_10_13_08_+1000_t1Vb739zoQJq+FEY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

On Fri,  4 May 2012 14:09:18 -0400 Trond Myklebust <Trond.Myklebust@netapp.=
com> wrote:
>
> Fix the following compile warnings:
> fs/nfs/direct.c: In function 'nfs_direct_read_schedule_segment':
> fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:352:27: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c: In function 'nfs_direct_write_schedule_segment':
> fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
> fs/nfs/direct.c:650:27: warning: comparison of distinct pointer types
> lacks a cast [enabled by default]
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Fred Isaman <iisaman@netapp.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>

That works for me.

Acked-by: Stephen Rothwell <sfr@canb.auug.org.au>

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__7_May_2012_10_13_08_+1000_t1Vb739zoQJq+FEY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPpxOUAAoJEECxmPOUX5FEkMkP/i+OOx/Elln/rblVbo485apT
7GYeBkuq/Thg6ObEiGGRwmLl2hqyN/MVB2RS1i2Nz8FvpRJRikzpxwmcWrvifH3t
oPJG+5mVqQtSHFHaCS3ma7A8K2pLTUZZ1it/1PvaAL4xskYNigeLwNizua7JgBZX
N8uvqrg/3DwMa//YVDsBSTYvSKn6Wg9B4qHhNucC7hn85HQCgZSfW+KojAjJ3UbO
5N7hFr1gRPrEHzedAFKii40IBkmeK/l6byuObkU5cw67PX4SDYj0jfl3F9pY4GQp
6o+PrLD1q1Qx+SHmvTmX60rlWddI9/t7OX+RkfpS1zG2QcrBVlvodoPxn0ju8P9b
6zi42akqf+KjwnBzcGRiBUKE/ppfGZDwtTPQfg0wAFQl7ILjAVnyKdMnGbzUjLqo
uKkEEMpW2hJMfwb4aIOhCP0dng6ySNVPaC2UMBO8WZ6tr1Lgx4JcjVyYqW4DMp+Q
6aZbWb3GOxAzQn4UWwohUv/5x6Od2j+39pO+UAUxtzVc/S+9BbZLwYMb9DHinTgR
h1mRKPNwPUCwPkAuNpvTj6EGVg7PVoO9Aha3AskV/iGahm4wQLuBt3HvH2ksf1sN
fW3w9LXi0VzIWGBeMtBsNJXWyXFKndWPc2KqfcPJG+LMWadll2X//Xzf3q0JEqAC
cJ6oZ6bbM587I6PtpaHQ
=2SX5
-----END PGP SIGNATURE-----

--Signature=_Mon__7_May_2012_10_13_08_+1000_t1Vb739zoQJq+FEY--
