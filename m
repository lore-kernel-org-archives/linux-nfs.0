Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35084 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbHUCAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 22:00:09 -0400
Received: by pacdd16 with SMTP id dd16so32329246pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 19:00:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Add a tracepoint for CB_LAYOUTRECALL
Date: Thu, 20 Aug 2015 21:00:05 -0500
Message-Id: <1440122405-30530-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440122405-30530-2-git-send-email-trond.myklebust@primarydata.com>
References: <1440122405-30530-1-git-send-email-trond.myklebust@primarydata.com>
 <1440122405-30530-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only support for single file layoutrecall for now.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 3 ++-
 fs/nfs/nfs4trace.h     | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 07258d269e5a..b85cf7a30232 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -41,7 +41,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
 	if (inode == NULL) {
-		trace_nfs4_cb_getattr(cps->clp, &args->fh, inode,
+		trace_nfs4_cb_getattr(cps->clp, &args->fh, NULL,
 				-ntohl(res->status));
 		goto out;
 	}
@@ -198,6 +198,7 @@ unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
+	trace_nfs4_cb_layoutrecall_inode(clp, &args->cbl_fh, ino, -rv);
 	iput(ino);
 out:
 	return rv;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 1aa096b665dc..28df12e525ba 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -941,6 +941,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_callback_event,
 			), \
 			TP_ARGS(clp, fhandle, inode, error))
 DEFINE_NFS4_INODE_CALLBACK_EVENT(nfs4_cb_getattr);
+DEFINE_NFS4_INODE_CALLBACK_EVENT(nfs4_cb_layoutrecall_inode);
 
 
 DECLARE_EVENT_CLASS(nfs4_idmap_event,
-- 
2.4.3

