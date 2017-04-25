Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44550 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S980207AbdDYDPb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 23:15:31 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 25 Apr 2017 13:15:24 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170424212031.GB1585@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <20170420161935.GB4782@fieldses.org> <20170421211253.GE19775@fieldses.org> <87vapurci7.fsf@notabene.neil.brown.name> <20170424140642.GB30046@fieldses.org> <20170424211920.GA1585@fieldses.org> <20170424212031.GB1585@fieldses.org>
Message-ID: <87o9vlp48j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 24 2017, J. Bruce Fields wrote:

> And, another problem spotted by the Synposys folks.
>
> I'll give these some more testing and hope to send a pull request in
> another day or two.
>
> --b.
>
> commit a0aa2db91590
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
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>

The code looks right ... but ...=20

>
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index dba2ff8eaa68..41cc47bf9d00 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -358,6 +358,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  {
>  	unsigned int len, v, hdr, dlen;
>  	u32 max_blocksize =3D svc_max_payload(rqstp);
> +	struct kvec *head =3D rqstp->rq_arg.head;
>=20=20
>  	p =3D decode_fh(p, &args->fh);
>  	if (!p)
> @@ -367,6 +368,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be=
32 *p,
>  	args->count =3D ntohl(*p++);
>  	args->stable =3D ntohl(*p++);
>  	len =3D args->len =3D ntohl(*p++);
> +	if ((void *)p > head->iov_base + head->iov_len)
> +		return 0;

I'm in two minds here.
On the one hand, the change for NFSv2 could be used here unchanged,
which would make the change slightly smaller and easier to review as
two parts would be identical.

On the other hand I think there is value in defining the "head" local
variable, but to fully realize that value you would need to define
"tail" as well, and then change

	dlen =3D rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
		+ rqstp->rq_arg.tail[0].iov_len - hdr;

to

        dlen =3D head->iov_len + rqstp->rq_arg.page_len + tail->iov_len - h=
dr;

i.e. either keep it simple (like the v2 code) or make it tidy (with head
and tail), but not half-and-half??


>  	/*
>  	 * The count must equal the amount of data passed.
>  	 */
> @@ -466,11 +469,15 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, =
__be32 *p,
>  	len =3D ntohl(*p++);
>  	if (len =3D=3D 0 || len > NFS3_MAXPATHLEN || len >=3D PAGE_SIZE)
>  		return 0;
> +	if (!*(rqstp->rq_next_page))
> +		return 0;

Why the extra parentheses?  "->" is at the highest precedence level for C.

>  	args->tname =3D new =3D page_address(*(rqstp->rq_next_page++));
>  	args->tlen =3D len;
>  	/* first copy and check from the first page */
>  	old =3D (char*)p;
>  	vec =3D &rqstp->rq_arg.head[0];
> +	if ((void *)old > vec->iov_base + vec->iov_len)
> +		return 0;
>  	avail =3D vec->iov_len - (old - (char*)vec->iov_base);

We seem to be repeating a calculation here.
I would prefer to make 'avail' a signed int then add

        if (avail < 0)
              return 0;

That would seem more "obviously correct".

But the code is correct as it stands.
Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


>  	while (len && avail && *old) {
>  		*new++ =3D *old++;
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 41b468a6a90f..7a0eed7c619d 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -301,6 +301,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be3=
2 *p,
>  	 * bytes.
>  	 */
>  	hdr =3D (void*)p - rqstp->rq_arg.head[0].iov_base;
> +	if (hdr > rqstp->rq_arg.head[0].iov_len)
> +		return 0;
>  	dlen =3D rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
>  		- hdr;
>=20=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj+v0wACgkQOeye3VZi
gbkixhAAlOqCFQanw/ItQuigbLhSpD39EmEkEmKrXaskBrWcfhlr6WIwrhWuL8iR
WjtFH43PJHNcWZj8I4Bjv/c8+oM84m+kS8YdFsZv0GqqTc0ogzAMo0U7Bceb2pTe
jaf2IXedJP73PWl/wvw7RoK/76djjd+VrhQ3zNnK0RprUiKe43FQiuBXrz6W3g7y
tn5v27GjuIFDNcVUKTPadKqiEDYkQ3ICWvzAn0JmJPC7jn9UQPFBpKycWBldcPjB
S+Qz4XWu+baHlEjr5c9kF+rIIEdzbGPboPPsdXHw4cbbyU3OIYPqI+EEcp8Isnk6
wkFMOMThW9clyTUeUIBfTtr7yesnHwY//I3U776Ih2oPbqxwuPeSH5jH5rrBnbYO
bl04Ij4xBGKmnn4z4+Xl3AmdkVgHj3037WFNjiv1HLCwu2XapsW4QIWNw9UYdT7E
7CoaMbq9OhhqVBIdmcB5tVGS0rOZVbo13SKTy34n0WCFNNJFhikZGIJ/V1LLrPCP
icP0Jc2EPWMqn648o0i2ngUH2/4MOid4VEhV9hWteyc2Yq6rYjIgpxF0TcqPXQ3Y
OXicZDNebKVX/q7PWSoXtTK9stdApBIaS69mqWTJktMhMr7k4icYmip2AEKXAaIF
5DyJ7ufm74lDxFhETzMvdxaSlco9YJcS7ihJQmXXp8FfZhNhipg=
=hQMY
-----END PGP SIGNATURE-----
--=-=-=--
