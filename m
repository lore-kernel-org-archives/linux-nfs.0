Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60336 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758965AbbBIGBs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 01:01:48 -0500
Date: Mon, 9 Feb 2015 17:01:40 +1100
From: NeilBrown <neilb@suse.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 13/19] pnfs/blocklayout: correctly decrement extent
 length
Message-ID: <20150209170140.18f4d004@notabene.brown>
In-Reply-To: <1408637375-11343-14-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
	<1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-14-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/HKVpkV9fJFOiF0qdeKoezbD"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/HKVpkV9fJFOiF0qdeKoezbD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Aug 2014 11:09:29 -0500 Christoph Hellwig <hch@lst.de> wrote:

> When we do non-page sized reads we can underflow the extent_length variab=
le
> and read incorrect data.  Fix the extent_length calculation and change to
> defensive <=3D checks for the extent length in the read and write path.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Hi Christoph,
 I was reviewing this patch for possible backport.
As 'extent_length' is sector_t, it is unsigned (either u64 or unsigned long=
).

So comparing "<=3D 0" has the same effect as comparing "=3D=3D 0".
So the new checks are not "defensive".

That doesn't mean they are wrong, but they could be misleading...

There may be nothing that needs to be done here, but I thought I should let
you know.

NeilBrown

> ---
>  fs/nfs/blocklayout/blocklayout.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blockl=
ayout.c
> index 5427ae7..87a633d 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -272,7 +272,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>  	isect =3D (sector_t) (f_offset >> SECTOR_SHIFT);
>  	/* Code assumes extents are page-aligned */
>  	for (i =3D pg_index; i < hdr->page_array.npages; i++) {
> -		if (!extent_length) {
> +		if (extent_length <=3D 0) {
>  			/* We've used up the previous extent */
>  			bl_put_extent(be);
>  			bl_put_extent(cow_read);
> @@ -303,6 +303,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>  			f_offset +=3D pg_len;
>  			bytes_left -=3D pg_len;
>  			isect +=3D (pg_offset >> SECTOR_SHIFT);
> +			extent_length -=3D (pg_offset >> SECTOR_SHIFT);
>  		} else {
>  			pg_offset =3D 0;
>  			pg_len =3D PAGE_CACHE_SIZE;
> @@ -333,7 +334,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>  			}
>  		}
>  		isect +=3D (pg_len >> SECTOR_SHIFT);
> -		extent_length -=3D PAGE_CACHE_SECTORS;
> +		extent_length -=3D (pg_len >> SECTOR_SHIFT);
>  	}
>  	if ((isect << SECTOR_SHIFT) >=3D header->inode->i_size) {
>  		hdr->res.eof =3D 1;
> @@ -797,7 +798,7 @@ next_page:
>  	/* Middle pages */
>  	pg_index =3D header->args.pgbase >> PAGE_CACHE_SHIFT;
>  	for (i =3D pg_index; i < header->page_array.npages; i++) {
> -		if (!extent_length) {
> +		if (extent_length <=3D 0) {
>  			/* We've used up the previous extent */
>  			bl_put_extent(be);
>  			bl_put_extent(cow_read);


--Sig_/HKVpkV9fJFOiF0qdeKoezbD
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVNhNRDnsnt1WYoG5AQJTSg//Y5rL4XiULzQ2LYGxWW61NiDtMzHo/Bor
72N9lRnAIm+Mmhg2CzXlGFH/aXTZcOonf+Vp0bbSRzpP3ZrB+saPGdbMZgciZFbA
V6frikf4BP9/ahc1UQHMhkvPFPwAdsouEKEoezAmAs8iaRWyJioxksXCoQNIDoXj
lCC1iADEMBgiGPm9OQ401bmXHk+X7ieshQXNLrka6TSZbuK6qOYIP4yY5/NXsw4t
3mzQ6RImdlorNJ6hk7oeLbqZ1fcaZRAkMz3LiYSXl5peqfqZ6KBU2rtGhUl9sgq+
9zz498CVODBZnBS80IcmIlcuJsAIho0uHlWF9AcatIGGJRlEQWxhQIVmZqUBqTY/
k4vwd9V69JvPEP0VQnbRZSZQNkVnS3WT1sK8yMVtGRUwVCgnCwgvBMBWrN9LTO16
JutpxPnjQEeNr8uFNS+5ObvtMBAgYLHR5bRDSMPfXz4ClWJfkcGNtEyNxOtYWNqc
6VS4usdvYSA3b3H7TvLx9mOKWz7UzckLINF403R6RxqAEm2IJ483dsKJlBzG8qZD
dkPuLNId4udA34RdTJOTxkGBUfFlf7Y+7QCqaZxskn9raR5e7aoxLUvLNP9zQ5fX
Qycx6TaxbiL2WIFCr4Al5icnrFxko7jqDR5g740P/K6bvAHbJc+WqhjU8AWMtcid
kr0vEO/pXnI=
=zL6+
-----END PGP SIGNATURE-----

--Sig_/HKVpkV9fJFOiF0qdeKoezbD--
