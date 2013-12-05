Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:58882 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056Ab3LEMd5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 07:33:57 -0500
Received: by mail-qc0-f173.google.com with SMTP id m20so3458086qcx.18
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 04:33:56 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] rpc_pipe: remove the clntXX dir if creating the pipe fails
Date: Thu,  5 Dec 2013 07:33:49 -0500
Message-Id: <1386246829-13226-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the event that we create the gssd/clntXX dir, but the pipe creation
subsequently fails, then we should remove the clntXX dir before
returning.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5cd7ad1..0b74c61 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1313,6 +1313,8 @@ rpc_gssd_dummy_populate(struct dentry *root, struct rpc_pipe *pipe_data)
 	}
 
 	pipe_dentry = rpc_mkpipe_dentry(clnt_dentry, "gssd", NULL, pipe_data);
+	if (IS_ERR(pipe_dentry))
+		__rpc_depopulate(gssd_dentry, gssd_dummy_clnt_dir, 0, 1);
 out:
 	dput(clnt_dentry);
 	dput(gssd_dentry);
-- 
1.8.4.2

