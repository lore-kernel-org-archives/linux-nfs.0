Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41162 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbcFVOfQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 10:35:16 -0400
Date: Wed, 22 Jun 2016 17:09:13 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
Message-ID: <20160622140913.GG9762@leon.nu>
Reply-To: leon@kernel.org
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
 <576A9AE6.4070500@grimberg.me>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="L1c6L/cjZjI9d0Eq"
In-Reply-To: <576A9AE6.4070500@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--L1c6L/cjZjI9d0Eq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 22, 2016 at 05:04:22PM +0300, Sagi Grimberg wrote:
>=20
> >+	/* This is overkill, but hardware requires that the
> >+	 * PBL array begins at a properly aligned address and
> >+	 * never occupies the last 8 bytes of a page.
> >+	 */
> >+	mr->pages =3D (__be64 *)get_zeroed_page(GFP_KERNEL);
> >+	if (!mr->pages)
> >  		return -ENOMEM;
>=20
> Again, I'm not convinced that this is a better choice then allocating
> the exact needed size as dma coherent, but given that the dma coherent
> allocations are always page aligned I wander if it's not the same
> effect...
>=20
> In any event, we can move forward with this for now:
>=20
> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>

Thanks Sagi,

As an update, we don't have reliable answer regarding mlx5 yet, if
similar limitation exists there too.

--L1c6L/cjZjI9d0Eq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXapwJAAoJEORje4g2clin3lsQALlfrLPmJ7wSs7p58NOi65Ba
jtZh05DzgTDGXeABf2th8b6kT6SZ1g5L317A6AypbJPORuOOKWwJXo/rCRYbzrGD
+RLTZQZz3Z9m3i+YOWQwcixJwNpPSJ3YsAtZS7mamiPXG/rXT9MdJy0JJxtMBEoo
shx0+VGSrqRn4aNecDtpVaSGIClLKKpg4ec75k0YCsDOFHYbMIFUq4dnPuLIxuiO
hRmZ/EvtnZXkjGQxA+m9rJ7helpU5bHQ3YGPV8gm21rjw4R5AbGyuv6MCNGakCmR
wCfreSNvoz3MeEpPhvRzNcSMK+uedDxmbZMBHTWVx1hM8I3A/5qIbRF0EbjXjyaY
dKWvej08sR8ozUq4VfxXtMXjUqNXP9NpYHxgU8TzWhBJryDp+sF6GNIRf7ncm5NC
xNkUhFBCckjezgqpKhUxbcAoPonQKXNo9dkw7fFTm3UqI4C+43xpOazFO8w4KGA5
A+ayhXCVSNtVbBmOEownCl97os/VHIISnpKZ86OA7bxrbwzPF1nlxO0WiiHNmWKT
wm2cMzu3eCLaT8cJUYpqt6PswKvEonKfYp0B4oswc1HauM320A6yq0NMKdi138tB
DCZZc5Ica6eRqwef3CLXQZ7i4o8Dr6RILGfT/b+q1jdmikynKNRmNwlato6HIhce
OWQk0ULbTERqXAckiprB
=T/Vn
-----END PGP SIGNATURE-----

--L1c6L/cjZjI9d0Eq--
