From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 03/20] svc: xpt_prep_reply_hdr
Date: Wed, 29 Aug 2007 13:15:46 -0400
Message-ID: <46D5A9C2.6000300@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162327.15224.25232.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060604030006010404070909"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQR9k-0007bo-KE
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:16:41 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQR9n-00008K-NT
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:16:45 -0700
In-Reply-To: <20070820162327.15224.25232.stgit@dell3.ogc.int>
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
--------------060604030006010404070909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Add a transport function that prepares the transport specific header for 
> RPC replies. UDP has none, TCP has a 4B record length. This will
> allow the RDMA transport to prepare it's variable length reply
> header as well.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    4 ++++
>  net/sunrpc/svc.c               |    8 +++++---
>  net/sunrpc/svcsock.c           |   15 +++++++++++++++
>  3 files changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 27c5b1f..1da42c2 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -27,6 +27,10 @@ struct svc_xprt {
>  	 * destruction of a svc_sock.
>  	 */
>  	void			(*xpt_free)(struct svc_sock *);
> +	/*
> +	 * Prepare any transport-specific RPC header.
> +	 */
> +	int                     (*xpt_prep_reply_hdr)(struct svc_rqst *);
>  };

A shorter name for this one might be nice, but I know it's kind of hard 
to choose one.

>  /*
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index e673ef9..72a900f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -815,9 +815,11 @@ svc_process(struct svc_rqst *rqstp)
>  	rqstp->rq_res.tail[0].iov_len = 0;
>  	/* Will be turned off only in gss privacy case: */
>  	rqstp->rq_sendfile_ok = 1;
> -	/* tcp needs a space for the record length... */
> -	if (rqstp->rq_prot == IPPROTO_TCP)
> -		svc_putnl(resv, 0);
> +
> +	/* setup response header. */
> +	if (rqstp->rq_sock->sk_xprt->xpt_prep_reply_hdr &&
> +	    rqstp->rq_sock->sk_xprt->xpt_prep_reply_hdr(rqstp))
> +		goto dropit;

Although others might disagree, I like making all the transport methods 
mandatory.

The TCP transport will be the common case here, and that will always 
have to do both the existence check and the call.

What is the purpose of the return code?  Does the RDMA header 
constructor return something other than zero, and if so, why?

And finally a dumb style nit... I generally don't like the extra comment 
here -- it restates what is already clear.

>  	rqstp->rq_xid = svc_getu32(argv);
>  	svc_putu32(resv, rqstp->rq_xid);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 4956c88..ca473ee 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1326,12 +1326,27 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
>  	return sent;
>  }
>  
> +/*
> + * Setup response header. TCP has a 4B record length field.
> + */
> +static int
> +svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
> +{
> +	struct kvec *resv = &rqstp->rq_res.head[0];
> +
> +	/* tcp needs a space for the record length... */
> +	svc_putnl(resv, 0);
> +
> +	return 0;
> +}
> +
>  static const struct svc_xprt svc_tcp_xprt = {
>  	.xpt_name = "tcp",
>  	.xpt_recvfrom = svc_tcp_recvfrom,
>  	.xpt_sendto = svc_tcp_sendto,
>  	.xpt_detach = svc_sock_detach,
>  	.xpt_free = svc_sock_free,
> +	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
>  };
>  
>  static void
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


--------------060604030006010404070909
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060604030006010404070909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060604030006010404070909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060604030006010404070909--
