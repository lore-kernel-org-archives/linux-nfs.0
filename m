Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38593 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab0K2Or1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 09:47:27 -0500
Subject: Re: [PATCH] mount: avoid po_destroy to modify errno what we really want
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CEE357D.2030007@cn.fujitsu.com>
Date: Mon, 29 Nov 2010 09:45:32 -0500
Cc: Steve Dickson <SteveD@redhat.com>, NFSv3 list <linux-nfs@vger.kernel.org>
Message-Id: <9C08C339-281F-4CD4-B8C1-70441869E2F6@oracle.com>
References: <4CEE357D.2030007@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 25, 2010, at 5:07 AM, Mi Jinlong wrote:

> We should return the errno that was set before po_destroy,
> rather than the errno that was set at po_destroy.
> 
> Because the po_destroy function don't affect the return value,
> this patch just revert the saved errno after po_destroy.

The only library function used in po_destroy() is free(3).  Does free(3) change the value of errno?

> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
> utils/mount/stropts.c |    8 ++++++--
> 1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 50a1a2a..d554877 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -592,7 +592,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> 		struct sockaddr *sap, socklen_t salen)
> {
> 	struct mount_options *options = po_dup(mi->options);
> -	int result = 0;
> +	int result = 0, save = 0;
> 
> 	if (!options) {
> 		errno = ENOMEM;
> @@ -637,7 +637,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> 	result = nfs_sys_mount(mi, options);
> 
> out_fail:
> +	save = errno;
> 	po_destroy(options);
> +	errno = save;
> 	return result;
> }
> 
> @@ -673,7 +675,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
> 		struct sockaddr *sap, socklen_t salen)
> {
> 	struct mount_options *options = po_dup(mi->options);
> -	int result = 0;
> +	int result = 0, save = 0;
> 
> 	if (!options) {
> 		errno = ENOMEM;
> @@ -724,7 +726,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
> 	result = nfs_sys_mount(mi, options);
> 
> out_fail:
> +	save = errno;
> 	po_destroy(options);
> +	errno = save;
> 	return result;
> }
> 
> -- 
> 1.7.3.2
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




