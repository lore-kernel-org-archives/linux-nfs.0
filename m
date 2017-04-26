Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35571 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1435080AbdDZGcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Apr 2017 02:32:09 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 26 Apr 2017 16:31:59 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170425204016.GA15279@fieldses.org>
References: <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <20170420161935.GB4782@fieldses.org> <20170421211253.GE19775@fieldses.org> <87vapurci7.fsf@notabene.neil.brown.name> <20170424140642.GB30046@fieldses.org> <20170424211920.GA1585@fieldses.org> <20170424212031.GB1585@fieldses.org> <87o9vlp48j.fsf@notabene.neil.brown.name> <20170425204016.GA15279@fieldses.org>
Message-ID: <87inlrptls.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 25 2017, J. Bruce Fields wrote:

>> > +	if (!*(rqstp->rq_next_page))
>> > +		return 0;
>>=20
>> Why the extra parentheses?  "->" is at the highest precedence level for =
C.
>
> I've been doing this stuff enough years, you'd think I'd have bothered
> to memorize the C operator precedence table by now.
>
> Anyway, this change is actually unrelated and not entirely necessary;
> dropped.
>
>> i.e. either keep it simple (like the v2 code) or make it tidy (with head
>> and tail), but not half-and-half??
>
> What the heck, let's go all out.

Looks good, thanks.


>
> You only live once!

:-)

NeilBrown


>
> --b.
>
> commit db44bac41bbf
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Apr 25 16:21:34 2017 -0400
>
>     nfsd4: minor NFSv2/v3 write decoding cleanup
>=20=20=20=20=20
>     Use a couple shortcuts that will simplify a following bugfix.
>=20=20=20=20=20
>     Cc: stable@vger.kernel.org
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index dba2ff8eaa68..d18cfddbe115 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -358,6 +358,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  {
>  	unsigned int len, v, hdr, dlen;
>  	u32 max_blocksize =3D svc_max_payload(rqstp);
> +	struct kvec *head =3D rqstp->rq_arg.head;
> +	struct kvec *tail =3D rqstp->rq_arg.tail;
>=20=20
>  	p =3D decode_fh(p, &args->fh);
>  	if (!p)
> @@ -377,9 +379,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  	 * Check to make sure that we got the right number of
>  	 * bytes.
>  	 */
> -	hdr =3D (void*)p - rqstp->rq_arg.head[0].iov_base;
> -	dlen =3D rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
> -		+ rqstp->rq_arg.tail[0].iov_len - hdr;
> +	hdr =3D (void*)p - head->iov_base;
> +	dlen =3D head->iov_len + rqstp->rq_arg.page_len + tail->iov_len - hdr;
>  	/*
>  	 * Round the length of the data which was specified up to
>  	 * the next multiple of XDR units and then compare that
> @@ -396,7 +397,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  		len =3D args->len =3D max_blocksize;
>  	}
>  	rqstp->rq_vec[0].iov_base =3D (void*)p;
> -	rqstp->rq_vec[0].iov_len =3D rqstp->rq_arg.head[0].iov_len - hdr;
> +	rqstp->rq_vec[0].iov_len =3D head->iov_len - hdr;
>  	v =3D 0;
>  	while (len > rqstp->rq_vec[v].iov_len) {
>  		len -=3D rqstp->rq_vec[v].iov_len;
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 41b468a6a90f..59bd88a23a3d 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -280,6 +280,7 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be3=
2 *p,
>  					struct nfsd_writeargs *args)
>  {
>  	unsigned int len, hdr, dlen;
> +	struct kvec *head =3D rqstp->rq_arg.head;
>  	int v;
>=20=20
>  	p =3D decode_fh(p, &args->fh);
> @@ -300,9 +301,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be3=
2 *p,
>  	 * Check to make sure that we got the right number of
>  	 * bytes.
>  	 */
> -	hdr =3D (void*)p - rqstp->rq_arg.head[0].iov_base;
> -	dlen =3D rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
> -		- hdr;
> +	hdr =3D (void*)p - head->iov_base;
> +	dlen =3D head->iov_len + rqstp->rq_arg.page_len - hdr;
>=20=20
>  	/*
>  	 * Round the length of the data which was specified up to
> @@ -316,7 +316,7 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be3=
2 *p,
>  		return 0;
>=20=20
>  	rqstp->rq_vec[0].iov_base =3D (void*)p;
> -	rqstp->rq_vec[0].iov_len =3D rqstp->rq_arg.head[0].iov_len - hdr;
> +	rqstp->rq_vec[0].iov_len =3D head->iov_len - hdr;
>  	v =3D 0;
>  	while (len > rqstp->rq_vec[v].iov_len) {
>  		len -=3D rqstp->rq_vec[v].iov_len;
> commit 13bf9fbff0e5
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Apr 21 15:26:30 2017 -0400
>
>     nfsd: stricter decoding of write-like NFSv2/v3 ops
>=20=20=20=20=20
>     The NFSv2/v3 code does not systematically check whether we decode past
>     the end of the buffer.  This generally appears to be harmless, but th=
ere
>     are a few places where we do arithmetic on the pointers involved and
>     don't account for the possibility that a length could be negative.  A=
dd
>     checks to catch these.
>=20=20=20=20=20
>     Reported-by: Tuomas Haanp=C3=A4=C3=A4 <thaan@synopsys.com>
>     Reported-by: Ari Kauppi <ari@synopsys.com>
>     Reviewed-by: NeilBrown <neilb@suse.com>
>     Cc: stable@vger.kernel.org
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index d18cfddbe115..452334694a5d 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -369,6 +369,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  	args->count =3D ntohl(*p++);
>  	args->stable =3D ntohl(*p++);
>  	len =3D args->len =3D ntohl(*p++);
> +	if ((void *)p > head->iov_base + head->iov_len)
> +		return 0;
>  	/*
>  	 * The count must equal the amount of data passed.
>  	 */
> @@ -472,6 +474,8 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __=
be32 *p,
>  	/* first copy and check from the first page */
>  	old =3D (char*)p;
>  	vec =3D &rqstp->rq_arg.head[0];
> +	if ((void *)old > vec->iov_base + vec->iov_len)
> +		return 0;
>  	avail =3D vec->iov_len - (old - (char*)vec->iov_base);
>  	while (len && avail && *old) {
>  		*new++ =3D *old++;
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 59bd88a23a3d..de07ff625777 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -302,6 +302,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be3=
2 *p,
>  	 * bytes.
>  	 */
>  	hdr =3D (void*)p - head->iov_base;
> +	if (hdr > head->iov_len)
> +		return 0;
>  	dlen =3D head->iov_len + rqstp->rq_arg.page_len - hdr;
>=20=20
>  	/*
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkAPt8ACgkQOeye3VZi
gbli3w//fGQ0k/RztlS0lw8Yx/srm/7+hxiJyJ5HA2puYvMsBZIf0G2wxVDiurI8
IwJuLFQSuk6CpLVnfMETzpt361OItRthCETGc/BmZcdHwSx8egvag3I9puYE+EO2
F1SeNVXgSIIWIGmdqsYckqsei4gRW/3iuufsGzAYkOR4aH/FU6tKC7An0wfCeuT3
e1M0G73ckMkPdNvncj0Ra5jUKpf4Bus1IpmuTjEXycUQmJpHVs0JWWlDnTcCvorx
IIHSRJDZnX730zXCqwzBsuqjuqkj6fha9YD9KotNnH3Od6t5fH0wN+p7pt70CDzm
2XhIn+18+sdjSmS+NINHgNqYnO7+llkSbmiZsmKRcyFW5uZ88Uwcw2bAXajpgCcl
l/ptgHhhR/v9NI/6ysiRCA+q59BU4Ov0csKIA+h9Cg03+g5/8BzxbII7cJUY+qQ9
kDwSVnkSO8Dwmdb3B6qhUHy67x/aVwbKpzdtN9QtsDNOCpwZlW7RbpuKq4ZyVrmQ
yMHS5AkQfGP30mk5ops6iUB0eXcozjfJUALqEA+8c3O2AQWXwniCtGu6F2iF5krh
TPqD09bY7P4s2WD7FwXySiFJIybrPj7XYk7rg18XJxwcS3ym/SFMW8XEJAsiwEQo
bGD5MXeZCjsoS7SlOlYDsdcf/YvmGhPiNN2GFeLuY1HqGYeKfIw=
=ucA4
-----END PGP SIGNATURE-----
--=-=-=--
