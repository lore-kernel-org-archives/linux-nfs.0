Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4328C37BE78;
	Mon, 28 Sep 2026 18:34:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790620465; cv=none; b=OIA6h+805hVDMYNtaFbli3XV4p5z0ng/bOqKKBUZqW7BIC6nN79+4eEtGtHYxfRFk1pxDHdhCzTMQ3cJ5BNFnrfdUsANK7to4xD/wUDLaka+HRNcQB5CYa7clV01zE4+WZ0lmK/C7PY6gvQJH3kXr0V/IeWfCdE04wzXsHdxKCA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790620465; c=relaxed/simple;
	bh=SDJzPULXUQpCnCQQmqpmpXLNVhdteEySbGZ00V0nLIQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VgzD1qSkWO7J4/fBZKQWvvmIiN3CMhWCkmPvrImqgrqutajEcqjuILAyKnfWlZapdh0+VT6UJamdmFRLCn4irl1WjoKPc8NiCWny1Qe6PmdBiHkr/4XR1IY+uHREhBq8GfQlIWbdirzXl+Cc9Pmg3R/Auv+9e8GNYO6UWltTTS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SBXubSgp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SBXubSgp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BEA9A1F00893;
	Mon, 28 Sep 2026 18:34:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790620464;
	bh=5pIEN2UtvN5eIU44q1/qv4MMPvuIqszD4V79FGpMd/o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SBXubSgpCki+2lBNQwC2RkIArg2h34+5ekKXsSa2n1ApbTIh7V8/Od6nisaIvb56m
	 HgxguCMP4SmGlg6fSTr8XF9vOn/72T6SPs8QRN/DDu0vMlj0xNdlzEdB3k1mD4FKy1
	 eXkLn9qQklRNTJlB11OgsfP7tz0Jwf6W0cUo2KNC11TTOdR2klmjMDj1pyRJxhljCX
	 nupMVDSzgapHDHikAtPwksqbGbaP4M3P4kfw+VroN4dImkzmWpLbNliMVZD1FNE4cT
	 4dk/w1wKCwYkv1lotomK2VMgdkmwLt+dbyARFC7B2YukIkUHDX+Skpu8up4eBFrtMh
	 Fg/HW/DGoDeyw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C693CF40068;
	Mon, 28 Sep 2026 14:34:22 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 28 Sep 2026 14:34:22 -0400
X-ME-Sender: <xms:LrO6an8n47t_iYcOErEnflIZsyOq-eR6laCGYSvpsY2B63EU46pE9g>
    <xme:LrO6aui-1ntsnFp_lztTP9q3YgzsDDuOaQ2hMp-_VsR7-1yTF1H1gOwWDeVAxXRwK
    NZv8m8oiZ4OJZBLIZ3KTxG_tnmMQwo5gBOUImdVQPgBIVK4NJNUVa72>
X-ME-Proxy-Cause: dmFkZTGc7cvDL4mkIpE6cHGIsHIVk+ec6mB+71C5cnDXLBZI3w3dRhGPFm/u70qUd5dJuC
    ymkveNqtTEgK29pKAum0P0EjcyBVXvH/YgthXhi+EWAv9yxqbHFoiuOdjChukrkuQ5vu1G
    2KGzfzxiUfnp6mJ1bymjjRbRGiH1JItNqI+LlRK4gEifPwVNjPVaVPLndGoGqbt+k+iAvh
    gzkZrpPJao8eqfEweRNQL9y8NpgsvbwI7Uo5a5KAar8T6rwY2zc4rikuB/5xAztmLgZRqN
    3ONxRXZ/SUagmVaJhTS11qzv8AUaj4X7IS2PkVHGiWIMvUd0CZCsq4GzdZ+Cl/M6ZSqkGK
    dqahX7KyNRiHXMYz+VezqwVIXA5ZETqtpHv5X0IvwM6s3lODe+HpY+9Pw/zOAo9SC0JoUL
    jQh/R6g4b8Pdcqe6fBc9+ta1mqXSASdL0mzGIOuDk8/bmUQ73kaB9CBBhxa59Yw38YLG5Y
    H4I37l0+6rq6+wNgZY+ug6SzApCK30w8CQ5tG457g6dO+tjiBnM3JxTk9+nROOQvoUd0a+
    tqS0sTgnS7POkLZ2xM/XU5TUpQQXhNQt7f6CsNhCIk4aNuG7hBBHSr3EAofsMxUlQSAZtJ
    WfzbfP9mtWgnaCeYutRmllwiPDdSx/VH3QbHRLpzGQx5uBZkFTL2y3R96z1Q
X-ME-Proxy: <xmx:LrO6amIFtjc8QDl-Y0yM6D3DCSPB9Ub32rvWCoqurIBrcP78CLGKFQ>
    <xmx:LrO6anGwqjfcm3Q3MtWanwpdWwLNqYpnRKCDKE7I82-4IpeH0DIUEQ>
    <xmx:LrO6aiTulwo9OvEHXYjF81vVU_FfsZXbzVvP7SPvYMrLgLO4BvE-fg>
    <xmx:LrO6arf-RbvajCGiv1tA-PxYwVJsZ327HX-mJQM4gKnEavDDH4c4Aw>
    <xmx:LrO6apo4HWvowf6_6DAPE4smldIJRlDMlgq1u0OBshO2YX3IdGbSPcHs>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A3A8A780070; Mon, 28 Sep 2026 14:34:22 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Aud5W1lPkfGZ
Date: Mon, 28 Sep 2026 11:34:02 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Dairui Zhang" <zhangdairui@gmail.com>, linux-nfs@vger.kernel.org
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 stable@vger.kernel.org
Message-Id: <c133d32b-8d4c-4c92-83b1-e0c86a0d0849@app.fastmail.com>
In-Reply-To: <20260928182749.1835924-1-zhangdairui@gmail.com>
References: <20260927094535.1745224-1-zhangdairui@gmail.com>
 <20260928182749.1835924-1-zhangdairui@gmail.com>
Subject: Re: [PATCH v2] nfsd: fix READ payload landing one page ahead of the XDR
 accounting
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Sep 28, 2026, at 11:27 AM, Dairui Zhang wrote:
> nfsd4_encode_readv() computes the in-page offset
> base = page_len & ~PAGE_MASK and passes it to nfsd_iter_read(),
> which writes the file data at that offset into *rq_next_page.
> After each operation rq_next_page is set to page_ptr + 1, so when
> the reply stream is mid-page the data lands one page ahead of where
> the payload accounting continues (in the current page at base).
> The client is then sent the stale tail of the current page -
> previous RPC payloads, since reply pages are reused without
> zeroing - instead of the file data: an info leak and corrupted
> READ results.
>
> Trigger: any compound where a READ follows an op that left the
> stream mid-page, e.g. [PUTFH, READ(100), READ(N)] or READDIR+READ.
>
> Place the data in the page the accounting is filling,
> buf->pages[page_len >> PAGE_SHIFT], instead of one page ahead. At
> an exact page boundary page_ptr is the empty page after the last
> full one and page_ptr + 1 is one page too far, so this covers that
> case too.
>
> Fixes: ed4a567a179e ("NFSD: Update rq_next_page between COMPOUND 
> operations")
> Suggested-by: Chuck Lever <cel@kernel.org>
> Reported-by: Dairui Zhang <zhangdairui@gmail.com>
> Assisted-by: LLM
> Cc: stable@vger.kernel.org
> Signed-off-by: Dairui Zhang <zhangdairui@gmail.com>
> ---
> v1 -> v2:
> - Use buf->pages[page_len >> PAGE_SHIFT] for rq_next_page instead of
>   page_ptr with an if (base) guard, per Chuck Lever's review: the
>   guard only covered the mid-page case, while at an exact page
>   boundary page_ptr is the empty page after the last full one and
>   page_ptr + 1 is already two pages past it. The new form matches
>   the accounting xdr_reserve_space_vec() extends.
> - v1: 
> https://lore.kernel.org/linux-nfs/20260927094535.1745224-1-zhangdairui@gmail.com/
>
> From code reading only - I haven't runtime-tested it, and this is
> my first patch to this list. If I've misread the flow somewhere,
> please tell me.

The comment is superfluous now, so it can be dropped.

Go ahead and test vigorously and let me know how it goes!


> ---
>  fs/nfsd/nfs4xdr.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 6a0a97d..e4b8285 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4933,6 +4933,14 @@ static __be32 nfsd4_encode_readv(struct 
> nfsd4_compoundres *resp,
>  	__be32 zero = xdr_zero;
>  	__be32 nfserr;
> 
> +	/*
> +	 * The payload accounting continues at
> +	 * pages[page_len >> PAGE_SHIFT]; write the data there, not one
> +	 * page ahead.
> +	 */
> +	resp->rqstp->rq_next_page = xdr->buf->pages +
> +				    (xdr->buf->page_len >> PAGE_SHIFT);
> +
>  	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
>  				read->rd_offset, &maxcount, base,
>  				&read->rd_eof);
> -- 
> 2.53.0

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
