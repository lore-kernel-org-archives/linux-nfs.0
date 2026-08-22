Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3103F351C0B;
	Sat, 22 Aug 2026 16:51:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787417484; cv=none; b=i/qTUfChGrbcCZTx5j4mbp5bbisrfq+Hg4S+2lD3Ai1VjCA+nyTSl/Q1WchLBUZFjHX0U+Xcrmn21JfT0BZ7YcZ80Q8SvXxFBhYgGoEUoKy2EO2zQhfcO69wa0DkNfOeVGfeFHiozkBT4v/aWYjHwWbf0q30gGTOXOl35qWw7W4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787417484; c=relaxed/simple;
	bh=yqEJXKn2EFzQ38JJ3EE6umwKuK8u3pLJba2iVw5Vopk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=tBTzsTjzgdv8qFeks2tcb740Oe6L11RK021QCW4G0egNqWoeCmCLEZlnwn+3axPgLDdgvMBDmBH3OHvuLJh2ye9iZJ/ESkY3mEa9oPcNztZQSYj+iB9CDHV5FE4lS/Ej3Q3YZqKfSMHh6cu7Qe7sGsyAHE31QbEAsEQgkvrly6E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j03uUJyZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j03uUJyZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E14B1F00A3A;
	Sat, 22 Aug 2026 16:51:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787417481;
	bh=dLSVwCinrBuiuXaWkx8ltrsj3GPmbguoW1GsWfsXtzw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=j03uUJyZg4zVFtvjAkdgQllUJeWFPh/7Md9HC1s7tITx+AV3WFrsy6+CczWIvSO90
	 NqoWs86I6hCFHSRU/2KuKMNyAALU2XMUYmRthQcqS9rwZh2UorLKpylcR+6t7Wp3Ev
	 IHhs7mFdkxaHL73WaPkNPH/4HkVXb3lYxNpkkF6G752m3v6BK66aLoCgsJ9iHE6aGU
	 GJSXQaDaO6C+7NUmOAR481GnNgmwg7LCxkA8NJjdaRU9CWZXMlVPZ79DELol/J9Y4U
	 ZGo2j9g813pvxXOHexYbGzCjPgVsi9p0Xrz3NYZmLBQvySdSBK2CKOQIQtqz0ubrDr
	 qlcllTKWXqQpg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A4AEDF40066;
	Sat, 22 Aug 2026 12:51:19 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 22 Aug 2026 12:51:19 -0400
X-ME-Sender: <xms:h9OJauYFKhOZVHa9L6JWGvW04EAQX2LSq7egJCNXWuiiSwS2GcQbmg>
    <xme:h9OJasP6x6mnumL7LPoUy9Us4FEtjnP016sSFjzd-y4qWaRUXEdJk6tywTHF6aDe_
    EeiJY7aRijtbdGgT0n1HLgNoADtV3Emnwx3OqAy9pGt55Hjl8qbriso>
X-ME-Proxy-Cause: dmFkZTFYQZ03hu+4Vl3cdsIE5tySqToP+c0OS/KMVaCFb+KExQzMd5lFwD27SpXLWsR6Ed
    OTk8zHsoJV0iWfSH2JOSFkvcNbD7Lx5eZqodR3vpHtz6Z97mn0GKVWAPI3GnTL5Ho6nX8H
    CmppZomduWwNbAYvV4aOULjUUL7w6IjcsJr9K5o3OMQbkzqb0n3MPRNpvkhjNvEIVDSMt0
    TZ4o3mQwFdSmTDfGANDcPZf2bAUHEeIHqifaXDRxowNO6J5aHlG1Ws7LST5yq2musj0nhQ
    hEfcu9MKW37f2guqY8Zm8aAG9zKE09nrHA6d/1L4t/qmAOzhNwFnUNCwEcAuGP1cVMxqn4
    GEEIgEZe6NnY2QrtU5BuMCRu8wnhn+VFodgfGvjR18aRMSKyAl9HbsdtinOT+nHCH93vak
    HuyRgIv447hs+R6tWL7jIpisJzTeqgzXhTpOewo5u1N3N4Zp8wSevPXh3fQmSYQIk+vPCZ
    B96A8uIYQ+ZbNmvRnGCUnwt9rmPN15fz/ivP99HdYUhqqjC2AZ5HDDqoHtluE6Y76RVUwp
    3ZOq5TmVlyPGsgy5y/XFvaFLLKSK3t+1h0SEZrYBIIY6tGRKxzrCCHuAkMyLNCBSQwNbHu
    r87Oyul618kQKdG9Pw6T2S/MlDpkmyOvELOZkrhj0D4SzzR76Lx2M0XCU51Q
X-ME-Proxy: <xmx:h9OJarHk6C6pufWTV5sYE-ETV3D0tsQQbVVuaPeon2XYxABTJ5r6PA>
    <xmx:h9OJauXczmCBEsdvb_8JvR5Vg6VYEsC3fZG9bf8WkmzXt9OcmYDUMA>
    <xmx:h9OJan80Zt-76wA_tzS_hNmKA9DM7Pb0_P0ie8CK0nr2goiQ-DzFfA>
    <xmx:h9OJar6ENDuJRV8ohD6vvJZSZbJf1mUXzeZLUgsQi90562UgmmF_2A>
    <xmx:h9OJagn7QRGwIegVoj8349xUttSfK2Y3mvrvpyYwTUdeRsCL19WvsjqA>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 78D717811F0; Sat, 22 Aug 2026 12:51:19 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AWMsfxfueHdw
Date: Sat, 22 Aug 2026 12:51:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org,
 slingappa@everpuredata.com, ebadger@everpuredata.com,
 jcurley@everpuredata.com, "Tim Menninger" <tmenninger@everpuredata.com>
Message-Id: <9b573eb8-ea13-47bb-a06a-db70d57fc20e@app.fastmail.com>
In-Reply-To: <20260821234827.1560856-1-tmenninger@purestorage.com>
References: <aa454838-8574-404e-94c8-cca6b15a796c@app.fastmail.com>
 <20260821234827.1560856-1-tmenninger@purestorage.com>
Subject: Re: [PATCH v3] xprtrdma: serialize unmap_sync with xprt_disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 21, 2026, at 7:48 PM, tmenninger@purestorage.com wrote:

> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 04b286223b24..b9ebfcbcabc5 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c

> @@ -388,6 +387,14 @@ static noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
>  	return kref_put(&ep->re_kref, rpcrdma_ep_destroy);
>  }
> 
> +void rpcrdma_ep_release(struct rpcrdma_ep *ep)
> +{
> +	struct rdma_cm_id *id = ep->re_id;
> +
> +	if (rpcrdma_ep_put(ep))
> +		rdma_destroy_id(id);
> +}
> +

Nit: The new externally-visible functions need kdoc comments.
rpcrdma_ep_put() is now static, so the kdoc comment there can
be converted to non-kdoc-style.


> @@ -601,6 +614,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
>  		rdma_destroy_id(id);
> 
>  	r_xprt->rx_ep = NULL;
> +
> +out_unlock:
> +	up_write(&r_xprt->rx_unmap_rwsem);
>  }

Nit: rpcrdma_xprt_disconnect() retains

    if (rpcrdma_ep_put(ep)) 
        rdma_destroy_id(id);

but should call the new rpcrdma_ep_release() helper.

The new block comments are wordy, and could be tightened. But no
show-stoppers here:

Reviewed-by: Chuck Lever <cel@kernel.org>

-- 
Chuck Lever
