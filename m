Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52592 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196AbcFVQAK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 12:00:10 -0400
Date: Wed, 22 Jun 2016 18:50:03 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagi@grimberg.me>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
Message-ID: <20160622155003.GI9762@leon.nu>
Reply-To: leon@kernel.org
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
 <576A9AE6.4070500@grimberg.me>
 <A9F49204-8E84-4B58-BAA4-5B4B360FD22F@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4LwthZj+AV2mq5CX"
In-Reply-To: <A9F49204-8E84-4B58-BAA4-5B4B360FD22F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--4LwthZj+AV2mq5CX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 22, 2016 at 10:47:27AM -0400, Chuck Lever wrote:
>=20
> > On Jun 22, 2016, at 10:04 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> >=20
> >=20
> >> +    /* This is overkill, but hardware requires that the
> >> +     * PBL array begins at a properly aligned address and
> >> +     * never occupies the last 8 bytes of a page.
> >> +     */
> >> +    mr->pages =3D (__be64 *)get_zeroed_page(GFP_KERNEL);
> >> +    if (!mr->pages)
> >>          return -ENOMEM;
> >=20
> > Again, I'm not convinced that this is a better choice then allocating
> > the exact needed size as dma coherent, but given that the dma coherent
> > allocations are always page aligned I wander if it's not the same
> > effect...
>=20
> My concerns with DMA coherent were:
>=20
> 1. That pool may be a somewhat limited resource?
>=20
> 2. IMO DMA-API.txt suggests DMA coherent will perform less
> well in some cases. Macro benchmarks I ran seemed to show
> there was a slight performance hit with that approach, though
> it was nearly in the noise.
>=20
> I agree that the over-allocation in the streaming solution is a
> concern. But as you say, there may be little we can do about it.

According to [1] dma_alloc_coherent doesn't allocate from pool, but
calls to the __get_free_page().

"A DMA pool is an allocation mechanism for small, coherent DMA mappings.
Mappings obtained from dma_alloc_coherent may have a minimum size of one
page."

>=20
> Wrt to Or's comment, the device's maximum page list depth
> is advertised to consumers via the device's attributes. However,
> it would be defensive if there was a sanity check added in
> mlx4_alloc_priv_pages to ensure that the max_pages argument
> is a reasonable value (ie, that the calculated array size does
> indeed fit into a page).
>=20
> > In any event, we can move forward with this for now:
> >=20
> > Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
>=20
> Thanks, I'll add that! Though as before, I'm happy to drop this
> patch if there is a different preferred official fix.

We submitted your version of patch with minor changes in
comments and commit message together with Sagi's ROB tag [2].

[1] http://www.makelinux.net/ldd3/chp-15-sect-4
[2] https://patchwork.kernel.org/patch/9193075/

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--4LwthZj+AV2mq5CX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXarOrAAoJEORje4g2clingvAP/jVdQGqSZBq7YP+BcQ35obVW
LFSXgub8Cf39/9yMHJQpR/NkiTTl3BuBUwK1DylCKxuce8F/bONWJCnTvUmEC6xK
UK5K31uYa9yPcw7LlR/5zHD/H1ChWyVIMr5tciQIwoLRkPXJeTLsBxNBr/yli6uc
L2U5bbHv+wJQXgaRLT4Nk6iVS4UQlI17dh9vD+QKLtnjlauSbajaJPBHBNPvtqZd
MBuiTkA9nr1aQUU5MplWigOSehruWs8MJmf4Y3nqgDpsIge4+Yyq1H+00mptTQJw
8pGp8hIWt0lWw0dSzNETN/BEikFBfAxiE9RGVVEFN93oFrcTBF00RA9D+pvyhY0F
USvDq0WHi1hBTGmHq8Fojd8Ad7HMVCTrAReqTZi48BjOCmWpcoU91aEKHFcNmnIW
yn+JcZ8VhGpC/98kZ3Lk7Z7t+wEds9zXxjFVmBdkgbVNci8TVjIABwpg3ECIHXpU
fj8wW9s+O+RzEeqrJXXZCbQUrnr2OdNnABwe62R3K3MaxK/Dw431jME6VdlcRkx4
DwVEJnp8R34TPkyHxAHH28Z/yinGASzygDlPma1wWASPJu6qR1lWUdYVEqfGTcvh
yaBEhxD0iyASIrVb3Do2xFuvDnKdDSyRVhqflBXLPkZ+d/JC8eGDEyWtWgDrF9s3
0ECihmYxd4hYYsgtai64
=fWQu
-----END PGP SIGNATURE-----

--4LwthZj+AV2mq5CX--
