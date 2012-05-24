Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:50175 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2EXEgj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2012 00:36:39 -0400
Message-ID: <4FBDBAD4.7040500@parallels.com>
Date: Thu, 24 May 2012 08:36:36 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Add memory barriers to the nfs_client->cl_cons_state
 initialisation
References: <1337794363-11905-1-git-send-email-Trond.Myklebust@netapp.com> <1337794363-11905-2-git-send-email-Trond.Myklebust@netapp.com> <1337794363-11905-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337794363-11905-3-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

23.05.2012 21:32, Trond Myklebust написал:
> Ensure that a process that uses the nfs_client->cl_cons_state test
> for whether the initialisation process is finished does not read
> stale data.
>
> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> ---
>   fs/nfs/client.c |    5 +++++
>   fs/nfs/idmap.c  |    1 +
>   2 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index e6070ea..4be85f9 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -456,6 +456,8 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
>   	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
>   		return false;
>
> +	smp_rmb();
> +
>   	/* Match the version and minorversion */
>   	if (clp->rpc_ops->version != 4 ||
>   	    clp->cl_minorversion != minorversion)
> @@ -587,6 +589,8 @@ found_client:
>   		return ERR_PTR(error);
>   	}
>
> +	smp_rmb();
> +
>   	BUG_ON(clp->cl_cons_state != NFS_CS_READY);
>
>   	dprintk("-->  nfs_get_client() = %p [share]\n", clp);
> @@ -598,6 +602,7 @@ found_client:
>    */
>   void nfs_mark_client_ready(struct nfs_client *clp, int state)
>   {
> +	smp_wmb();

BTW, why barrier is before assignment?

>   	clp->cl_cons_state = state;
>   	wake_up_all(&nfs_client_active_wq);
>   }
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 6ca949b..7d4e8dd 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -548,6 +548,7 @@ restart:
>   		/* Skip nfs_clients that failed to initialise */
>   		if (clp->cl_cons_state<  0)
>   			continue;
> +		smp_rmb();
>   		if (clp->rpc_ops !=&nfs_v4_clientops)
>   			continue;
>   		cl_dentry = clp->cl_idmap->idmap_pipe->dentry;

