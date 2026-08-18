Received: from fout-a8-smtp.messagingengine.com (fout-a8-smtp.messagingengine.com [103.168.172.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B88C137266E;
	Tue, 18 Aug 2026 22:54:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787093663; cv=none; b=cCcj/tQUiLKT5pPaXKZVxn69t+nbeUuMU+5P8auzZLxb1eiOKNKwISKkKicBL7b1aOpdCx4SwcGpveI9LQU6ud692Wlv4vJYCxEeaxUkYcXL2x8AwGySf+n8C0564QwgoXBOEJEu0EegAKgbk9sgTkoiCHT9OIpK2Bte6Ugm8dw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787093663; c=relaxed/simple;
	bh=jNGsnt7JxZDro4Dl9qDm75sVqt/MoHTpkOoVaRMFwUo=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=tSMVx2Sf6tcUHVcqA5wkoMVUVHKURxWrvK7N2wEVk4fvvp8jL3KXN1lsYlujpybcyItnF6rAbvemsP7l+FJ2yZ25g2sbBCcqIp+0UrT8UW6x1hjAw0bzCXYF1DmPJ8awkbh4d2MPvYANeTcD4wdxMGnZ8MYVNfpqJ7gIJdQePh8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=D/Qi/Oca; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=TMjNT8Qq; arc=none smtp.client-ip=103.168.172.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="D/Qi/Oca";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TMjNT8Qq"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.phl.internal (Postfix) with ESMTP id 9FAF4EC0215;
	Tue, 18 Aug 2026 18:54:19 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Tue, 18 Aug 2026 18:54:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787093659; x=1787180059; bh=VrK/Fz/a6RMWuEL+llgYxO1oJmCF8OszZeA
	OV6N0i+g=; b=D/Qi/OcaO4E4OEbuc7Xef/kGb8pExe9foo1IUFQ/Z9OjUm2z1EJ
	PpeA1BfN1TCO9eIpgZ1jZGCndYjn2tEcgdykiMzPKEa6vEhCkFUyYtozCtOlbGmI
	BPOQWrfJM2lwMTbcT/pV95jrWw4jbwBEgJ85fw/3tE6P/pu1xdAVydD4NujXLMVl
	6QDoed0v0Ehytx20N5CIrTPYjs5VjMtBawd1FOJagOk2E/1oDze7CnEvkacdbZ75
	gCERv8Z3lnZCAyBqkKwokRzseQEGd/gaaDB+dtqstNNVjf9J8vNxnC02l+cWf83x
	zQV5WXakvSbrsrIgJ50KcjKxsk/xI3lieCw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787093659; x=
	1787180059; bh=VrK/Fz/a6RMWuEL+llgYxO1oJmCF8OszZeAOV6N0i+g=; b=T
	MjNT8QqI6mJ7H1VCXMhyoStIUwWQ3VNKmv/NrqyWaulo3vsQI5gIeqeyLlnpyQhp
	2RTQx2zCbB4suaJJGZXibydC+xP9/hNbaafjn7/IJLjSk+5e8XK8xf7ScMQhGZlb
	r5Vg8et+K10f0UZBDsVtTDipetcNnGQgS0esguroYl1Sg1QaZ/bZMw+O3h+K/Gu2
	hYO1S/Ycs+NCoFJ5q7uR2yn3UAGQ4w7Pcvkr+6dj4fHpS7avXpuwe35jga5YwwYf
	ZvluBjYHvPLO3DDwUNuxg3T6X3AEOg0fGaX6SAR0gOhqKTDsUlSihdPyHhe9WGvr
	34M5pLhTDDwgoIkgfIfwA==
X-ME-Sender: <xms:m-KEahy6Tfv1KazsJAq1gdDafDg_v_p54PM2uynSXGB2nCU7pojtvA>
    <xme:m-KEai2jy-FUHMMffIujctbau7NYVXxhxeTvQ5PiKu3n0tFeyF-Semp3xkEmcCpXw
    L6n0BliqC9DDMApZrvX0ZhVuz_MXHLbguMFLrN3zdygj_Qt>
X-ME-Received: <xmr:m-KEaql-VdKrT4te7_pHd31cQ1MPlYzTgHRHvIJ10haUkc2dZGielGla3VAHEnjA2ATVpzwtbNY-Q3W_ywzQo2Ut7yDrycg>
X-ME-Proxy-Cause: dmFkZTEIxaJ+HKl/elznRl+9WLXno7X7iwj6Vz+PjkEidYkWpPyw6ofE8biRr5rxXukwgN
    Z36zkKaNh5+ENDAJuIYHVC0Uc6uKkSWKculOJC5J2FSFm0eT9R1ayGa4/cZ/xspXGhfAfh
    HY25VSsnq058i0axHzz44QZFDipD9P1QhNcOjDn8OLkRmMf0lce7+MPXsMggUfdVDGTiq+
    4o47VAbGhcRT5Vbv7DaAUOjclVDkEZwo9tU4fkJMmZ4fm4HF4OQoVkTK1wbCRktRcHY4rv
    +V7rt5A8WtFtnbMoy9H8zdYQM58faJcY7NWiGn29I8U/1GxDL7AWPdImUxqjCxf5FSRegc
    dKpPLqhfnvFHgG4VnoX0/WxIJm00v3xcXTYkgxVMtaOd9sLcJkycNnPubND6mm/WJmKlvS
    SCQ9zG82PpY245hzw70lMAZSaYpeEfbt0u7OUNc3phg94OTrmEQ2gbezpwX9JRoMxNeEUM
    S4Px+xhW6TAleiz21KcGUGTSiJdBsUkCKFkm2SWv5oNnkVacvw4ZwKvUQe82lfsSFHZhyi
    jPOJD/XLbmmuNg/zV1zcbaLiAmx/9EvVpLxgZ8d2B9Dk73z9kDySQ2Qhy1bKjJ0vOwp/jL
    CBlXyn45ZxZEIwagdYd0yB1A47JEZkhbNS2Ohws5uPawKBhXUKSf0d8eWb7w
X-ME-Proxy: <xmx:m-KEap-V_drzguSr3MtsNAKz5q9V-XlyU8yFQkjRqEbij2zfhKtpNg>
    <xmx:m-KEaoKckqxYPumDzu8wRw5DAfq3I4DKXIO6A4HjeEXatubJl9m48Q>
    <xmx:m-KEaujtS4k1RMWchJcLrGlPfioKVrwiBN75YU28vydBy_ynHPfI0Q>
    <xmx:m-KEak_d4qsvsck2Ldlr-r8C8vjzCt2611yKcxpxVapYYibzksu4iA>
    <xmx:m-KEakC4m-QA5TFdgLiDgoWpthOF_LzjosuyegZ01WvjQFqQYS4e35KT>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 18 Aug 2026 18:54:15 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Ameer Hamza" <ameer.hamza@truenas.com>
Cc: cel@kernel.org, jlayton@kernel.org, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, anna@kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 alexander.motin@truenas.com, caleb.stjohn@truenas.com,
 ameer.hamza@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
In-reply-to: <20260817210811.3984663-2-ameer.hamza@truenas.com>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
  <20260817210811.3984663-2-ameer.hamza@truenas.com>
Date: Wed, 19 Aug 2026 08:54:11 +1000
Message-id: <178709365192.2852630.5607658976022815566@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 18 Aug 2026, Ameer Hamza wrote:
> For some files splicing a READ cannot avoid a copy: gfs2, kernfs
> and the cifs direct-I/O modes use copy_splice_read() as their
> ->splice_read, and the VFS substitutes it for DAX files.
> copy_splice_read() allocates a fresh page for every page of
> payload and reads into it; nfsd_splice_actor() then installs
> those pages in rq_respages, displacing Reply pages the thread
> already owns. Both sets of pages are then freed.
>=20
> Route these READs through nfsd_iter_read() instead. It performs
> the same single copy, but into the thread's own Reply pages, so
> the per-READ allocation and the displacement both disappear. On
> its own this is not expected to raise throughput; it changes
> which pages a Reply is built from so that the next patch can
> recycle them.
>=20
> 9p and ceph fall back to copy_splice_read() only inside their
> own ->splice_read methods, which nfsd_splice_read_is_zero_copy()
> cannot detect,

I think that if we are going to do this then we should do it properly
and make it easy to detect these cases.

Could we add an FMODE flags FMODE_DONT_COPY_FOR_SPLICE which causes
copy_splice_read() to return -ENOTSUP or similar.
Then nfsd can call splice_read if it appear to exist, but set that flag.
If it fails with -ENOTSUP, fall back to iter_read.

I really don't like the approach of explicitly testing whether
f_op->splice_read is a particular value.

Thanks,
NeilBrown



>                 so they keep the splice path. nfsd_iter_read() is
> the path sec=3Dkrb5i, sec=3Dkrb5p and nfsd_disable_splice_read READs
> already take, and is unchanged here; the one visible difference
> is that an fsnotify watcher now sees two access events per READ
> instead of one, the extra one from vfs_iocb_iter_read().
>=20
> Assisted-by: Claude:claude-fable-5
> Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
> ---
>  fs/nfsd/nfs4xdr.c |  4 ++--
>  fs/nfsd/vfs.c     |  5 ++++-
>  fs/nfsd/vfs.h     | 29 +++++++++++++++++++++++++++++
>  3 files changed, 35 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 7d1b2d6f57f20..07a4bd8feb764 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -5369,7 +5369,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __b=
e32 nfserr,
>  	maxcount =3D min_t(unsigned long, read->rd_length,
>  			 (xdr->buf->buflen - xdr->buf->len));
> =20
> -	if (file->f_op->splice_read && splice_ok)
> +	if (nfsd_splice_read_is_zero_copy(file) && splice_ok)
>  		nfserr =3D nfsd4_encode_splice_read(resp, read, file, maxcount);
>  	else
>  		nfserr =3D nfsd4_encode_readv(resp, read, maxcount);
> @@ -6267,7 +6267,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres =
*resp,
>  	maxcount =3D min_t(unsigned long, read->rd_length,
>  			 (xdr->buf->buflen - xdr->buf->len));
> =20
> -	if (file->f_op->splice_read && splice_ok)
> +	if (nfsd_splice_read_is_zero_copy(file) && splice_ok)
>  		nfserr =3D nfsd4_encode_splice_read(resp, read, file, maxcount);
>  	else
>  		nfserr =3D nfsd4_encode_readv(resp, read, maxcount);
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f9131827d391e..1a5fec4cf73d3 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1176,6 +1176,9 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_f=
h *fhp,
>   *
>   * Some filesystems or situations cannot use nfsd_splice_read. This
>   * function is the slightly less-performant fallback for those cases.
> + * It is also the preferred path where splicing would copy anyway
> + * (see nfsd_splice_read_is_zero_copy()), because the copy then
> + * lands directly in Reply pages nfsd already owns.
>   *
>   * Returns nfs_ok on success, otherwise an nfserr stat value is
>   * returned.
> @@ -1576,7 +1579,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_f=
h *fhp,
>  		return err;
> =20
>  	file =3D nf->nf_file;
> -	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
> +	if (nfsd_splice_read_is_zero_copy(file) && nfsd_read_splice_ok(rqstp))
>  		err =3D nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
>  	else
>  		err =3D nfsd_iter_read(rqstp, fhp, nf, offset, count, 0, eof);
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index f0cb184643f2f..70bd3c6fc1880 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -149,6 +149,35 @@ __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct =
svc_fh *fhp,
>  				unsigned long *count, unsigned int base,
>  				u32 *eof);
>  bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
> +
> +/**
> + * nfsd_splice_read_is_zero_copy - check whether splice can avoid a data c=
opy
> + * @file: file to be read from
> + *
> + * copy_splice_read() reads via ->read_iter into freshly allocated
> + * pages, exactly as nfsd_iter_read() does into pages nfsd already
> + * holds. Filesystems that implement ->splice_read with it gain
> + * nothing from the splice path, and neither do DAX files, for
> + * which the VFS substitutes copy_splice_read() no matter what
> + * the filesystem registered. The VFS substitutes it for O_DIRECT
> + * files as well, but nfsd never opens files O_DIRECT.
> + *
> + * The test is one-sided: a filesystem's own ->splice_read method
> + * may fall back to copy_splice_read() internally, as ceph and 9p
> + * do, and that cannot be detected here.
> + *
> + * Return values:
> + *   %true: splicing from @file is not known to copy
> + *   %false: splicing from @file would copy, or is not supported
> + *           at all; use nfsd_iter_read()
> + */
> +static inline bool nfsd_splice_read_is_zero_copy(const struct file *file)
> +{
> +	return file->f_op->splice_read &&
> +	       file->f_op->splice_read !=3D copy_splice_read &&
> +	       !IS_DAX(file_inode(file));
> +}
> +
>  __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  				loff_t offset, unsigned long *count,
>  				u32 *eof);
> --=20
> 2.53.0
>=20
>=20

