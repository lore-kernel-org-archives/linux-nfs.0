From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/21] SUNRPC: create stubs for xprtsock init and
	cleanup
Date: Thu, 16 Nov 2006 15:04:39 -0500
Message-ID: <20061116200439.32549.42062.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1e-0006s9-HE
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:58 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1d-0000XT-6O
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:59 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

Over time we will want to add some specific init and cleanup logic for the
xprtsock implementation.  Add stub routines for initialization and exit
processing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/sunrpc_syms.c |    4 ++++
 net/sunrpc/xprtsock.c    |   18 ++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 192dff5..87f3f13 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -139,6 +139,8 @@ #endif
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 extern struct cache_detail ip_map_cache;
+extern int init_socket_xprt(void);
+extern void cleanup_socket_xprt(void);
 
 static int __init
 init_sunrpc(void)
@@ -156,6 +158,7 @@ #ifdef CONFIG_PROC_FS
 	rpc_proc_init();
 #endif
 	cache_register(&ip_map_cache);
+	init_socket_xprt();
 out:
 	return err;
 }
@@ -163,6 +166,7 @@ out:
 static void __exit
 cleanup_sunrpc(void)
 {
+	cleanup_socket_xprt();
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
 	if (cache_unregister(&ip_map_cache))
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 295bbcf..fd8e39e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1512,3 +1512,21 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 
 	return xprt;
 }
+
+/**
+ * init_socket_xprt - stub
+ *
+ */
+int init_socket_xprt(void)
+{
+	return 0;
+}
+
+/**
+ * cleanup_socket_xprt - stub
+ *
+ */
+void cleanup_socket_xprt(void)
+{
+	return;
+}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
