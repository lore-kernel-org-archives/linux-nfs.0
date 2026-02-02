Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C0BE2E22AA;
	Mon,  2 Feb 2026 18:19:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770056375; cv=none; b=nojN8CThxRRehH8dRvUjjmmpWC+Zx37y8PciFkqIWZvXnIObiUHQZZSuFTNfShN5Ym8kCireTzscm0AvimCyo6SoFEtR4BY328p87b6+zK1x1ERYFmD2SWqijVEtYBAGgsOSwQmHvPOiO87trQbqN63SGLEDqlwQstz9pYo4CLk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770056375; c=relaxed/simple;
	bh=vVl96LCrbznZU72nHAStgcberNXB57p0T9mJjmMM7zo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pBnkHW0RMIHWjVbUkMs0HpZfrP7fZBV3W38GJsdjM2LfW+OD+FfTlgUNwpUVW1YRC10Mm0pFUwOtkknfVxA6v0Mt0UECxdUMURHWJJMaeg91wF0ORnX948oxc0eFndaTQGnp6IxpdVSJ5BHkZb+1d2CgjEtfezhS4hAgJ/JbYXo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lWzn33rD; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lWzn33rD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70B38C116C6;
	Mon,  2 Feb 2026 18:19:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770056375;
	bh=vVl96LCrbznZU72nHAStgcberNXB57p0T9mJjmMM7zo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=lWzn33rDKAeo1uglcKo5+ED21YZQlTtMyncGVp98W8LeQTfq+Ls1ok0krxqzidDnv
	 yhYHzHx5alQF7XM6SRMw6296y0EJ32Yah37oJUznjdfW3AXNC/3z7jBchFLM0twiO+
	 y8Hd5pZsl5HvludQonyKouxabDyLkyOFEvIXTi5BRv/KNlxEVGldPyYmNJCMmASSlR
	 bjzTYG+vGZ/rtCFcABBqIeHHxSFY3pcQhkVf44AmuLjdrP3+Pfa0bYbE7e9O9PcCVe
	 DUieRFald+XCkixtgm5m2pnGzM4Wo1uS3T8s7D9dvZ+GD8sdMtfXMw81zwUZEso4fk
	 WrkaG3K3BjNMQ==
Date: Mon, 2 Feb 2026 10:19:32 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Benjamin Coddington <bcodding@hammerspace.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Rick Macklem <rick.macklem@gmail.com>, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v3 3/3] NFSD: Sign filehandles
Message-ID: <20260202181932.GA2036@quark>
References: <cover.1770046529.git.bcodding@hammerspace.com>
 <11253ead28024160aaf8abf5c234de6605cc93b5.1770046529.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11253ead28024160aaf8abf5c234de6605cc93b5.1770046529.git.bcodding@hammerspace.com>

On Mon, Feb 02, 2026 at 11:19:38AM -0500, Benjamin Coddington wrote:
> +/*
> + * Append an 8-byte MAC to the filehandle hashed from the server's fh_key:
> + */
> +static int fh_append_mac(struct svc_fh *fhp, struct net *net)
> +{
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +	struct knfsd_fh *fh = &fhp->fh_handle;
> +	siphash_key_t *fh_key = nn->fh_key;
> +	u64 hash;
> +
> +	if (!(fhp->fh_export->ex_flags & NFSEXP_SIGN_FH))
> +		return 0;
> +
> +	if (!fh_key) {
> +		pr_warn_ratelimited("NFSD: unable to sign filehandles, fh_key not set.\n");
> +		return -EINVAL;
> +	}
> +
> +	if (fh->fh_size + sizeof(hash) > fhp->fh_maxsize) {
> +		pr_warn_ratelimited("NFSD: unable to sign filehandles, fh_size %d would be greater"
> +			" than fh_maxsize %d.\n", (int)(fh->fh_size + sizeof(hash)), fhp->fh_maxsize);
> +		return -EINVAL;
> +	}
> +
> +	hash = siphash(&fh->fh_raw, fh->fh_size, fh_key);
> +	memcpy(&fh->fh_raw[fh->fh_size], &hash, sizeof(hash));
> +	fh->fh_size += sizeof(hash);
> +
> +	return 0;

Note that this is still creating endianness-specific MAC values,
considering that siphash() returns a u64 which is being copied directly
into a byte array.  Maybe not what was intended?

- Eric
