From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 4/4] mount.nfs: Prepare way for "vers=4,rdma" mounts
Date: Tue, 07 Sep 2010 16:07:12 -0400
Message-ID: <4C869B70.4020405@RedHat.com>
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net> <20100907162638.3392.14786.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758081Ab0IGUHP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:07:15 -0400
In-Reply-To: <20100907162638.3392.14786.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/07/2010 12:26 PM, Chuck Lever wrote:
> At some point, when the kernel starts to support "vers=4,rdma" mounts,
> we will want the mount.nfs command to pass "vers=4,rdma" mounts
> instead of rejecting them.
> 
> Assuming that the kernel will reject these today with EPROTONOSUPPORT,
> that would cause the version fallback logic to go to "vers=3,rdma"
> automatically.  So the extra check we have now is not needed anyway.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/stropts.c |    7 -------
>  1 files changed, 0 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 9695c73..a8b22ce 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -302,13 +302,6 @@ static int nfs_set_version(struct nfsmount_info *mi)
>  
>  	if (strncmp(mi->type, "nfs4", 4) == 0)
>  		mi->version = 4;
> -	else {
> -		unsigned long protocol;
> -		if (!nfs_nfs_protocol(mi->options, &protocol))
> -			return 0;
> -		if (protocol == NFSPROTO_RDMA)
> -			mi->version = 3;
> -	}
>  
>  	/*
>  	 * If we still don't know, check for version-specific
> 
This is a show stopper... We can default to v4 because the callbacks.

steved.
 
