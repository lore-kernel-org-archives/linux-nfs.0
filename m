Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:10373 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752164AbdFTUkf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 16:40:35 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS fix dangling DS mount
Date: Tue, 20 Jun 2017 16:40:31 -0400
Message-ID: <20170620204031.64667-1-kolga@netapp.com>
In-Reply-To: <1497987431.13996.1.camel@primarydata.com>
References: <1497987431.13996.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a regression by commit 8d40b0f14846 ("NFS filelayout:call
GETDEVICEINFO after pnfs_layout_process completes"). It leaves the
DS mount dangling.

Previously, filelayout_alloc_sec() would call filelayout_check_layout()
which would call nfs4_find_get_deviceid which ups the count on the
device_id. It's only called once and it's matched by the
filelayout_free_lseg() that calls nfs4_fl_put_deviceid().

After that patch, each read/write ends up calling nfs4_find_get_deviceid
and there is no balance for that. Instead, do nfs4_fl_put_deviceid()
in the filelayout's .pg_cleanup and remove it from filelayout_free_lseg.

But we still want a reference to hold over the lifetime of the segment.
So up the ref count when we allocate new device node and free it in
the filelayout_free_lseg().

Fixes: 8d40b0f14846 ("NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c    | 15 +++++++++++++--
 fs/nfs/filelayout/filelayoutdev.c |  1 +
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 1cf85d6..ce82da1 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -991,18 +991,29 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 	nfs_pageio_reset_write_mds(pgio);
 }
 
+static void filelayout_pg_cleanup(struct nfs_pageio_descriptor *desc)
+{
+	if (desc->pg_lseg) {
+		struct nfs4_filelayout_segment *fl =
+			FILELAYOUT_LSEG(desc->pg_lseg);
+
+		nfs4_fl_put_deviceid(fl->dsaddr);
+	}
+	pnfs_generic_pg_cleanup(desc);
+}
+
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
 	.pg_init = filelayout_pg_init_read,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
-	.pg_cleanup = pnfs_generic_pg_cleanup,
+	.pg_cleanup = filelayout_pg_cleanup,
 };
 
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
 	.pg_init = filelayout_pg_init_write,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
-	.pg_cleanup = pnfs_generic_pg_cleanup,
+	.pg_cleanup = filelayout_pg_cleanup,
 };
 
 static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index d913e81..862fe1f 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -147,6 +147,7 @@ struct nfs4_file_layout_dsaddr *
 	stripe_indices = NULL;
 	dsaddr->ds_num = num;
 	nfs4_init_deviceid_node(&dsaddr->id_node, server, &pdev->dev_id);
+	nfs4_get_deviceid(&dsaddr->id_node);
 
 	INIT_LIST_HEAD(&dsaddrs);
 
-- 
1.8.3.1

