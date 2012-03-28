Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49454 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757834Ab2C1OTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 10:19:34 -0400
Date: Wed, 28 Mar 2012 10:19:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, dan.carpenter@oracle.com
Subject: Re: [PATCH] nfsd: fix NULL pointer dereference in cld_pipe_downcall
Message-ID: <20120328141933.GC7779@fieldses.org>
References: <1332934561-1709-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332934561-1709-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 07:36:01AM -0400, Jeff Layton wrote:
> If we find that "cup" is NULL in this case, then we obviously don't
> want to dereference it. What we really want to print in this case
> is the xid that we copied off earlier.

Thanks, applied.--b.

> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 21b53d5..eaaf948 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -602,8 +602,7 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  
>  	/* couldn't find upcall? */
>  	if (!cup) {
> -		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__,
> -			cup->cu_msg.cm_xid);
> +		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__, xid);
>  		return -EINVAL;
>  	}
>  
> -- 
> 1.7.7.6
> 
