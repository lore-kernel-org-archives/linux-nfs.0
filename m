Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38573 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306Ab1J1OWT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 10:22:19 -0400
Date: Fri, 28 Oct 2011 10:22:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH v7 3/7] SUNRPC: introduce svc helpers for prepairing
 rpcbind infrastructure
Message-ID: <20111028142215.GB5193@fieldses.org>
References: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
 <20111028105254.24628.49150.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111028105254.24628.49150.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2011 at 02:52:59PM +0300, Stanislav Kinsbursky wrote:
> This helpers will be used only for those services, that will send portmapper
> registration calls.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Acked-by: J. Bruce Fields <bfields@redhat.com>

> 
> ---
>  include/linux/sunrpc/clnt.h |    2 ++
>  net/sunrpc/rpcb_clnt.c      |    2 +-
>  net/sunrpc/svc.c            |   35 +++++++++++++++++++++++++++++++++++
>  3 files changed, 38 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index db7bcaf..1eb437d 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -135,6 +135,8 @@ void		rpc_shutdown_client(struct rpc_clnt *);
>  void		rpc_release_client(struct rpc_clnt *);
>  void		rpc_task_release_client(struct rpc_task *);
>  
> +int		rpcb_create_local(void);
> +void		rpcb_put_local(void);
>  int		rpcb_register(u32, u32, int, unsigned short);
>  int		rpcb_v4_register(const u32 program, const u32 version,
>  				 const struct sockaddr *address,
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 115df11..c144b95 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -320,7 +320,7 @@ out:
>   * Returns zero on success, otherwise a negative errno value
>   * is returned.
>   */
> -static int rpcb_create_local(void)
> +int rpcb_create_local(void)
>  {
>  	static DEFINE_MUTEX(rpcb_create_local_mutex);
>  	int result = 0;
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 6a69a11..d2d61bf 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -354,6 +354,41 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
>  	return &serv->sv_pools[pidx % serv->sv_nrpools];
>  }
>  
> +static int svc_rpcb_setup(struct svc_serv *serv)
> +{
> +	int err;
> +
> +	err = rpcb_create_local();
> +	if (err)
> +		return err;
> +
> +	/* Remove any stale portmap registrations */
> +	svc_unregister(serv);
> +	return 0;
> +}
> +
> +static void svc_rpcb_cleanup(struct svc_serv *serv)
> +{
> +	svc_unregister(serv);
> +	rpcb_put_local();
> +}
> +
> +static int svc_uses_rpcbind(struct svc_serv *serv)
> +{
> +	struct svc_program	*progp;
> +	unsigned int		i;
> +
> +	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
> +		for (i = 0; i < progp->pg_nvers; i++) {
> +			if (progp->pg_vers[i] == NULL)
> +				continue;
> +			if (progp->pg_vers[i]->vs_hidden == 0)
> +				return 1;
> +		}
> +	}
> +
> +	return 0;
> +}
>  
>  /*
>   * Create an RPC service
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
