From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] nfs41: fix nfs4_callback_recallslot
Date: Thu, 21 Jan 2010 14:47:22 -0500
Message-ID: <1264103242.3721.12.camel@localhost>
References: <1264101557-6619-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703Ab0AUTro convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 14:47:44 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0LJlfNT029717
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2010 11:47:44 -0800 (PST)
In-Reply-To: <1264101557-6619-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-21 at 14:19 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Return NFS4_OK if target high slotid equals enforced high slotid.
> Fix nfs_client reference leak.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback_proc.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index e5155d9..c79e18c 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -381,13 +381,17 @@ unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
>  	fc_tbl = &clp->cl_session->fc_slot_table;
>  
>  	status = htonl(NFS4ERR_BAD_HIGH_SLOT);

This is not related directly to your patch, but "sparse" is going to
have a field day with all these scattered around the place. Are there
any plans to clean all this up, and replace those 'int' and 'unsigned'
declarations that are being assigned big ended values with the correct
'__be32' type?

> -	if (args->crsa_target_max_slots >= fc_tbl->max_slots ||
> +	if (args->crsa_target_max_slots > fc_tbl->max_slots ||
>  	    args->crsa_target_max_slots < 1)
> -		goto out;
> +		goto out_putclient;
> +
> +	status = htonl(NFS4_OK);
> +	if (args->crsa_target_max_slots == fc_tbl->max_slots)
> +		goto out_putclient;
>  
>  	fc_tbl->target_max_slots = args->crsa_target_max_slots;
>  	nfs41_handle_recall_slot(clp);
> -	status = htonl(NFS4_OK);
> +out_putclient:
>  	nfs_put_client(clp);	/* balance nfs_find_client */
>  out:
>  	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));


