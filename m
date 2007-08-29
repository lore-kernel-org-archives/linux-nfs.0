From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 02/20] svc: xpt_detach and xpt_free
Date: Wed, 29 Aug 2007 13:05:48 -0400
Message-ID: <46D5A76C.9030901@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162325.15224.71015.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010405090001030006030601"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQQzr-0006Yb-BY
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:06:27 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQQzv-0007HT-8C
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:06:31 -0700
In-Reply-To: <20070820162325.15224.71015.stgit@dell3.ogc.int>
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
--------------010405090001030006030601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Tom-

Tom Tucker wrote:
> Add transport switch functions to ensure that no additional receive 
> ready events will be delivered by the transport (xpt_detach), 
> and another to free memory associated with the transport (xpt_free).
> Change svc_delete_socket() and svc_sock_put() to use the new
> transport functions.

Can you explain why these exist as separate functions?  I'm wondering if 
there is an opportunity here to make the server architecture simpler 
here rather than merely mimicking the existing design.

> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |   12 ++++++++++
>  net/sunrpc/svcsock.c           |   50 +++++++++++++++++++++++++++++++++-------
>  2 files changed, 53 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 4792ed6..27c5b1f 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -15,6 +15,18 @@ struct svc_xprt {
>  	const char		*xpt_name;
>  	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
>  	int			(*xpt_sendto)(struct svc_rqst *rqstp);
> +	/*
> +	 * Detach the svc_sock from it's socket, so that the
> +	 * svc_sock will not be enqueued any more.  This is
> +	 * the first stage in the destruction of a svc_sock.
> +	 */
> +	void			(*xpt_detach)(struct svc_sock *);
> +	/*
> +	 * Release all network-level resources held by the svc_sock,
> +	 * and the svc_sock itself.  This is the final stage in the
> +	 * destruction of a svc_sock.
> +	 */
> +	void			(*xpt_free)(struct svc_sock *);
>  };

I generally prefer that this kind of documentation should appear in a 
separate document or a larger block comment outside the structure 
definition, but that's just MO.

Also, these functions are supposed to be generic -- should they take an 
svc_sock * or something more abstract?

I'm not sure I like the names "detach" and "free", but again that's just 
my personal taste.  The client side uses "close" and "destroy", and I 
lean towards making the client and server consistent with each other.

>  /*
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 789d94a..4956c88 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -84,6 +84,8 @@ static void		svc_udp_data_ready(struct s
>  static int		svc_udp_recvfrom(struct svc_rqst *);
>  static int		svc_udp_sendto(struct svc_rqst *);
>  static void		svc_close_socket(struct svc_sock *svsk);
> +static void		svc_sock_detach(struct svc_sock *);
> +static void		svc_sock_free(struct svc_sock *);
>  
>  static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
>  static int svc_deferred_recv(struct svc_rqst *rqstp);
> @@ -378,14 +380,9 @@ svc_sock_put(struct svc_sock *svsk)
>  	if (atomic_dec_and_test(&svsk->sk_inuse)) {
>  		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
>  
> -		dprintk("svc: releasing dead socket\n");
> -		if (svsk->sk_sock->file)
> -			sockfd_put(svsk->sk_sock);
> -		else
> -			sock_release(svsk->sk_sock);
>  		if (svsk->sk_info_authunix != NULL)
>  			svcauth_unix_info_release(svsk->sk_info_authunix);
> -		kfree(svsk);
> +    	    	svsk->sk_xprt->xpt_free(svsk);
>  	}
>  }

Why wouldn't xpt_free also do the auth-info release?

> @@ -889,6 +886,8 @@ static const struct svc_xprt svc_udp_xpr
>  	.xpt_name = "udp",
>  	.xpt_recvfrom = svc_udp_recvfrom,
>  	.xpt_sendto = svc_udp_sendto,
> +	.xpt_detach = svc_sock_detach,
> +	.xpt_free = svc_sock_free,
>  };
>  
>  static void
> @@ -1331,6 +1330,8 @@ static const struct svc_xprt svc_tcp_xpr
>  	.xpt_name = "tcp",
>  	.xpt_recvfrom = svc_tcp_recvfrom,
>  	.xpt_sendto = svc_tcp_sendto,
> +	.xpt_detach = svc_sock_detach,
> +	.xpt_free = svc_sock_free,
>  };
>  
>  static void
> @@ -1770,6 +1771,38 @@ bummer:
>  }
>  
>  /*
> + * Detach the svc_sock from the socket so that no
> + * more callbacks occur.
> + */
> +static void
> +svc_sock_detach(struct svc_sock *svsk)
> +{
> +	struct sock *sk = svsk->sk_sk;
> +
> +	dprintk("svc: svc_sock_detach(%p)\n", svsk);
> +
> +	/* put back the old socket callbacks */
> +	sk->sk_state_change = svsk->sk_ostate;
> +	sk->sk_data_ready = svsk->sk_odata;
> +	sk->sk_write_space = svsk->sk_owspace;
> +}
> +
> +/*
> + * Free the svc_sock's socket resources and the svc_sock itself.
> + */
> +static void
> +svc_sock_free(struct svc_sock *svsk)
> +{
> +	dprintk("svc: svc_sock_free(%p)\n", svsk);
> +
> +	if (svsk->sk_sock->file)
> +		sockfd_put(svsk->sk_sock);
> +	else
> +		sock_release(svsk->sk_sock);
> +	kfree(svsk);
> +}
> +
> +/*
>   * Remove a dead socket
>   */
>  static void
> @@ -1783,9 +1816,8 @@ svc_delete_socket(struct svc_sock *svsk)
>  	serv = svsk->sk_server;
>  	sk = svsk->sk_sk;
>  
> -	sk->sk_state_change = svsk->sk_ostate;
> -	sk->sk_data_ready = svsk->sk_odata;
> -	sk->sk_write_space = svsk->sk_owspace;
> +	if (svsk->sk_xprt->xpt_detach)
> +		svsk->sk_xprt->xpt_detach(svsk);
>  
>  	spin_lock_bh(&serv->sv_lock);

--------------010405090001030006030601
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


--------------010405090001030006030601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010405090001030006030601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010405090001030006030601--
