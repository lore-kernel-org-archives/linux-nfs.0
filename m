From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] Flow control problems(2)
Date: Mon, 19 May 2003 22:23:46 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030519.222346.88467838.taka@valinux.co.jp>
References: <20030519.222154.102583212.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([210.128.90.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19HkhJ-0002W7-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 06:29:01 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20030519.222154.102583212.taka@valinux.co.jp>
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

> There are some flow control problems when we use NFS over TCP.
> 
> svc_sock_enqueue() checkes whether there is enough space in a
> sending buffer using sock_wspace(). But in case of TCP it won't
> work correctly.
> 
> We should use tcp_wspace() instead of sock_wspace().

If there isn't enough space in the socket, svc_sock_enqueue()
won't do anythning. Then some buffers depending on the socket
will be released after a brief interval. But TCP/IP stack won't
notify about it as the socket doesn't have a SOCK_NOSPACE flag.

We should set a SOCK_NOSPACE flag on the socket while there isn't
enough space in it.


Thank you,
Hirokazu Takahashi.



--- net/sunrpc/svcsock.c.ORG	Fri May 16 11:43:46 2031
+++ net/sunrpc/svcsock.c	Fri May 16 11:45:27 2031
@@ -166,6 +166,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		goto out_unlock;
 	}
 
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 	if (((svsk->sk_reserved + serv->sv_bufsz)*2
 	     > svc_sock_wspace(svsk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
@@ -176,6 +177,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 			svc_sock_wspace(svsk));
 		goto out_unlock;
 	}
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 
 	/* Mark socket as busy. It will remain in this state until the
 	 * server has processed all pending data and put the socket back


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
