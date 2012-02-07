Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62549 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab2BGPnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 10:43:20 -0500
Message-ID: <4F314688.5050406@netapp.com>
Date: Tue, 07 Feb 2012 10:43:04 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Subject: Re: [PATCH 3/5] NFS: search for client session id in proper network
 namespace
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6> <20120126111149.8386.51043.stgit@localhost6.localdomain6>
In-Reply-To: <20120126111149.8386.51043.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/26/12 06:11, Stanislav Kinsbursky wrote:

> Network namespace is taken from request transport and passed as a part of
> cb_process_state structure.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  fs/nfs/callback.h      |    1 +
>  fs/nfs/callback_proc.c |    2 +-
>  fs/nfs/callback_xdr.c  |    1 +
>  fs/nfs/client.c        |    4 ++--
>  fs/nfs/internal.h      |    3 ++-
>  5 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index c89d3b9..197e0d3 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -39,6 +39,7 @@ struct cb_process_state {
>  	__be32			drc_status;
>  	struct nfs_client	*clp;
>  	int			slotid;
> +	struct net		*net;
>  };
>  
>  struct cb_compound_hdr_arg {
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 0e6e63f..f71978d 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -461,7 +461,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	int i;
>  	__be32 status = htonl(NFS4ERR_BADSESSION);
>  
> -	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
> +	clp = nfs4_find_client_sessionid(cps->net, args->csa_addr, &args->csa_sessionid);
>  	if (clp == NULL)
>  		goto out;
>  
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index f2be3e1e..8c2a969 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -861,6 +861,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  		.drc_status = 0,
>  		.clp = NULL,
>  		.slotid = -1,
> +		.net = rqstp->rq_xprt->xpt_net,
>  	};
>  	unsigned int nops = 0;
>  
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9e11d29..2328dcb 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1232,11 +1232,11 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
>   * Returns NULL if no such client
>   */
>  struct nfs_client *
> -nfs4_find_client_sessionid(const struct sockaddr *addr,
> +nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
>  			   struct nfs4_sessionid *sid)
>  {
>  	struct nfs_client *clp;
> -	struct nfs_net *nn = net_generic(&init_net, nfs_net_id);
> +	struct nfs_net *nn = net_generic(net, nfs_net_id);


Hi,

You changed this function for the v4.1 case, but not for v4.0 (this is what I was trying to bisect earlier).  Without CONFIG_NFS_V4_1 set, I get this:

 make[1]: Nothing to be done for `all'.
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/generated/compile.h
  CHK     kernel/config_data.h
  CC [M]  fs/nfs/client.o
fs/nfs/client.c:1265:1: error: conflicting types for 'nfs4_find_client_sessionid'
fs/nfs/internal.h:155:1: note: previous declaration of 'nfs4_find_client_sessionid' was here
make[2]: *** [fs/nfs/client.o] Error 1
make[1]: *** [fs/nfs] Error 2
make: *** [fs] Error 2

- Bryan

>  
>  	spin_lock(&nn->nfs_client_lock);
>  	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index b38b733..0c3648a 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -152,7 +152,8 @@ extern void nfs_cleanup_cb_ident_idr(struct net *);
>  extern void nfs_put_client(struct nfs_client *);
>  extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
>  extern struct nfs_client *
> -nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *);
> +nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
> +				struct nfs4_sessionid *);
>  extern struct nfs_server *nfs_create_server(
>  					const struct nfs_parsed_mount_data *,
>  					struct nfs_fh *);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


