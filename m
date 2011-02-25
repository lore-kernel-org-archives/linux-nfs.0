Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24913 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403Ab1BYSDt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Feb 2011 13:03:49 -0500
Subject: Re: [PATCH 2/4] SQUASHME: NFSv4.1: DS only check
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <1298542269-2477-2-git-send-email-andros@netapp.com>
Date: Fri, 25 Feb 2011 10:03:16 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <CD11C5E9-EAB1-4E20-B022-5BC6858E7297@netapp.com>
References: <1298542269-2477-1-git-send-email-andros@netapp.com> <1298542269-2477-2-git-send-email-andros@netapp.com>
To: andros@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 24, 2011, at 2:11 AM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> squash into fdd1e4e137c75a69a274acc680706906c72344e1
> NFSv4.1: add MDS mount DS only check
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/client.c    |   10 ++++------
> fs/nfs/nfs4state.c |    2 +-
> 2 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 738f624..6dd50ac 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1400,12 +1400,6 @@ static int nfs4_set_client(struct nfs_server *server,
> 		goto error;
> 	}
> 
> -	/* Cannot mount a DS only server */
> -	if (is_ds_only_client(clp)) {
> -		error = -ENODEV;
> -		goto error;
> -	}
> -
> 	/*
> 	 * Query for the lease time on clientid setup or renewal
> 	 *
> @@ -1500,6 +1494,10 @@ static int nfs4_server_common_setup(struct nfs_server *server,
> 	BUG_ON(!server->nfs_client->rpc_ops);
> 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
> 
> +	/* data servers support only a subset of NFSv4.1 */
> +	if (is_ds_only_client(server->nfs_client))
> +		return -EPROTONOSUPPORT;
> +
> 	fattr = nfs_alloc_fattr();
> 	if (fattr == NULL)
> 		return -ENOMEM;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 6da026a..0021f40 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -153,7 +153,7 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
> 	int status;
> 	struct nfs_fsinfo fsinfo;
> 
> -	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
> +	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state))
> 		nfs4_schedule_state_renewal(clp);
> 		return 0;
> 	}
> -- 

This last bit looks suspicious.  I'll fix it before adding it to my wave4-cthon branch.

Fred

> 1.7.3.1
> 

