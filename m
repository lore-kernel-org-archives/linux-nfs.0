Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44540 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbcFPOfs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2016 10:35:48 -0400
Date: Thu, 16 Jun 2016 17:35:18 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160616143518.GX5408@leon.nu>
Reply-To: leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gpOboRovIPmaBszt"
In-Reply-To: <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gpOboRovIPmaBszt
Content-Type: multipart/mixed; boundary="dnBRaVjvtun1Q0Od"
Content-Disposition: inline


--dnBRaVjvtun1Q0Od
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 15, 2016 at 12:40:07PM -0400, Chuck Lever wrote:
>=20
> > On Jun 15, 2016, at 12:28 AM, Leon Romanovsky <leon@kernel.org> wrote:
> >=20
> > On Tue, Jun 14, 2016 at 11:15:25PM -0400, Chuck Lever wrote:
> >> From: Sagi Grimberg <sagi@grimberg.me>
> >>=20
> >> kmalloc doesn't guarantee the returned memory is all on one page.
> >=20
> > IMHO, the patch posted by Christoph at that thread is best way to go,
> > because you changed streaming DMA mappings to be coherent DMA mappings =
[1].
> >=20
> > "The kernel developers recommend the use of streaming mappings over
> > coherent mappings whenever possible" [1].
> >=20
> > [1] http://www.makelinux.net/ldd3/chp-15-sect-4
>=20
> Hi Leon-
>=20
> I'll happily drop this patch from my 4.8 series as soon
> as an official mlx4/mlx5 fix is merged.
>=20
> Meanwhile, I notice some unexplained instability (driver
> resets, list corruption, and so on) when I test NFS/RDMA
> without this patch included. So it is attached to the
> series for anyone with mlx4 who wants to pull my topic
> branch and try it out.

hi Chuck,

We plan to send attached patch during our second round of fixes for
mlx4/mlx5 and would be grateful to you if you could provide your
Tested-by tag before.

Thanks

--dnBRaVjvtun1Q0Od
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="213f61b4.diff"
Content-Transfer-Encoding: quoted-printable

=46rom 213f61b44b54edbcbf272e694e889c61412be579 Mon Sep 17 00:00:00 2001
=46rom: Yishai Hadas <yishaih@mellanox.com>
Date: Thu, 16 Jun 2016 11:13:41 +0300
Subject: [PATCH] IB/mlx4: Ensure cache line boundaries for dma_map_single

"In order for memory mapped by this API to operate
correctly, the mapped region must begin exactly on a cache line
boundary and end exactly on one (to prevent two separately mapped
regions from sharing a single cache line).
Therefore, it is recommended that driver writers who
don't take special care to determine the cache line size at run time
only map virtual regions that begin and end on page boundaries (which
are guaranteed also to be cache line boundaries)." [1]

This patch uses __get_free_pages instead of kzalloc
to be sure that above will be true in all ARCHs and in all
SLUBs debug configurations.

[1] https://www.kernel.org/doc/Documentation/DMA-API.txt

issue: 802618
Change-Id: Iee8176b183290213b1b4e66f1835f5c90f067075
Fixes: 1b2cd0fc673c ('IB/mlx4: Support the new memory registration API')
Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
---

diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/m=
lx4/mlx4_ib.h
index 6c5ac5d..4a8bbe4 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -139,7 +139,6 @@
 	u32			max_pages;
 	struct mlx4_mr		mmr;
 	struct ib_umem	       *umem;
-	void			*pages_alloc;
 };
=20
 struct mlx4_ib_mw {
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/m=
r.c
index 6312721..56b8d87 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -278,16 +278,12 @@
 		      int max_pages)
 {
 	int size =3D max_pages * sizeof(u64);
-	int add_size;
 	int ret;
=20
-	add_size =3D max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
-
-	mr->pages_alloc =3D kzalloc(size + add_size, GFP_KERNEL);
-	if (!mr->pages_alloc)
+	mr->pages =3D (__be64 *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					       get_order(size));
+	if (!mr->pages)
 		return -ENOMEM;
-
-	mr->pages =3D PTR_ALIGN(mr->pages_alloc, MLX4_MR_PAGES_ALIGN);
=20
 	mr->page_map =3D dma_map_single(device->dma_device, mr->pages,
 				      size, DMA_TO_DEVICE);
@@ -299,7 +295,7 @@
=20
 	return 0;
 err:
-	kfree(mr->pages_alloc);
+	free_pages((unsigned long)mr->pages, get_order(size));
=20
 	return ret;
 }
@@ -313,7 +309,7 @@
=20
 		dma_unmap_single(device->dma_device, mr->page_map,
 				 size, DMA_TO_DEVICE);
-		kfree(mr->pages_alloc);
+		free_pages((unsigned long)mr->pages, get_order(size));
 		mr->pages =3D NULL;
 	}
 }

--dnBRaVjvtun1Q0Od--

--gpOboRovIPmaBszt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXYrkmAAoJEORje4g2clinb34P/3ocx9uPuQTAKVW29cRgSh3w
Yq8gJMbB6VXw/x9ecuGiDZI3cI7MiJkLyKafuLi/o5HwGBFnW67At68Ub0WR5Wja
z4bb4SUPdu9b0YRubf01pXDkvvAw/wMmcF0CJd60dhb3apEWpbYhIN7MN2E3Kv/t
D1Yn5NK0FhqbPuIyltpIEIs8SEQmaYO1R/tYeVRVfvBLZItZw5tm3tqiYeRw2xAr
Q5qaenjqKhV9y6SQvKVqrXImbfpggAWiwvbNFKXgl7tUdUEe8khkJCJe702yZ2cQ
s7xRw1nLJ0MbjrWapv5XvDAzCsSDETt+wDYFZwWwPaqflcdWdw3gs8EhSSPAzGRV
sZFKTObnxaOOSXjS3Y53JbpjMZLDssRDR4OVMLncJZoifbwmE/bCkPTaU5CzyQb1
QgwvkTPIFSqUKSSpfBNeRkB+g6fAiZZSPVgnANy0mS/FNYfu3icp+SKQK3R0noU5
4/xL90r1B0Dq0MQsBCDoCWeIJLcMQ8m7GBEP+dG+E2WHdyAQR2G6vzsvKAuBSy7K
MyMQZ6KcAMbZEVMS4dFna5L5E5mnx8LiNEMcWHDXZgYFdvJsl2aByHP9EchwMPmZ
S1+8houprDA1uuhtdlRFIkNVV7Tx96vvCZfk19kbZB/Rb1BNSx46B/inID2uKqWx
GHU9SUZdIbEHFDANuJyX
=vF74
-----END PGP SIGNATURE-----

--gpOboRovIPmaBszt--
