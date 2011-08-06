Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:33277 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1HFRCP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 13:02:15 -0400
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1312625496-2496-1-git-send-email-luk@debian.org>
Date: Sat, 6 Aug 2011 13:01:56 -0400
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <309705ED-3215-493C-BA2B-5CF19CA0BF91@oracle.com>
References: <1312625496-2496-1-git-send-email-luk@debian.org>
To: Luk Claes <luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 6, 2011, at 6:11 AM, Luk Claes wrote:

> If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.

I'm not clear on what's broken.

> Signed-off-by: Luk Claes <luk@debian.org>
> ---
> utils/mount/stropts.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index f1aa503..8b2799c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
> 	if (po_append(options, new_option) == PO_FAILED)
> 		return 0;
> 
> -	po_remove_all(options, "port");
> -	if (nfs_pmap->pm_port != NFS_PORT) {
> +	if(po_remove_all(options, "port") == PO_FOUND ||
> +	   nfs_pmap->pm_port != NFS_PORT) {
> 		snprintf(new_option, sizeof(new_option) - 1,
> 			 "port=%lu", nfs_pmap->pm_port);
> 		if (po_append(options, new_option) == PO_FAILED)
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



