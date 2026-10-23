Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792783906;
	b=sm0fQ8AooRuE1e3WsYQtp3jCZDx9hoJt3PKGN49uuGwa9OvVZ8kQzFxMvwTdBy3xqqqo
	 CCgHPSTvCXaNenJEv2+twgYg+U039qSNon4ysapodAsKhprSR4+hjujf9+zHD6HDWGmiC
	 Ygsdh1ZhRbWIOp+jmTq1ah39cYmnW7K+bRh/u8sl/ALWZrSqHZGo9bA7IGd38YDQu+ya1
	 /knzKZb/9Lm3BI4ZbicoA/lSXqvryAvzYfjFmeaTPNDCZKOCJXhNPL9qhakrxVK8YgFJc
	 rMCXFJP9d9NSE70seUBhdnsWlE9ZN3wL0U4wirt+zdynLATLRCdsEvnflGFIzNGDFxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792783906;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ggr/VQhdQP+lPE/D1sHGykkWE4SyoiDv3FucKYLEUgs=;
	b=MoB+x8hAp7JYHU6fLUVK8HfvbK1wxznd2n6rpkRMk3y6YmQfSEquFLVlovEmTD+IOCXt
	 NBDi3bPsrlWsRRhc3cLh0YRXDZq9fL6I/Raik8K55OfPsRONyzbSWJv+K5fffS+wuNV8N
	 kTtfKv4BHYkhpQfQgYx28SK0frAZVIJ2UxUzV7gRjZHN4C7FLRIS1hOHJxQxOMIAsPa9F
	 ZWOlmbAp2oxof/J0qbMqF8JN1hl9LAb1Kcq34w6EBtWzq+HlMMYwPKiDJ5ZcK/6zvcoSe
	 GOd3zIQ0QEf8pjHeZVlEov/+UFoEBP//PtEr4VZzAFXu7ltxlg9+5gryF5d8mjp495A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W9aP5+YE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46804606A31E;
	Fri, 23 Oct 2026 19:31:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W9aP5+YE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 866871F01825;
	Fri, 23 Oct 2026 19:31:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792783904;
	bh=ggr/VQhdQP+lPE/D1sHGykkWE4SyoiDv3FucKYLEUgs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=W9aP5+YESx0X7mpjDbBI03HX351/wXxdLq9Ep8Doz/8JvB0wxn0Z/5hBCkYZSqf8Q
	 Qe2e6V+luezlZWXDDTC0v7zZHFxzJZrrtsYvyzr7io2Lne2mrMy70n2AfWxgUIo7ib
	 VRCa7UkeEZjSvhYvcpedJjQQ8b/qecc5Rwjq+z72Ar1NxWDNsqeb/PR0eIuxlPPyMq
	 30MaF+J4e4iYWCZZbk2dwnvvg+y1ovS31247YxGwFSClCKikf1EDWp4DxkpetB4GB6
	 FT1zoPS2+kEo6g9FkFCSEwgltitAj8F2CsqrZLAbw8y3PuGo7ll+gGn7nVr+z8LGb4
	 X7jfqAfpKzSfw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E426CF40067;
	Fri, 23 Oct 2026 15:31:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 15:31:43 -0400
X-ME-Sender: <xms:H7bbakkxEDgyybWMuc9-02sPY-gpZvRMx_gCSqLSJs1vf6Clwl85Pw>
    <xme:H7bbauplBwSHm2c3_inLEN1MAk4FNYUggj-GM2c6us2UtGyrQFyaIpdisfXVbXm9G
    rYwnaeCv_hpY7XbSwzo-KXZVmVuR685RstgMoMP2tCL-mQfn_y9pLE>
X-ME-Proxy-Cause: dmFkZTEzkoJfQL7/iSb54XjHaX9ewOb08c9bIZid7L4WnKVNmwJaMtH7xOus53ANN/L7xf
    wyfclulp08ivY2KA2dERjZaXRzqyaErPrZxd7oj69nFOwKZlxo0XPR1t8Q7rJNsgpRF3eI
    RRgejklr1RnJfqxJLH3de/PCSMPkbYfbKY1cd6csd0SEkf2TizDhfEWCjoPAKq8JDoak8T
    G0u9/S5c7N4HCHn4x9B0FRrSMPCNgl/wGDci5Eh4Iu2xpoNB+D1eXzVOuCbCmFCQGMa9Y3
    g1SBfnsyWuMsnKsA1W5iX/sOqaaNTi2jwQfcnNkPO070Vd0u6oD2VS6YrSRU53xNuxqErn
    mL0KJ30Sxpx44wQeh47Rnr6vxWVvthsMF7uKxJc1N10Idn3g5A2JpaelG41GinaP4dbdXi
    9yfV3pVJOw7GPGAFsvNujapKdd5LVb+vQK5Dd4L+eN6ApY/97+bYMlN8Ptlpv+Zz1SQpLj
    Llyem2k5DhPk08znFVfxmSwcO0LMDLl/y6s+Pib5xwvTM8nlxmh31CAgmTi9NX+l1WPfVK
    P7TgCr/ePtyernHY0r+t2wudIv0rRrzu5hI0hKst1tTvl2zAUpbSU5nnhOO/3TPZc2IcXx
    1pzN2G22Q7c1s6WL0A9XlVNoQYz4kGnFZC3rWM69lNOBZqvx8BRzzSChDEyQ
X-ME-Proxy: <xmx:H7bbap3vrbaRruijTAnhRzuQGwm1sLNLGQjSt9vhcp__wqeequYmQA>
    <xmx:H7bbaseT8liqPDDNDR8APsyu9ZgMf463y-eLjq-KZNHfv68UVA02ag>
    <xmx:H7bbauVGPeAIE4BCO6ArtkeRVsbA5qw2ml7xkaCydrdLJ30vMu9OJg>
    <xmx:H7bbak8CGgAJoLvCOSEFY9jG2MB6_tmpDvFOAcN0IXfgzBNhr6WmIQ>
    <xmx:H7bbaoiVwLhWaLBi4m5V-7ZgYXFyXOUmeQoX3YEpurVnNFn2DYHlNFdJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C7958782738; Fri, 23 Oct 2026 15:31:43 -0400 (EDT)
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
X-ThreadId: A2zF8WBQdH93
Date: Fri, 23 Oct 2026 15:31:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <6d50ff7b-6765-4e83-92dc-009a571f9844@slotpi15m67>
In-Reply-To: <20261023125033.528835-3-lixiasong1@huawei.com>
References: <20261023125033.528835-1-lixiasong1@huawei.com>
 <20261023125033.528835-3-lixiasong1@huawei.com>
Subject: Re: [PATCH 2/3] rpcrdma: Pin notifications during removal callbacks
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/23/26 8:50 AM, Li Xiasong wrote:
> +static bool rpcrdma_ep_removal_get(struct rpcrdma_notification *rn)
> +{
> +	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
> +
> +	return kref_get_unless_zero(&ep->re_kref);
> +}

Before this series the whole ep could be freed under the walk;
that's now fixed. But now that there is a get/put pair, it seems
natural to close the remaining gap here. rpcrdma_ep_removal_get()
could also take xprt_get(ep->re_xprt), and rpcrdma_ep_removal_put()
could drop it with xprt_put(). xprt_put() defers the destroy to a
work item, so dropping the last transport reference from inside the
removal walk does not recurse into xprt_rdma_destroy() while the
mutex is held.


> diff --git a/include/linux/sunrpc/rdma_rn.h b/include/linux/sunrpc/rdma_rn.h

> +	bool			(*rn_get)(struct rpcrdma_notification *rn);
> +	void			(*rn_put)(struct rpcrdma_notification *rn);

Let's add @rn_get and @rn_put entries to the struct's kdoc comment.

The kernel-doc for rpcrdma_rn_register() should also spell out the
contract for @get: it has to pin the object that embeds @rn so that
the owner cannot call rpcrdma_rn_unregister() while the pin is
held. rpcrdma_remove_one() depends on that when it calls
rn->rn_put() after dropping the mutex. Both registrants in this
patch satisfy it, since they unregister only from their final kref
release, but a future registrant has no way to know the new rule.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
