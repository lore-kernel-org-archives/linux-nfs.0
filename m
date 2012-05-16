Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:58408 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757152Ab2EPREc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 13:04:32 -0400
Received: by qcro28 with SMTP id o28so637502qcr.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 10:04:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] rpc_pipefs: clear write bit from top level rpc_pipefs directory
Date: Wed, 16 May 2012 13:04:26 -0400
Message-Id: <1337187866-20263-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can't create new files or directories here from userspace, so let's
not pretend that this directory is writable.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 3b62cf2..f955d72 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1118,7 +1118,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &s_ops;
 	sb->s_time_gran = 1;
 
-	inode = rpc_get_inode(sb, S_IFDIR | 0755);
+	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);
 	sb->s_root = root = d_make_root(inode);
 	if (!root)
 		return -ENOMEM;
-- 
1.7.7.6

