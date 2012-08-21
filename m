Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758022Ab2HUR3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 13:29:04 -0400
Date: Tue, 21 Aug 2012 13:29:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: remove unused listener-removal interfaces
Message-ID: <20120821172902.GA15958@fieldses.org>
References: <20120815234259.GB28054@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120815234259.GB28054@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 15, 2012 at 07:43:00PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> You can use nfsd/portlist to give nfsd additional sockets to listen on.
> In theory you can also remove listening sockets this way.  But nobody's
> ever done that as far as I can tell.
> 
> Also this was partially broken in 2.6.25, by
> a217813f9067b785241cb7f31956e51d2071703a "knfsd: Support adding
> transports by writing portlist file".
> 
> (Note that we decide whether to take the "delfd" case by checking for a
> digit--but what's actually expected in that case is something made by
> svc_one_sock_name(), which won't begin with a digit.)
> 
> So, let's just rip out this stuff.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfsctl.c               |   78 ----------------------------------------
>  include/linux/sunrpc/svcsock.h |    3 --
>  net/sunrpc/svcsock.c           |   51 --------------------------
>  3 files changed, 132 deletions(-)
> 
> OK, maybe this is somewhat of a troll patch--but I don't actually know
> how to fix this interface, so: do we really have a use for it?

Neil, was the the "-portname" thing originally yours?  Did you have a
use case in mind?

--b.

> 
> --b.
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index e41a08ff..dab350d 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -683,25 +683,6 @@ static ssize_t __write_ports_addfd(char *buf)
>  }
>  
>  /*
> - * A '-' followed by the 'name' of a socket means we close the socket.
> - */
> -static ssize_t __write_ports_delfd(char *buf)
> -{
> -	char *toclose;
> -	int len = 0;
> -
> -	toclose = kstrdup(buf + 1, GFP_KERNEL);
> -	if (toclose == NULL)
> -		return -ENOMEM;
> -
> -	if (nfsd_serv != NULL)
> -		len = svc_sock_names(nfsd_serv, buf,
> -					SIMPLE_TRANSACTION_LIMIT, toclose);
> -	kfree(toclose);
> -	return len;
> -}
> -
> -/*
>   * A transport listener is added by writing it's transport name and
>   * a port number.
>   */
> @@ -746,31 +727,6 @@ out_err:
>  	return err;
>  }
>  
> -/*
> - * A transport listener is removed by writing a "-", it's transport
> - * name, and it's port number.
> - */
> -static ssize_t __write_ports_delxprt(char *buf)
> -{
> -	struct svc_xprt *xprt;
> -	char transport[16];
> -	int port;
> -
> -	if (sscanf(&buf[1], "%15s %4u", transport, &port) != 2)
> -		return -EINVAL;
> -
> -	if (port < 1 || port > USHRT_MAX || nfsd_serv == NULL)
> -		return -EINVAL;
> -
> -	xprt = svc_find_xprt(nfsd_serv, transport, &init_net, AF_UNSPEC, port);
> -	if (xprt == NULL)
> -		return -ENOTCONN;
> -
> -	svc_close_xprt(xprt);
> -	svc_xprt_put(xprt);
> -	return 0;
> -}
> -
>  static ssize_t __write_ports(struct file *file, char *buf, size_t size)
>  {
>  	if (size == 0)
> @@ -779,15 +735,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
>  	if (isdigit(buf[0]))
>  		return __write_ports_addfd(buf);
>  
> -	if (buf[0] == '-' && isdigit(buf[1]))
> -		return __write_ports_delfd(buf);
> -
>  	if (isalpha(buf[0]))
>  		return __write_ports_addxprt(buf);
>  
> -	if (buf[0] == '-' && isalpha(buf[1]))
> -		return __write_ports_delxprt(buf);
> -
>  	return -EINVAL;
>  }
>  
> @@ -825,21 +775,6 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
>   * OR
>   *
>   * Input:
> - *			buf:		C string containing a "-" followed
> - *					by an integer value representing a
> - *					previously passed in socket file
> - *					descriptor
> - *			size:		non-zero length of C string in @buf
> - * Output:
> - *	On success:	NFS service no longer listens on that socket;
> - *			passed-in buffer filled with a '\n'-terminated C
> - *			string containing a unique name of the listener;
> - *			return code is the size in bytes of the string
> - *	On error:	return code is a negative errno value
> - *
> - * OR
> - *
> - * Input:
>   *			buf:		C string containing a transport
>   *					name and an unsigned integer value
>   *					representing the port to listen on,
> @@ -848,19 +783,6 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
>   * Output:
>   *	On success:	returns zero; NFS service is started
>   *	On error:	return code is a negative errno value
> - *
> - * OR
> - *
> - * Input:
> - *			buf:		C string containing a "-" followed
> - *					by a transport name and an unsigned
> - *					integer value representing the port
> - *					to listen on, separated by whitespace
> - *			size:		non-zero length of C string in @buf
> - * Output:
> - *	On success:	returns zero; NFS service no longer listens
> - *			on that transport
> - *	On error:	return code is a negative errno value
>   */
>  static ssize_t write_ports(struct file *file, char *buf, size_t size)
>  {
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index cb4ac69..92ad02f 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -39,9 +39,6 @@ int		svc_recv(struct svc_rqst *, long);
>  int		svc_send(struct svc_rqst *);
>  void		svc_drop(struct svc_rqst *);
>  void		svc_sock_update_bufs(struct svc_serv *serv);
> -int		svc_sock_names(struct svc_serv *serv, char *buf,
> -					const size_t buflen,
> -					const char *toclose);
>  int		svc_addsock(struct svc_serv *serv, const int fd,
>  					char *name_return, const size_t len);
>  void		svc_init_xprt_sock(void);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index c7a7b14..42fedbd 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -305,57 +305,6 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
>  	return len;
>  }
>  
> -/**
> - * svc_sock_names - construct a list of listener names in a string
> - * @serv: pointer to RPC service
> - * @buf: pointer to a buffer to fill in with socket names
> - * @buflen: size of the buffer to be filled
> - * @toclose: pointer to '\0'-terminated C string containing the name
> - *		of a listener to be closed
> - *
> - * Fills in @buf with a '\n'-separated list of names of listener
> - * sockets.  If @toclose is not NULL, the socket named by @toclose
> - * is closed, and is not included in the output list.
> - *
> - * Returns positive length of the socket name string, or a negative
> - * errno value on error.
> - */
> -int svc_sock_names(struct svc_serv *serv, char *buf, const size_t buflen,
> -		   const char *toclose)
> -{
> -	struct svc_sock *svsk, *closesk = NULL;
> -	int len = 0;
> -
> -	if (!serv)
> -		return 0;
> -
> -	spin_lock_bh(&serv->sv_lock);
> -	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list) {
> -		int onelen = svc_one_sock_name(svsk, buf + len, buflen - len);
> -		if (onelen < 0) {
> -			len = onelen;
> -			break;
> -		}
> -		if (toclose && strcmp(toclose, buf + len) == 0) {
> -			closesk = svsk;
> -			svc_xprt_get(&closesk->sk_xprt);
> -		} else
> -			len += onelen;
> -	}
> -	spin_unlock_bh(&serv->sv_lock);
> -
> -	if (closesk) {
> -		/* Should unregister with portmap, but you cannot
> -		 * unregister just one protocol...
> -		 */
> -		svc_close_xprt(&closesk->sk_xprt);
> -		svc_xprt_put(&closesk->sk_xprt);
> -	} else if (toclose)
> -		return -ENOENT;
> -	return len;
> -}
> -EXPORT_SYMBOL_GPL(svc_sock_names);
> -
>  /*
>   * Check input queue length
>   */
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
