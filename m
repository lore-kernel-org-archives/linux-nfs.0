Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795547301;
	b=jFNlnIDwg/y5XqSAm9dITQTkHJ7dKkKx5yXvNaQ/Rkl6H3XfueEiuWumIBpdGH3u/lmT
	 cp+hbtqIIxuDZlI4JsDN0Hk49pnOpdjrkVi5dtu9UT2h2kzCz+fv5LlfUHQyBIhLLgpuF
	 iqZLTXP19Ys46I7FV2z84gBhkwJPLmA30mY+qjhVKcGP4Z+r40vXnliVb5YJOiMNdXJKC
	 Wsya0OI2o+1iIKefiVrT3gxKvt6R//C+5fPwSsZ2t4UixGX7HhRmhK/tqCDfKBVBrP4SK
	 1sbk4WabkwLQsj05Y77l5f8GBn8Ax2seUt3usyDpuzXg0BhVQxg2mKQMnkI5STtGhXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795547301;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=WjA94FENQV0Hv0Bf8GSbnF6rCX9MA1Augd3aPH8o7CI=;
	b=wsKY3aY8sBgHP9zBYb343h2ssRCsorXY4zrth6rh2PqMsMwyzmhIdkH3h8qeDRWoe5aU
	 bUiR3nXnq7XclPC2/K/sVS08rDiYU0nkmIxEUnq//qOpacB3k6xoq/4wgjqiR+MzAFHWK
	 nkd+eyW5ryDTPYZmCKlT0iRsTPCWXpQIyp8AnYIgAhCNVdCsmh/+xxfUiSBcHjjDgWkYF
	 Q9luL3yLlg97oIy2UElhOK8043gF6/1iPqYB0S/1nlFoEHelcnqe/JFZdopBen+S1FuVC
	 NUSWqspUWZ0Rc8/huuMRt5W16NQ6rHcPWW1WF0vwg95U6h17CW9QDTvaqVS+coYWtKg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PdP0C22t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 085FA606A321
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 19:08:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PdP0C22t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 17B6A1F000C0;
	Tue, 24 Nov 2026 19:08:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795547300;
	bh=WjA94FENQV0Hv0Bf8GSbnF6rCX9MA1Augd3aPH8o7CI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=PdP0C22t+mrbjXDXb0bHAXASsfSfMMiXXjoCEiYE7gOWaVm40+Y4BnvSItldk/7BL
	 uhg4HKJl7Bsxd/EA/oAV9rQzorgflX0JCiCjafIXkkhOwuSf/5RjvTHPtSsryVpFkC
	 8DCkx1LIDqmsI1aIWcT+zciY03zlJts2Rjmu5Rkn6Og9wDnC/d3zdSFSPzTEswINyJ
	 rIM9r84urnXSOwF2JL+GCqlMUxz224dUCCVEswsqKWVNcgdUJeaUSsR85pY+spuJNL
	 RO0AbhsPvwJ4wGqVjNq3NrGB9Z533MreRm4kLO5+Ggx0KcQlIdUHCP2GgWTcxTocd7
	 KmtdF/ympus9Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6436EF4006F;
	Tue, 24 Nov 2026 14:08:19 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 14:08:19 -0500
X-ME-Sender: <xms:o-AFa0ww0iNgDZiuRkbfynGitu9MIIoFe4M-1SfhtRTEeFSisBmc2g>
    <xme:o-AFazGsgWF6gJonE_qHvCHR3Mw9MwTzL1JPPZ8y_77Z0V7Ct5L3XgGv6-MtnFvT7
    Xj5HfQHkc6Szi-I66nfDwPcixnl4bALNJifnKt8lwe-I9k0b0AB5umW>
X-ME-Proxy-Cause: dmFkZTGAi2eNM/rVfcPjL/ENMAoTp88oow+cXfR1472efG9lAcpofDkYsAnS/j/hvHrkJC
    xkdy/sZBcHspWu2YELutvkmMo5AOyBwfDW5aE+A5eH7vYOxCMOykEv97kPOjVIHMpFinJM
    XO2f6DyiG+qTAsEFoigpNkqIFTh3HVCLsdqnF+Kn1WyPG8/SN+QZ5fHCS8iNPmfKWlQzBZ
    gJuA8HDek1GwJtLwmeMR0eF036A/chB+KmafqyU/pY9ibiDGdEp0MbXFt7KUiEkoCISk7x
    s09eUbGSNzBDat89BgRUcqM0Ka/3Mg4nR8doN/mvXEH8kwA7UhGbASxeM4dnS0NCsqTMts
    NyykY/cyF9S2vrxdg1LNTuWrD3Je4TMpJIuOifUp4mXAZZSkEmx99WfL8rUBfW+0O/+42m
    2DDgMf08aC7FZ3F7qp+GDfgKxS18HnZTyZV64VhDS1FZK5j95+Yb9BsE0+baV8yv/+wYzw
    ntzyrkf2wI/xFqhZOi7Rg6d3RuyYXaGFCIzkd7/ghuoitpOfqgGy+qtiXp17DNKLBD4B8P
    COf+7FLAU/E3QjjyQWvyW97u3It349wGx78VHQD2iciubw1dzJCC1C7/BcceWTjxQ5gx+V
    HONkSwPbF99KEiL8vaGEKOzGaWS2ehncngkVY9jzYlSUEImZFbwqpPT/uPRg
X-ME-Proxy: <xmx:o-AFa31JqPm5gEaIyThM7v6qFXv8ZxBklDeYWTutwxNlh-lI0C2sIQ>
    <xmx:o-AFa3nCiilGKLHre1PdbQDr5VlHK8VWQ9xNvfMcWpKL1rWDwadpFw>
    <xmx:o-AFa39Ab8VLtW4h854KCNDSO7yMF7e5ZCvm31EyEgDy7NfS-iHZEw>
    <xmx:o-AFa8rpYJ92trpBbqVNVcwZSdsR9f8siPuS4k8UkwofwO40E8tKvw>
    <xmx:o-AFawlPwPalfTmLqiwKUa4oSBelMYqnNbAbUxTVYUXtKNRV6uDFQssd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4A613780070; Tue, 24 Nov 2026 14:08:19 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AmWEqgcKr2g3
Date: Tue, 24 Nov 2026 14:07:59 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Dan Aloni" <dan.aloni@vastdata.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Hubert Dziedziczak" <hubert.dziedziczak@nmc2.ai>
Message-Id: <6f2f2b6b-74ed-4c5b-a7ac-d4748139f5f8@app.fastmail.com>
In-Reply-To: <20261124130027.1432127-1-dan.aloni@vastdata.com>
References: <20261124130027.1432127-1-dan.aloni@vastdata.com>
Subject: Re: [PATCH] sunrpc: fix for missing initialization of GSS au_flags
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Nov 24, 2026, at 8:00 AM, Dan Aloni wrote:
> gss_create_new() gets struct gss_auth from kmalloc() and never stores to
> rpc_auth.au_flags except through __set_bit(). That sets
> RPCAUTH_AUTH_UPDATE_SLACK on every GSS auth, and RPCAUTH_AUTH_DATATOUCH only for
> krb5i and krb5p. __set_bit() leaves every other bit alone, so a leftover
> DATATOUCH bit from the slab stays set on plain krb5 when the kernel does not
> zero allocations.
>
> This had led to non-determinant behavior of `rpcrdma_marshal_req()`, which reads
> that bit as "this GSS flavor must not place payload bytes directly". A large
> READ then goes out as a reply chunk instead of a write chunk, when it it not
> needed.
>
> So we should init this field. Another option was to do kzalloc instead, but I
> thought it's better here to stay aligned with the current initialization manner.
>
> Cc: Hubert Dziedziczak <hubert.dziedziczak@nmc2.ai>
> Signed-off-by: Dan Aloni <dan.aloni@vastdata.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c 
> b/net/sunrpc/auth_gss/auth_gss.c
> index 8ddc65e894dab..a666704f1eb9b 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1056,6 +1056,7 @@ gss_create_new(const struct rpc_auth_create_args 
> *args, struct rpc_clnt *clnt)
>  	auth->au_rslack = GSS_KRB5_MAX_SLACK_NEEDED >> 2;
>  	auth->au_verfsize = GSS_VERF_SLACK >> 2;
>  	auth->au_ralign = GSS_VERF_SLACK >> 2;
> +	auth->au_flags = 0;
>  	__set_bit(RPCAUTH_AUTH_UPDATE_SLACK, &auth->au_flags);
>  	auth->au_ops = &authgss_ops;
>  	auth->au_flavor = flavor;
> -- 
> 2.52.0

Hi Dan -

This looks like a client-side issue, so I'm directing it to Trond and
Anna for application to the NFS client tree.

  Reviewed-by: Chuck Lever <cel@kernel.org>

When applying, consider adding:

  Fixes: 53bc19f17f21 ("SUNRPC: receive buffer size estimation values almost never change")

and

  Cc: stable@vger.kernel.org


-- 
Chuck Lever
