From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] increase socket buffer for RPC over UDP
Date: Fri, 26 Jul 2002 22:10:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <14051.7508182258$1027714628@news.gmane.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YBQX-0008JT-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 13:11:05 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Make RPC over UDP use a socket buffer size that is large enough to fit
all the messages. Congestion control is in any case handled by the Van
Jacobson algoritm, and we need to work around a bug in
ip_build_xmit_slow() w.r.t. fragmentation when there is insufficient
buffer memory to fit the entire message.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.28-rpc_wspace/fs/nfs/inode.c linux-2.5.28-rpc_buf/fs/nfs/inode.c
--- linux-2.5.28-rpc_wspace/fs/nfs/inode.c	Sun Jul  7 19:41:55 2002
+++ linux-2.5.28-rpc_buf/fs/nfs/inode.c	Fri Jul 26 00:05:29 2002
@@ -425,7 +425,8 @@
 		goto failure_kill_reqlist;
 	}
 
-	/* We're airborne */
+	/* We're airborne Set socket buffersize */
+	rpc_setbufsize(clnt, server->wsize + 100, server->rsize + 100);
 
 	/* Check whether to start the lockd process */
 	if (!(server->flags & NFS_MOUNT_NONLM))
diff -u --recursive --new-file linux-2.5.28-rpc_wspace/include/linux/sunrpc/clnt.h linux-2.5.28-rpc_buf/include/linux/sunrpc/clnt.h
--- linux-2.5.28-rpc_wspace/include/linux/sunrpc/clnt.h	Tue Jul 16 13:44:28 2002
+++ linux-2.5.28-rpc_buf/include/linux/sunrpc/clnt.h	Fri Jul 26 00:05:29 2002
@@ -127,6 +127,7 @@
 void		rpc_restart_call(struct rpc_task *);
 void		rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset);
 void		rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset);
+void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 
 static __inline__
 int rpc_call(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp, int flags)
diff -u --recursive --new-file linux-2.5.28-rpc_wspace/include/linux/sunrpc/xprt.h linux-2.5.28-rpc_buf/include/linux/sunrpc/xprt.h
--- linux-2.5.28-rpc_wspace/include/linux/sunrpc/xprt.h	Fri Jul 26 00:01:06 2002
+++ linux-2.5.28-rpc_buf/include/linux/sunrpc/xprt.h	Fri Jul 26 00:05:29 2002
@@ -122,6 +122,9 @@
 	unsigned long		cong;		/* current congestion */
 	unsigned long		cwnd;		/* congestion window */
 
+	unsigned int		rcvsize,	/* socket receive buffer size */
+				sndsize;	/* socket send buffer size */
+
 	struct rpc_wait_queue	sending;	/* requests waiting to send */
 	struct rpc_wait_queue	resend;		/* requests waiting to resend */
 	struct rpc_wait_queue	pending;	/* requests in flight */
@@ -177,6 +180,7 @@
 void			xprt_release(struct rpc_task *);
 void			xprt_reconnect(struct rpc_task *);
 int			xprt_clear_backlog(struct rpc_xprt *);
+void			xprt_sock_setbufsize(struct rpc_xprt *);
 
 #define XPRT_CONNECT	0
 
diff -u --recursive --new-file linux-2.5.28-rpc_wspace/net/sunrpc/clnt.c linux-2.5.28-rpc_buf/net/sunrpc/clnt.c
--- linux-2.5.28-rpc_wspace/net/sunrpc/clnt.c	Thu Jul 18 18:55:49 2002
+++ linux-2.5.28-rpc_buf/net/sunrpc/clnt.c	Fri Jul 26 00:05:29 2002
@@ -335,6 +335,20 @@
 		rpcproc_count(task->tk_client, task->tk_msg.rpc_proc)++;
 }
 
+void
+rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
+{
+	struct rpc_xprt *xprt = clnt->cl_xprt;
+
+	xprt->sndsize = 0;
+	if (sndsize)
+		xprt->sndsize = sndsize + RPC_SLACK_SPACE;
+	xprt->rcvsize = 0;
+	if (rcvsize)
+		xprt->rcvsize = rcvsize + RPC_SLACK_SPACE;
+	xprt_sock_setbufsize(xprt);
+}
+
 /*
  * Restart an (async) RPC call. Usually called from within the
  * exit handler.
diff -u --recursive --new-file linux-2.5.28-rpc_wspace/net/sunrpc/sunrpc_syms.c linux-2.5.28-rpc_buf/net/sunrpc/sunrpc_syms.c
--- linux-2.5.28-rpc_wspace/net/sunrpc/sunrpc_syms.c	Sat May 25 20:48:18 2002
+++ linux-2.5.28-rpc_buf/net/sunrpc/sunrpc_syms.c	Fri Jul 26 00:05:29 2002
@@ -50,6 +50,7 @@
 EXPORT_SYMBOL(rpc_clnt_sigunmask);
 EXPORT_SYMBOL(rpc_delay);
 EXPORT_SYMBOL(rpc_restart_call);
+EXPORT_SYMBOL(rpc_setbufsize);
 
 /* Client transport */
 EXPORT_SYMBOL(xprt_create_proto);
diff -u --recursive --new-file linux-2.5.28-rpc_wspace/net/sunrpc/xprt.c linux-2.5.28-rpc_buf/net/sunrpc/xprt.c
--- linux-2.5.28-rpc_wspace/net/sunrpc/xprt.c	Fri Jul 26 00:01:06 2002
+++ linux-2.5.28-rpc_buf/net/sunrpc/xprt.c	Fri Jul 26 00:05:29 2002
@@ -1421,6 +1421,27 @@
 }
 
 /*
+ * Set socket buffer length
+ */
+void
+xprt_sock_setbufsize(struct rpc_xprt *xprt)
+{
+	struct sock *sk = xprt->inet;
+
+	if (xprt->stream)
+		return;
+	if (xprt->rcvsize) {
+		sk->userlocks |= SOCK_RCVBUF_LOCK;
+		sk->rcvbuf = xprt->rcvsize * RPC_MAXCONG * 2;
+	}
+	if (xprt->sndsize) {
+		sk->userlocks |= SOCK_SNDBUF_LOCK;
+		sk->sndbuf = xprt->sndsize * RPC_MAXCONG * 2;
+		sk->write_space(sk);
+	}
+}
+
+/*
  * Create a client socket given the protocol and peer address.
  */
 static struct socket *


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
