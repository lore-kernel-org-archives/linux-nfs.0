Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:35083 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab1DEDqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 23:46:44 -0400
Date: Mon, 4 Apr 2011 22:46:41 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in
 auth_unix cache.
Message-ID: <20110405034641.GC6764@hallyn.com>
References: <4D9431B3.2070305@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D9431B3.2070305@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Quoting Rob Landley (rlandley@parallels.com):
> From: Rob Landley <rlandley@parallels.com>
> 
> The auth_unix cache needs to check network namespace when comparing
> addresses. Add field to struct ip_map and extra argument to
> __ip_map_lookup() so it has the information to do so, and add test.
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>
> ---
> 
>  net/sunrpc/svcauth_unix.c |   21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 30916b0..63a2fa7 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -14,6 +14,7 @@
>  #include <net/sock.h>
>  #include <net/ipv6.h>
>  #include <linux/kernel.h>
> +#include <linux/user_namespace.h>
>  #define RPCDBG_FACILITY	RPCDBG_AUTH
>  
>  #include <linux/sunrpc/clnt.h>
> @@ -94,6 +95,7 @@ struct ip_map {
>  	struct cache_head	h;
>  	char			m_class[8]; /* e.g. "nfsd" */
>  	struct in6_addr		m_addr;
> +	struct net		*m_net;
>  	struct unix_domain	*m_client;
>  #ifdef CONFIG_NFSD_DEPRECATED
>  	int			m_add_change;
> @@ -134,6 +136,7 @@ static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
>  	struct ip_map *orig = container_of(corig, struct ip_map, h);
>  	struct ip_map *new = container_of(cnew, struct ip_map, h);
>  	return strcmp(orig->m_class, new->m_class) == 0 &&
> +	       net_eq(orig->m_net, new->m_net) &&
>  	       ipv6_addr_equal(&orig->m_addr, &new->m_addr);
>  }
>  static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
> @@ -142,6 +145,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
>  	struct ip_map *item = container_of(citem, struct ip_map, h);
>  
>  	strcpy(new->m_class, item->m_class);
> +	new->m_net = item->m_net;

Does this need to take a reference?  Or is there no way for an
entry to outlive its netns?  It sort of looks like
svcauth_unix_info_release will ensure that doesn't happen, but
I'm not convinced because other parts of the kernel can get
to ip_map_init through the struct cache_detail.

>  	ipv6_addr_copy(&new->m_addr, &item->m_addr);
>  }
>  static void update(struct cache_head *cnew, struct cache_head *citem)
> @@ -186,7 +190,7 @@ static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
>  	return sunrpc_cache_pipe_upcall(cd, h, ip_map_request);
>  }
>  
> -static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
> +static struct ip_map *__ip_map_lookup(struct cache_detail *cd, struct net *net, char *class, struct in6_addr *addr);
>  static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
>  
>  static int ip_map_parse(struct cache_detail *cd,
> @@ -256,7 +260,8 @@ static int ip_map_parse(struct cache_detail *cd,
>  		dom = NULL;
>  
>  	/* IPv6 scope IDs are ignored for now */
> -	ipmp = __ip_map_lookup(cd, class, &sin6.sin6_addr);
> +	ipmp = __ip_map_lookup(cd, current->nsproxy->net_ns, class,
> +			       &sin6.sin6_addr);
>  	if (ipmp) {
>  		err = __ip_map_update(cd, ipmp,
>  			     container_of(dom, struct unix_domain, h),
> @@ -301,13 +306,14 @@ static int ip_map_show(struct seq_file *m,
>  }
>  
>  
> -static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
> -		struct in6_addr *addr)
> +static struct ip_map *__ip_map_lookup(struct cache_detail *cd, struct net *net,
> +		char *class, struct in6_addr *addr)
>  {
>  	struct ip_map ip;
>  	struct cache_head *ch;
>  
>  	strcpy(ip.m_class, class);
> +	ip.m_net = net;
>  	ipv6_addr_copy(&ip.m_addr, addr);
>  	ch = sunrpc_cache_lookup(cd, &ip.h,
>  				 hash_str(class, IP_HASHBITS) ^
> @@ -325,7 +331,7 @@ static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
>  	struct sunrpc_net *sn;
>  
>  	sn = net_generic(net, sunrpc_net_id);
> -	return __ip_map_lookup(sn->ip_map_cache, class, addr);
> +	return __ip_map_lookup(sn->ip_map_cache, net, class, addr);
>  }
>  
>  static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
> @@ -748,8 +754,9 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
>  
>  	ipm = ip_map_cached_get(xprt);
>  	if (ipm == NULL)
> -		ipm = __ip_map_lookup(sn->ip_map_cache, rqstp->rq_server->sv_program->pg_class,
> -				    &sin6->sin6_addr);
> +		ipm = __ip_map_lookup(sn->ip_map_cache, net,
> +				      rqstp->rq_server->sv_program->pg_class,
> +				      &sin6->sin6_addr);
>  
>  	if (ipm == NULL)
>  		return SVC_DENIED;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
