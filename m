Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794227856;
	b=mQCqbWUrdkfac31BNf44P+ORPHZ/oPUjFDBrti5/dTT6V+G8Eyu+C8U68EzPR/i9y3JP
	 x9HMMcqRAkAIoUR4RDzRLXtJt/JcbzzKzlU/kScIecr9UXJxKX9ds/JakrT08yRSa1A4a
	 wvILPhmWeRV648XduSRUm9WRgJBiXn//NbP1ImIpCzbfYfx5qp3p+6XccAAvPyif7jI25
	 KK+7M7hZ+n/zqGi0L+EmUZR5IksjSI6X4ZSMURDI1mK6m8wFqAD7xz4Pjol/6XQSfdB5p
	 H26EU4pM0G1sgaE271vE1/H1TlE9gnIr0Mvy2VjUwkdVtd/ZuFsQxGs9bHpWhP/hUbw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794227856;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=UgVQW3EXLMWqXBojH3GBNS76TkZ4Jj+Y2ccm4/Y2v80=;
	b=tNgVE7M2a53/V6kiicK1rig2sqzsDK5QQ17ZPPsFdPUc/h3jIAvBoimy4DvcaDpNCVUe
	 bxjxNyH0ZhojmdbQmFKTaFOCPWE7qJjVA4OcaDIbbSA8IqTmsueabpvqiTT54xnYFyTf/
	 kApxN8OOguQ/PoUqPcz51CmcqVWOKnbJlIrim01R1+lJhDjcH8lGEks1Z6jYc3E1zkbAj
	 97iuMb1hfdYGNPMDOxJsO05venatPgW+Bsr9SP5zXboMD6J2VtWH4i30kphsBrYPU1jjT
	 b0Ys+K3Tbvvl3LQqkF5rL9um72/b5ulQfCl5CN/EmSQXLL/tQtBeClCNOkp8ftAwGQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R75+NsOx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58234606A31C
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 12:37:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R75+NsOx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 731011F008A7;
	Mon,  9 Nov 2026 12:37:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794227856;
	bh=UgVQW3EXLMWqXBojH3GBNS76TkZ4Jj+Y2ccm4/Y2v80=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=R75+NsOxUy4Zbfi7b0205D3PMbzm/S3LHJbYBQNlPLweADTeYhjl9xXAAx18mcL2h
	 HKX4T9g4/zlN1JgK69nePOIMOmrOZCNyU6b3DrldZGzovv5ex4Ie/DV3WKONyBPLU7
	 TW0bKgVpXs2h7cu+exYS+j13yJN2JTagbO6QER+xnFEIp24NSTHsXenOO8fQtpv2ek
	 L6Tqi6/egp/RMuYek47XNaBGgqYXuJOcOeE0POeP9mbKHeLU3niJP7OJBM0WbVpOEo
	 qIKQBjh4NYJ0C72NCpd1qSzU4a6ADMDCdOHmjQUvbnoYZnuWjjMuoHsnYyOznsQoGr
	 z6JSvNwWPkvfw==
Message-ID: <e1858af02f12f8102f9102b923ebe73eea497879.camel@kernel.org>
Subject: Re: [PATCH v2] NFSD: Use direct I/O only for the last operation in
 a COMPOUND
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neilb@ownmail.net>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Nov 2026 07:37:33 -0500
In-Reply-To: <20261108175502.75385-1-cel@kernel.org>
References: <20261108175502.75385-1-cel@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-3.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Sun, 2026-11-08 at 12:55 -0500, Chuck Lever wrote:
> A direct read widens the requested byte range to the file system's
> alignment and leaves the payload at a nonzero rq_res.page_base. The
> xdr_stream encoder does not account for page_base:
> xdr_reserve_space_vec() sizes each chunk from page_len alone, and
> xdr_get_next_encode_buffer() opens each new page at its first byte.
> The stream's position lags the end of the payload by page_base
> bytes.
>=20
> An NFSv4 operation encoded after such a READ overwrites the tail of
> the payload, and the transport sends alignment padding in place of
> that operation's result. The client sees corrupted file data
> followed by an undecodable reply. NFSv2 and NFSv3 are unaffected:
> their READ encoders pass page_base explicitly, and nothing is
> encoded into the pages after the payload.
>=20
> Have nfsd4_read() permit a direct read only for the last operation
> in its COMPOUND, next to the same decision it already makes for
> splice reads, and pass the result to nfsd_iter_read() as a new
> argument. The NFSv2 and NFSv3 READ path always permits a direct
> read. The decision is NFSv4 reply-encoding policy, so it stays out
> of fs/nfsd/vfs.c.
>=20
> Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
> Changes in v2:
> - Split from the "NFSD short subjects" series and post on its own
> - Move NFSv4-specific logic out of fs/nfsd/vfs.c
> - Link to v1: https://lore.kernel.org/r/20261004194029.10714-2-cel@kernel=
.org
>=20
>  fs/nfsd/nfs4proc.c |  2 ++
>  fs/nfsd/nfs4xdr.c  |  3 ++-
>  fs/nfsd/vfs.c      | 15 ++++++++++++---
>  fs/nfsd/vfs.h      |  3 ++-
>  fs/nfsd/xdr4.h     |  1 +
>  5 files changed, 19 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a50f9dcb3a31..aaca7d3c3e04 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1143,6 +1143,8 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_com=
pound_state *cstate,
> =20
>  		argp->splice_ok =3D false;
>  	}
> +	/* The xdr_stream encoder does not account for rq_res.page_base */
> +	read->rd_dio_ok =3D nfsd4_last_compound_op(rqstp);
> =20
>  	/* check stateid */
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c4fd840da4d9..feb50abccff4 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -5308,7 +5308,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compo=
undres *resp,
>  	__be32 nfserr;
> =20
>  	nfserr =3D nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
> -				read->rd_offset, &maxcount, &read->rd_eof);
> +				read->rd_offset, &maxcount, &read->rd_eof,
> +				read->rd_dio_ok);
>  	read->rd_length =3D maxcount;
>  	if (nfserr)
>  		return nfserr;
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index cb4bf7b235b4..97077f18a1b7 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1234,6 +1234,8 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
>   * @offset: starting byte offset
>   * @count: IN: requested number of bytes; OUT: number of bytes read
>   * @eof: OUT: set non-zero if operation reached the end of the file
> + * @dio_ok: false forces a buffered read even when the export selects
> + *	    direct I/O
>   *
>   * Some filesystems or situations cannot use nfsd_splice_read. This
>   * function is the slightly less-performant fallback for those cases.
> @@ -1241,12 +1243,17 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
>   * records. On return, @rqstp->rq_next_page points past the last page
>   * offered to the read.
>   *
> + * A direct read leaves its alignment pad at the front of the pages and
> + * records the pad length in @rqstp->rq_res.page_base. The xdr_stream
> + * encoder does not account for page_base, so pass @dio_ok false when
> + * more XDR items follow the payload in the pages.
> + *
>   * Returns nfs_ok on success, otherwise an nfserr stat value is
>   * returned.
>   */
>  __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		      struct nfsd_file *nf, loff_t offset, unsigned long *count,
> -		      u32 *eof)
> +		      u32 *eof, bool dio_ok)
>  {
>  	struct xdr_buf *buf =3D &rqstp->rq_res;
>  	struct page **page =3D buf->pages + (buf->page_len >> PAGE_SHIFT);
> @@ -1265,7 +1272,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struc=
t svc_fh *fhp,
>  		break;
>  	case NFSD_IO_DIRECT:
>  		/* When dio_read_offset_align is zero, dio is not supported */
> -		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
> +		if (dio_ok && nf->nf_dio_read_offset_align &&
> +		    !rqstp->rq_res.page_len)
>  			return nfsd_direct_read(rqstp, fhp, nf, offset,
>  						count, page, eof);
>  		fallthrough;
> @@ -1649,7 +1657,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
>  	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
>  		err =3D nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
>  	else
> -		err =3D nfsd_iter_read(rqstp, fhp, nf, offset, count, eof);
> +		err =3D nfsd_iter_read(rqstp, fhp, nf, offset, count, eof,
> +				     true);
> =20
>  	nfsd_file_put(nf);
>  	trace_nfsd_read_done(rqstp, fhp, offset, *count);
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 1f05c83a3ea6..0b0152ba56b3 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -182,7 +182,8 @@ __be32		nfsd_splice_read(struct svc_rqst *rqstp, stru=
ct svc_fh *fhp,
>  				u32 *eof);
>  __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  				struct nfsd_file *nf, loff_t offset,
> -				unsigned long *count, u32 *eof);
> +				unsigned long *count, u32 *eof,
> +				bool dio_ok);
>  bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
>  __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  				loff_t offset, unsigned long *count,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index ec198993429e..61afbabc1773 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -301,6 +301,7 @@ struct nfsd4_read {
>  	u32			rd_length;          /* request */
>  	int			rd_vlen;
>  	struct nfsd_file	*rd_nf;
> +	bool			rd_dio_ok;
> =20
>  	struct svc_rqst		*rd_rqstp;          /* response */
>  	struct svc_fh		*rd_fhp;            /* response */


Looks sane. It does look like the Linux client sends a READ last in the
compound. I do wonder if other clients might send other stuff afterward
(GETATTR maybe?), but falling back to buffered is not the end of the
world in such cases.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
