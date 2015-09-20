Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32998 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbbITPDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 11:03:43 -0400
Received: by pacex6 with SMTP id ex6so93273349pac.0
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 08:03:43 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/2] NFS: Do cleanup before resetting pageio read/write to mds
Message-ID: <55FECAC0.6040800@gmail.com>
Date: Sun, 20 Sep 2015 23:03:28 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a reference leak of layout segment after resetting
pageio read/write to mds.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/read.c  | 3 +++
 fs/nfs/write.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index ae0ff7a..01b8cc8 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -72,6 +72,9 @@ void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
 	struct nfs_pgio_mirror *mirror;
 
+	if (pgio->pg_ops && pgio->pg_ops->pg_cleanup)
+		pgio->pg_ops->pg_cleanup(pgio);
+
 	pgio->pg_ops = &nfs_pgio_rw_ops;
 
 	/* read path should never have more than one mirror */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 388f480..72624dc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1351,6 +1351,9 @@ void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
 	struct nfs_pgio_mirror *mirror;
 
+	if (pgio->pg_ops && pgio->pg_ops->pg_cleanup)
+		pgio->pg_ops->pg_cleanup(pgio);
+
 	pgio->pg_ops = &nfs_pgio_rw_ops;
 
 	nfs_pageio_stop_mirroring(pgio);
-- 
2.5.0

