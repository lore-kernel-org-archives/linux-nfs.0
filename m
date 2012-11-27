Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935Ab2K0RBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 12:01:43 -0500
Date: Tue, 27 Nov 2012 12:01:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        bjschuma@netapp.com
Subject: Re: [PATCH] nfsd: prevent NULL ptr derefs on fault injection
Message-ID: <20121127170136.GE27142@fieldses.org>
References: <1354033871-25815-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354033871-25815-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 11:31:11AM -0500, Sasha Levin wrote:
> A recent patch series has moved hashtable initialization to when the net
> struct is initialized.
> 
> When injecting faults, we tried accessing the hashtables even if the struct
> wasn't really initialized (nfsd wasn't in use) - this caused a NULL ptr
> deref.

Thanks, adding Bryan to cc.--b.

> 
> A simple test would be:
> 
> 	echo 1 > /sys/kernel/debug/nfsd/forget_locks
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  fs/nfsd/netns.h     | 3 +++
>  fs/nfsd/nfs4state.c | 9 +++++++++
>  2 files changed, 12 insertions(+)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 227b93e..c5806a57 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -83,5 +83,8 @@ struct nfsd_net {
>  	struct delayed_work laundromat_work;
>  };
>  
> +/* Simple check to find out if a given net was properly initialized */
> +#define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
> +
>  extern int nfsd_net_id;
>  #endif /* __NFSD_NETNS_H__ */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e75872f..0e7428c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4598,6 +4598,9 @@ void nfsd_forget_clients(u64 num)
>  	int count = 0;
>  	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
>  
> +	if (!nfsd_netns_ready(nn))
> +		return;
> +
>  	nfs4_lock_state();
>  	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
>  		expire_client(clp);
> @@ -4643,6 +4646,9 @@ void nfsd_forget_locks(u64 num)
>  	int count;
>  	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
>  
> +	if (!nfsd_netns_ready(nn))
> +		return;
> +
>  	nfs4_lock_state();
>  	count = nfsd_release_n_owners(num, false, release_lockowner_sop, nn);
>  	nfs4_unlock_state();
> @@ -4655,6 +4661,9 @@ void nfsd_forget_openowners(u64 num)
>  	int count;
>  	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
>  
> +	if (!nfsd_netns_ready(nn))
> +		return;
> +
>  	nfs4_lock_state();
>  	count = nfsd_release_n_owners(num, true, release_openowner_sop, nn);
>  	nfs4_unlock_state();
> -- 
> 1.8.0
> 
