From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options
 are	present
Date: Mon, 16 Nov 2009 12:54:22 -0500
Message-ID: <4B0191CE.4000709@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173712.12619.45807.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542AbZKPRyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 12:54:24 -0500
In-Reply-To: <20091008173712.12619.45807.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/08/2009 01:37 PM, Chuck Lever wrote:
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
> +			goto out_fail;
> +		}
>  		if (po_append(options, "vers=4") == PO_FAILED) {
>  			errno = EINVAL;
>  			goto out_fail;
> 
Committed... with a comment...

steved.
