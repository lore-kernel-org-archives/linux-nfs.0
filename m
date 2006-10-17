From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] SUNRPC: move saved socket callback functions to
	a private data structure
Date: Tue, 17 Oct 2006 14:44:42 -0400
Message-ID: <20061017184441.25704.33905.stgit@schiele.dsl.sfldmi.ameritech.net>
References: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZtvu-0000KM-7z
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:59 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZtvs-0007DD-16
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:59 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Move the three fields for saving socket callback functions out of the
rpc_xprt structure and into a private data structure maintained in
net/sunrpc/xprtsock.c.

Test plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    6 ------
 net/sunrpc/xprtsock.c       |   25 ++++++++++++++++---------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 21beb56..17f3227 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -17,8 +17,6 @@ #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
 
-#include <net/sock.h>
-
 extern unsigned int xprt_udp_slot_table_entries;
 extern unsigned int xprt_tcp_slot_table_entries;
 
@@ -191,10 +189,6 @@ struct rpc_xprt {
 					bklog_u;	/* backlog queue utilization */
 	} stat;
 
-	void			(*old_data_ready)(struct sock *, int);
-	void			(*old_state_change)(struct sock *);
-	void			(*old_write_space)(struct sock *);
-
 	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c0e23e3..5eeccc4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -157,6 +157,13 @@ struct xs_xprt {
 	 */
 	size_t			rcvsize,
 				sndsize;
+
+	/*
+	 * Saved socket callback addresses
+	 */
+	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_state_change)(struct sock *);
+	void			(*old_write_space)(struct sock *);
 };
 
 /*
@@ -554,9 +561,9 @@ static void xs_close(struct rpc_xprt *xp
 	private->sock = NULL;
 
 	sk->sk_user_data = NULL;
-	sk->sk_data_ready = xprt->old_data_ready;
-	sk->sk_state_change = xprt->old_state_change;
-	sk->sk_write_space = xprt->old_write_space;
+	sk->sk_data_ready = private->old_data_ready;
+	sk->sk_state_change = private->old_state_change;
+	sk->sk_write_space = private->old_write_space;
 	write_unlock_bh(&sk->sk_callback_lock);
 
 	sk->sk_no_check = 0;
@@ -1155,9 +1162,9 @@ static void xs_udp_connect_worker(void *
 		write_lock_bh(&sk->sk_callback_lock);
 
 		sk->sk_user_data = xprt;
-		xprt->old_data_ready = sk->sk_data_ready;
-		xprt->old_state_change = sk->sk_state_change;
-		xprt->old_write_space = sk->sk_write_space;
+		private->old_data_ready = sk->sk_data_ready;
+		private->old_state_change = sk->sk_state_change;
+		private->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_no_check = UDP_CSUM_NORCV;
@@ -1242,9 +1249,9 @@ static void xs_tcp_connect_worker(void *
 		write_lock_bh(&sk->sk_callback_lock);
 
 		sk->sk_user_data = xprt;
-		xprt->old_data_ready = sk->sk_data_ready;
-		xprt->old_state_change = sk->sk_state_change;
-		xprt->old_write_space = sk->sk_write_space;
+		private->old_data_ready = sk->sk_data_ready;
+		private->old_state_change = sk->sk_state_change;
+		private->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
