From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options
 are	present
Date: Fri, 09 Oct 2009 09:29:53 -0400
Message-ID: <4ACF3AD1.2080802@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173712.12619.45807.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbZJINad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 09:30:33 -0400
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
I think it make senses to assume the version negation should 
start version 3 when  mountXXXX options exist instead of 
failing a mount they probably didn't want.. 

steved.
 
