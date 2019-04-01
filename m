Return-Path: <SRS0=xBSR=SD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CD3BC43381
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 01:20:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5855220870
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 01:20:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726893AbfDABUi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 31 Mar 2019 21:20:38 -0400
Received: from mx2.suse.de ([195.135.220.15]:55494 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726196AbfDABUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 31 Mar 2019 21:20:38 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 71A24AE3F;
        Mon,  1 Apr 2019 01:20:36 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Murphy Zhou <jencce.kernel@gmail.com>, linux-nfs@vger.kernel.org
Date:   Mon, 01 Apr 2019 12:20:28 +1100
Cc:     bfields@fieldses.org, jlayton@kernel.org,
        Murphy Zhou <jencce.kernel@gmail.com>
Subject: Re: [PATCH] nfsd/nfsd3_proc_readdir: check before encoding on temporary page
In-Reply-To: <20190329142332.12010-1-jencce.kernel@gmail.com>
References: <20190329142332.12010-1-jencce.kernel@gmail.com>
Message-ID: <875zry34ir.fsf@notabene.neil.brown.name>
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

On Fri, Mar 29 2019, Murphy Zhou wrote:

> After this commit
>   f875a79 nfsd: allow nfsv3 readdir request to be larger.
> nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
> request and the directory are large enough, we can run out of pages
> in rq_respages. Then the temporary page we are encoding on is a
> random page, Oops happen.
>
> Listing a directory with 30000 files in it can trigger the panic.
>
> Fixing this by ensuring the temporary page resides in rq_respages.
> And when counting how many bytes left currently from buffer to the
> end of the page which buffer is pointing to, aka len1, do not
> assume that curr_page_addr is at the beginning of the same page.
> Also, update resp->count by going through all pages. Because the
> pages may not be sequential, the old way is not safe.
>
> Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
> Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>

Hi,
 thanks for finding these problems and submitting a patch.  Clearly I
 should have tested better :-(

> ---
>  fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
>  fs/nfsd/nfs3xdr.c  |  8 +++++---
>  2 files changed, 20 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 8f933e84cec1..9bc32af4e2da 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -442,7 +442,9 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
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
> @@ -462,7 +464,18 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
>  	nfserr =3D nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie,=20
>  					&resp->common, nfs3svc_encode_entry);
>  	memcpy(resp->verf, argp->verf, 8);
> -	resp->count =3D resp->buffer - argp->buffer;
> +	count =3D 0;
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

This section makes perfect sense.  You have copied code from
nfsd3_proc_readdirplus() int nfsd3_proc_readdir().  This is needed
because readdir doesn't limit replies to PAGE_SIZE any more.

>=20=20
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 93fea246f676..1fabf1952bdb 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -953,6 +953,7 @@ encode_entry(struct readdir_cd *ccd, const char *name=
, int namlen,
>  			break;
>  	}
>=20=20
> +

Adding blank lines is best avoided.

>  	if ((caddr_t)(cd->buffer + elen) < (curr_page_addr + PAGE_SIZE)) {
>  		/* encode entry in current page */
>=20=20
> @@ -961,11 +962,12 @@ encode_entry(struct readdir_cd *ccd, const char *na=
me, int namlen,
>  		if (plus)
>  			p =3D encode_entryplus_baggage(cd, p, name, namlen, ino);
>  		num_entry_words =3D p - cd->buffer;
> -	} else if (*(page+1) !=3D NULL) {
> +	} else if (*(page+1) !=3D NULL && (page+1) < cd->rqstp->rq_next_page) {

Adding the test against rq_next_page looks correct.
nfs3svc_decode_readdirplusargs increments ->rq_next_page over enough
pages to cover the request count.
However nfs4svc_decode_readdirargs doesn't!  So it will not advance
rq_next_page properly.  We need to fix that to make it like
nfs3svc_decode_readdirplusargs().

But I don't think this test should be needed.  svc_alloc_arg() NULL-
terminates the ->rq_pages array which ->rq_next_page points in to.

So I think this test is correct as it stands, but
nfs4svc_decode_readdirargs() needs to be fixed.

>  		/* temporarily encode entry into next page, then move back to
>  		 * current and next page in rq_respages[] */
>  		__be32 *p1, *tmp;
>  		int len1, len2;
> +		caddr_t	tmp_page_addr =3D NULL;
>=20=20
>  		/* grab next page for temporary storage of entry */
>  		p1 =3D tmp =3D page_address(*(page+1));
> @@ -977,7 +979,8 @@ encode_entry(struct readdir_cd *ccd, const char *name=
, int namlen,
>=20=20
>  		/* determine entry word length and lengths to go in pages */
>  		num_entry_words =3D p1 - tmp;
> -		len1 =3D curr_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
> +		tmp_page_addr =3D (caddr_t)((unsigned long)cd->buffer & PAGE_MASK);
> +		len1 =3D tmp_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;

I think tmp_page_addr will always be the same as curr_page_addr.
At least, it will when nfs4svc_decode_readdirargs() is fixed.

Could you please revert the changed you've made to nfs3xdr.c (keeping
the change to nfsd3_proc_readdir()), and fix nfs4svc_decode_readdirargs
to be more like nfs4svc_decode_readdirplusargs, and see if that fixed
the problem?

Thanks a lot,
NeilBrown


>  		if ((num_entry_words << 2) < len1) {
>  			/* the actual number of words in the entry is less
>  			 * than elen and can still fit in the current page
> @@ -1026,7 +1029,6 @@ encode_entry(struct readdir_cd *ccd, const char *na=
me, int namlen,
>  	cd->buffer =3D p;
>  	cd->common.err =3D nfs_ok;
>  	return 0;
> -
>  }
>=20=20
>  int
> --=20
> 2.21.0

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyhZ1wACgkQOeye3VZi
gbl8FxAAu5O3yH0RY7KqNR+oh1qHTfqAoXu4QFQ0rfryP8001ukQkbu0fkTlNaNj
ZjYXXbNTq4TIs8by80yqdKt4J4EFWUp/nD3atFIB75dSVZcO14j5asClnQWGx1tX
BX4l28wjVYKZs62LNd0iXgJnlojDbmI6RD5n21YwidX+xmcnSn+iFb0d1Z8j0Piw
WccAsHJwnvgCqLLnxpZfMyGqLHRY0P/UfYCj27KjKlb15seZtBqj/B3YofjY1Ux5
96P53aRldu4zDG0DNFlkMsX6PRe2EjwpZn/KPrQRmkNuziKwHsTp6X4PFFSr4eyE
ZI6as3rE8xund9J6Rdj+kzKnKVSYLXCIqK+ygk+xHmBug1XailsQr3WTg/rDcKOQ
HicnnWu305WQyrhiVDm/J0Ym+TGzDPoxISG7GYhW2HKuOvtLG4urp18xNKg4HMfw
wYqtwpw7Lbe5q8V9pHM0nXb7xy9I0UGCQVh1EvvRNk58wbiQq7GYyBVrdvIoUqAT
00mYHzT0NL4atYurki4NoHBkzbZ6TUiCfcl6+T82A7iolkEuyE7pIuuM0nCo8ah2
uSs0Hf3tf9dYlGOdqpPxuxLFueSyYQXAVgeLl3/XJ/XHSKACocekycy+8lEx4i5a
4u1rjKAvoiHH2GV3+FGvAznPBVzUnCE3at0PJbsnU3pjDos5eX8=
=CGxm
-----END PGP SIGNATURE-----
--=-=-=--
