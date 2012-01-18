Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35536 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab2ARV6z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2012 16:58:55 -0500
Message-ID: <4F174080.6090702@panasas.com>
Date: Wed, 18 Jan 2012 23:58:24 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <stable@vger.kernel.org>
CC: Greg KH <greg@kroah.com>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] pnfs-obj: Must return layout on IO error (linux-3.0.y)
References: <20120111154700.5A847262B@git.kroah.org> <20120112231449.GB20151@kroah.com> <4F174005.9080403@panasas.com>
In-Reply-To: <4F174005.9080403@panasas.com>
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

[This is the linux-3.0.y version of mainline [fe0fe83] patch]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    3 ++-
 fs/nfs/pnfs.c                |   12 ++++++++++++
 fs/nfs/pnfs.h                |    1 +
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 1d1dc1e..75fe694 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1006,7 +1006,8 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
-	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR |
+				   PNFS_LAYOUTRET_ON_ERROR,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 36d2a29..9951887 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1119,6 +1119,14 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 		data->mds_ops->rpc_release(data);
 		return 0;
 	}
+	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+					PNFS_LAYOUTRET_ON_ERROR) {
+		/* Don't lo_commit on error, Server will needs to
+		 * preform a file recovery.
+		 */
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(data->inode)->flags);
+		pnfs_return_layout(data->inode);
+	}
 
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
@@ -1167,6 +1175,10 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 		return 0;
 	}
 
+	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+						PNFS_LAYOUTRET_ON_ERROR)
+		pnfs_return_layout(data->inode);
+
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9d147d9..bb8b324 100644
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


