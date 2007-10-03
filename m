From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/35] SVC Transport Switch
Date: Wed, 03 Oct 2007 09:02:37 -0500
Message-ID: <1191420157.1565.91.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071003110345.GM21388@sgi.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id4pM-0002hV-LG
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 07:03:52 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id4pQ-0001e5-Cz
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 07:03:57 -0700
In-Reply-To: <20071003110345.GM21388@sgi.com>
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

On Wed, 2007-10-03 at 21:03 +1000, Greg Banks wrote:
> On Mon, Oct 01, 2007 at 02:14:26PM -0500, Tom Tucker wrote:
> > This is rev 2 of the new pluggable transport switch for
> > RPC servers. This version includes two new patches: one to add a field
> > for keeping track of a transport specific header that precedes the
> > RPC header for deferral processing, and one that cleans up some 
> > left over references to svc_sock in transport independent code.
> 
> > Subject: [RFC,PATCH 22/35] svc: Remove sk_lastrecv
> 
> ok
> 
> 
> > Subject: [RFC,PATCH 31/35] svc: Make svc_check_conn_limits xprt independent
> 
> ok
> 
> 
> > Subject: [RFC,PATCH 33/35] svc: Add transport hdr size for defer/revisit
> 
> Hmm.  When I did it this way I needed to do two things this patch
> doesn't do.
> 
>  * Save my equivalent of rqstp->rq_hdr_len in the deferred call record
>  
>  * Have a hunk a in svc_deferred_recv() to restore
>    rqstp->rq_arg.head[0].iov_base properly so that on revisit it points
>    to the byte *after* the transport-specific header (where it should
>    be on return from xpo_recvfrom).
>    
> Like this:
> 
> 
> --- linux-2.6.16.orig/include/linux/sunrpc/svc.h        2007-03-27 23:10:51.439088106 +1000
> +++ linux-2.6.16/include/linux/sunrpc/svc.h     2007-05-23 23:11:52.324128040 +1000
> @@ -350,6 +350,8 @@ struct svc_deferred_req {
>         u32                     daddr;  /* where reply must come from */
>         struct cache_deferred_req handle;
>         int                     argslen;
> +       int                     trans_header;   /* size of preserved transport-
> +                                                * specific header */
>         u32                     args[0];
>  };
>                                                                                 
> --- linux-2.6.16.orig/net/sunrpc/svcsock.c      2007-05-23 23:05:56.293445240 +1000
> +++ linux-2.6.16/net/sunrpc/svcsock.c   2007-05-23 23:11:52.396118869 +1000
> @@ -1727,6 +1729,8 @@ static struct cache_deferred_req *svc_de
>                 dr->addr = rqstp->rq_addr;
>                 dr->daddr = rqstp->rq_daddr;
>                 dr->argslen = rqstp->rq_arg.len >> 2;
> +               dr->trans_header = rqstp->rq_arg.trans_header;
> +               skip += dr->trans_header;
>                 memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
>                 dprintk("svc: deferred %d bytes of request, dr=%p\n",
>                         dr->argslen<<2, dr);
> @@ -1745,10 +1749,11 @@ static int svc_deferred_recv(struct svc_
>  {
>         struct svc_deferred_req *dr = rqstp->rq_deferred;
>                                                                                 
> -       rqstp->rq_arg.head[0].iov_base = dr->args;
> +       rqstp->rq_arg.head[0].iov_base = dr->args + dr->trans_header;
>         rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
>         rqstp->rq_arg.page_len = 0;
>         rqstp->rq_arg.len = dr->argslen<<2;
> +       rqstp->rq_arg.trans_header = dr->trans_header;
>         rqstp->rq_prot        = dr->prot;
>         rqstp->rq_addr        = dr->addr;
>         rqstp->rq_daddr       = dr->daddr;
> 
> Is this somehow no longer necessary?

No, it's still necessary, but your approach is a nice optimization since
you don't need to re-parse the header to get it's size when handling the
deferred recv.

Thanks,

> 
> @@ -393,6 +393,9 @@ svc_recvfrom(struct svc_rqst *rqstp, str
>         };
>         int len;
>                                                                                                                                           
> +       /* TCP/UDP have no transport header */
> +       rqstp->rq_xprt_hlen = 0;
> +
>         len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
>                                 msg.msg_flags);
> 
> This comment is not quite correct.  TCP has a transport header, but
> we don't need it after svc_tcp_recvfrom() returns, so it doesn't
> need to be handled by defer/revisit.
> 

Ok, 

> 
> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
