From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 04/20] svc: xpt_has_wspace
Date: Wed, 29 Aug 2007 13:32:55 -0400
Message-ID: <46D5ADC7.2090009@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162329.15224.29032.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030704060802030703020207"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQRQo-00012a-1l
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:34:18 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQRQs-0006EN-7Z
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:34:22 -0700
In-Reply-To: <20070820162329.15224.29032.stgit@dell3.ogc.int>
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
--------------030704060802030703020207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Move the code that checks for available write space on the socket, 
> into a new transport function. This will allow transports flexibility
> when determining if enough space/memory is available to process
> the reply. The role of this function for RDMA is to avoid stalling
> an knfsd thread when SQ space is not available.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    4 ++
>  net/sunrpc/svcsock.c           |   75 ++++++++++++++++++++++++++--------------
>  2 files changed, 52 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 1da42c2..3faa95c 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -31,6 +31,10 @@ struct svc_xprt {
>  	 * Prepare any transport-specific RPC header.
>  	 */
>  	int                     (*xpt_prep_reply_hdr)(struct svc_rqst *);
> +	/*
> +	 * Return 1 if sufficient space to write reply to network.
> +	 */
> +	int			(*xpt_has_wspace)(struct svc_sock *);
>  };

Again I think this documentation, while important (required, even), 
should go somewhere else.  There is more information required here for a 
complete function document, but there isn't enough space in this 
structure for it.

And as before the "svc_sock *" might be replaced with something more 
generic.

>  /*
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index ca473ee..b16dad4 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -205,22 +205,6 @@ svc_release_skb(struct svc_rqst *rqstp)
>  }
>  
>  /*
> - * Any space to write?
> - */
> -static inline unsigned long
> -svc_sock_wspace(struct svc_sock *svsk)
> -{
> -	int wspace;
> -
> -	if (svsk->sk_sock->type == SOCK_STREAM)
> -		wspace = sk_stream_wspace(svsk->sk_sk);
> -	else
> -		wspace = sock_wspace(svsk->sk_sk);
> -
> -	return wspace;
> -}
> -
> -/*
>   * Queue up a socket with data pending. If there are idle nfsd
>   * processes, wake 'em up.
>   *
> @@ -269,21 +253,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
>  	BUG_ON(svsk->sk_pool != NULL);
>  	svsk->sk_pool = pool;
>  
> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
> -	     > svc_sock_wspace(svsk))
> -	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
> -	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
> -		/* Don't enqueue while not enough space for reply */
> -		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
> -			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
> -			svc_sock_wspace(svsk));
> +	if (!test_bit(SK_CLOSE, &svsk->sk_flags)
> +	    && !test_bit(SK_CONN, &svsk->sk_flags)
> +	    && !svsk->sk_xprt->xpt_has_wspace(svsk)) {
>  		svsk->sk_pool = NULL;
>  		clear_bit(SK_BUSY, &svsk->sk_flags);
>  		goto out_unlock;
>  	}
> -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -
>  
>  	if (!list_empty(&pool->sp_threads)) {
>  		rqstp = list_entry(pool->sp_threads.next,

Your patch changes the order of the tests here of SOCK_NOSPACE, 
SK_CLOSE, SK_CONN, and the other variables.  Can you prove this is safe?

Have you considered abstracting all of svc_sock_enqueue into the switch 
API, instead of just the wspace checking part?  At some point the RDMA 
transport may want to schedule the enqueued I/O differently than the 
socket interface does.

If not, it should be made more generic (perhaps moved out of svcsock.c 
and renamed).

> @@ -882,12 +858,45 @@ svc_udp_sendto(struct svc_rqst *rqstp)
>  	return error;
>  }
>  
> +/**
> + * svc_sock_has_write_space - Checks if there is enough space
> + * to send the reply on the socket.
> + * @svsk: the svc_sock to write on
> + * @wspace: the number of bytes available for writing
> + */
> +static int svc_sock_has_write_space(struct svc_sock *svsk, int wspace)
> +{
> +	struct svc_serv	*serv = svsk->sk_server;
> +	int required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> +
> +	if (required*2 > wspace) {
> +		/* Don't enqueue while not enough space for reply */
> +		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
> +			svsk->sk_sk, required, wspace);
> +		return 0;
> +	}
> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}

My own style preference here is to keep the set_bit(SOCK_NOSPACE) and 
clear_bit(SOCK_NOSPACE) in the same function if possible, just as a 
defensive coding practice.

> +static int
> +svc_udp_has_wspace(struct svc_sock *svsk)
> +{
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
> +}
> +
>  static const struct svc_xprt svc_udp_xprt = {
>  	.xpt_name = "udp",
>  	.xpt_recvfrom = svc_udp_recvfrom,
>  	.xpt_sendto = svc_udp_sendto,
>  	.xpt_detach = svc_sock_detach,
>  	.xpt_free = svc_sock_free,
> +	.xpt_has_wspace = svc_udp_has_wspace,
>  };
>  
>  static void
> @@ -1340,6 +1349,17 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
>  	return 0;
>  }
>  
> +static int
> +svc_tcp_has_wspace(struct svc_sock *svsk)
> +{
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
> +}
> +
>  static const struct svc_xprt svc_tcp_xprt = {
>  	.xpt_name = "tcp",
>  	.xpt_recvfrom = svc_tcp_recvfrom,
> @@ -1347,6 +1367,7 @@ static const struct svc_xprt svc_tcp_xpr
>  	.xpt_detach = svc_sock_detach,
>  	.xpt_free = svc_sock_free,
>  	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> +	.xpt_has_wspace = svc_tcp_has_wspace,
>  };
>  
>  static void

--------------030704060802030703020207
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


--------------030704060802030703020207
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030704060802030703020207
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030704060802030703020207--
