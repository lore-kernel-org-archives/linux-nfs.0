From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 07/20] svc: centralise close handling
Date: Wed, 29 Aug 2007 14:16:41 -0400
Message-ID: <46D5B809.9020807@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162336.15224.39616.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090400030607070208070401"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQS6D-0005P5-QS
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:17:05 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQS6G-0003TV-V4
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:17:10 -0700
In-Reply-To: <20070820162336.15224.39616.stgit@dell3.ogc.int>
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
--------------090400030607070208070401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Centralise the handling of the SK_CLOSE bit so that future
> server transport implementations will be easier to
> write correctly. The xpt_recvfrom method does not 
> need to check for SK_CLOSE anymore, that's handled in 
> core code.

You are removing the test_bit(SK_CLOSE) from the transport specific 
recvfrom functions into the main svc_recv() entry point.  This moves the 
test before this code:

         if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
                 svc_sock_received(svsk);
                 return svc_deferred_recv(rqstp);
         }

Why not move this test too (it's the same in both the tcp and udp 
recvfrom routines)?

Is it always safe to check if the socket is closed before checking the 
deferred queue?  Does that mean that now deferred requests are 
automatically thrown away if SK_CLOSE is set?

> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/svcsock.c |   28 +++++++++++++---------------
>  1 files changed, 13 insertions(+), 15 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 8fad53d..5c3a794 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -756,11 +756,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  		return svc_deferred_recv(rqstp);
>  	}
>  
> -	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
> -		svc_delete_socket(svsk);
> -		return 0;
> -	}
> -
>  	clear_bit(SK_DATA, &svsk->sk_flags);
>  	skb = NULL;
>  	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> @@ -1158,11 +1153,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		return svc_deferred_recv(rqstp);
>  	}
>  
> -	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
> -		svc_delete_socket(svsk);
> -		return 0;
> -	}
> -

Should you also remove the "test_bit(SK_CLOSE)" from the dprintk in this 
function?

>  	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
>  		svc_tcp_accept(svsk);
>  		svc_sock_received(svsk);
> @@ -1406,8 +1396,10 @@ svc_tcp_init(struct svc_sock *svsk)
>  
>  		set_bit(SK_CHNGBUF, &svsk->sk_flags);
>  		set_bit(SK_DATA, &svsk->sk_flags);
> -		if (sk->sk_state != TCP_ESTABLISHED)
> +		if (sk->sk_state != TCP_ESTABLISHED) {
> +			/* note: caller calls svc_sock_enqueue() */
>  			set_bit(SK_CLOSE, &svsk->sk_flags);
> +		}
>  	}
>  }

The comment is unclear.  Maybe a longer block comment is needed before 
the if statement.  Do you really need the brackets here?

> @@ -1525,10 +1517,16 @@ svc_recv(struct svc_rqst *rqstp, long ti
>  	}
>  	spin_unlock_bh(&pool->sp_lock);
>  
> -	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> -		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> -	len = svsk->sk_xprt->xpt_recvfrom(rqstp);
> -	dprintk("svc: got len=%d\n", len);
> +	len = 0;
> +	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
> +		dprintk("svc_recv: found SK_CLOSE\n");
> +		svc_delete_socket(svsk);
> +	} else {
> +		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> +			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> +		len = svsk->sk_xprt->xpt_recvfrom(rqstp);
> +		dprintk("svc: got len=%d\n", len);
> +	}
>  
>  	/* No data, incomplete (TCP) read, or accept() */
>  	if (len == 0 || len == -EAGAIN) {


--------------090400030607070208070401
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


--------------090400030607070208070401
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090400030607070208070401
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090400030607070208070401--
