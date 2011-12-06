Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47179 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932811Ab1LFCK7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 21:10:59 -0500
Date: Mon, 5 Dec 2011 21:10:59 -0500
To: Benny Halevy <benny@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/13] pnfsd-block: reverse boolean_t values so they
 make sense
Message-ID: <20111206021059.GB4486@fieldses.org>
References: <4EDB79A9.2080109@tonian.com>
 <1323006496-13542-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323006496-13542-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 04, 2011 at 03:48:16PM +0200, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/bl_ops.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
> index 89249c4..4d2939e 100644
> --- a/fs/nfsd/bl_ops.c
> +++ b/fs/nfsd/bl_ops.c
> @@ -57,7 +57,7 @@
>  #endif
>  
>  
> -typedef enum {True, False} boolean_t;
> +typedef enum {False = 0, True = !False} boolean_t;

Shouldn't we just use "bool"?

--b.

>  /* ---- block layoutget and commit structure ---- */
>  typedef struct bl_layout_rec {
>  	struct list_head	blr_hash,
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
