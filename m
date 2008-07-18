From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/8] SUNRPC: Clean up svc_register
Date: Fri, 18 Jul 2008 19:29:31 -0400
Message-ID: <20080718232931.GB15850@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net> <20080630224553.24887.73617.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44171 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbYGRX3m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2008 19:29:42 -0400
In-Reply-To: <20080630224553.24887.73617.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:45:53PM -0400, Chuck Lever wrote:
> In preparation for adding rpcbind version 4 support to svc_register, clean
> it up.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/svc.h |    4 ++-
>  net/sunrpc/svc.c           |   61 +++++++++++++++++++++++++++-----------------
>  2 files changed, 41 insertions(+), 24 deletions(-)
> 
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index a27178b..05312e7 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -394,7 +394,9 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>  int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
>  void		   svc_destroy(struct svc_serv *);
>  int		   svc_process(struct svc_rqst *);
> -int		   svc_register(struct svc_serv *, int, unsigned short);
> +int		   svc_register(const struct svc_serv *, const unsigned short,
> +				const unsigned short);
> +
>  void		   svc_wake_up(struct svc_serv *);
>  void		   svc_reserve(struct svc_rqst *rqstp, int space);
>  struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index a41b163..c31a1e4 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -749,43 +749,58 @@ svc_exit_thread(struct svc_rqst *rqstp)
>  }
>  EXPORT_SYMBOL(svc_exit_thread);
>  
> -/*
> - * Register an RPC service with the local portmapper.
> - * To unregister a service, call this routine with
> - * proto and port == 0.
> +static int __svc_register(const u32 program, const u32 version,
> +			  sa_family_t family,
> +			  const unsigned short protocol,
> +			  const unsigned short port)
> +{
> +	int error, result;
> +
> +	error = rpcb_register(program, version, protocol, port, &result);
> +	if (!result)
> +		error = -EACCES;
> +	return error;
> +}
> +
> +/**
> + * svc_register - register an RPC service with the local portmapper
> + * @serv: svc_serv struct for the service to register
> + * @protocol: transport protocol number to advertise
> + * @port: port to advertise
> + *
>   */
> -int
> -svc_register(struct svc_serv *serv, int proto, unsigned short port)
> +int svc_register(const struct svc_serv *serv, const unsigned short protocol,
> +		 const unsigned short port)
>  {
> -	struct svc_program	*progp;
> -	unsigned int		i;
> -	int			error = 0, dummy;
> +	struct svc_program *progp;
> +	u32 version;

Same style nit (i/version) as before.  (Also: u32?  If we ever have to
care how big the array index is here, we've got bigger problems....)

I don't really see "protocol" as much clearer than "proto" either, but
OK.

Seems good otherwise.

--b.

> +	int error = 0;
>  
> -	BUG_ON(proto == 0 && port == 0);
> +	BUG_ON(protocol == 0 && port == 0);
>  
>  	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
> -		for (i = 0; i < progp->pg_nvers; i++) {
> -			if (progp->pg_vers[i] == NULL)
> +		for (version = 0; version < progp->pg_nvers; version++) {
> +			if (progp->pg_vers[version] == NULL)
>  				continue;
>  
> -			dprintk("svc: svc_register(%s, %s, %d, %d)%s\n",
> +			dprintk("svc: svc_register(%s, %u, %u, %s, %u)%s\n",
>  					progp->pg_name,
> -					proto == IPPROTO_UDP?  "udp" : "tcp",
> +					version,
> +					serv->sv_family,
> +					protocol == IPPROTO_UDP ?
> +							"udp" : "tcp",
>  					port,
> -					i,
> -					progp->pg_vers[i]->vs_hidden?
> -						" (but not telling portmap)" : "");
> +					progp->pg_vers[version]->vs_hidden ?
> +					  " (but not telling portmap)" : "");
>  
> -			if (progp->pg_vers[i]->vs_hidden)
> +			if (progp->pg_vers[version]->vs_hidden)
>  				continue;
>  
> -			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
> +			error = __svc_register(progp->pg_prog, version,
> +						serv->sv_family, protocol,
> +						port);
>  			if (error < 0)
>  				break;
> -			if (port && !dummy) {
> -				error = -EACCES;
> -				break;
> -			}
>  		}
>  	}
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
