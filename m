From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Date: Mon, 22 Aug 2011 15:23:48 -0400
Message-ID: <20110822192348.GA16261@fieldses.org>
References: <4E4F8B5D.6060404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>, jlayton@redhat.com
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60625 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752878Ab1HVTXu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 15:23:50 -0400
In-Reply-To: <4E4F8B5D.6060404@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
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
> This patch adds scope id to svc_addr_u for IPv6 address, and copy scope from
> xprt->xpt_local to rqstp->rq_daddr for use.
> 
> With this patch, lockd can callback to client success.

I guess this makes sense to me, but someone who understands IPv6 better
should comment... Chuck?  Jeff?

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/lockd/host.c            |    3 ++-
>  fs/nfsd/nfs4state.c        |    7 ++++++-
>  include/linux/sunrpc/svc.h |   12 ++++++++++--
>  net/sunrpc/svc_xprt.c      |    5 ++++-
>  net/sunrpc/svcsock.c       |    4 ++--
>  5 files changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index b7c99bf..1fff87a 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -346,7 +346,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
>  		src_sap = (struct sockaddr *)&sin;
>  		break;
>  	case AF_INET6:
> -		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6);
> +		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6.sin6_addr);
> +		sin6.sin6_scope_id = rqstp->rq_daddr.addr6.sin6_scope_id;
>  		src_sap = (struct sockaddr *)&sin6;
>  		break;
>  	default:
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3787ec1..1169411 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1182,7 +1182,7 @@ static void rpc_svcaddr2sockaddr(struct sockaddr *sa, unsigned short family, uni
>  		return;
>  	case AF_INET6:
>  		((struct sockaddr_in6 *)sa)->sin6_family = AF_INET6;
> -		((struct sockaddr_in6 *)sa)->sin6_addr = svcaddr->addr6;
> +		((struct sockaddr_in6 *)sa)->sin6_addr = svcaddr->addr6.sin6_addr;
>  		return;
>  	}
>  }
> @@ -1219,6 +1219,11 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
>  	conn->cb_prog = se->se_callback_prog;
>  	conn->cb_ident = se->se_callback_ident;
>  	rpc_svcaddr2sockaddr((struct sockaddr *)&conn->cb_saddr, expected_family, &rqstp->rq_daddr);
> +
> +	if (conn->cb_saddr.ss_family == AF_INET6)
> +		((struct sockaddr_in6 *)&conn->cb_saddr)->sin6_scope_id = 
> +			rqstp->rq_daddr.addr6.sin6_scope_id;
> +
>  	return;
>  out_err:
>  	conn->cb_addr.ss_family = AF_UNSPEC;
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 223588a..cd611b5 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -212,9 +212,17 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
>  	iov->iov_len += sizeof(__be32);
>  }
>  
> +/* 
> + * Add scope id for LINKLOCAL address
> + */
> +struct in6_addr_scopeid{
> +	struct in6_addr	sin6_addr;
> +	__u32		sin6_scope_id;
> +};
> +
>  union svc_addr_u {
> -    struct in_addr	addr;
> -    struct in6_addr	addr6;
> +	struct in_addr		addr;
> +	struct in6_addr_scopeid	addr6;
>  };
>  
>  /*
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index bd31208..8aada49 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -269,7 +269,10 @@ void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
>  		break;
>  	case AF_INET6:
> -		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
> +		rqstp->rq_daddr.addr6.sin6_addr = 
> +				((struct sockaddr_in6 *)sin)->sin6_addr;
> +		rqstp->rq_daddr.addr6.sin6_scope_id =
> +				 ((struct sockaddr_in6 *)sin)->sin6_scope_id;
>  		break;
>  	}
>  }
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 767d494..beb2575 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -155,7 +155,7 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>  			cmh->cmsg_type = IPV6_PKTINFO;
>  			pki->ipi6_ifindex = 0;
>  			ipv6_addr_copy(&pki->ipi6_addr,
> -					&rqstp->rq_daddr.addr6);
> +					&rqstp->rq_daddr.addr6.sin6_addr);
>  			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
>  		}
>  		break;
> @@ -513,7 +513,7 @@ static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
>  	struct in6_pktinfo *pki = CMSG_DATA(cmh);
>  	if (cmh->cmsg_type != IPV6_PKTINFO)
>  		return 0;
> -	ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
> +	ipv6_addr_copy(&rqstp->rq_daddr.addr6.sin6_addr, &pki->ipi6_addr);
>  	return 1;
>  }
>  
> -- 
> 1.7.6
> 
> 
> 
