Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860Ab3JUNyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 09:54:06 -0400
Date: Mon, 21 Oct 2013 09:54:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: reject version and minorversion changes on remount
 attempts
Message-ID: <20131021095402.4d00845b@tlielax.poochiereds.net>
In-Reply-To: <1382363505-6481-1-git-send-email-jlayton@redhat.com>
References: <1382363505-6481-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Oct 2013 09:51:45 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> Reported-by: Eric Doutreleau <edoutreleau@genoscope.cns.fr>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/super.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a03b9c6..137572b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2143,6 +2143,8 @@ nfs_compare_remount_data(struct nfs_server *nfss,
>  	if (data->flags != nfss->flags ||
>  	    data->rsize != nfss->rsize ||
>  	    data->wsize != nfss->wsize ||
> +	    data->version != nfss->nfs_client->rpc_ops->version ||
> +	    data->minorversion != nfss->nfs_client->cl_minorversion ||
>  	    data->retrans != nfss->client->cl_timeout->to_retries ||
>  	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
>  	    data->acregmin != nfss->acregmin / HZ ||
> @@ -2197,6 +2199,8 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
>  	data->nfs_server.port = nfss->port;
>  	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
> +	data->version = nfsvers;
> +	data->minorversion = nfss->nfs_client->cl_minorversion;
>  	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
>  		data->nfs_server.addrlen);
>  

Sorry for the resend here. There is no difference between this patch
and the one I sent last week, other than the addition of the
Reported-by tag.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
