From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options
 are present
Date: Thu, 08 Oct 2009 13:45:29 -0400
Message-ID: <1255023929.11961.7.camel@heimdal.trondhjem.org>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net>
	 <20091008173712.12619.45807.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51331 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759140AbZJHRqX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2009 13:46:23 -0400
In-Reply-To: <20091008173712.12619.45807.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-10-08 at 13:37 -0400, Chuck Lever wrote:
> Don't try NFSv4 if any MNT protocol related options were presented by
> the user.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/stropts.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0685caa..3401f63 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -564,6 +564,13 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
>  	}
>  
>  	if (mi->version == 0) {
> +		if (po_contains(options, "mounthost") ||
> +		    po_contains(options, "mountaddr") ||
> +		    po_contains(options, "mountvers") ||
> +		    po_contains(options, "mountproto")) {
> +			errno = EPROTONOSUPPORT;

Shouldn't this be EINVAL ?

> +			goto out_fail;
> +		}
>  		if (po_append(options, "vers=4") == PO_FAILED) {
>  			errno = EINVAL;
>  			goto out_fail;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


