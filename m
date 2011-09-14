From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Date: Wed, 14 Sep 2011 14:26:49 -0400
Message-ID: <4E70F1E9.2030906@RedHat.com>
References: <1312625496-2496-1-git-send-email-luk@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Luk Claes <luk@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757261Ab1INS0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 14:26:53 -0400
In-Reply-To: <1312625496-2496-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/06/2011 06:11 AM, Luk Claes wrote:
> If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.
> 
> Signed-off-by: Luk Claes <luk@debian.org>
Committed....

steved.

> ---
>  utils/mount/stropts.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index f1aa503..8b2799c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>  	if (po_append(options, new_option) == PO_FAILED)
>  		return 0;
>  
> -	po_remove_all(options, "port");
> -	if (nfs_pmap->pm_port != NFS_PORT) {
> +	if(po_remove_all(options, "port") == PO_FOUND ||
> +	   nfs_pmap->pm_port != NFS_PORT) {
>  		snprintf(new_option, sizeof(new_option) - 1,
>  			 "port=%lu", nfs_pmap->pm_port);
>  		if (po_append(options, new_option) == PO_FAILED)
