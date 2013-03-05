Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756385Ab3CEVUJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 16:20:09 -0500
Date: Tue, 5 Mar 2013 16:20:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH] nfsd: check client tracker initialization result
Message-ID: <20130305212001.GD15816@fieldses.org>
References: <20130228120959.6764.17787.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130228120959.6764.17787.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 03:09:59PM +0300, Stanislav Kinsbursky wrote:
> Function nfsd4_client_tracking_init() can return error.

Before, I think that we the nfsd4_client_* functions just became no-ops
in this case.  With the result that no client records get written, and
so clients are unable to reclaim on the next boot.

Which is annoying, but possibly not as annoying as your server
completely refusing to start.

It's arguably more helpful in the long run to fail immediately when we
recognize reboot recovery isn't going to work.  But in practice this may
mean people that never knew they had a problem suddenly have servers
that don't start at all.

So I'm inclined to be more forgiving and leave this as it is.  But maybe
something like a warning printk would be appropriate.

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/nfs4state.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f194f86..fc4b81b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -69,6 +69,7 @@ static u64 current_sessionid = 1;
>  
>  /* forward declarations */
>  static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
> +void nfs4_state_shutdown_net(struct net *net);
>  
>  /* Locking: */
>  
> @@ -4942,7 +4943,9 @@ nfs4_state_start_net(struct net *net)
>  	ret = nfs4_state_create_net(net);
>  	if (ret)
>  		return ret;
> -	nfsd4_client_tracking_init(net);
> +	ret = nfsd4_client_tracking_init(net);
> +	if (ret)
> +		goto out_tracking;
>  	nn->boot_time = get_seconds();
>  	locks_start_grace(net, &nn->nfsd4_manager);
>  	nn->grace_ended = false;
> @@ -4950,6 +4953,10 @@ nfs4_state_start_net(struct net *net)
>  	       nn->nfsd4_grace, net);
>  	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
>  	return 0;
> +
> +out_tracking:
> +	nfs4_state_destroy_net(net);
> +	return ret;
>  }
>  
>  /* initialization to perform when the nfsd service is started: */
> 
