Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35241 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:36 -0400
Received: by mail-io0-f196.google.com with SMTP id q83so10786608iod.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/14] pNFS: Always update the layout stateid if NFS_LAYOUT_INVALID_STID is set
Date: Sun, 24 Jul 2016 17:30:48 -0400
Message-Id: <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout stateid is invalid, then pnfs_set_layout_stateid() must
always initialise it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dcccded1aeed..eef844785bc6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -762,7 +762,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 			bool update_barrier)
 {
 	u32 oldseq, newseq, new_barrier;
-	int empty = list_empty(&lo->plh_segs);
+	bool empty = !pnfs_layout_is_valid(lo);
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-- 
2.7.4

