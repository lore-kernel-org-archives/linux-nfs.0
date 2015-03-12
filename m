Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36599 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbCLQAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2015 12:00:31 -0400
Received: by iegc3 with SMTP id c3so47940317ieg.3
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2015 09:00:30 -0700 (PDT)
Message-ID: <1426176012.15787.5.camel@primarydata.com>
Subject: Re: [PATCH] NFS: remount with security change should return EINVAL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 12 Mar 2015 12:00:12 -0400
In-Reply-To: <e4fb183aaa5faf4fac14e0f81ad3a40f604f68d4.1417834215.git.bcodding@redhat.com>
References: <e4fb183aaa5faf4fac14e0f81ad3a40f604f68d4.1417834215.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-12-05 at 21:52 -0500, Benjamin Coddington wrote:
> A remount that alters security flavors can appear to succeed when it should
> instead return -EINVAL.  Check to see if the current security flavor exists
> within the flavors specified in the remount options, and if not fail the
> remount.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/super.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 31a11b0..e6275e0 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2191,7 +2191,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
>  	    data->version != nfss->nfs_client->rpc_ops->version ||
>  	    data->minorversion != nfss->nfs_client->cl_minorversion ||
>  	    data->retrans != nfss->client->cl_timeout->to_retries ||
> -	    data->selected_flavor != nfss->client->cl_auth->au_flavor ||
> +	    !nfs_auth_info_match(&data->auth_info, nfss->client->cl_auth->au_flavor) ||
>  	    data->acregmin != nfss->acregmin / HZ ||
>  	    data->acregmax != nfss->acregmax / HZ ||
>  	    data->acdirmin != nfss->acdirmin / HZ ||
> @@ -2239,7 +2239,6 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	data->wsize = nfss->wsize;
>  	data->retrans = nfss->client->cl_timeout->to_retries;
>  	data->selected_flavor = nfss->client->cl_auth->au_flavor;
> -	data->auth_info = nfss->auth_info;
>  	data->acregmin = nfss->acregmin / HZ;
>  	data->acregmax = nfss->acregmax / HZ;
>  	data->acdirmin = nfss->acdirmin / HZ;

Thanks Ben. Applied...
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




