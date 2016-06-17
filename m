Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56852 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453AbcFQJUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2016 05:20:34 -0400
Date: Fri, 17 Jun 2016 12:20:18 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagigrim@gmail.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160617092018.GZ5408@leon.nu>
Reply-To: leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lUFOiBjYbj2M+tdK"
In-Reply-To: <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--lUFOiBjYbj2M+tdK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 05:58:29PM -0400, Chuck Lever wrote:
>=20
> > On Jun 16, 2016, at 5:10 PM, Sagi Grimberg <sagigrim@gmail.com> wrote:
> >=20
> >=20
> >>>> On Jun 15, 2016, at 12:28 AM, Leon Romanovsky <leon@kernel.org> wrot=
e:
> >>>>=20
> >>>> On Tue, Jun 14, 2016 at 11:15:25PM -0400, Chuck Lever wrote:
> >>>>> From: Sagi Grimberg <sagi@grimberg.me>
> >>>>>=20
> >>>>> kmalloc doesn't guarantee the returned memory is all on one page.
> >>>>=20
> >>>> IMHO, the patch posted by Christoph at that thread is best way to go,
> >>>> because you changed streaming DMA mappings to be coherent DMA mappin=
gs [1].
> >>>>=20
> >>>> "The kernel developers recommend the use of streaming mappings over
> >>>> coherent mappings whenever possible" [1].
> >>>>=20
> >>>> [1] http://www.makelinux.net/ldd3/chp-15-sect-4
> >>>=20
> >>> Hi Leon-
> >>>=20
> >>> I'll happily drop this patch from my 4.8 series as soon
> >>> as an official mlx4/mlx5 fix is merged.
> >>>=20
> >>> Meanwhile, I notice some unexplained instability (driver
> >>> resets, list corruption, and so on) when I test NFS/RDMA
> >>> without this patch included. So it is attached to the
> >>> series for anyone with mlx4 who wants to pull my topic
> >>> branch and try it out.
> >>=20
> >> hi Chuck,
> >>=20
> >> We plan to send attached patch during our second round of fixes for
> >> mlx4/mlx5 and would be grateful to you if you could provide your
> >> Tested-by tag before.
>=20
> Fwiw, Tested-by: Chuck Lever <chuck.lever@oracle.com>

Thanks, I appreciate it.

>=20
>=20
> > First of all, IIRC the patch author was Christoph wasn't he.
> >=20
> > Plus, you do realize that this patch makes the pages allocation
> > in granularity of pages. In systems with a large page size this
> > is completely redundant, it might even be harmful as the storage
> > ULPs need lots of MRs.
>=20
> I agree that the official fix should take a conservative
> approach to allocating this resource; there will be lots
> of MRs in an active system. This fix doesn't seem too
> careful.

In mlx5 system, we always added 2048 bytes to such allocations, for
reasons unknown to me. And it doesn't seem as a conservative approach
either.

>=20
>=20
> > Also, I don't see how that solves the issue, I'm not sure I even
> > understand the issue. Do you? Were you able to reproduce it?
>=20
> The issue is that dma_map_single() does not seem to DMA map
> portions of a memory region that are past the end of the first
> page of that region. Maybe that's a bug?

No, I didn't find support for that. Function dma_map_single expects
contiguous memory aligned to cache line, there is no limitation to be
page bounded.

>=20
> This patch works around that behavior by guaranteeing that
>=20
> a) the memory region starts at the beginning of a page, and
> b) the memory region is never larger than a page

b) the memory region ends on cache line.

>=20
> This patch is not sufficient to repair mlx5, because b)
> cannot be satisfied in that case; the array of __be64's can
> be larger than 512 entries.
>=20
>=20
> > IFF the pages buffer end not being aligned to a cacheline is problematic
> > then why not extent it to end in a cacheline? Why in the next full page?
>=20
> I think the patch description justifies the choice of
> solution, but does not describe the original issue at
> all. The original issue had nothing to do with cacheline
> alignment.

I disagree, kmalloc with supplied flags will return contiguous memory
which is enough for dma_map_single. It is cache line alignment.

>=20
> Lastly, this patch should remove the definition of
> MLX4_MR_PAGES_ALIGN.

Thanks, I missed it.

>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20

--lUFOiBjYbj2M+tdK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXY8DSAAoJEORje4g2clinAJsP/0dnIisWtTT89E6mPsNH5AMO
U4orv8SEJLHJUNC6vqYRdXEPIlm4KPSpQ1k0S32ma6yhoMaLzFbkjX7W0a6WsZHq
P0zxWcCy8IwJvesyhXugZWzHCEzVLqPLgYh75hBjlx2nrPyhZTqJ4/0KfV0tm9Su
tKrznyUF7OhBsFQn9QV6m7/c+USz5I3+OqOWiahrDcA65A7/axdZt9PRqfkcZAb/
LJlK/ZYvR0gS0iiNxP0dGESbUeLaOs5Y8AVnDdW9Oxqvuu9iiYilhu2e72qEs5/s
YL4P6vSFUutnDW/EZdfr8aaMAz4qz1rYDffTEcb/ODonwGJ3MiSJDW3xBlJ1ekk2
M7pUmdoCztFlq4kd6LOBiYrVLIyirlXkWZ2v9x1scvuCd1zwidG5XC5ZeYAZ2b2L
Di0bXx1lqibVWg9I5A5bOGCeGJ+TikLRzmQSxKntVcjdhp+0mq4RXsb6oCCXwiWO
o4OzHXMAc01pKIsajqOtorxsRbP9nnQdAd4YNOixMBXDtAmz1hb/EyfQW1MhzxyT
LrjxP7M2qPqKUY7qxKmOPPBJa3BwCuw5g8dNhoPWQIiKxz9/rrqhkCRxX4u+0PPG
k+WanS32xOrIdQraAynkuxVvk2wnBKMmzFvezXh4PGG2fyJzarF8+uIJNfipEszZ
xuzooa1Yr1G6J/sVNjOA
=8LY4
-----END PGP SIGNATURE-----

--lUFOiBjYbj2M+tdK--
