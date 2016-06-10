Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33645 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbcFJPuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 11:50:22 -0400
Received: by mail-qk0-f193.google.com with SMTP id u63so5651698qkh.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 08:50:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.1/pnfs: Ensure we handle delegation errors in nfs4_proc_layoutget()
Date: Fri, 10 Jun 2016 11:49:54 -0400
Message-Id: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_handle_exception() relies on the caller setting the 'inode' field
in the struct nfs4_exception argument when the error applies to a
delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index de97567795a5..27fe63b502d5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8036,7 +8036,10 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct pnfs_layout_segment *lseg = NULL;
-	struct nfs4_exception exception = { .timeout = *timeout };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.timeout = *timeout,
+	};
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
-- 
2.5.5

