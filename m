From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/7] lockd: Use sockaddr_storage + length for h_addr
	field
Date: Thu, 4 Sep 2008 13:46:33 -0400
Message-ID: <20080904174633.GL4536@fieldses.org>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net> <20080903183539.16867.8416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36969 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755148AbYIDRqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 13:46:34 -0400
In-Reply-To: <20080903183539.16867.8416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 03, 2008 at 02:35:39PM -0400, Chuck Lever wrote:
> To store larger addresses in the nlm_host structure, make h_addr a
> sockaddr_storage, and add an address length field.

Erps, I just noticed that mail to bfields@citi.umich.edu started getting
shunted off into a mailbox I don't check starting a week or two ago.  If
anyone sent me private mail to that address and hasn't gotten a
response, you might want to resend....  Anyway, thanks, I'll try to look
at this soon.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/clntlock.c         |    2 +-
>  fs/lockd/host.c             |   11 ++++++-----
>  include/linux/lockd/lockd.h |   16 +++++++++++++++-
>  3 files changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> index 0b45fd3..0df5587 100644
> --- a/fs/lockd/clntlock.c
> +++ b/fs/lockd/clntlock.c
> @@ -166,7 +166,7 @@ __be32 nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *lock
>  		 */
>  		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
>  			continue;
> -		if (!nlm_cmp_addr(&block->b_host->h_addr, addr))
> +		if (!nlm_cmp_addr(nlm_addr_in(block->b_host), addr))
>  			continue;
>  		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
>  			continue;
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 008e402..8c7022e 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -116,7 +116,7 @@ static struct nlm_host *nlm_lookup_host(int server,
>  	 */
>  	chain = &nlm_hosts[hash];
>  	hlist_for_each_entry(host, pos, chain, h_hash) {
> -		if (!nlm_cmp_addr(&host->h_addr, sin))
> +		if (!nlm_cmp_addr(nlm_addr_in(host), sin))
>  			continue;
>  
>  		/* See if we have an NSM handle for this client */
> @@ -165,8 +165,9 @@ static struct nlm_host *nlm_lookup_host(int server,
>  		goto out;
>  	}
>  	host->h_name	   = nsm->sm_name;
> -	host->h_addr       = *sin;
> -	nlm_clear_port((struct sockaddr *)&host->h_addr);
> +	memcpy(nlm_addr(host), sin, sizeof(*sin));
> +	host->h_addrlen = sizeof(*sin);
> +	nlm_clear_port(nlm_addr(host));
>  	host->h_saddr	   = *ssin;
>  	host->h_version    = version;
>  	host->h_proto      = proto;
> @@ -291,8 +292,8 @@ nlm_bind_host(struct nlm_host *host)
>  		};
>  		struct rpc_create_args args = {
>  			.protocol	= host->h_proto,
> -			.address	= (struct sockaddr *)&host->h_addr,
> -			.addrsize	= sizeof(host->h_addr),
> +			.address	= nlm_addr(host),
> +			.addrsize	= host->h_addrlen,
>  			.saddress	= (struct sockaddr *)&host->h_saddr,
>  			.timeout	= &timeparms,
>  			.servername	= host->h_name,
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 0691efb..41d7a8e 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -38,7 +38,8 @@
>   */
>  struct nlm_host {
>  	struct hlist_node	h_hash;		/* doubly linked list */
> -	struct sockaddr_in	h_addr;		/* peer address */
> +	struct sockaddr_storage	h_addr;		/* peer address */
> +	size_t			h_addrlen;
>  	struct sockaddr_in	h_saddr;	/* our address (optional) */
>  	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
>  	char *			h_name;		/* remote hostname */
> @@ -77,6 +78,19 @@ struct nsm_handle {
>  };
>  
>  /*
> + * Rigorous type checking on sockaddr type conversions
> + */
> +static inline struct sockaddr_in *nlm_addr_in(const struct nlm_host *host)
> +{
> +	return (struct sockaddr_in *)&host->h_addr;
> +}
> +
> +static inline struct sockaddr *nlm_addr(const struct nlm_host *host)
> +{
> +	return (struct sockaddr *)&host->h_addr;
> +}
> +
> +/*
>   * Map an fl_owner_t into a unique 32-bit "pid"
>   */
>  struct nlm_lockowner {
> 
