Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:32832 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757000AbcH2K5v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 06:57:51 -0400
Received: by mail-qk0-f194.google.com with SMTP id n66so10085138qkf.0
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 03:57:51 -0700 (PDT)
Message-ID: <1472468267.2597.0.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: constify reply_cache_stats_operations structure
From: Jeff Layton <jlayton@poochiereds.net>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 29 Aug 2016 06:57:47 -0400
In-Reply-To: <1472416615-24079-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1472416615-24079-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-08-28 at 22:36 +0200, Julia Lawall wrote:
> reply_cache_stats_operations, of type struct file_operations, is
> never
> modified, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  fs/nfsd/nfsctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 65ad016..3bc9693 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -217,7 +217,7 @@ static const struct file_operations
> pool_stats_operations = {
>  	.release	= nfsd_pool_stats_release,
>  };
>  
> -static struct file_operations reply_cache_stats_operations = {
> +static const struct file_operations reply_cache_stats_operations = {
>  	.open		= nfsd_reply_cache_stats_open,
>  	.read		= seq_read,
>  	.llseek		= seq_lseek,
> 

I'm pretty sure Bruce will pick this up for v4.9:

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
