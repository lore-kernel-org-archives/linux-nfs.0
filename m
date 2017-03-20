Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41361 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755034AbdCTWHI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 18:07:08 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/3] NFS store nfs4_deviceid in struct nfs4_filelayout_segment
Date: Mon, 20 Mar 2017 18:07:01 -0400
Message-ID: <1490047622-35305-3-git-send-email-andros@netapp.com>
In-Reply-To: <1490047622-35305-1-git-send-email-andros@netapp.com>
References: <1490047622-35305-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation for moving the filelayout getdeviceinfo call from
filelayout_alloc_lseg called by pnfs_process_layout

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 13 +++++--------
 fs/nfs/filelayout/filelayout.h |  1 +
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 44347f4..4812bf0 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -572,7 +572,6 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			struct nfs4_filelayout_segment *fl,
 			struct nfs4_layoutget_res *lgr,
-			struct nfs4_deviceid *id,
 			gfp_t gfp_flags)
 {
 	struct nfs4_deviceid_node *d;
@@ -602,7 +601,7 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 	}
 
 	/* find and reference the deviceid */
-	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), id,
+	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &fl->deviceid,
 			lo->plh_lc_cred, gfp_flags);
 	if (d == NULL)
 		goto out;
@@ -657,7 +656,6 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 			 struct nfs4_filelayout_segment *fl,
 			 struct nfs4_layoutget_res *lgr,
-			 struct nfs4_deviceid *id,
 			 gfp_t gfp_flags)
 {
 	struct xdr_stream stream;
@@ -682,9 +680,9 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 	if (unlikely(!p))
 		goto out_err;
 
-	memcpy(id, p, sizeof(*id));
+	memcpy(&fl->deviceid, p, sizeof(fl->deviceid));
 	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
-	nfs4_print_deviceid(id);
+	nfs4_print_deviceid(&fl->deviceid);
 
 	nfl_util = be32_to_cpup(p++);
 	if (nfl_util & NFL4_UFLG_COMMIT_THRU_MDS)
@@ -831,15 +829,14 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 {
 	struct nfs4_filelayout_segment *fl;
 	int rc;
-	struct nfs4_deviceid id;
 
 	dprintk("--> %s\n", __func__);
 	fl = kzalloc(sizeof(*fl), gfp_flags);
 	if (!fl)
 		return NULL;
 
-	rc = filelayout_decode_layout(layoutid, fl, lgr, &id, gfp_flags);
-	if (rc != 0 || filelayout_check_layout(layoutid, fl, lgr, &id, gfp_flags)) {
+	rc = filelayout_decode_layout(layoutid, fl, lgr, gfp_flags);
+	if (rc != 0 || filelayout_check_layout(layoutid, fl, lgr, gfp_flags)) {
 		_filelayout_free_lseg(fl);
 		return NULL;
 	}
diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
index 4c4d436..79323b5 100644
--- a/fs/nfs/filelayout/filelayout.h
+++ b/fs/nfs/filelayout/filelayout.h
@@ -61,6 +61,7 @@ struct nfs4_filelayout_segment {
 	u32				stripe_unit;
 	u32				first_stripe_index;
 	u64				pattern_offset;
+	struct nfs4_deviceid		deviceid;
 	struct nfs4_file_layout_dsaddr	*dsaddr; /* Point to GETDEVINFO data */
 	unsigned int			num_fh;
 	struct nfs_fh			**fh_array;
-- 
1.8.3.1

