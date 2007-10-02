From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 29/35] svc: Move common create logic to common code
Date: Tue, 2 Oct 2007 12:42:09 -0400
Message-ID: <BB17F85E-446E-4DBA-BD0D-8463FC605294@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192834.3250.88964.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IckzX-0006sS-9C
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:53:03 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ickpe-0002EK-QA
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:42:51 -0700
In-Reply-To: <20071001192834.3250.88964.stgit@dell3.ogc.int>
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

On Oct 1, 2007, at 3:28 PM, Tom Tucker wrote:
>
> Move the code that adds a transport instance to the sv_tempsocks and
> sv_permsocks lists out of the transport specific functions and into  
> core
> logic.
>
> The svc_addsock routine still manipulates sv_permsocks directly. This
> code may be removed when rpc.nfsd is modified to create transports
> by writing to the portlist file.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  net/sunrpc/svc_xprt.c |    7 +++++++
>  net/sunrpc/svcsock.c  |   38 +++++++++++++++++++-------------------
>  2 files changed, 26 insertions(+), 19 deletions(-)
>
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 2a27d5e..56cda03 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -144,6 +144,13 @@ int svc_create_xprt(struct svc_serv *ser
>  				if (IS_ERR(newxprt)) {
>  					module_put(xcl->xcl_owner);
>  					ret = PTR_ERR(newxprt);
> +				} else {
> +					clear_bit(XPT_TEMP,
> +						  &newxprt->xpt_flags);
> +					spin_lock_bh(&serv->sv_lock);
> +					list_add(&newxprt->xpt_list,
> +						 &serv->sv_permsocks);
> +					spin_unlock_bh(&serv->sv_lock);
>  				}
>  			}
>  			goto out;
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index d6f3c02..f1ea6f7 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -93,6 +93,7 @@ static int svc_deferred_recv(struct svc_
>  static struct cache_deferred_req *svc_defer(struct cache_req *req);
>  static struct svc_xprt *
>  svc_create_socket(struct svc_serv *, int, struct sockaddr *, int,  
> int);
> +static void svc_age_temp_xprts(unsigned long closure);
>
>  /* apparently the "standard" is that clients close
>   * idle connections after 5 minutes, servers after
> @@ -1604,6 +1605,18 @@ svc_recv(struct svc_rqst *rqstp, long ti
>  			 */
>  			__module_get(newxpt->xpt_class->xcl_owner);
>  			svc_check_conn_limits(xprt->xpt_server);
> +			spin_lock_bh(&serv->sv_lock);
> +			set_bit(XPT_TEMP, &newxpt->xpt_flags);
> +			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
> +			serv->sv_tmpcnt++;
> +			if (serv->sv_temptimer.function == NULL) {
> +				/* setup timer to age temp sockets */
> +				setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
> +					    (unsigned long)serv);
> +				mod_timer(&serv->sv_temptimer,
> +					  jiffies + svc_conn_age_period * HZ);
> +			}
> +			spin_unlock_bh(&serv->sv_lock);
>  		}
>  		svc_xprt_received(xprt);
>  	} else {
> @@ -1750,7 +1763,6 @@ static struct svc_sock *svc_setup_socket
>  	struct svc_sock	*svsk;
>  	struct sock	*inet;
>  	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
> -	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
>
>  	dprintk("svc: svc_setup_socket %p\n", sock);
>  	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
> @@ -1784,24 +1796,6 @@ static struct svc_sock *svc_setup_socket
>  	else
>  		svc_tcp_init(svsk, serv);
>
> -	spin_lock_bh(&serv->sv_lock);
> -	if (is_temporary) {
> -		set_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
> -		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_tempsocks);
> -		serv->sv_tmpcnt++;
> -		if (serv->sv_temptimer.function == NULL) {
> -			/* setup timer to age temp sockets */
> -			setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
> -					(unsigned long)serv);
> -			mod_timer(&serv->sv_temptimer,
> -					jiffies + svc_conn_age_period * HZ);
> -		}
> -	} else {
> -		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
> -		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
> -	}
> -	spin_unlock_bh(&serv->sv_lock);
> -
>  	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>  				svsk, svsk->sk_sk);
>
> @@ -1832,6 +1826,12 @@ int svc_addsock(struct svc_serv *serv,
>  			svc_xprt_received(&svsk->sk_xprt);
>  			err = 0;
>  		}
> +		if (so->sk->sk_protocol == IPPROTO_TCP)
> +			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);

One might wish that, even though this is in socket-transport-specific  
code, you didn't have to check the underlying socket's protocol  
setting here, but that this could be done in a TCP-specific function  
such as svc_tcp_init.

> +		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
> +		spin_lock_bh(&serv->sv_lock);
> +		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
> +		spin_unlock_bh(&serv->sv_lock);
>  	}
>  	if (err) {
>  		sockfd_put(so);

Chuck Lever
chuck.lever@oracle.com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
