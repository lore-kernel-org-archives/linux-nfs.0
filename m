From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] kNFSd - 6 of 6 - Make sure nfsd replies from the
	address the request was sent to.
Date: Sun, 07 Sep 2003 23:32:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1062970326.3947.8.camel@E136.suse.de>
References: <E19unZ5-0004Vg-00@notabene>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ib9pcfDjUUWnPYS56i/S"
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19w76r-0006NZ-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Sep 2003 14:30:13 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19w76n-0001zY-7j
	for nfs@lists.sourceforge.net; Sun, 07 Sep 2003 14:30:09 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <E19unZ5-0004Vg-00@notabene>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-Ib9pcfDjUUWnPYS56i/S
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello,

the patch contains an alignment induced bug on 64-bit platforms:
sizeof(cm) becomes 32 bytes, instead of 16 + 12 = 28. This causes
ip_cmsg_send to fail. See the attached fix.

On Thu, 2003-09-04 at 08:25, NeilBrown wrote: 
> This is important on multi-homes hosts.
> 
> 
> diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
> -- ./include/linux/sunrpc/svc.h~current~	2003-09-04 11:32:11.000000000 +1000
> +++ ./include/linux/sunrpc/svc.h	2003-09-04 11:46:27.000000000 +1000
> @@ -112,6 +112,8 @@ struct svc_rqst {
>  				rq_secure  : 1,	/* secure port */
>  				rq_auth    : 1;	/* check client */
>  
> +	__u32			rq_daddr;	/* dest addr of request - reply from here */
> +
>  	void *			rq_argp;	/* decoded arguments */
>  	void *			rq_resp;	/* xdr'd results */
>  
> 
> diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
> -- ./net/sunrpc/svcsock.c~current~	2003-09-04 11:45:48.000000000 +1000
> +++ ./net/sunrpc/svcsock.c	2003-09-04 11:46:27.000000000 +1000
> @@ -317,6 +317,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
>  	struct svc_sock	*svsk = rqstp->rq_sock;
>  	struct socket	*sock = svsk->sk_sock;
>  	struct msghdr	msg;
> +	struct { struct cmsghdr cmh;
> +		struct in_pktinfo pki;
> +	} cm;
>  	int		i, buflen, len;
>  
>  	for (i = buflen = 0; i < nr; i++)
> @@ -326,8 +329,18 @@ svc_sendto(struct svc_rqst *rqstp, struc
>  	msg.msg_namelen = sizeof(rqstp->rq_addr);
>  	msg.msg_iov     = iov;
>  	msg.msg_iovlen  = nr;
> -	msg.msg_control = NULL;
> -	msg.msg_controllen = 0;
> +	if (rqstp->rq_prot == IPPROTO_UDP) {
> +		msg.msg_control = &cm;
> +		msg.msg_controllen = sizeof(cm);
> +		cm.cmh.cmsg_len = sizeof(cm);
> +		cm.cmh.cmsg_level = SOL_IP;
> +		cm.cmh.cmsg_type = IP_PKTINFO;
> +		cm.pki.ipi_ifindex = 0;
> +		cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
> +	} else {
> +		msg.msg_control = NULL;
> +		msg.msg_controllen = 0;
> +	}
>  
>  	/* This was MSG_DONTWAIT, but I now want it to wait.
>  	 * The only thing that it would wait for is memory and
> @@ -531,6 +544,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	rqstp->rq_addr.sin_family = AF_INET;
>  	rqstp->rq_addr.sin_port = skb->h.uh->source;
>  	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
> +	rqstp->rq_daddr = skb->nh.iph->daddr;
>  
>  	if (serv->sv_stats)
>  		serv->sv_stats->netudpcnt++;


Cheers, 
-- 
Andreas Gruenbacher <agruen@suse.de>
SuSE Labs, SuSE Linux AG <http://www.suse.de/>

--=-Ib9pcfDjUUWnPYS56i/S
Content-Disposition: attachment; filename=multihome-64bit-alignment.diff
Content-Type: text/x-patch; name=multihome-64bit-alignment.diff; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

diff -u linux/net/sunrpc/svcsock.c linux/net/sunrpc/svcsock.c
--- linux/net/sunrpc/svcsock.c	2003-08-17 21:01:56.000000000 +1000
+++ linux/net/sunrpc/svcsock.c	2003-08-17 21:01:56.000000000 +1000
@@ -331,8 +331,8 @@
 	msg.msg_iovlen  = nr;
 	if (rqstp->rq_prot == IPPROTO_UDP) {
 		msg.msg_control = &cm;
-		msg.msg_controllen = sizeof(cm);
-		cm.cmh.cmsg_len = sizeof(cm);
+		msg.msg_controllen = CMSG_LEN(sizeof(struct in_pktinfo));
+		cm.cmh.cmsg_len = CMSG_LEN(sizeof(struct in_pktinfo));
 		cm.cmh.cmsg_level = SOL_IP;
 		cm.cmh.cmsg_type = IP_PKTINFO;
 		cm.pki.ipi_ifindex = 0;

--=-Ib9pcfDjUUWnPYS56i/S--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
