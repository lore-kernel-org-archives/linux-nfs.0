Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44721 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbCYIlA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 04:41:00 -0400
Date: Wed, 25 Mar 2015 01:40:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu
Subject: Re: [PATCH] nfs: kstrdup() memory handling
Message-ID: <20150325084057.GA25682@infradead.org>
References: <1426957648-13104-1-git-send-email-sanidhya.gatech@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1426957648-13104-1-git-send-email-sanidhya.gatech@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 21, 2015 at 01:07:28PM -0400, Sanidhya Kashyap wrote:
> index 86d6214..08bf1f1 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -1217,8 +1217,15 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
>  		goto out;
>  	}
>  
> -	if (server->nfs_client->cl_hostname == NULL)
> +	if (server->nfs_client->cl_hostname == NULL) {
>  		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
> +		if (!server->nfs_client->cl_hostname) {
> +			error = -ENOMEM;
> +			dprintk("<-- %s(): not enough memory %d\n",
> +				__func__, error);
> +			goto out;
> +		}
> +	}
>  	nfs_server_insert_lists(server);

The function alays ensures to call nfs_server_insert_lists on each exit
path, and you add one that doesn't.

>  
>  	error = nfs_probe_destination(server);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 627f37c..2d8b408 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4974,6 +4974,9 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp,
>  							RPC_DISPLAY_PROTO));
>  	rcu_read_unlock();
>  	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
> +	if (!clp->cl_owner_id)
> +		return -ENOMEM;
> +
>  	return result;
>  }
>  
> @@ -4998,6 +5001,9 @@ nfs4_init_uniform_client_string(struct nfs_client *clp,
>  				clp->rpc_ops->version, clp->cl_minorversion,
>  				nodename);
>  	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
> +	if (!clp->cl_owner_id)
> +		return -ENOMEM;
> +

Both these use a scnprintf + kstrdup pattern thast should be replaced by
kasprintf.  But I still don't understand why both function get away with
just returning the caller supplied buf in one case, but need a dynamic
allocation in the other case.
