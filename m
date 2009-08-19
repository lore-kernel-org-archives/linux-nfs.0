From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/32] SUNRPC: rpc_pipefs cleanup
Date: Wed, 19 Aug 2009 19:38:37 -0400
Message-ID: <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754127AbZHSXlA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:00 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YF028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:48 -0700 (PDT)
In-Reply-To: <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the files[] array closer to rpc_fill_super()

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   80 ++++++++++++++++++++++++------------------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e5f37de..2a4e6eb 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -398,19 +398,6 @@ static const struct file_operations rpc_info_operations = {
 
 
 /*
- * We have a single directory with 1 node in it.
- */
-enum {
-	RPCAUTH_lockd,
-	RPCAUTH_mount,
-	RPCAUTH_nfs,
-	RPCAUTH_portmap,
-	RPCAUTH_statd,
-	RPCAUTH_nfsd4_cb,
-	RPCAUTH_RootEOF
-};
-
-/*
  * Description of fs contents.
  */
 struct rpc_filelist {
@@ -419,33 +406,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-static const struct rpc_filelist files[] = {
-	[RPCAUTH_lockd] = {
-		.name = "lockd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_mount] = {
-		.name = "mount",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_nfs] = {
-		.name = "nfs",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_portmap] = {
-		.name = "portmap",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_statd] = {
-		.name = "statd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_nfsd4_cb] = {
-		.name = "nfsd4_cb",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-};
-
 enum {
 	RPCAUTH_info,
 	RPCAUTH_EOF
@@ -965,6 +925,46 @@ static struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+/*
+ * We have a single directory with 1 node in it.
+ */
+enum {
+	RPCAUTH_lockd,
+	RPCAUTH_mount,
+	RPCAUTH_nfs,
+	RPCAUTH_portmap,
+	RPCAUTH_statd,
+	RPCAUTH_nfsd4_cb,
+	RPCAUTH_RootEOF
+};
+
+static const struct rpc_filelist files[] = {
+	[RPCAUTH_lockd] = {
+		.name = "lockd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	[RPCAUTH_mount] = {
+		.name = "mount",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	[RPCAUTH_nfs] = {
+		.name = "nfs",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	[RPCAUTH_portmap] = {
+		.name = "portmap",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	[RPCAUTH_statd] = {
+		.name = "statd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	[RPCAUTH_nfsd4_cb] = {
+		.name = "nfsd4_cb",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+};
+
 static int
 rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
-- 
1.6.0.4
