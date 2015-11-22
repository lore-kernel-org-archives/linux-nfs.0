Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34031 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbKVMZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Nov 2015 07:25:17 -0500
Received: by qkfo3 with SMTP id o3so50122798qkf.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2015 04:25:15 -0800 (PST)
Date: Sun, 22 Nov 2015 07:25:12 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, kernel-janitors@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: recover: constify nfsd4_client_tracking_ops
 structures
Message-ID: <20151122072512.2b6b3518@tlielax.poochiereds.net>
In-Reply-To: <1448176930-15173-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1448176930-15173-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 22 Nov 2015 08:22:10 +0100
Julia Lawall <Julia.Lawall@lip6.fr> wrote:

> The nfsd4_client_tracking_ops structures are never modified, so declare
> them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  fs/nfsd/netns.h       |    2 +-
>  fs/nfsd/nfs4recover.c |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index d8b16c2..5fbf3bb 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -92,7 +92,7 @@ struct nfsd_net {
>  
>  	struct file *rec_file;
>  	bool in_grace;
> -	struct nfsd4_client_tracking_ops *client_tracking_ops;
> +	const struct nfsd4_client_tracking_ops *client_tracking_ops;
>  
>  	time_t nfsd4_lease;
>  	time_t nfsd4_grace;
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index e3d4709..79f0307 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -631,7 +631,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
>  	return -ENOENT;
>  }
>  
> -static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
> +static const struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
>  	.init		= nfsd4_legacy_tracking_init,
>  	.exit		= nfsd4_legacy_tracking_exit,
>  	.create		= nfsd4_create_clid_dir,
> @@ -1050,7 +1050,7 @@ out_err:
>  		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
>  }
>  
> -static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
> +static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
>  	.init		= nfsd4_init_cld_pipe,
>  	.exit		= nfsd4_remove_cld_pipe,
>  	.create		= nfsd4_cld_create,
> @@ -1394,7 +1394,7 @@ nfsd4_umh_cltrack_grace_done(struct nfsd_net *nn)
>  	kfree(legacy);
>  }
>  
> -static struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
> +static const struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
>  	.init		= nfsd4_umh_cltrack_init,
>  	.exit		= NULL,
>  	.create		= nfsd4_umh_cltrack_create,
> 

Looks good to me.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
