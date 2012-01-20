Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3888 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745Ab2ATUM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 15:12:26 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] SUNRPC: constify rpc_program->name
Date: Fri, 20 Jan 2012 15:12:17 -0500
Message-Id: <1327090338-6496-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1327090338-6496-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1327090338-6496-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/clnt.c           |    5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db6970c..4a46ffd 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -70,12 +70,12 @@ struct rpc_clnt {
  */
 #define RPC_MAXVERSION		4
 struct rpc_program {
-	char *			name;		/* protocol name */
+	const char *		name;		/* protocol name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
 	struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
-	char *			pipe_dir_name;	/* path to rpc_pipefs dir */
+	const char *		pipe_dir_name;	/* path to rpc_pipefs dir */
 };
 
 struct rpc_version {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e9b22e8..1b2317f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -118,7 +118,8 @@ static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 }
 
 static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
-				    struct rpc_clnt *clnt, char *dir_name)
+				    struct rpc_clnt *clnt,
+				    const char *dir_name)
 {
 	static uint32_t clntid;
 	char name[15];
@@ -151,7 +152,7 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 }
 
 static int
-rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
+rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name)
 {
 	struct super_block *pipefs_sb;
 	struct dentry *dentry;
-- 
1.7.7.5

