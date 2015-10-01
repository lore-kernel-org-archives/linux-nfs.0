Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35970 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbJAXXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 19:23:19 -0400
Received: by qkcf65 with SMTP id f65so36324400qkc.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2015 16:23:18 -0700 (PDT)
Date: Thu, 1 Oct 2015 19:23:15 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH] NFS: Fix a write performance regression
Message-ID: <20151001192315.02be2dee@tlielax.poochiereds.net>
In-Reply-To: <1443741146-21816-1-git-send-email-trond.myklebust@primarydata.com>
References: <1443741146-21816-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  1 Oct 2015 19:12:26 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If all other conditions in nfs_can_extend_write() are met, and there
> are no locks, then we should be able to assume close-to-open semantics
> and the ability to extend our write to cover the whole page.
> 
> With this patch, the xfstests generic/074 test completes in 232s instead
> of >1400s on my test rig.
> 
> Fixes: bd61e0a9c852 ("locks: convert posix locks to file_lock_context")
> Cc: Jeff Layton <jlayton@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/write.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 72624dc4a623..1d6f6b43b7f4 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1223,7 +1223,7 @@ static int nfs_can_extend_write(struct file *file, struct page *page, struct ino
>  		return 1;
>  	if (!flctx || (list_empty_careful(&flctx->flc_flock) &&
>  		       list_empty_careful(&flctx->flc_posix)))
> -		return 0;
> +		return 1;
>  
>  	/* Check to see if there are whole file write locks */
>  	ret = 0;


Ouch -- mea culpa. Actually broken originally in
5263e31e452fb84138b9bee061d5c06c0f359fea, I think...

In any case:

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
