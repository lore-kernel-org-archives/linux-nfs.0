Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35050 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbHUCAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 22:00:08 -0400
Received: by pacdd16 with SMTP id dd16so32328558pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 19:00:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4.1/pnfs: Add a tracepoint for return-on-close events
Date: Thu, 20 Aug 2015 21:00:03 -0500
Message-Id: <1440122405-30530-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow tracing of return-on-close.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4trace.h | 1 +
 fs/nfs/pnfs.c      | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 470af1a78bec..0b67f7825d00 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1136,6 +1136,7 @@ TRACE_EVENT(nfs4_layoutget,
 
 DEFINE_NFS4_INODE_EVENT(nfs4_layoutcommit);
 DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn);
+DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn_on_close);
 
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8a3f30b695e2..cf90eeda9d71 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1144,6 +1144,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 	if (pnfs_seqid_is_newer(barrier, lo->plh_barrier))
 		lo->plh_barrier = barrier;
 	spin_unlock(&ino->i_lock);
+	trace_nfs4_layoutreturn_on_close(ino, 0);
 }
 
 void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
-- 
2.4.3

