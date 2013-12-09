Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:51212 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932572Ab3LIOiJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 09:38:09 -0500
Received: by mail-qc0-f175.google.com with SMTP id e9so2797047qcy.34
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 06:38:07 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trondmy@gmail.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] rpc_pipe: fix cleanup of dummy gssd directory when notification fails
Date: Mon,  9 Dec 2013 09:38:00 -0500
Message-Id: <1386599880-20031-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it could leak dentry references in some cases. Make sure
we clean up properly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5d973b2..b185548 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1369,6 +1369,18 @@ out:
 	return pipe_dentry;
 }
 
+static void
+rpc_gssd_dummy_depopulate(struct dentry *pipe_dentry)
+{
+	struct dentry *clnt_dir = pipe_dentry->d_parent;
+	struct dentry *gssd_dir = clnt_dir->d_parent;
+
+	__rpc_rmpipe(clnt_dir->d_inode, pipe_dentry);
+	__rpc_depopulate(clnt_dir, gssd_dummy_info_file, 0, 1);
+	__rpc_depopulate(gssd_dir, gssd_dummy_clnt_dir, 0, 1);
+	dput(pipe_dentry);
+}
+
 static int
 rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
@@ -1412,7 +1424,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	return 0;
 
 err_depopulate:
-	dput(gssd_dentry);
+	rpc_gssd_dummy_depopulate(gssd_dentry);
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
-- 
1.8.4.2

