From: Tim Hasson <tim@aidasystems.com>
Subject: Re: [Patch] Linux NFS & Heartbeat Failover (RH9.0)
Date: Tue, 19 Aug 2003 04:53:09 -0700
Sender: linux-ha-admin@lists.linux-ha.org
Message-ID: <1061293989.3f420fa55fa3a@mail.aidasystems.com>
References: <1061046205.3f3e47bd69679@mail.aidasystems.com> <16191.24979.340685.673333@gargle.gargle.HOWL>
Reply-To: linux-ha@lists.linux-ha.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, linux-ha@lists.linux-ha.org, forsberg@cendio.se
Return-path: <linux-ha-admin@lists.linux-ha.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16191.24979.340685.673333@gargle.gargle.HOWL>
Errors-To: linux-ha-admin@lists.linux-ha.org
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha/>
List-ID: <nfs.lists.sourceforge.net>

Hi,

Neil, Thank you very much for your very useful patch. Unfortunately, I didnt 
realize this was against ~current (2.6.x ?) therefore it failed horribly :/
I modified it against 2.4.20-19 (redhat9's kernel-source updated), and it 
works as expected. The nfsd on port 2049 no longer responds on eth0 when it 
gets a request on eth0:0, but instead replies on the if/addr it received the 
connection from.
Keep up the good work!

Best Regards,
Tim Hasson

This is a unidiff against 2.4.20-19
--- ./include/linux/sunrpc/svc.h.orig   2003-08-19 01:23:38.000000000 -0700
+++ ./include/linux/sunrpc/svc.h        2003-08-19 01:29:41.000000000 -0700
@@ -111,6 +111,7 @@
                                rq_userset : 1, /* auth->setuser OK */
                                rq_secure  : 1, /* secure port */
                                rq_auth    : 1; /* check client */
+        u32                   rq_daddr;       /* dest addr of request - reply 
from here */

        void *                  rq_argp;        /* decoded arguments */
        void *                  rq_resp;        /* xdr'd results */

--- ./net/sunrpc/svcsock.c.orig 2003-08-19 01:28:27.000000000 -0700
+++ ./net/sunrpc/svcsock.c      2003-08-19 01:54:32.000000000 -0700
@@ -316,6 +316,9 @@
        struct socket   *sock = svsk->sk_sock;
        struct msghdr   msg;
        int             i, buflen, len;
+       struct { struct cmsghdr cmh;
+               struct in_pktinfo pki;
+       } cm;

        for (i = buflen = 0; i < nr; i++)
                buflen += iov[i].iov_len;
@@ -324,8 +327,6 @@
        msg.msg_namelen = sizeof(rqstp->rq_addr);
        msg.msg_iov     = iov;
        msg.msg_iovlen  = nr;
-       msg.msg_control = NULL;
-       msg.msg_controllen = 0;

        /* This was MSG_DONTWAIT, but I now want it to wait.
         * The only thing that it would wait for is memory and
@@ -335,6 +336,19 @@
         */
        msg.msg_flags   = 0;

+       /* set the source */
+       if (rqstp->rq_prot == IPPROTO_UDP) {
+               msg.msg_control = &cm;
+               msg.msg_controllen = sizeof(cm);
+               cm.cmh.cmsg_len = sizeof(cm);
+               cm.cmh.cmsg_level = SOL_IP;
+               cm.cmh.cmsg_type = IP_PKTINFO;
+               cm.pki.ipi_ifindex = 0;
+               cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
+       } else {
+               msg.msg_control = NULL;
+               msg.msg_controllen = 0;
+       }
        oldfs = get_fs(); set_fs(KERNEL_DS);
        len = sock_sendmsg(sock, &msg, buflen);
        set_fs(oldfs);
@@ -529,6 +543,7 @@
        rqstp->rq_addr.sin_family = AF_INET;
        rqstp->rq_addr.sin_port = skb->h.uh->source;
        rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+       rqstp->rq_daddr = skb->nh.iph->daddr;

        if (serv->sv_stats)
                serv->sv_stats->netudpcnt++;


Quoting Neil Brown <neilb@cse.unsw.edu.au>:

> On Saturday August 16, tim@aidasystems.com wrote:
> > 
> > Running tcpdump on the primary node like so:
> > tcpdump -np -s 1600 udp port 2049
> > gives some interesting info, especially when I retry mounting by the
> virtual 
> > ip from the nfs client. It looks like the server accepts the connection on
> the 
> > virtual ip (i.e. eth0:0) but nfsd on port 2049 replies using the primary 
> > interface ip (i.e. eth0). The client doesn't like the reply from different
> 
> > host I guess therefore timing out.
> 
> Could you try the following patch and let me know if it helps?
> Thanks.
> 
> NeilBrown
> 
> 
>  ----------- Diffstat output ------------
>  ./include/linux/sunrpc/svc.h |    2 ++
>  ./net/sunrpc/svcsock.c       |   18 ++++++++++++++++--
>  2 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
> --- ./include/linux/sunrpc/svc.h~current~	2003-08-17 20:25:23.000000000
> +1000
> +++ ./include/linux/sunrpc/svc.h	2003-08-17 20:26:34.000000000 +1000
> @@ -112,6 +112,8 @@ struct svc_rqst {
>  				rq_secure  : 1,	/* secure port */
>  				rq_auth    : 1;	/* check client */
>  
> +	__u32			rq_daddr;	/* dest addr of request - 
reply from here */
> +
>  	void *			rq_argp;	/* decoded arguments */
>  	void *			rq_resp;	/* xdr'd results */
>  
> 
> diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
> --- ./net/sunrpc/svcsock.c~current~	2003-08-13 10:04:08.000000000 +1000
> +++ ./net/sunrpc/svcsock.c	2003-08-17 21:01:56.000000000 +1000
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
> 

_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
