Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40963 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbcKRFBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 00:01:17 -0500
From: NeilBrown <neilb@suse.com>
To: Andy Adamson <andros@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Nov 2016 16:01:09 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4.1: nfs4_fl_prepare_ds must be careful about reporting success.
In-Reply-To: <87lgxiwoxi.fsf@notabene.neil.brown.name>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name>
Message-ID: <8760nlfkkq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Ping?
No sign of this in linux-next, and no replies....

Thanks,
NeilBrown


On Fri, Oct 21 2016, NeilBrown wrote:

>
> Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL
> 'ds', then ds->ds_clp will also be non-NULL.
>
> This is not necessasrily true in the case when the process received a
> fatal signal while nfs4_pnfs_ds_connect is waiting in
> nfs4_wait_ds_connect().  In that case ->ds_clp may not be set, and the
> devid may not recently have been marked unavailable.
>
> So add a test for ->ds_clp =3D=3D NULL and return NULL in that case.
>
> Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/filelayout/filelayoutdev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filela=
youtdev.c
> index 4946ef40ba87..85ef38f9765f 100644
> --- a/fs/nfs/filelayout/filelayoutdev.c
> +++ b/fs/nfs/filelayout/filelayoutdev.c
> @@ -283,7 +283,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, =
u32 ds_idx)
>  			     s->nfs_client->cl_rpcclient->cl_auth->au_flavor);
>=20=20
>  out_test_devid:
> -	if (filelayout_test_devid_unavailable(devid))
> +	if (ret->ds_clp =3D=3D NULL ||
> +	    filelayout_test_devid_unavailable(devid))
>  		ret =3D NULL;
>  out:
>  	return ret;
> --=20
> 2.10.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYLosWAAoJEDnsnt1WYoG5C3EQAMSOb7i69dLdAdfagrVeFBwU
3LM0uaYY8x2r4eS0qtbOATYZEXnW9Rg9dbDlaV5FjQPmxlL13vTpRAkVvssRV1nm
yIqoYu/DweFZM0pbZTvCz2NWDkkhj5bb2GqQEln/ba+CJj/Jbv91N+DJgQ47cjtq
+BQoExKzDTDRI0ysKswqfIibcA5QUv/WqvqaOLzIYqjDG/s0aQwUSfuKAsf2n/ZS
KpE4gJRhhVd3XI/zMKrb8GNdte2jc7sawt85dvz6IaqcYSWSusoutONOSPOCgVyP
YOxMXIlu3onCxvQR0F2m1QB9COxcF99eK/qxknXsfxVlQdo6pF5TzVSYSzy2fC/o
+RqnyRyaC/lo7jl/T9AUE914Bw4ujt3QgsK/W+bBfhn1CPKo3XKNxpq2JHuw/NhV
Y+FnBuyiYjhlXLe44RIiUALbN378m5W9VWuHG9/ZQxskS+NzXgItwS/FsLN1NAah
W7bc27gp8RKAz6SSfFmeyE7QxxgDwxv6ZcQFF7nlK/wFPp5nfmpi5Fuw2zVa2g+s
d3XxEOWiDEZAyXOznJoYr/kN4Ex2AyjaJ4bV9BtVPv0pFOzqB/iy1fjPCuUZHcYY
+5Ty5MFlyk2RNzMKczdgtIeXU4fFDlITFTu5YcSfV1kB+OtPF0a8tqjPU+OdH6/B
Z7V9++sc3JZypOvushnN
=I/Dl
-----END PGP SIGNATURE-----
--=-=-=--
