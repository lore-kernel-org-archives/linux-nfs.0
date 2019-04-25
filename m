Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8493C43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9728206BA
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729064AbfDYOEd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:04:33 -0400
Received: from fieldses.org ([173.255.197.46]:50906 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727541AbfDYOEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:04:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id DAEEE201A; Thu, 25 Apr 2019 10:04:22 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        jlayton@redhat.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/10] rpc: replace rpc_filelist by tree_descr
Date:   Thu, 25 Apr 2019 10:04:16 -0400
Message-Id: <1556201060-7947-7-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Use a common structure instead of defining our own here.

The only difference is using an int instead of umode_t for the mode
field; I haven't tried to figure out why tree_descr uses int.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/rpc_pipe.c | 37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 69663681bf9d..9af9f4c8fa1e 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -460,15 +460,6 @@ static const struct file_operations rpc_info_operations = {
 };
 
 
-/*
- * Description of fs contents.
- */
-struct rpc_filelist {
-	const char *name;
-	const struct file_operations *i_fop;
-	umode_t mode;
-};
-
 static struct inode *
 rpc_get_inode(struct super_block *sb, umode_t mode)
 {
@@ -648,7 +639,7 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
  * FIXME: This probably has races.
  */
 static void __rpc_depopulate(struct dentry *parent,
-			     const struct rpc_filelist *files,
+			     const struct tree_descr *files,
 			     int start, int eof)
 {
 	struct inode *dir = d_inode(parent);
@@ -680,7 +671,7 @@ static void __rpc_depopulate(struct dentry *parent,
 }
 
 static void rpc_depopulate(struct dentry *parent,
-			   const struct rpc_filelist *files,
+			   const struct tree_descr *files,
 			   int start, int eof)
 {
 	struct inode *dir = d_inode(parent);
@@ -691,7 +682,7 @@ static void rpc_depopulate(struct dentry *parent,
 }
 
 static int rpc_populate(struct dentry *parent,
-			const struct rpc_filelist *files,
+			const struct tree_descr *files,
 			int start, int eof,
 			void *private)
 {
@@ -711,7 +702,7 @@ static int rpc_populate(struct dentry *parent,
 			case S_IFREG:
 				err = __rpc_create(dir, dentry,
 						files[i].mode,
-						files[i].i_fop,
+						files[i].ops,
 						private);
 				break;
 			case S_IFDIR:
@@ -1015,10 +1006,10 @@ enum {
 	RPCAUTH_EOF
 };
 
-static const struct rpc_filelist authfiles[] = {
+static const struct tree_descr authfiles[] = {
 	[RPCAUTH_info] = {
 		.name = "info",
-		.i_fop = &rpc_info_operations,
+		.ops = &rpc_info_operations,
 		.mode = S_IFREG | 0400,
 	},
 };
@@ -1076,20 +1067,20 @@ int rpc_remove_client_dir(struct rpc_clnt *rpc_client)
 	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
-static const struct rpc_filelist cache_pipefs_files[3] = {
+static const struct tree_descr cache_pipefs_files[3] = {
 	[0] = {
 		.name = "channel",
-		.i_fop = &cache_file_operations_pipefs,
+		.ops = &cache_file_operations_pipefs,
 		.mode = S_IFREG | 0600,
 	},
 	[1] = {
 		.name = "content",
-		.i_fop = &content_file_operations_pipefs,
+		.ops = &content_file_operations_pipefs,
 		.mode = S_IFREG | 0400,
 	},
 	[2] = {
 		.name = "flush",
-		.i_fop = &cache_flush_operations_pipefs,
+		.ops = &cache_flush_operations_pipefs,
 		.mode = S_IFREG | 0600,
 	},
 };
@@ -1145,7 +1136,7 @@ enum {
 	RPCAUTH_RootEOF
 };
 
-static const struct rpc_filelist files[] = {
+static const struct tree_descr files[] = {
 	[RPCAUTH_lockd] = {
 		.name = "lockd",
 		.mode = S_IFDIR | 0555,
@@ -1242,7 +1233,7 @@ void rpc_put_sb_net(const struct net *net)
 }
 EXPORT_SYMBOL_GPL(rpc_put_sb_net);
 
-static const struct rpc_filelist gssd_dummy_clnt_dir[] = {
+static const struct tree_descr gssd_dummy_clnt_dir[] = {
 	[0] = {
 		.name = "clntXX",
 		.mode = S_IFDIR | 0555,
@@ -1277,10 +1268,10 @@ rpc_dummy_info_show(struct seq_file *m, void *v)
 }
 DEFINE_SHOW_ATTRIBUTE(rpc_dummy_info);
 
-static const struct rpc_filelist gssd_dummy_info_file[] = {
+static const struct tree_descr gssd_dummy_info_file[] = {
 	[0] = {
 		.name = "info",
-		.i_fop = &rpc_dummy_info_fops,
+		.ops = &rpc_dummy_info_fops,
 		.mode = S_IFREG | 0400,
 	},
 };
-- 
2.20.1

