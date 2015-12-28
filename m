Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38813 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbbL1SF7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 13:05:59 -0500
Received: by mail-ig0-f182.google.com with SMTP id mw1so24927995igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 10:05:59 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] NFSv4.1/pNFS: Ensure we enforce RFC5661 Section 12.5.5.2.1
Date: Mon, 28 Dec 2015 13:05:17 -0500
Message-Id: <1451325918-33544-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451325918-33544-4-git-send-email-trond.myklebust@primarydata.com>
References: <1451325918-33544-1-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-2-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-3-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RFC requires us to check if the server is recalling a stateid that we
haven't yet received. If so, tell it to wait.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 34852ece4057..1b24ad07d4f5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -160,6 +160,22 @@ static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp,
 	return lo;
 }
 
+/*
+ * Enforce RFC5661 section 12.5.5.2.1. (Layout Recall and Return Sequencing)
+ */
+static bool pnfs_check_stateid_sequence(struct pnfs_layout_hdr *lo,
+					const nfs4_stateid *new)
+{
+	u32 oldseq, newseq;
+
+	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
+	newseq = be32_to_cpu(new->seqid);
+
+	if (newseq > oldseq + 1)
+		return false;
+	return true;
+}
+
 static u32 initiate_file_draining(struct nfs_client *clp,
 				  struct cb_layoutrecallargs *args)
 {
@@ -175,6 +191,10 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	ino = lo->plh_inode;
 
 	spin_lock(&ino->i_lock);
+	if (!pnfs_check_stateid_sequence(lo, &args->cbl_stateid)) {
+		rv = NFS4ERR_DELAY;
+		goto unlock;
+	}
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 
-- 
2.5.0

