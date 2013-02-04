Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56614 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab3BDSMq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 13:12:46 -0500
Date: Mon, 4 Feb 2013 13:12:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix comment in struct xdr_buf definition
Message-ID: <20130204181246.GK815@fieldses.org>
References: <1360000277-12778-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360000277-12778-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 12:51:17PM -0500, Jeff Layton wrote:
> ...these pages aren't necessarily contiguous.

I guess you could say it was correct if you took "contiguous" to mean
that the xdr data they hold is meant to be contiguous.

But, yeah, at best I can't see how that comment would help anyone.

Applying absent any objections.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/xdr.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 6398899..224d060 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -56,7 +56,7 @@ struct xdr_buf {
>  	struct kvec	head[1],	/* RPC header + non-page data */
>  			tail[1];	/* Appended after page data */
>  
> -	struct page **	pages;		/* Array of contiguous pages */
> +	struct page **	pages;		/* Array of pages */
>  	unsigned int	page_base,	/* Start of page data */
>  			page_len,	/* Length of page data */
>  			flags;		/* Flags for data disposition */
> -- 
> 1.7.11.7
> 
