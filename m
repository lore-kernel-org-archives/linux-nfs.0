Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38618 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbbFZS5r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jun 2015 14:57:47 -0400
Received: by igrv9 with SMTP id v9so7037589igr.1
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 11:57:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Turn off layoutcommit for servers that don't need it
Date: Fri, 26 Jun 2015 14:57:44 -0400
Message-Id: <1435345064-12128-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensures that we record the value of 'ffl_flags' from
the layout, and then checks for the presence of the
FF_FLAGS_NO_LAYOUTCOMMIT flag before deciding whether or not to
call pnfs_set_layoutcommit().

The effect is that servers now can decide whether or not they want
the client to call layoutcommit before returning a writeable layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 +++++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 +++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 85b4234b8090..594ab35eacfb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -343,6 +343,10 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 			fls->mirror_array[i]->gid);
 	}
 
+	p = xdr_inline_decode(&stream, 4);
+	if (p)
+		fls->flags = be32_to_cpup(p);
+
 	ff_layout_sort_mirrors(fls);
 	rc = ff_layout_check_layout(lgr);
 	if (rc)
@@ -1018,6 +1022,12 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	return 0;
 }
 
+static bool
+ff_layout_need_layoutcommit(struct pnfs_layout_segment *lseg)
+{
+	return !(FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_LAYOUTCOMMIT);
+}
+
 /*
  * We reference the rpc_cred of the first WRITE that triggers the need for
  * a LAYOUTCOMMIT, and use it to send the layoutcommit compound.
@@ -1030,6 +1040,9 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 static void
 ff_layout_set_layoutcommit(struct nfs_pgio_header *hdr)
 {
+	if (!ff_layout_need_layoutcommit(hdr->lseg))
+		return;
+
 	pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
 			hdr->mds_offset + hdr->res.count);
 	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
@@ -1221,7 +1234,8 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
-	if (data->verf.committed == NFS_UNSTABLE)
+	if (data->verf.committed == NFS_UNSTABLE
+	    && ff_layout_need_layoutcommit(data->lseg))
 		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 6fcd8d5e8e3d..f92f9a0a856b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -9,6 +9,8 @@
 #ifndef FS_NFS_NFS4FLEXFILELAYOUT_H
 #define FS_NFS_NFS4FLEXFILELAYOUT_H
 
+#define FF_FLAGS_NO_LAYOUTCOMMIT 1
+
 #include "../pnfs.h"
 
 /* XXX: Let's filter out insanely large mirror count for now to avoid oom
@@ -85,6 +87,7 @@ struct nfs4_ff_layout_mirror {
 struct nfs4_ff_layout_segment {
 	struct pnfs_layout_segment	generic_hdr;
 	u64				stripe_unit;
+	u32				flags;
 	u32				mirror_array_cnt;
 	struct nfs4_ff_layout_mirror	**mirror_array;
 };
-- 
2.4.3

