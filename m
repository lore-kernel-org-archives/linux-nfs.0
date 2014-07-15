Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60457 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269AbaGORII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:08:08 -0400
Date: Tue, 15 Jul 2014 10:08:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/7] sunrpc: clean up endianness warnings in setup_token
Message-ID: <20140715170806.GE7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405303064-9102-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405303064-9102-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 09:57:40PM -0400, Jeff Layton wrote:
> This is safe since KG_TOK_MIC_MSG and SEAL_ALG_NONE are both endian
> palindromes. I'm also making the assumption that the signalg field
> really should be in little-endian. That looks odd, but looking at the
> spec I guess it's correct.

> @@ -83,10 +83,10 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
>  
>  	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
>  	krb5_hdr = ptr;
> +	*ptr++ = cpu_to_be16(KG_TOK_MIC_MSG);
> +	*ptr++ = (__force __be16)cpu_to_le16(ctx->gk5e->signalg);
> +	*ptr++ = cpu_to_be16(SEAL_ALG_NONE);
> +	*ptr++ = cpu_to_be16(0xffff);

If signalg is little endian and all others are palindromes it seems
like ptr should be defines as __le16.

>  	return (char *)krb5_hdr;

Seems like krb5_hdr should simply be defined as void *, together with
the return value?

