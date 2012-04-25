Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:38941 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758797Ab2DYUbt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 16:31:49 -0400
Subject: Re: [PATCH 1/1] mounts.nfs: v2 and v3 background mounts should retry when server is down.
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335368390-26767-1-git-send-email-steved@redhat.com>
Date: Wed, 25 Apr 2012 16:31:44 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <56A41F90-A936-4926-B532-E6600655025E@oracle.com>
References: <1335368390-26767-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Apr 25, 2012, at 11:39 AM, Steve Dickson wrote:

> The point of background mounts is to have the mount
> retried if the mount fails. This patch allows the v2/v3
> background mount to proceed in the case when the server
> is down by not making EOPNOTSUPP a permanent error.

Just curious... why wouldn't we want to do this for foreground mounts as well?

> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/mount/stropts.c |    6 ++++--
> 1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index d52e21a..e09aa7c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -911,7 +911,8 @@ static int nfsmount_parent(struct nfsmount_info *mi)
> 	if (nfs_try_mount(mi))
> 		return EX_SUCCESS;
> 
> -	if (nfs_is_permanent_error(errno)) {
> +	/* retry background mounts when the server is not up */
> +	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
> 		mount_error(mi->spec, mi->node, errno);
> 		return EX_FAIL;
> 	}
> @@ -946,7 +947,8 @@ static int nfsmount_child(struct nfsmount_info *mi)
> 		if (nfs_try_mount(mi))
> 			return EX_SUCCESS;
> 
> -		if (nfs_is_permanent_error(errno))
> +		/* retry background mounts when the server is not up */
> +		if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP)
> 			break;
> 
> 		if (time(NULL) > timeout)
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




