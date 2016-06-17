Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55014 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbcFQJFz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2016 05:05:55 -0400
Date: Fri, 17 Jun 2016 12:05:41 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Sagi Grimberg <sagigrim@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160617090541.GY5408@leon.nu>
Reply-To: leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="g3W8FGNyQaC+nhss"
In-Reply-To: <576315C9.30002@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--g3W8FGNyQaC+nhss
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 17, 2016 at 12:10:33AM +0300, Sagi Grimberg wrote:
>=20
> >>>On Jun 15, 2016, at 12:28 AM, Leon Romanovsky <leon@kernel.org> wrote:
> >>>
> >>>On Tue, Jun 14, 2016 at 11:15:25PM -0400, Chuck Lever wrote:
> >>>>From: Sagi Grimberg <sagi@grimberg.me>
> >>>>
> >>>>kmalloc doesn't guarantee the returned memory is all on one page.
> >>>
> >>>IMHO, the patch posted by Christoph at that thread is best way to go,
> >>>because you changed streaming DMA mappings to be coherent DMA mappings=
 [1].
> >>>
> >>>"The kernel developers recommend the use of streaming mappings over
> >>>coherent mappings whenever possible" [1].
> >>>
> >>>[1] http://www.makelinux.net/ldd3/chp-15-sect-4
> >>
> >>Hi Leon-
> >>
> >>I'll happily drop this patch from my 4.8 series as soon
> >>as an official mlx4/mlx5 fix is merged.
> >>
> >>Meanwhile, I notice some unexplained instability (driver
> >>resets, list corruption, and so on) when I test NFS/RDMA
> >>without this patch included. So it is attached to the
> >>series for anyone with mlx4 who wants to pull my topic
> >>branch and try it out.
> >
> >hi Chuck,
> >
> >We plan to send attached patch during our second round of fixes for
> >mlx4/mlx5 and would be grateful to you if you could provide your
> >Tested-by tag before.
>=20
> First of all, IIRC the patch author was Christoph wasn't he.

Do you think that author's name can provide different results in
verification/bug reproduction? We didn't send this patch officially
yet and all relevant authors will be acknowledged and honored when the
official (second round of IB fixes) will come.

>=20
> Plus, you do realize that this patch makes the pages allocation
> in granularity of pages. In systems with a large page size this
> is completely redundant, it might even be harmful as the storage
> ULPs need lots of MRs.

I see proper execution of the driver as an important goal which goes
before various micro optimizations, which will come after.

id you ask yourself, why are not so many users use that ARCH_KMALLOC_MINALI=
GN?

=E2=9E=9C  linux-rdma git:(master) grep -rI ARCH_KMALLOC_MINALIGN drivers/*
drivers/infiniband/hw/mlx4/mr.c:        add_size =3D max_t(int, MLX4_MR_PAG=
ES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
drivers/infiniband/hw/mlx5/mr.c:        add_size =3D max_t(int, MLX5_UMR_AL=
IGN - ARCH_KMALLOC_MINALIGN, 0);
drivers/md/dm-crypt.c:                ARCH_KMALLOC_MINALIGN);
drivers/usb/core/buffer.c:       * ARCH_KMALLOC_MINALIGN.
drivers/usb/core/buffer.c:      if (ARCH_KMALLOC_MINALIGN <=3D 32)
drivers/usb/core/buffer.c:      else if (ARCH_KMALLOC_MINALIGN <=3D 64)
drivers/usb/core/buffer.c:      else if (ARCH_KMALLOC_MINALIGN <=3D 128)
drivers/usb/misc/usbtest.c:     return (unsigned long)buf & (ARCH_KMALLOC_M=
INALIGN - 1);

>=20
> Also, I don't see how that solves the issue, I'm not sure I even
> understand the issue. Do you? Were you able to reproduce it?

Yes, the issue is that address supplied to dma_map_single wasn't aligned
to DMA cacheline size.

And as the one, who wrote this code for mlx5, it will be great if you
can give me a pointer. Why did you chose to use MLX5_UMR_ALIGN in that
function? This will add 2048 bytes instead of 64 for mlx4.

>=20
> IFF the pages buffer end not being aligned to a cacheline is problematic
> then why not extent it to end in a cacheline? Why in the next full page?

It will fit in one page.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--g3W8FGNyQaC+nhss
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXY71lAAoJEORje4g2clinSWgP/20EKA5ueyxu4UC5Xwg8RsuX
QaRpvXGbq7Fx874KHqcXeci/Rh5kK6WlKOv/vHO4S4m6DmBWKdfbNFgQ3SZYGD5D
LQmJDVHQ48BRb+bj3LiY+2Kv6VxSQWLW6DZ+BTx38eqsWxS1UkdBvgDPxTnxaKIo
E8M2623v8ZiUsHLtV84gBMCFIUkB8OApVq+s5O0LrsBQKyBJZqv3pSPi2M31lIuT
THjrMEN7BH4GL5VoMcwnWAcTp0ZNUqeolRspLen0Fh3pPoqKIgSxKn5jUuAB1/t+
svmg3dFvmChp+ootvb5PsudHRpqa3QwgSiYeEbEec5PIIu1yUxmZXjuZgjyP8INU
8wtbxjZoPjmYXj6a2+uBPB5Jl7MJovRGZZeX/iaqXaM3BoFM0uLRcwVx9dmLXZmk
cTTeue27XwEkfYAOGJuiflSxzWUd3pIpZakrARwvMZEfx/FbhHgHSTvHUzRd5YS9
CQq300VI9m6hHDiuAROSE1R54v7llS6asj4gjRnVylZV357UIlX2bFrUnt8/iA7H
XvdWuw8BWwsjtN9hK1V4rGSLvOq52vakQBBrX9uxW9/kXKkN3LazFhztljdLe+mq
0jVGFVajp9aa2AWNHDtxVkn81oL6Hi4iTZMI1P/1YaDkVA+2IYbOFSBAfiyAz3vP
KiGkjseI0WEaAeB3XViq
=Lid/
-----END PGP SIGNATURE-----

--g3W8FGNyQaC+nhss--
