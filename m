Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:32967 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbaFQK2P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 06:28:15 -0400
Date: Tue, 17 Jun 2014 03:28:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: sparse endianness warning cleanups
Message-ID: <20140617102812.GA32216@infradead.org>
References: <1403000146-31394-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403000146-31394-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> @@ -581,8 +581,8 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
>  	__be32 verf[2];
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
> -	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
> -	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
> +	verf[0] = (__force __be32)nn->nfssvc_boot.tv_sec;
> +	verf[1] = (__force __be32)nn->nfssvc_boot.tv_usec;
>  	memcpy(verifier->data, verf, sizeof(verifier->data));

Given that the verifier should be opaque is there any reason not to
simple do the byte swap here?  If not I think the rule that no __force
cast should be without a comment applies here.

> -	verf[0] = (__be32)get_seconds();
> -	verf[1] = (__be32)i++;
> +	verf[0] = (__force __be32)get_seconds();
> +	verf[1] = (__force __be32)i++;
>  	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));

Same here.

In general I think one patch per issue also would better, and some
comments of what's fixed (trivial for the places adding static, not so
trivial for various __force overrides)
