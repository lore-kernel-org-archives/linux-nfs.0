Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbbCKT6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2015 15:58:22 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2BJwLOL005098
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 15:58:21 -0400
Received: from [10.10.62.215] (vpn-62-215.rdu2.redhat.com [10.10.62.215])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2BJwJLj018750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 15:58:20 -0400
Date: Wed, 11 Mar 2015 15:58:19 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: remount with security change should return EINVAL
In-Reply-To: <e4fb183aaa5faf4fac14e0f81ad3a40f604f68d4.1417834215.git.bcodding@redhat.com>
Message-ID: <alpine.OSX.2.19.9992.1503111555580.947@planck.local>
References: <e4fb183aaa5faf4fac14e0f81ad3a40f604f68d4.1417834215.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bump..  ..even though I can't imagine a smaller problem, any chance to take
this one?

Ben

On Fri, 5 Dec 2014, Benjamin Coddington wrote:

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
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
