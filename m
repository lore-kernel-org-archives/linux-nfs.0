From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH] svc: REPOST - Fix the UDP address logic
Date: Wed, 24 Oct 2007 14:29:59 -0400
Message-ID: <471F8F27.1040008@oracle.com>
References: <20071023181301.11155.90411.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060802090106070203020901"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ikl16-0004Dj-15
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 11:31:44 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ikl1B-0003ad-6f
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 11:31:49 -0700
In-Reply-To: <20071023181301.11155.90411.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060802090106070203020901
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> This version of the patch sets xpt_remotelen based on the address
> family returned in the sockaddr. If the address family is not
> AF_INET or AF_INET6, the svc_udp_recvfrom function will
> return -ENOTSUPP.
> --
> 
> When the address information was moved to the svc_xprt structure, a bug
> was introduced to UDP that caused an incorrect address to be used
> when responding to RPC on the UDP transport. This was the result of
> failing to completely implement the generic address logic for the UDP 
> transport.
> 
> Thanks to Greg for pointing this out...
> 
> Since I confused myself, it's probably a good idea to describe how 
> this is supposed to work. The transport is responsible for setting 
> the xpt_local and xpt_remote addresses in the svc_xprt structure as
> part of xpo_recvfrom processing. This cannot be done in a generic way 
> and in fact varies between TCP, UDP and RDMA. A set of xpo_ functions
> (e.g. getlocalname, getremotename) could have been added but this would
> have resulted in additional caching and copying of the addresses around. 
> 
> The generic svc_recv code copies the addresses from the svc_xprt 
> structure into the rqstp structure as part of svc_recv processing.  
> 
> The xpt_local address should also be set on listening endpoints, for
> tcp/rdma this is done as part of endpoint creation and for new 
> connections in xpo_accept processing. 
> 
> This patch was tested with Connectathon over V3 on UDP.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/svcsock.c |   31 +++++++++++++++++++++++++------
>  1 files changed, 25 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index e1a27ee..8924cad 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -140,6 +140,18 @@ static char *__svc_print_addr(struct soc
>  	return buf;
>  }
>  
> +static size_t svc_sockaddr_len(struct sockaddr *addr)
> +{
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		return sizeof(struct sockaddr_in);
> +	case AF_INET6:
> +		return sizeof(struct sockaddr_in6);
> +	}
> +	dprintk("svc: unrecognized address family %d\n", addr->sa_family);
> +	return -ENOTSUPP;
> +}
> +

Nit: sa_family is probably an unsigned short, so use "%u" instead of
"%d".  Also I'm using -EAFNOSUPPORT in similar error cases, but I may 
have missed a stated preference.

I'm working blind here (not having pulled down Bruce's or your summary
branches).  I suspect you may need the result of svc_sockaddr_len() in
other parts of your code (perhaps in the RDMA transport implementation).

Based on your patch and comments, I assume that there are some missing
changes (from me, perhaps) that leave updating rq_addrlen with a
sizeof() instead of a real address size in several other places besides
the UDP receive path.  It would be cleaner to fix all of those in one or
more separate patches (placed before your "Fix the UDP address logic"
patch).

(There is a documented preference for this kind of patch atomizing and
ordering which you can probably find in Documentation/SubmittingPatches
or something like that).

>  /**
>   * svc_print_addr - Format rq_addr field for printing
>   * @rqstp: svc_rqst struct containing address to print
> @@ -473,17 +485,21 @@ svc_write_space(struct sock *sk)
>  static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
>  					    struct cmsghdr *cmh)
>  {
> -	struct svc_sock *svsk =
> -		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> +	struct svc_xprt *xprt = rqstp->rq_xprt;
> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
>  	switch (svsk->sk_sk->sk_family) {
>  	case AF_INET: {
>  		struct in_pktinfo *pki = CMSG_DATA(cmh);
> -		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
> +		struct sockaddr_in *sin =
> +			(struct sockaddr_in *)&xprt->xpt_local;
> +		sin->sin_addr.s_addr = pki->ipi_spec_dst.s_addr;
>  		break;
>  		}
>  	case AF_INET6: {
>  		struct in6_pktinfo *pki = CMSG_DATA(cmh);
> -		ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
> +		struct sockaddr_in6 *sin6 =
> +			(struct sockaddr_in6 *)&xprt->xpt_local;
> +		ipv6_addr_copy(&sin6->sin6_addr, &pki->ipi6_addr);
>  		break;
>  		}
>  	}

Neil asked me to add macros for casting sockaddr_storage fields in the 
svc_rqst structure (see svc_addr() and svc_addr_in()).  You might 
consider adding similar macros for cleanly extracting address 
information from svc_xprt.

> @@ -506,7 +522,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	struct cmsghdr *cmh = &buffer.hdr;
>  	int		err, len;
>  	struct msghdr msg = {
> -		.msg_name = svc_addr(rqstp),
> +		.msg_name = &svsk->sk_xprt.xpt_remote,
>  		.msg_control = cmh,
>  		.msg_controllen = sizeof(buffer),
>  		.msg_flags = MSG_DONTWAIT,
> @@ -541,7 +557,10 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  		svc_xprt_received(&svsk->sk_xprt);
>  		return -EAGAIN;
>  	}
> -	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
> +	len = svc_sockaddr_len((struct sockaddr *)&svsk->sk_xprt.xpt_remote);
> +	if (len < 0)
> +		return len;
> +	svsk->sk_xprt.xpt_remotelen = len;
>  	if (skb->tstamp.tv64 == 0) {
>  		skb->tstamp = ktime_get_real();
>  		/* Don't enable netstamp, sunrpc doesn't

--------------060802090106070203020901
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRvdCBj
b20NCnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2
MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQN
Cg0K
--------------060802090106070203020901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------060802090106070203020901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060802090106070203020901--
