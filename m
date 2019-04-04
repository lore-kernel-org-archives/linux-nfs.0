Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65783C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 22:48:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F818217D4
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 22:48:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730447AbfDDWr7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 18:47:59 -0400
Received: from mx2.suse.de ([195.135.220.15]:50124 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730437AbfDDWr7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Apr 2019 18:47:59 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 142BCAF68;
        Thu,  4 Apr 2019 22:47:57 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Murphy Zhou <jencce.kernel@gmail.com>, linux-nfs@vger.kernel.org
Date:   Fri, 05 Apr 2019 09:47:51 +1100
Cc:     bfields@fieldses.org, jlayton@kernel.org,
        Murphy Zhou <jencce.kernel@gmail.com>
Subject: Re: [PATCH v2] nfsd/nfsd3_proc_readdir: fix buffer count and page pointers
In-Reply-To: <20190404065711.19763-1-jencce.kernel@gmail.com>
References: <20190404065711.19763-1-jencce.kernel@gmail.com>
Message-ID: <87mul5z8tk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04 2019, Murphy Zhou wrote:

> After this commit
>   f875a79 nfsd: allow nfsv3 readdir request to be larger.
> nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
> directory been read is large enough, we can use multiple pages
> in rq_respages. Update buffer count and page pointers like we do
> in readdirplus to make this happen.
>
> Now listing a directory within 3000 files will panic because we
> are counting in a wrong way and would write on random page.
>
> Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
> Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
> ---
>
> v2:
>   fix nfs3svc_decode_readdirargs to set page pointers like decode_readdir=
plusargs
>   do not test pointers in encode_entry as we've fixed them when decoding
>
>  fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
>  fs/nfsd/nfs3xdr.c  | 11 +++++++++--
>  2 files changed, 24 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 8f933e8..9bc32af 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -442,7 +442,9 @@
>  	struct nfsd3_readdirargs *argp =3D rqstp->rq_argp;
>  	struct nfsd3_readdirres  *resp =3D rqstp->rq_resp;
>  	__be32		nfserr;
> -	int		count;
> +	int		count =3D 0;
> +	struct page	**p;
> +	caddr_t		page_addr =3D NULL;
>=20=20
>  	dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
>  				SVCFH_fmt(&argp->fh),
> @@ -462,7 +464,18 @@
>  	nfserr =3D nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie,=20
>  					&resp->common, nfs3svc_encode_entry);
>  	memcpy(resp->verf, argp->verf, 8);
> -	resp->count =3D resp->buffer - argp->buffer;
> +	count =3D 0;

Thanks - looks good.
Setting 'count' to zero a second time looks a bit clumsy, but that is a
minor detail.

 Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


> +	for (p =3D rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
> +		page_addr =3D page_address(*p);
> +
> +		if (((caddr_t)resp->buffer >=3D page_addr) &&
> +		    ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
> +			count +=3D (caddr_t)resp->buffer - page_addr;
> +			break;
> +		}
> +		count +=3D PAGE_SIZE;
> +	}
> +	resp->count =3D count >> 2;
>  	if (resp->offset) {
>  		loff_t offset =3D argp->cookie;
>=20=20
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 93fea24..8d78912 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -573,6 +573,7 @@ void fill_post_wcc(struct svc_fh *fhp)
>  nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
>  {
>  	struct nfsd3_readdirargs *args =3D rqstp->rq_argp;
> +	int len;
>  	u32 max_blocksize =3D svc_max_payload(rqstp);
>=20=20
>  	p =3D decode_fh(p, &args->fh);
> @@ -582,8 +583,14 @@ void fill_post_wcc(struct svc_fh *fhp)
>  	args->verf   =3D p; p +=3D 2;
>  	args->dircount =3D ~0;
>  	args->count  =3D ntohl(*p++);
> -	args->count  =3D min_t(u32, args->count, max_blocksize);
> -	args->buffer =3D page_address(*(rqstp->rq_next_page++));
> +	len =3D args->count  =3D min_t(u32, args->count, max_blocksize);
> +
> +	while (len > 0) {
> +		struct page *p =3D *(rqstp->rq_next_page++);
> +		if (!args->buffer)
> +			args->buffer =3D page_address(p);
> +		len -=3D PAGE_SIZE;
> +	}
>=20=20
>  	return xdr_argsize_check(rqstp, p);
>  }
> --=20
> 1.8.3.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlymiZcACgkQOeye3VZi
gblYfg/+NKg/eo27bXoxV/W5DmX9V/7csFBAYVkx+FmAah9Own0x3JTZSl41Njbp
xW2AnRhv4hXdPfzF1+w9WLQTUbNn2I6sc+PRvvh/mahF5Bjs7uawmbfTnILAdNWf
JN4FR+ySkhQ9ZAVKnR8L4oGCQOEOdgflF/Sb3HMkdLZHj5B0H7gd5nokFnigw3li
oYu+7eX+fQBlTLPmggsMtx0uDEwJpa37RRYOYkYEaTXPJykSNFtqmeZ8pTyyQ+ID
aqNkfw1F05lMCOOKbmrZxYQB/GmUSYk/67U9CkAlMP2cdJlJ7QJC5GuxmUkV7Sjc
Nj2ASpFkhwQBBQisEg8FBwM+zKtTkje34se0nKicsg7bRQ5x6Rk9p2QyrEa1oOQ9
7ClEdDZQXOSbffU2umi2IM9btPH1DZl428Jy2783gG8hzWGBIqWgj0f+ufEgPaGA
/a2xgXZIF60WUuaB8qFUIHu3MkprThllhos2v9FGdR3DhOcsU6obtVtRHXKJbk2E
evZ2XjKCYXn0uIhx1r56DP5pA4LmZm8soExTNlmR/nW9Q1FEAraAClkjPXDpEv/A
lsAonHyb9rnMb7kYQB6p9zRqWBoRLS54TQk65fsm7a2I3osVWHju78b0PVjf+4Lv
4PWHj5tBxQjzZX4/02i8x3lAabgGcARcaghB1s285hsoo/kKiyM=
=d2/7
-----END PGP SIGNATURE-----
--=-=-=--
