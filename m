From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Wed, 16 May 2007 17:10:53 -0400
Message-ID: <20070516211053.GE18927@fieldses.org>
References: <20070516192211.GJ9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoQlr-0002Se-Br
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 14:11:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoQlt-0005kr-Fb
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 14:10:58 -0700
In-Reply-To: <20070516192211.GJ9626@sgi.com>
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

On Thu, May 17, 2007 at 05:22:11AM +1000, Greg Banks wrote:
> @@ -268,21 +252,15 @@ svc_sock_enqueue(struct svc_sock *svsk)
>  	BUG_ON(svsk->sk_pool != NULL);
>  	svsk->sk_pool = pool;
>  
> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
> -	     > svc_sock_wspace(svsk))
> +	if (svsk->sk_ops->sko_has_wspace
>  	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
>  	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
> -		/* Don't enqueue while not enough space for reply */
> -		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
> -			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
> -			svc_sock_wspace(svsk));
> -		svsk->sk_pool = NULL;
> -		clear_bit(SK_BUSY, &svsk->sk_flags);
> -		goto out_unlock;
> +		if (!svsk->sk_ops->sko_has_wspace(svsk)) {
> +			svsk->sk_pool = NULL;
> +			clear_bit(SK_BUSY, &svsk->sk_flags);
> +			goto out_unlock;
> +		}
>  	}
> -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -
>  
>  	if (!list_empty(&pool->sp_threads)) {
>  		rqstp = list_entry(pool->sp_threads.next,
> @@ -904,13 +882,42 @@ svc_tcpip_prepare_reply(struct svc_rqst 
>  	return 0;
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
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	if (required*2 > wspace) {
> +		/* Don't enqueue while not enough space for reply */
> +		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
> +			svsk->sk_sk, required, wspace);
> +		return 0;
> +	}
> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}

So, this is just my ignorance--why do the set and clear of SOCK_NOSPACE
need to be ordered in the way they are?  (Why not just set once inside
the if clause?)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
