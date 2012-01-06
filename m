Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54611 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984Ab2AFHi1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 02:38:27 -0500
Message-ID: <4F06A348.7070600@panasas.com>
Date: Fri, 6 Jan 2012 09:31:20 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Fred Isaman <iisaman@netapp.com>
CC: Stable Tree <stable@kernel.org>
Subject: [PATCH 2/2] pnfs-obj: Must return layout on IO error
References: <4F06A18E.4010706@panasas.com>
In-Reply-To: <4F06A18E.4010706@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


As mandated by the standard. In case of an IO error, a pNFS
objects layout driver must return it's layout. This is because
all device errors are reported to the server as part of the
layout return buffer.

This is implemented the same way PNFS_LAYOUTRET_ON_SETATTR
is done, through a bit flag on the pnfs_layoutdriver_type->flags
member. The flag is set by the layout driver that wants a
layout_return preformed at pnfs_ld_{write,read}_done in case
of an error.
(Though I have not defined a wrapper like pnfs_ld_layoutret_on_setattr
 because this code is never called outside of pnfs.c and pnfs IO
 paths)

Without this patch 3.[0-2] Kernels leak memory and have an annoying
WARN_ON after every IO error utilizing the pnfs-obj driver.

[This patch is for 3.2 Kernel. 3.1/0 Kernels need a different patch]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    3 ++-
 fs/nfs/pnfs.c                |   12 ++++++++++++
 fs/nfs/pnfs.h                |    1 +
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index c807ab9..55d0128 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -551,7 +551,8 @@ static const struct nfs_pageio_ops objio_pg_write_ops = {
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
-	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR |
+				   PNFS_LAYOUTRET_ON_ERROR,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8e672a2..f881a63 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1178,6 +1178,15 @@ void pnfs_ld_write_done(struct nfs_write_data *data)
 		put_lseg(data->lseg);
 		data->lseg = NULL;
 		dprintk("pnfs write error = %d\n", data->pnfs_error);
+		if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+						PNFS_LAYOUTRET_ON_ERROR) {
+			/* Don't lo_commit on error, Server will needs to
+			 * preform a file recovery.
+			 */
+			clear_bit(NFS_INO_LAYOUTCOMMIT,
+				  &NFS_I(data->inode)->flags);
+			pnfs_return_layout(data->inode);
+		}
 	}
 	data->mds_ops->rpc_release(data);
 }
@@ -1267,6 +1276,9 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 	put_lseg(data->lseg);
 	data->lseg = NULL;
 	dprintk("pnfs write error = %d\n", data->pnfs_error);
+	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+						PNFS_LAYOUTRET_ON_ERROR)
+		pnfs_return_layout(data->inode);
 
 	nfs_pageio_init_read_mds(&pgio, data->inode);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1509530..53d593a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,6 +68,7 @@ enum {
 enum layoutdriver_policy_flags {
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
+	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
 };
 
 struct nfs4_deviceid_node;
-- 
1.7.2.3


