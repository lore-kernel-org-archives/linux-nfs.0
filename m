Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:19763 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab1H0WEh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Aug 2011 18:04:37 -0400
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110826224351.GB18699@fieldses.org>
Date: Sat, 27 Aug 2011 18:03:42 -0400
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <EAF1EF05-F63E-4416-9956-37AE2CA86B74@oracle.com>
References: <4E4F8B5D.6060404@cn.fujitsu.com> <20110822192620.GB16261@fieldses.org> <3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com> <20110822194459.GC16261@fieldses.org> <4E5492FD.8040903@cn.fujitsu.com> <16175F9F-67BA-4406-8A2A-936814D56E0F@oracle.com> <36B5EA7A-21EF-4E82-BF97-F657AEC5ED3B@oracle.com> <4E57440F.90808@cn.fujitsu.com> <20110826224351.GB18699@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I don't see any obvious problems with it.  It would be nice to see this patch in operation on an IPv6-capable network.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On Aug 26, 2011, at 6:43 PM, J. Bruce Fields wrote:

> Jeff and Chuck, you're OK with the revised version?
> 
> --b.
> 
> On Fri, Aug 26, 2011 at 02:58:23PM +0800, Mi Jinlong wrote:
>>> From 84420475509ccc39ac8899f6f63140879a5278b6 Mon Sep 17 00:00:00 2001
>> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> Date: Mon, 26 Aug 2011 13:22:39 +0800
>> Subject: [PATCH v2] SUNRPC: Replace svc_addr_u by sockaddr_storage
>> 
>> For IPv6 local address, lockd can not callback to client for 
>> missing scope id when binding address at inet6_bind:
>> 
>> 324       if (addr_type & IPV6_ADDR_LINKLOCAL) {
>> 325               if (addr_len >= sizeof(struct sockaddr_in6) &&
>> 326                   addr->sin6_scope_id) {
>> 327                       /* Override any existing binding, if another one
>> 328                        * is supplied by user.
>> 329                        */
>> 330                       sk->sk_bound_dev_if = addr->sin6_scope_id;
>> 331               }
>> 332 
>> 333               /* Binding to link-local address requires an interface */
>> 334               if (!sk->sk_bound_dev_if) {
>> 335                       err = -EINVAL;
>> 336                       goto out_unlock;
>> 337               }
>> 
>> Replacing svc_addr_u by sockaddr_storage, let rqstp->rq_daddr contains more info
>> besides address.
>> 
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>> fs/lockd/host.c             |   25 ++-----------------------
>> fs/nfsd/nfs4state.c         |   16 +---------------
>> include/linux/sunrpc/clnt.h |    3 ++-
>> include/linux/sunrpc/svc.h  |   30 +++++++++++++++++++++---------
>> net/sunrpc/svc_xprt.c       |   13 ++-----------
>> net/sunrpc/svcsock.c        |   23 +++++++++++++++++------
>> 6 files changed, 45 insertions(+), 65 deletions(-)
>> 
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index b7c99bf..6f29836 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -316,14 +316,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
>> 	struct hlist_node *pos;
>> 	struct nlm_host	*host = NULL;
>> 	struct nsm_handle *nsm = NULL;
>> -	struct sockaddr_in sin = {
>> -		.sin_family	= AF_INET,
>> -	};
>> -	struct sockaddr_in6 sin6 = {
>> -		.sin6_family	= AF_INET6,
>> -	};
>> -	struct sockaddr *src_sap;
>> -	size_t src_len = rqstp->rq_addrlen;
>> +	struct sockaddr *src_sap = svc_daddr(rqstp);
>> +	size_t src_len = rqstp->rq_daddrlen;
>> 	struct nlm_lookup_host_info ni = {
>> 		.server		= 1,
>> 		.sap		= svc_addr(rqstp),
>> @@ -340,21 +334,6 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
>> 
>> 	mutex_lock(&nlm_host_mutex);
>> 
>> -	switch (ni.sap->sa_family) {
>> -	case AF_INET:
>> -		sin.sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
>> -		src_sap = (struct sockaddr *)&sin;
>> -		break;
>> -	case AF_INET6:
>> -		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6);
>> -		src_sap = (struct sockaddr *)&sin6;
>> -		break;
>> -	default:
>> -		dprintk("lockd: %s failed; unrecognized address family\n",
>> -			__func__);
>> -		goto out;
>> -	}
>> -
>> 	if (time_after_eq(jiffies, next_gc))
>> 		nlm_gc_hosts();
>> 
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 3787ec1..07a18a5 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1173,20 +1173,6 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
>> 	return NULL;
>> }
>> 
>> -static void rpc_svcaddr2sockaddr(struct sockaddr *sa, unsigned short family, union svc_addr_u *svcaddr)
>> -{
>> -	switch (family) {
>> -	case AF_INET:
>> -		((struct sockaddr_in *)sa)->sin_family = AF_INET;
>> -		((struct sockaddr_in *)sa)->sin_addr = svcaddr->addr;
>> -		return;
>> -	case AF_INET6:
>> -		((struct sockaddr_in6 *)sa)->sin6_family = AF_INET6;
>> -		((struct sockaddr_in6 *)sa)->sin6_addr = svcaddr->addr6;
>> -		return;
>> -	}
>> -}
>> -
>> static void
>> gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_rqst *rqstp)
>> {
>> @@ -1218,7 +1204,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
>> 
>> 	conn->cb_prog = se->se_callback_prog;
>> 	conn->cb_ident = se->se_callback_ident;
>> -	rpc_svcaddr2sockaddr((struct sockaddr *)&conn->cb_saddr, expected_family, &rqstp->rq_daddr);
>> +	memcpy(&conn->cb_saddr, &rqstp->rq_daddr, rqstp->rq_daddrlen);
>> 	return;
>> out_err:
>> 	conn->cb_addr.ss_family = AF_UNSPEC;
>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>> index db7bcaf..1529a80 100644
>> --- a/include/linux/sunrpc/clnt.h
>> +++ b/include/linux/sunrpc/clnt.h
>> @@ -218,7 +218,8 @@ static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
>> {
>> 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
>> 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
>> -	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
>> +	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr)
>> +		&& (sin1->sin6_scope_id == sin2->sin6_scope_id);
>> }
>> 
>> static inline bool __rpc_copy_addr6(struct sockaddr *dst,
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 223588a..3bc0dc9 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -212,11 +212,6 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
>> 	iov->iov_len += sizeof(__be32);
>> }
>> 
>> -union svc_addr_u {
>> -    struct in_addr	addr;
>> -    struct in6_addr	addr6;
>> -};
>> -
>> /*
>>  * The context of a single thread, including the request currently being
>>  * processed.
>> @@ -225,8 +220,12 @@ struct svc_rqst {
>> 	struct list_head	rq_list;	/* idle list */
>> 	struct list_head	rq_all;		/* all threads list */
>> 	struct svc_xprt *	rq_xprt;	/* transport ptr */
>> +
>> 	struct sockaddr_storage	rq_addr;	/* peer address */
>> 	size_t			rq_addrlen;
>> +	struct sockaddr_storage	rq_daddr;	/* dest addr of request
>> +						 *  - reply from here */
>> +	size_t			rq_daddrlen;
>> 
>> 	struct svc_serv *	rq_server;	/* RPC service definition */
>> 	struct svc_pool *	rq_pool;	/* thread pool */
>> @@ -255,9 +254,6 @@ struct svc_rqst {
>> 	unsigned short
>> 				rq_secure  : 1;	/* secure port */
>> 
>> -	union svc_addr_u	rq_daddr;	/* dest addr of request
>> -						 *  - reply from here */
>> -
>> 	void *			rq_argp;	/* decoded arguments */
>> 	void *			rq_resp;	/* xdr'd results */
>> 	void *			rq_auth_data;	/* flavor-specific data */
>> @@ -300,6 +296,21 @@ static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
>> 	return (struct sockaddr *) &rqst->rq_addr;
>> }
>> 
>> +static inline struct sockaddr_in *svc_daddr_in(const struct svc_rqst *rqst)
>> +{
>> +	return (struct sockaddr_in *) &rqst->rq_daddr;
>> +}
>> +
>> +static inline struct sockaddr_in6 *svc_daddr_in6(const struct svc_rqst *rqst)
>> +{
>> +	return (struct sockaddr_in6 *) &rqst->rq_daddr;
>> +}
>> +
>> +static inline struct sockaddr *svc_daddr(const struct svc_rqst *rqst)
>> +{
>> +	return (struct sockaddr *) &rqst->rq_daddr;
>> +}
>> +
>> /*
>>  * Check buffer bounds after decoding arguments
>>  */
>> @@ -340,7 +351,8 @@ struct svc_deferred_req {
>> 	struct svc_xprt		*xprt;
>> 	struct sockaddr_storage	addr;	/* where reply must go */
>> 	size_t			addrlen;
>> -	union svc_addr_u	daddr;	/* where reply must come from */
>> +	struct sockaddr_storage	daddr;	/* where reply must come from */
>> +	size_t			daddrlen;
>> 	struct cache_deferred_req handle;
>> 	size_t			xprt_hlen;
>> 	int			argslen;
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index bd31208..d86bb67 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -254,8 +254,6 @@ EXPORT_SYMBOL_GPL(svc_create_xprt);
>>  */
>> void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>> {
>> -	struct sockaddr *sin;
>> -
>> 	memcpy(&rqstp->rq_addr, &xprt->xpt_remote, xprt->xpt_remotelen);
>> 	rqstp->rq_addrlen = xprt->xpt_remotelen;
>> 
>> @@ -263,15 +261,8 @@ void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>> 	 * Destination address in request is needed for binding the
>> 	 * source address in RPC replies/callbacks later.
>> 	 */
>> -	sin = (struct sockaddr *)&xprt->xpt_local;
>> -	switch (sin->sa_family) {
>> -	case AF_INET:
>> -		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
>> -		break;
>> -	case AF_INET6:
>> -		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
>> -		break;
>> -	}
>> +	memcpy(&rqstp->rq_daddr, &xprt->xpt_local, xprt->xpt_locallen);
>> +	rqstp->rq_daddrlen = xprt->xpt_locallen;
>> }
>> EXPORT_SYMBOL_GPL(svc_xprt_copy_addrs);
>> 
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index 767d494..dfd686e 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -143,19 +143,20 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>> 			cmh->cmsg_level = SOL_IP;
>> 			cmh->cmsg_type = IP_PKTINFO;
>> 			pki->ipi_ifindex = 0;
>> -			pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
>> +			pki->ipi_spec_dst.s_addr =
>> +				 svc_daddr_in(rqstp)->sin_addr.s_addr;
>> 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
>> 		}
>> 		break;
>> 
>> 	case AF_INET6: {
>> 			struct in6_pktinfo *pki = CMSG_DATA(cmh);
>> +			struct sockaddr_in6 *daddr = svc_daddr_in6(rqstp);
>> 
>> 			cmh->cmsg_level = SOL_IPV6;
>> 			cmh->cmsg_type = IPV6_PKTINFO;
>> -			pki->ipi6_ifindex = 0;
>> -			ipv6_addr_copy(&pki->ipi6_addr,
>> -					&rqstp->rq_daddr.addr6);
>> +			pki->ipi6_ifindex = daddr->sin6_scope_id;
>> +			ipv6_addr_copy(&pki->ipi6_addr,	&daddr->sin6_addr);
>> 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
>> 		}
>> 		break;
>> @@ -498,9 +499,13 @@ static int svc_udp_get_dest_address4(struct svc_rqst *rqstp,
>> 				     struct cmsghdr *cmh)
>> {
>> 	struct in_pktinfo *pki = CMSG_DATA(cmh);
>> +	struct sockaddr_in *daddr = svc_daddr_in(rqstp);
>> +
>> 	if (cmh->cmsg_type != IP_PKTINFO)
>> 		return 0;
>> -	rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
>> +
>> +	daddr->sin_family = AF_INET;
>> +	daddr->sin_addr.s_addr = pki->ipi_spec_dst.s_addr;
>> 	return 1;
>> }
>> 
>> @@ -511,9 +516,14 @@ static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
>> 				     struct cmsghdr *cmh)
>> {
>> 	struct in6_pktinfo *pki = CMSG_DATA(cmh);
>> +	struct sockaddr_in6 *daddr = svc_daddr_in6(rqstp);
>> +
>> 	if (cmh->cmsg_type != IPV6_PKTINFO)
>> 		return 0;
>> -	ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
>> +
>> +	daddr->sin6_family = AF_INET6;
>> +	ipv6_addr_copy(&daddr->sin6_addr, &pki->ipi6_addr);
>> +	daddr->sin6_scope_id = pki->ipi6_ifindex;
>> 	return 1;
>> }
>> 
>> @@ -614,6 +624,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>> 		skb_free_datagram_locked(svsk->sk_sk, skb);
>> 		return 0;
>> 	}
>> +	rqstp->rq_daddrlen = svc_addr_len(svc_daddr(rqstp));
>> 
>> 	if (skb_is_nonlinear(skb)) {
>> 		/* we have to copy */
>> -- 
>> 1.7.6
>> 
>> 
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




