Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751986AbcKVRen (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Nov 2016 12:34:43 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CECB0F44E0
        for <linux-nfs@vger.kernel.org>; Tue, 22 Nov 2016 17:33:56 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id uAMHXuID031959
        for <linux-nfs@vger.kernel.org>; Tue, 22 Nov 2016 12:33:56 -0500
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a
 permanent error
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115640.26568.2934329194247787636.stgit@noble>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <8afd838e-328a-d110-b0f2-b4e3ea89e593@RedHat.com>
Date: Tue, 22 Nov 2016 12:33:56 -0500
MIME-Version: 1.0
In-Reply-To: <147157115640.26568.2934329194247787636.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/18/2016 09:45 PM, NeilBrown wrote:
> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should retry when server is down.")
> 
> changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
> which maps to EOPNOTSUPP, is not a permanent error.
> This useful because when an NFS server starts up there is a small window between
> the moment that rpcbind (or portmap) starts responding to lookup requests,
> and the moment when nfsd registers with rpcbind.  During that window
> rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not give up.
> 
> This same reasoning applies to foreground mounts.  They don't wait for
> as long, but could still hit the window and fail prematurely.
> 
> So revert the above patch and instead add EOPNOTSUPP to the list of
> temporary errors known to nfs_is_permanent_error.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mount/stropts.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 9de6794c6177..d5dfb5e4a669 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
>  	case ETIMEDOUT:
>  	case ECONNREFUSED:
>  	case EHOSTUNREACH:
> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
Neil,

I think this introduced a regression... When the server does not support
a protocol, say UDP, this patch cause the mount to hang forever,
which I don't think we want.

steved.
>  	case EAGAIN:
>  		return 0;	/* temporary */
>  	default:
> @@ -1019,8 +1020,7 @@ static int nfsmount_parent(struct nfsmount_info *mi)
>  	if (nfs_try_mount(mi))
>  		return EX_SUCCESS;
>  
> -	/* retry background mounts when the server is not up */
> -	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
> +	if (nfs_is_permanent_error(errno)) {
>  		mount_error(mi->spec, mi->node, errno);
>  		return EX_FAIL;
>  	}
> @@ -1055,8 +1055,7 @@ static int nfsmount_child(struct nfsmount_info *mi)
>  		if (nfs_try_mount(mi))
>  			return EX_SUCCESS;
>  
> -		/* retry background mounts when the server is not up */
> -		if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP)
> +		if (nfs_is_permanent_error(errno))
>  			break;
>  
>  		if (time(NULL) > timeout)
> 
> 
