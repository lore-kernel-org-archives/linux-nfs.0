Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51910 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068AbaGOREo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:04:44 -0400
Date: Tue, 15 Jul 2014 10:04:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] sunrpc: clean up sparse endianness warnings in
 gss_krb5_wrap.c
Message-ID: <20140715170442.GC7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405303064-9102-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405303064-9102-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 09:57:43PM -0400, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_wrap.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index 42560e55d978..c5cc0270a334 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -201,9 +201,9 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
>  
>  	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
>  
> +	*(__be16 *)(ptr + 2) = (__force __be16)cpu_to_le16(kctx->gk5e->signalg);

This looks silly.  This should be:

	*(__le16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);

Maybe with a comment somewhere explaining why we're doing little endian
encoding here if it's not obvious from the surrounding code.

