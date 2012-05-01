Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757697Ab2EATfz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 15:35:55 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q41JZtCe002673
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 1 May 2012 15:35:55 -0400
Message-ID: <4FA03B11.1020302@RedHat.com>
Date: Tue, 01 May 2012 15:35:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mounts.nfs: v2 and v3 background mounts should retry
 when server is down.
References: <1335368390-26767-1-git-send-email-steved@redhat.com>
In-Reply-To: <1335368390-26767-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/25/2012 11:39 AM, Steve Dickson wrote:
> The point of background mounts is to have the mount
> retried if the mount fails. This patch allows the v2/v3
> background mount to proceed in the case when the server
> is down by not making EOPNOTSUPP a permanent error.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/mount/stropts.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index d52e21a..e09aa7c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -911,7 +911,8 @@ static int nfsmount_parent(struct nfsmount_info *mi)
>  	if (nfs_try_mount(mi))
>  		return EX_SUCCESS;
>  
> -	if (nfs_is_permanent_error(errno)) {
> +	/* retry background mounts when the server is not up */
> +	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
>  		mount_error(mi->spec, mi->node, errno);
>  		return EX_FAIL;
>  	}
> @@ -946,7 +947,8 @@ static int nfsmount_child(struct nfsmount_info *mi)
>  		if (nfs_try_mount(mi))
>  			return EX_SUCCESS;
>  
> -		if (nfs_is_permanent_error(errno))
> +		/* retry background mounts when the server is not up */
> +		if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP)
>  			break;
>  
>  		if (time(NULL) > timeout)
> -- 1.7.7.6 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
> 
