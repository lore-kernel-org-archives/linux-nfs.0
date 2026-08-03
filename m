Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D441C2931F9;
	Mon,  3 Aug 2026 15:33:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785771207; cv=none; b=aI/xeI2YkDH0BmCNHOEjslXvpnwP0mzgY7exgZbkBP8w6r8Y70jo52oLCnU4nYRKPWYLNl33tlFBv+mBuvGJei4Owf8dikIpRpyveS15KNQzMLlY4JqMvWGEfP6vFZGhDsRR55H5hlpMi9yifN//rAFmO0VbjY+4DSre14VlS2I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785771207; c=relaxed/simple;
	bh=yKFDZSLgAL+0Lm6PnnZyd1Iobkvq0ogaVHdOsUYeWgA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=q2mqz+LT0p/9OdDqI5YO3YvOXPkNQGmFjwc5cf82eMKGlELrQjapwB8SrQBn4KnHTgO4p3MzgAOuArBZsiijIbrk+iw7JYMAC0tr7uDXuGSX0reyuBqeCOTL7h2FGh91DRSijWtBm55T0b363j6q1go6PNW9U1A5BNfly7RT5f8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Colq1IZZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Colq1IZZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0CA1A1F00AC4;
	Mon,  3 Aug 2026 15:33:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785771201;
	bh=0JT9sV4z3V+NBsWMLJN5e4hlZL1WD+4UrWpBgnDwF2o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Colq1IZZSoYCQp6VXrLvNZbeyrPugKOUPgR+NOS+lMMRWOmQAfmSFG0RSveUvRkkS
	 ZtN+OZXid7ts19W4DHU3eaEA7N/71vwhI0jBT12n5W4TilQeNC76TqGcq+gFdxFrX3
	 cvXDRhQCPyHTYuS6D4dIlaK0VxOhiI4BG63xX6f00P5b0UCiz3la3Tvmcz35+iqors
	 HL3rRMjX3GxgDu9KK/57/gTtAQpilIDRkqfFSkwLAVIZYc8n225hs4JxFDwfz+/dav
	 mcOPfepy1AVYN8C52WK1eP0Tlru/jbjHBCWvb7TPkKWo6/h01/8kBpGrwpo9kr06M4
	 mZvcJR84opm/Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0AC5AF4006A;
	Mon,  3 Aug 2026 11:33:20 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 03 Aug 2026 11:33:20 -0400
X-ME-Sender: <xms:v7RwavMhX5TvN-VUAVtZzds51W_ADJgF-q0PtcHvVlQtX7MMo144vA>
    <xme:v7RwakyalIa-7dBtXqd4k2s3aIlA99hbkXbOmJd_O4PWmLTyHm2AEsEQwlp6Z1zWg
    jdkFSYxOIE5vsbJ_oFbiRDizjPmKl-5GsRa9PFM6HtVdM6FKaWy7dI>
X-ME-Proxy-Cause: dmFkZTEwU1uDHyVG750YINiZNAI7QrkCuGEJodaefQmWnOD4o6ew0fgnneM/4Z5jZnuSST
    4xMZZW2+P0vI9yOusL+cT8wQA+pgtEJNvCEbpUtkJ+kOUFr2rod+0h+XGxk7X5SjpwgTzR
    41XeSbg4FLGRuUW/SRTAmIDngm6CJGfk6czX8b6dUD2P1SBfr/Rjjv1+IN3TRvMqcNtzXN
    mQu5WKHsRmqvTlMLnO9H+lnLceNwsiJ3wXwCSWai5NcwhLOL3Qdi1rXB98W0enCRXNYESe
    ybVIB+LwQzJIRKUwuDQn17JdLu6jyfTJ1/v8/4Esuv/4AB+hNE0tINhYx7kOJYf2EajIKh
    9euHAcxEXpB2oL7VUGrIsDWdzuQaq6+rJ7EcW+rhS3nbuIEwgSZJ1IJ7ht7f005yB4Ju4S
    Rsm6F2DvS8axiOpJi92/rY8hVzu8TKIWbT5Z3dxPEOx3C0cd17g999uJ6/2I2rBrdsEOMS
    M0N3cJYI9gVOpZZw7/DoqJeL56KDpjW9UUA4vIQr0ren7yqNjzfnU1wHQQ5PN/iQ72Z/kL
    ToNZapp8xFQ2pHDNVoSzbgU1e+bJQ5wQGP/cGr7XyjqVmvm9h8IIEnFDyuTqOIvQNEXPdz
    mFagZzOMJg56w2a7exy1hW955O7hHgkBOGLepwcKtjCh9NB/POslpOlNjpcg
X-ME-Proxy: <xmx:v7RwamswusoE_mYpeQSsmFAnJy0vG66BAW9soJW__dkaqbic90obQw>
    <xmx:wLRwane9IuZB0PxabBqW6evvo2o856iTyor5oHBc7-Bcqfy6BiQeKw>
    <xmx:wLRwaj_mepGkkdFPc-XMrfrpE_kdrATgTW1Ieqgv-mV9ZzD61niU8A>
    <xmx:wLRwaiSD-HLvp_-weztZsRNwz2DDX62M8Yq-W0MHbPXT0jddbivi9Q>
    <xmx:wLRwakoD8N2r8w2IC-HbxPqnB_pIt9e-BtLCtt60Qo4d9SXTIrk_JdFl>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DC70B780070; Mon,  3 Aug 2026 11:33:19 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0Y-jwfPBytZ
Date: Mon, 03 Aug 2026 11:32:59 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "kernel test robot" <lkp@intel.com>
Message-Id: <54f8ab19-fb1b-4cd6-9600-e3d3d6971173@app.fastmail.com>
In-Reply-To: <20260803-dir-deleg-v1-1-51be76861821@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
 <20260803-dir-deleg-v1-1-51be76861821@kernel.org>
Subject: Re: [PATCH 1/2] nfsd: fix type mismatch and explain host-endian xdr buffer
 usage
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Aug 3, 2026, at 10:49 AM, Jeff Layton wrote:
> sparse flagged this type mismatch. Also the xdr buffer usage is a bit
> non-standard, so explain what we're doing and why.
>
> Fixes: 4b64b811f368 ("nfsd: add notification handlers for dir events")
> Reported-by: kernel test robot <lkp@intel.com>
> Closes: 
> https://lore.kernel.org/oe-kbuild-all/202607310455.AT0GoC5j-lkp@intel.com/
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4xdr.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index a47eb544b99f..5cbb4a415384 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4383,13 +4383,18 @@ nfsd4_setup_notify_entry4(struct notify_entry4 
> *ne, struct xdr_stream *xdr,
>  	struct path path = nf->nf_file->f_path;
>  	struct nfsd4_fattr_args args = { };
>  	const u32 *reqmask;
> -	uint32_t *attrmask;
> +	u32 *attrmask;
>  	__be32 status;
>  	bool parent;
>  	int ret;
> 
> -	/* Reserve space for attrmask */
> -	attrmask = xdr_reserve_space(xdr, 3 * sizeof(uint32_t));
> +	/*
> +	 * attrmask is the host-order bmval[3] that nfsd4_encode_attr_vals()
> +	 * consumes and that ne_attrs.attrmask.element points at. It must
> +	 * outlive this call, so steal a few words from the xdr stream to hold
> +	 * it.
> +	 */
> +	attrmask = (u32 *)xdr_reserve_space(xdr, 3 * sizeof(*attrmask));
>  	if (!attrmask)
>  		return false;

I still don't understand what's going on. "Steal a few words to hold it"
sounds like you're trying to avoid a kmalloc call. Is this code reserving
space in the XDR stream, or isn't it? If it is, then accessing those bytes
has to be done with a big-endian pointer, the same way it is done at every
other xdr_reserve_space() call site. Storing host-order bytes that are not
part of an opaque into an XDR stream is just... wrong.

If you're doing the usual "reserve and backfill the encoded data later"
dance, then spell it the way everyone else does so us poor human readers
can recognize that's what's going on.


-- 
Chuck Lever
