From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Date: Thu, 25 Aug 2011 05:58:56 -0400
Message-ID: <20110825055856.73372a4a@tlielax.poochiereds.net>
References: <4E4F8B5D.6060404@cn.fujitsu.com>
	<20110822192620.GB16261@fieldses.org>
	<3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com>
	<20110822194459.GC16261@fieldses.org>
	<4E5492FD.8040903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab1HYKAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Aug 2011 06:00:14 -0400
In-Reply-To: <4E5492FD.8040903@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 24 Aug 2011 13:58:21 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> 
> J. Bruce Fields:
> > On Mon, Aug 22, 2011 at 03:32:13PM -0400, Chuck Lever wrote:
> >> On Aug 22, 2011, at 3:26 PM, J. Bruce Fields wrote:
> >>
> >>> On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
> >>>> +/* 
> >>>> + * Add scope id for LINKLOCAL address
> >>>> + */
> >>>> +struct in6_addr_scopeid{
> >>>> +	struct in6_addr	sin6_addr;
> >>>> +	__u32		sin6_scope_id;
> >>>> +};
> >>>> +
> >>>> union svc_addr_u {
> >>>> -    struct in_addr	addr;
> >>>> -    struct in6_addr	addr6;
> >>>> +	struct in_addr		addr;
> >>>> +	struct in6_addr_scopeid	addr6;
> >>> By the way, is there any reason why nfsd really needs its own address
> >>> structure?  Shouldn't we use sockaddr_storage or something?  I feel like
> >>> we've got a little too much one-off address handling in nfsd.
> >> That would be my only complaint about the patch.
> >>
> >> I think we chose a smaller struct here to save space, and we could do that because we didn't need a port number or scope ID.  If a scope ID is indeed required, then we should consider something larger like a struct sockaddr_storage, IMO.
> > 
> > If we care about the size of struct svc_rqst: rq_vec and rq_pages fields
> > are 4k and 2k, respectively, and the rest is lost in the noise.
> > 
> > Mi Jinlong, would you have the time to try this?
> > 
> > 	- Replace svc_addr_u by sockaddr_storage
> > 	- See of that allows us to delete some lines of code in nfsd by
> > 	  using standard helper functions instead of copying things by
> > 	  hand.
> > 
> > You'd do that in one patch, then apply your scope-id fix on top of it as
> > a second patch.
> 
>   After replace svc_addr_u by sockaddr_storage, the scope-id fix isn't needed.
> 
> thanks,
> Mi Jinlong 
> 
> From 86bb57f2d7c29124ae73bd121bb6b97a72fe6f4d Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Mon, 24 Aug 2011 13:22:39 +0800
> Subject: [PATCH] SUNRPC: Replace svc_addr_u by sockaddr_storage
> 
> For IPv6 local address, lockd can not callback to client for 
> missing scope id when binding address at inet6_bind:
> 
>  324       if (addr_type & IPV6_ADDR_LINKLOCAL) {
>  325               if (addr_len >= sizeof(struct sockaddr_in6) &&
>  326                   addr->sin6_scope_id) {
>  327                       /* Override any existing binding, if another one
>  328                        * is supplied by user.
>  329                        */
>  330                       sk->sk_bound_dev_if = addr->sin6_scope_id;
>  331               }
>  332 
>  333               /* Binding to link-local address requires an interface */
>  334               if (!sk->sk_bound_dev_if) {
>  335                       err = -EINVAL;
>  336                       goto out_unlock;
>  337               }
> 
> Replacing svc_addr_u by sockaddr_storage, let rqstp->rq_daddr contains more info
> besides address.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/lockd/host.c            |   14 ++------------
>  fs/nfsd/nfs4state.c        |   16 +---------------
>  include/linux/sunrpc/svc.h |   30 +++++++++++++++++++++---------
>  net/sunrpc/svc_xprt.c      |   13 ++-----------
>  net/sunrpc/svcsock.c       |    9 +++++----
>  5 files changed, 31 insertions(+), 51 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index b7c99bf..b23db05 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -316,14 +316,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
>  	struct hlist_node *pos;
>  	struct nlm_host	*host = NULL;
>  	struct nsm_handle *nsm = NULL;
> -	struct sockaddr_in sin = {
> -		.sin_family	= AF_INET,
> -	};
> -	struct sockaddr_in6 sin6 = {
> -		.sin6_family	= AF_INET6,
> -	};
>  	struct sockaddr *src_sap;
> -	size_t src_len = rqstp->rq_addrlen;
> +	size_t src_len = rqstp->rq_daddrlen;
>  	struct nlm_lookup_host_info ni = {
>  		.server		= 1,
>  		.sap		= svc_addr(rqstp),
> @@ -342,12 +336,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
>  
>  	switch (ni.sap->sa_family) {
>  	case AF_INET:
> -		sin.sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
> -		src_sap = (struct sockaddr *)&sin;
> -		break;
>  	case AF_INET6:
> -		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6);
> -		src_sap = (struct sockaddr *)&sin6;
> +		src_sap = svc_daddr(rqstp);
>  		break;
>  	default:
>  		dprintk("lockd: %s failed; unrecognized address family\n",
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3787ec1..07a18a5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1173,20 +1173,6 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
>  	return NULL;
>  }
>  
> -static void rpc_svcaddr2sockaddr(struct sockaddr *sa, unsigned short family, union svc_addr_u *svcaddr)
> -{
> -	switch (family) {
> -	case AF_INET:
> -		((struct sockaddr_in *)sa)->sin_family = AF_INET;
> -		((struct sockaddr_in *)sa)->sin_addr = svcaddr->addr;
> -		return;
> -	case AF_INET6:
> -		((struct sockaddr_in6 *)sa)->sin6_family = AF_INET6;
> -		((struct sockaddr_in6 *)sa)->sin6_addr = svcaddr->addr6;
> -		return;
> -	}
> -}
> -
>  static void
>  gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_rqst *rqstp)
>  {
> @@ -1218,7 +1204,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
>  
>  	conn->cb_prog = se->se_callback_prog;
>  	conn->cb_ident = se->se_callback_ident;
> -	rpc_svcaddr2sockaddr((struct sockaddr *)&conn->cb_saddr, expected_family, &rqstp->rq_daddr);
> +	memcpy(&conn->cb_saddr, &rqstp->rq_daddr, rqstp->rq_daddrlen);
>  	return;
>  out_err:
>  	conn->cb_addr.ss_family = AF_UNSPEC;
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 223588a..3bc0dc9 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -212,11 +212,6 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
>  	iov->iov_len += sizeof(__be32);
>  }
>  
> -union svc_addr_u {
> -    struct in_addr	addr;
> -    struct in6_addr	addr6;
> -};
> -
>  /*
>   * The context of a single thread, including the request currently being
>   * processed.
> @@ -225,8 +220,12 @@ struct svc_rqst {
>  	struct list_head	rq_list;	/* idle list */
>  	struct list_head	rq_all;		/* all threads list */
>  	struct svc_xprt *	rq_xprt;	/* transport ptr */
> +
>  	struct sockaddr_storage	rq_addr;	/* peer address */
>  	size_t			rq_addrlen;
> +	struct sockaddr_storage	rq_daddr;	/* dest addr of request
> +						 *  - reply from here */
> +	size_t			rq_daddrlen;
>  
>  	struct svc_serv *	rq_server;	/* RPC service definition */
>  	struct svc_pool *	rq_pool;	/* thread pool */
> @@ -255,9 +254,6 @@ struct svc_rqst {
>  	unsigned short
>  				rq_secure  : 1;	/* secure port */
>  
> -	union svc_addr_u	rq_daddr;	/* dest addr of request
> -						 *  - reply from here */
> -
>  	void *			rq_argp;	/* decoded arguments */
>  	void *			rq_resp;	/* xdr'd results */
>  	void *			rq_auth_data;	/* flavor-specific data */
> @@ -300,6 +296,21 @@ static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
>  	return (struct sockaddr *) &rqst->rq_addr;
>  }
>  
> +static inline struct sockaddr_in *svc_daddr_in(const struct svc_rqst *rqst)
> +{
> +	return (struct sockaddr_in *) &rqst->rq_daddr;
> +}
> +
> +static inline struct sockaddr_in6 *svc_daddr_in6(const struct svc_rqst *rqst)
> +{
> +	return (struct sockaddr_in6 *) &rqst->rq_daddr;
> +}
> +
> +static inline struct sockaddr *svc_daddr(const struct svc_rqst *rqst)
> +{
> +	return (struct sockaddr *) &rqst->rq_daddr;
> +}
> +
>  /*
>   * Check buffer bounds after decoding arguments
>   */
> @@ -340,7 +351,8 @@ struct svc_deferred_req {
>  	struct svc_xprt		*xprt;
>  	struct sockaddr_storage	addr;	/* where reply must go */
>  	size_t			addrlen;
> -	union svc_addr_u	daddr;	/* where reply must come from */
> +	struct sockaddr_storage	daddr;	/* where reply must come from */
> +	size_t			daddrlen;
>  	struct cache_deferred_req handle;
>  	size_t			xprt_hlen;
>  	int			argslen;
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index bd31208..d86bb67 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -254,8 +254,6 @@ EXPORT_SYMBOL_GPL(svc_create_xprt);
>   */
>  void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  {
> -	struct sockaddr *sin;
> -
>  	memcpy(&rqstp->rq_addr, &xprt->xpt_remote, xprt->xpt_remotelen);
>  	rqstp->rq_addrlen = xprt->xpt_remotelen;
>  
> @@ -263,15 +261,8 @@ void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  	 * Destination address in request is needed for binding the
>  	 * source address in RPC replies/callbacks later.
>  	 */
> -	sin = (struct sockaddr *)&xprt->xpt_local;
> -	switch (sin->sa_family) {
> -	case AF_INET:
> -		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
> -		break;
> -	case AF_INET6:
> -		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
> -		break;
> -	}
> +	memcpy(&rqstp->rq_daddr, &xprt->xpt_local, xprt->xpt_locallen);
> +	rqstp->rq_daddrlen = xprt->xpt_locallen;
>  }
>  EXPORT_SYMBOL_GPL(svc_xprt_copy_addrs);
>  
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 767d494..b9f4ad4 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -143,7 +143,8 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>  			cmh->cmsg_level = SOL_IP;
>  			cmh->cmsg_type = IP_PKTINFO;
>  			pki->ipi_ifindex = 0;
> -			pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
> +			pki->ipi_spec_dst.s_addr =
> +				 svc_daddr_in(rqstp)->sin_addr.s_addr;
>  			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
>  		}
>  		break;
> @@ -155,7 +156,7 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>  			cmh->cmsg_type = IPV6_PKTINFO;
>  			pki->ipi6_ifindex = 0;
>  			ipv6_addr_copy(&pki->ipi6_addr,
> -					&rqstp->rq_daddr.addr6);
> +					&svc_daddr_in6(rqstp)->sin6_addr);
>  			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
>  		}
>  		break;
> @@ -500,7 +501,7 @@ static int svc_udp_get_dest_address4(struct svc_rqst *rqstp,
>  	struct in_pktinfo *pki = CMSG_DATA(cmh);
>  	if (cmh->cmsg_type != IP_PKTINFO)
>  		return 0;
> -	rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
> +	svc_daddr_in(rqstp)->sin_addr.s_addr = pki->ipi_spec_dst.s_addr;
>  	return 1;
>  }
>  
> @@ -513,7 +514,7 @@ static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
>  	struct in6_pktinfo *pki = CMSG_DATA(cmh);
>  	if (cmh->cmsg_type != IPV6_PKTINFO)
>  		return 0;
> -	ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
> +	ipv6_addr_copy(&svc_daddr_in6(rqstp)->sin6_addr, &pki->ipi6_addr);
>  	return 1;
>  }
>  

Looks good to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
