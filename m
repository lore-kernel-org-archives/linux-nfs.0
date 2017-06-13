Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:6571 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752259AbdFMSgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 14:36:24 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS fix dangling DS mount
Date: Tue, 13 Jun 2017 14:36:20 -0400
Message-ID: <20170613183620.57538-1-kolga@netapp.com>
In-Reply-To: <CAN-5tyHUJW85oxaX81Zr3Drp5WFv05-tWWXGcKCQh5S+1VZ7JQ@mail.gmail.com>
References: <CAN-5tyHUJW85oxaX81Zr3Drp5WFv05-tWWXGcKCQh5S+1VZ7JQ@mail.gmail.com>
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
So start the recount at 2 and keep the nfs4_fl_put_deviceid() in
the filelayout_free_lseg().

Fixes: 8d40b0f14846 ("NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 15 +++++++++++++--
 fs/nfs/pnfs_dev.c              |  2 +-
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index acd30ba..33ebd1a 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -989,18 +989,29 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
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
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 2961fcd..671d65f 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -255,7 +255,7 @@ struct nfs4_deviceid_node *
 	d->nfs_client = server->nfs_client;
 	d->flags = 0;
 	d->deviceid = *id;
-	atomic_set(&d->ref, 1);
+	atomic_set(&d->ref, 2);
 }
 EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
 
-- 
1.8.3.1

