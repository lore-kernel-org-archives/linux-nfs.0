From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG] [PATCH] CLOSE_WAIT sockets may remain forever
Date: Sat, 14 Jun 2003 01:09:49 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030614.010949.48529350.taka@valinux.co.jp>
References: <20030611.214512.123409801.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([210.128.90.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QrFV-0007M4-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 09:17:57 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20030611.214512.123409801.taka@valinux.co.jp>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I also realized that one more patch is needed.

> I found a bug that CLOSE_WAIT sockets may remain forever on an
> NFS server when NFS client is IRIX6.5 .
> IRIX6.5 try to connect the server twice. I guess the first trial is
> checking capability of the server and it closes the socket
> immediately without sending data.
> 
> In this case the Linux server can't close a newly established
> socket as it isn't accepted yet.
> There are no problems if it's a typical NFS client which
> sends data after establishing connection.

Potentially NFS clients might close the socket before it is accepted
by an NFS server. This may leaves CLOSE_WAIT sockets since there are
no chances to set a SK_CLOSE flag on it.

We should apply these patches or it might become a target of a DOS attack.

 e.g)
   attack_knfsd()
   {
        for(;;) {
            fd = socket(....);
	    connect(fd, ....);   //connect to the knfsd port.
	    close(fd);
        }
   }


Thank you,
Hirokazu Takahashi.


> --- svcsock.c.ORG	Wed Jun 11 20:28:15 2031
> +++ svcsock.c	Wed Jun 11 20:51:01 2031
> @@ -680,8 +680,17 @@ svc_tcp_listen_data_ready(struct sock *s
>  	dprintk("svc: socket %p TCP (listen) state change %d\n",
>  			sk, sk->state);
>  
> -	if  (sk->state != TCP_ESTABLISHED) {
> -		/* Aborted connection, SYN_RECV or whatever... */
> +	if  (sk->state != TCP_LISTEN) {
> +		/*
> +		 * This callback may called twice when a new connection
> +		 * is established as a child socket inherits everything
> +		 * from a parent LISTEN socket.
> +		 * 1) data_ready method of the parent socket will be called
> +		 *    when one of child sockets become ESTABLISHED.
> +		 * 2) data_ready method of the child socket may be called
> +		 *    when it receives data before the socket is accepted.
> +		 * In case of 2, we should ignore it silently.
> +		 */
>  		goto out;
>  	}
>  	if (!(svsk = (struct svc_sock *) sk->user_data)) {
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
> thread debugger on the planet. Designed with thread debugging features
> you've never dreamed of, try TotalView 6 free at www.etnus.com.
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


--- svcsock.c.ORG2	Fri Jun 13 11:39:22 2031
+++ svcsock.c	Sat Jun 14 00:10:31 2031
@@ -1068,6 +1068,8 @@ svc_tcp_init(struct svc_sock *svsk)
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 		set_bit(SK_DATA, &svsk->sk_flags);
+		if (sk->state != TCP_ESTABLISHED) 
+			set_bit(SK_CLOSE, &svsk->sk_flags);
 	}
 }
 


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
