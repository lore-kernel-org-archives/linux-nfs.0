Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:48454 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBTC2e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:34 -0500
Received: by mail-oa0-f43.google.com with SMTP id h16so1504984oag.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] NFSv4.1: Ensure that we free existing layout segments if we get a new layout
Date: Wed, 19 Feb 2014 21:28:23 -0500
Message-Id: <1392863305-14870-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392863305-14870-4-git-send-email-trond.myklebust@primarydata.com>
References: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server returns a completely new layout stateid in response to our
LAYOUTGET, then make sure to free any existing layout segments.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6e67ada6c22c..cb53d450ae32 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -665,6 +665,17 @@ static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
 	return (s32)(s1 - s2) > 0;
 }
 
+static void
+pnfs_verify_layout_stateid(struct pnfs_layout_hdr *lo,
+		const nfs4_stateid *new,
+		struct list_head *free_me_list)
+{
+	if (nfs4_stateid_match_other(&lo->plh_stateid, new))
+		return;
+	/* Layout is new! Kill existing layout segments */
+	pnfs_mark_matching_lsegs_invalid(lo, free_me_list, NULL);
+}
+
 /* update lo->plh_stateid with new if is more recent */
 void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
@@ -1315,6 +1326,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct nfs4_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = lo->plh_inode;
+	LIST_HEAD(free_me);
 	int status = 0;
 
 	/* Inject layout blob into I/O device driver */
@@ -1341,6 +1353,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget_reply;
 	}
 
+	/* Check that the new stateid matches the old stateid */
+	pnfs_verify_layout_stateid(lo, &res->stateid, &free_me);
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
 
@@ -1355,6 +1369,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 
 	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&free_me);
 	return lseg;
 out:
 	return ERR_PTR(status);
-- 
1.8.5.3

