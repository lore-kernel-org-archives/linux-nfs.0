From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Wed, 16 May 2007 16:35:07 -0500
Message-ID: <C270E33B.3042D%tom@opengridcomputing.com>
References: <20070516192047.GI9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoR4W-0004Jx-PB
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 14:30:13 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoR4U-00022Y-5o
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 14:30:10 -0700
In-Reply-To: <20070516192047.GI9626@sgi.com>
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


Greg:

I like this patch organization. I'll replicate this in the integrated
tree... 

See comment below.

On 5/16/07 2:20 PM, "Greg Banks" <gnb@sgi.com> wrote:

> 
> Move the code at the beginning of svc_process() that sets up
> page buffers for the reply, into a new sko_prepape_reply
> method in svc_sock_ops.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    6 +++
>  net/sunrpc/svc.c               |   22 ++------------
>  net/sunrpc/svcsock.c           |   46 ++++++++++++++++++++++++++++--
>  3 files changed, 54 insertions(+), 20 deletions(-)
> 
> Index: linux/net/sunrpc/svcsock.c
> ===================================================================
> --- linux.orig/net/sunrpc/svcsock.c 2007-05-17 00:16:39.911496313 +1000
> +++ linux/net/sunrpc/svcsock.c 2007-05-17 00:36:20.381217499 +1000
> @@ -880,12 +880,37 @@ svc_udp_sendto(struct svc_rqst *rqstp)
> return error;
>  }
>  
> +/*
> + * Setup response xdr_buf.  Initially it has just one page.
> + */
> +static int
> +svc_tcpip_prepare_reply(struct svc_rqst *rqstp)
> +{
> + struct kvec *resv = &rqstp->rq_res.head[0];
> +
> + rqstp->rq_resused = 1;
> + resv->iov_base = page_address(rqstp->rq_respages[0]);
> + resv->iov_len = 0;
> + rqstp->rq_res.pages = rqstp->rq_respages + 1;
> + rqstp->rq_res.len = 0;
> + rqstp->rq_res.page_base = 0;
> + rqstp->rq_res.page_len = 0;
> + rqstp->rq_res.buflen = PAGE_SIZE;
> + rqstp->rq_res.tail[0].iov_base = NULL;
> + rqstp->rq_res.tail[0].iov_len = 0;
> + /* Will be turned off only in gss privacy case: */
> + rqstp->rq_sendfile_ok = 1;

I think this belongs in the svc_process logic. It doesn't have anything to
do with the buffer, but rather whether or not GSS is turned on.

> +
> + return 0;
> +}
> +
>  static const struct svc_sock_ops svc_udp_ops = {
> .sko_name = "udp",
> .sko_recvfrom = svc_udp_recvfrom,
> .sko_sendto = svc_udp_sendto,
> .sko_detach = svc_tcpip_detach,
> - .sko_free = svc_tcpip_free
> + .sko_free = svc_tcpip_free,
> + .sko_prepare_reply = svc_tcpip_prepare_reply
>  };
>  
>  static void
> @@ -1324,12 +1349,29 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
> return sent;
>  }
>  
> +/*
> + * Setup response xdr_buf.  Initially it has just one page.
> + */
> +static int
> +svc_tcp_prepare_reply(struct svc_rqst *rqstp)
> +{
> + struct kvec *resv = &rqstp->rq_res.head[0];
> +
> + svc_tcpip_prepare_reply(rqstp);
> +
> + /* tcp needs a space for the record length... */
> + svc_putnl(resv, 0);
> +
> + return 0;
> +}
> +
>  static const struct svc_sock_ops svc_tcp_ops = {
> .sko_name = "tcp",
> .sko_recvfrom = svc_tcp_recvfrom,
> .sko_sendto = svc_tcp_sendto,
> .sko_detach = svc_tcpip_detach,
> - .sko_free = svc_tcpip_free
> + .sko_free = svc_tcpip_free,
> + .sko_prepare_reply = svc_tcp_prepare_reply
>  };
>  
>  static void
> Index: linux/include/linux/sunrpc/svcsock.h
> ===================================================================
> --- linux.orig/include/linux/sunrpc/svcsock.h 2007-05-17 00:12:50.074342601
> +1000
> +++ linux/include/linux/sunrpc/svcsock.h 2007-05-17 00:36:20.553194321 +1000
> @@ -27,6 +27,12 @@ struct svc_sock_ops {
> * destruction of a svc_sock.
> */
> void   (*sko_free)(struct svc_sock *);
> + /*
> +  * Perform any transport-specific work necessary to setup
> +  * the reply buffer before the reply is encoded.  May
> +  * fail, e.g. due to memory allocation.
> +  */
> + int                     (*sko_prepare_reply)(struct svc_rqst *);
>  };
>  
>  /*
> Index: linux/net/sunrpc/svc.c
> ===================================================================
> --- linux.orig/net/sunrpc/svc.c 2007-04-26 13:08:32.000000000 +1000
> +++ linux/net/sunrpc/svc.c 2007-05-17 00:36:20.557193782 +1000
> @@ -800,24 +800,10 @@ svc_process(struct svc_rqst *rqstp)
> if (argv->iov_len < 6*4)
> goto err_short_len;
>  
> - /* setup response xdr_buf.
> -  * Initially it has just one page
> -  */
> - rqstp->rq_resused = 1;
> - resv->iov_base = page_address(rqstp->rq_respages[0]);
> - resv->iov_len = 0;
> - rqstp->rq_res.pages = rqstp->rq_respages + 1;
> - rqstp->rq_res.len = 0;
> - rqstp->rq_res.page_base = 0;
> - rqstp->rq_res.page_len = 0;
> - rqstp->rq_res.buflen = PAGE_SIZE;
> - rqstp->rq_res.tail[0].iov_base = NULL;
> - rqstp->rq_res.tail[0].iov_len = 0;
> - /* Will be turned off only in gss privacy case: */
> - rqstp->rq_sendfile_ok = 1;
> - /* tcp needs a space for the record length... */
> - if (rqstp->rq_prot == IPPROTO_TCP)
> -  svc_putnl(resv, 0);
> + /* setup response xdr_buf. */
> + if (rqstp->rq_sock->sk_ops->sko_prepare_reply &&
> +     rqstp->rq_sock->sk_ops->sko_prepare_reply(rqstp))
> +  goto dropit;
>  
> rqstp->rq_xid = svc_getu32(argv);
> svc_putu32(resv, rqstp->rq_xid);



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
