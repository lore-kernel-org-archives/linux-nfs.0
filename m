Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37774 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883AbcFRK44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jun 2016 06:56:56 -0400
Date: Sat, 18 Jun 2016 13:56:50 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagigrim@gmail.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160618105650.GD5408@leon.nu>
Reply-To: leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ht9V8wKec6a3w1Ef"
In-Reply-To: <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ht9V8wKec6a3w1Ef
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 17, 2016 at 03:55:56PM -0400, Chuck Lever wrote:
>=20
> > On Jun 17, 2016, at 5:20 AM, Leon Romanovsky <leon@kernel.org> wrote:
> >=20
> > On Thu, Jun 16, 2016 at 05:58:29PM -0400, Chuck Lever wrote:
> >>=20
> >>> On Jun 16, 2016, at 5:10 PM, Sagi Grimberg <sagigrim@gmail.com> wrote:
> >>=20
> >>> First of all, IIRC the patch author was Christoph wasn't he.
> >>>=20
> >>> Plus, you do realize that this patch makes the pages allocation
> >>> in granularity of pages. In systems with a large page size this
> >>> is completely redundant, it might even be harmful as the storage
> >>> ULPs need lots of MRs.
> >>=20
> >> I agree that the official fix should take a conservative
> >> approach to allocating this resource; there will be lots
> >> of MRs in an active system. This fix doesn't seem too
> >> careful.
> >=20
> > In mlx5 system, we always added 2048 bytes to such allocations, for
> > reasons unknown to me. And it doesn't seem as a conservative approach
> > either.
>=20
> The mlx5 approach is much better than allocating a whole
> page, when you consider platforms with 64KB pages.
>=20
> A 1MB payload (for NFS) on such a platform comprises just
> 16 pages. So xprtrdma will allocate MRs with support for
> 16 pages. That's a priv pages array of 128 bytes, and you
> just put it in a 64KB page all by itself.
>=20
> So maybe adding 2048 bytes is not optimal either. But I
> think sticking with kmalloc here is a more optimal choice.

I agree with your's and Sagi's points, just preferred working solution
over optimal. I'll send an optimal version.

>=20
>=20
> >>> Also, I don't see how that solves the issue, I'm not sure I even
> >>> understand the issue. Do you? Were you able to reproduce it?
> >>=20
> >> The issue is that dma_map_single() does not seem to DMA map
> >> portions of a memory region that are past the end of the first
> >> page of that region. Maybe that's a bug?
> >=20
> > No, I didn't find support for that. Function dma_map_single expects
> > contiguous memory aligned to cache line, there is no limitation to be
> > page bounded.
>=20
> There certainly isn't, but that doesn't mean there can't
> be a bug somewhere ;-) and maybe not in dma_map_single.
> It could be that the "array on one page only" limitation
> is somewhere else in the mlx4 driver, or even in the HCA
> firmware.

We checked with HW/FW/arch teams prior to respond.

>=20
>=20
> >> This patch works around that behavior by guaranteeing that
> >>=20
> >> a) the memory region starts at the beginning of a page, and
> >> b) the memory region is never larger than a page
> >=20
> > b) the memory region ends on cache line.
>=20
> I think we demonstrated pretty clearly that the issue
> occurs only when the end of the priv pages array crosses
> into a new page.
>=20
> We didn't see any problem otherwise.

SLUB debug do exactly one thing, change alignment and this is why no
issue there observed before.

>=20
> >> This patch is not sufficient to repair mlx5, because b)
> >> cannot be satisfied in that case; the array of __be64's can
> >> be larger than 512 entries.
> >>=20
> >>=20
> >>> IFF the pages buffer end not being aligned to a cacheline is problema=
tic
> >>> then why not extent it to end in a cacheline? Why in the next full pa=
ge?
> >>=20
> >> I think the patch description justifies the choice of
> >> solution, but does not describe the original issue at
> >> all. The original issue had nothing to do with cacheline
> >> alignment.
> >=20
> > I disagree, kmalloc with supplied flags will return contiguous memory
> > which is enough for dma_map_single. It is cache line alignment.
>=20
> The reason I find this hard to believe is that there is
> no end alignment guarantee at all in this code, but it
> works without issue when SLUB debugging is not enabled.
>=20
> xprtrdma allocates 256 elements in this array on x86.
> The code makes the array start on an 0x40 byte boundary.
> I'm pretty sure that means the end of that array will
> also be on at least an 0x40 byte boundary, and thus
> aligned to the DMA cacheline, whether or not SLUB
> debugging is enabled.
>=20
> Notice that in the current code, if the consumer requests
> an odd number of SGs, that array can't possibly end on
> an alignment boundary. But we've never had a complaint.
>=20
> SLUB debugging changes the alignment of lots of things,
> but mlx4_alloc_priv_pages is the only breakage that has
> been reported.

I think it is related to custom logic which is in this function only.
I posted grep output earlier to emphasize it.

For example adds 2K region after the actual data and it will ensure
alignment.

>=20
> DMA-API.txt says:
>=20
> > [T]he mapped region must begin exactly on a cache line
> > boundary and end exactly on one (to prevent two separately
> > mapped regions from sharing a single cache line)
>=20
> The way I read this, cacheline alignment shouldn't be
> an issue at all, as long as DMA cachelines aren't
> shared between mappings.
>=20
> If I simply increase the memory allocation size a little
> and ensure the end of the mapping is aligned, that should
> be enough to prevent DMA cacheline sharing with another
> memory allocation on the same page. But I still see Local
> Protection Errors when SLUB debugging is enabled, on my
> system (with patches to allocate more pages per MR).
>=20
> I'm not convinced this has anything to do with DMA
> cacheline alignment. The reason your patch fixes this
> issue is because it keeps the entire array on one page.

If you don't mind, we can do an experiment.
Let's add padding which will prevent alignment issue and
for sure will cross the page boundary.

diff --git a/drivers/infiniband/hw/mlx4/mr.c
b/drivers/infiniband/hw/mlx4/mr.c
index 6312721..41e277e 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -280,8 +280,10 @@ mlx4_alloc_priv_pages(struct ib_device *device,
        int size =3D max_pages * sizeof(u64);
	int add_size;
	int ret;
-
+/*
        add_size =3D max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN=
, 0);
+*/
+       add_size =3D 2048;

        mr->pages_alloc =3D kzalloc(size + add_size, GFP_KERNEL);
	if (!mr->pages_alloc)

--ht9V8wKec6a3w1Ef
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZSjyAAoJEORje4g2clinhhwQAMjeGpDZcbZHkShQb8UUrnLN
D9KlFfcdA7P8+hiNP8LfqB1/xqR8eOOOJWYol6Ui1K5YdB6KhGEXKLYymHVqNGvh
z9IJKPn6H7eXx+CG8tvjmD84RLWGFQ/ozs1eAV1a+lcoFZtXVqaKmYxuGIHd1I0H
ji3GZ3IMURdku0oLwdZ+67jMqm4g/KyQg+v279lyeTtlVLXs6lnAeLzjYSQ/nLqO
trvBGTAJWsduxKAkAm7WI4h7mqZKuTGmJVwtoEPP7XEVh9Q3NxNHTlwmGDTmgbeL
uHL1yhCUx6NlwUE+YkySCLdWJ4KzlR8A1Q2xe0cd4Z14N6XOm2HBvw2PE5b2Ej53
tz1WQwA2/KSGocE0r41fa2f5sF/2KR8ahK7SppCbgHm+fiyjk1Ux+wjqKwtHhvVL
Bbhev6OlpLZCZk3uQ13DTtXXj3teJE6IT27/Vkx19pQ8dDBUh7YWdk5y/p6nfT3H
+LDNkULa7i3/k6Ebn6IzO8y83dOooRFqoHFaqx9qIs90otW0+HL/N0fCxcycp2j7
4Vgr1rtUZIs6o3LJKkzdjm50Hp2Zo30Cbc7ytncBdpjrHVCtCB9OSw5SQjANTk60
sk7NRdm4SeJoBpENWBe1tbe5VGlJR9aHJHNw+6/oo9ZXXQlKK5ED1StHpmI/a/3k
vXHtld0l6V4WfP7J0L+7
=2roq
-----END PGP SIGNATURE-----

--ht9V8wKec6a3w1Ef--
