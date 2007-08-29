From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 10/20] svc: Add generic refcount services
Date: Wed, 29 Aug 2007 14:55:17 -0400
Message-ID: <46D5C115.1080302@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162342.15224.70459.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000005060804030506050606"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQShM-0001Iu-FH
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:55:28 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQShQ-0000JK-Ls
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:55:33 -0700
In-Reply-To: <20070820162342.15224.70459.stgit@dell3.ogc.int>
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
--------------000005060804030506050606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Add inline svc_sock_get() so that service transport code will not
> need to manipulate sk_inuse directly.  Also, make svc_sock_put()
> available so that transport code outside svcsock.c can use it.

If svc_sock_get/put is meant to be generic, then you should probably 
rename them, move them to a generic source file, and have them take 
something other than "svc_sock *".

Would it make sense to add a kref to these objects instead of 
manipulating a naked atomic_t reference count?

> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |   15 +++++++++++++++
>  net/sunrpc/svcsock.c           |   29 ++++++++++++++---------------
>  2 files changed, 29 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index ea8b62b..9f37f30 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -115,6 +115,7 @@ int		svc_addsock(struct svc_serv *serv,
>  			    int *proto);
>  void		svc_sock_enqueue(struct svc_sock *svsk);
>  void		svc_sock_received(struct svc_sock *svsk);
> +void	    	__svc_sock_put(struct svc_sock *svsk);
>  
>  /*
>   * svc_makesock socket characteristics
> @@ -123,4 +124,18 @@ #define SVC_SOCK_DEFAULTS	(0U)
>  #define SVC_SOCK_ANONYMOUS	(1U << 0)	/* don't register with pmap */
>  #define SVC_SOCK_TEMPORARY	(1U << 1)	/* flag socket as temporary */
>  
> +/*
> + * Take and drop a temporary reference count on the svc_sock.
> + */
> +static inline void svc_sock_get(struct svc_sock *svsk)
> +{
> +	atomic_inc(&svsk->sk_inuse);
> +}
> +
> +static inline void svc_sock_put(struct svc_sock *svsk)
> +{
> +	if (atomic_dec_and_test(&svsk->sk_inuse))
> +	    __svc_sock_put(svsk);
> +}
> +
>  #endif /* SUNRPC_SVCSOCK_H */
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index dcb5c7a..02f682a 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -273,7 +273,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
>  				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
>  				rqstp, rqstp->rq_sock);
>  		rqstp->rq_sock = svsk;
> -		atomic_inc(&svsk->sk_inuse);
> +		svc_sock_get(svsk);
>  		rqstp->rq_reserved = serv->sv_max_mesg;
>  		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
>  		BUG_ON(svsk->sk_pool != pool);
> @@ -351,17 +351,16 @@ void svc_reserve(struct svc_rqst *rqstp,
>  /*
>   * Release a socket after use.
>   */
> -static inline void
> -svc_sock_put(struct svc_sock *svsk)
> +void
> +__svc_sock_put(struct svc_sock *svsk)
>  {
> -	if (atomic_dec_and_test(&svsk->sk_inuse)) {
> -		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
> +	BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
>  
> -		if (svsk->sk_info_authunix != NULL)
> -			svcauth_unix_info_release(svsk->sk_info_authunix);
> -    	    	svsk->sk_xprt->xpt_free(svsk);
> -	}
> +	if (svsk->sk_info_authunix != NULL)
> +		svcauth_unix_info_release(svsk->sk_info_authunix);
> +	svsk->sk_xprt->xpt_free(svsk);
>  }
> +EXPORT_SYMBOL_GPL(__svc_sock_put);

I see here that you are integrating the detach and free methods into 
"svc_sock_put".  It might make sense to reorder your patches so that 
this comes earlier in the series (or is integrated somehow with the 
patch that introduces detach and free).

>  static void
>  svc_sock_release(struct svc_rqst *rqstp)
> @@ -1109,7 +1108,7 @@ svc_tcp_accept(struct svc_sock *svsk)
>  					  struct svc_sock,
>  					  sk_list);
>  			set_bit(SK_CLOSE, &svsk->sk_flags);
> -			atomic_inc(&svsk->sk_inuse);
> +			svc_sock_get(svsk);
>  		}
>  		spin_unlock_bh(&serv->sv_lock);
>  
> @@ -1481,7 +1480,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
>  	spin_lock_bh(&pool->sp_lock);
>  	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
>  		rqstp->rq_sock = svsk;
> -		atomic_inc(&svsk->sk_inuse);
> +		svc_sock_get(svsk);
>  		rqstp->rq_reserved = serv->sv_max_mesg;
>  		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
>  	} else {
> @@ -1620,7 +1619,7 @@ svc_age_temp_sockets(unsigned long closu
>  			continue;
>  		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
>  			continue;
> -		atomic_inc(&svsk->sk_inuse);
> +		svc_sock_get(svsk);
>  		list_move(le, &to_be_aged);
>  		set_bit(SK_CLOSE, &svsk->sk_flags);
>  		set_bit(SK_DETACHED, &svsk->sk_flags);
> @@ -1868,7 +1867,7 @@ svc_delete_socket(struct svc_sock *svsk)
>  	 */
>  	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
>  		BUG_ON(atomic_read(&svsk->sk_inuse)<2);
> -		atomic_dec(&svsk->sk_inuse);
> +		svc_sock_put(svsk);
>  		if (test_bit(SK_TEMP, &svsk->sk_flags))
>  			serv->sv_tmpcnt--;
>  	}
> @@ -1883,7 +1882,7 @@ static void svc_close_socket(struct svc_
>  		/* someone else will have to effect the close */
>  		return;
>  
> -	atomic_inc(&svsk->sk_inuse);
> +	svc_sock_get(svsk);
>  	svc_delete_socket(svsk);
>  	clear_bit(SK_BUSY, &svsk->sk_flags);
>  	svc_sock_put(svsk);
> @@ -1976,7 +1975,7 @@ svc_defer(struct cache_req *req)
>  		dr->argslen = rqstp->rq_arg.len >> 2;
>  		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
>  	}
> -	atomic_inc(&rqstp->rq_sock->sk_inuse);
> +	svc_sock_get(rqstp->rq_sock);
>  	dr->svsk = rqstp->rq_sock;
>  
>  	dr->handle.revisit = svc_revisit;

--------------000005060804030506050606
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


--------------000005060804030506050606
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000005060804030506050606
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000005060804030506050606--
