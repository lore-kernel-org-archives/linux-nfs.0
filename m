Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:47783 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaLXHOM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:12 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so7202490iec.36
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:12 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 39/49] nfs: only reset desc->pg_mirror_idx when mirroring is supported
Date: Tue, 23 Dec 2014 23:13:18 -0800
Message-Id: <1419405208-25975-40-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

so that we don't reset desc->pg_mirror_idx for read unnecessarily.
Remove WARN_ON_ONCE from __nfs_pageio_add_request to allow LD to
set pg_mirror_idx for read where pg_mirror_count is always 1.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/internal.h | 7 +++++++
 fs/nfs/pagelist.c | 8 ++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ef1c703..5be06bc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -6,6 +6,7 @@
 #include <linux/mount.h>
 #include <linux/security.h>
 #include <linux/crc32.h>
+#include <linux/nfs_page.h>
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
 
@@ -261,6 +262,12 @@ static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 	atomic_set(&c->io_count, 0);
 }
 
+static inline bool nfs_pgio_has_mirroring(struct nfs_pageio_descriptor *desc)
+{
+	WARN_ON_ONCE(desc->pg_mirror_count < 1);
+	return desc->pg_mirror_count > 1;
+}
+
 /* nfs2xdr.c */
 extern struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index eec12b7..f9d8c46 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1021,8 +1021,6 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	unsigned int bytes_left = 0;
 	unsigned int offset, pgbase;
 
-	WARN_ON_ONCE(desc->pg_mirror_idx >= desc->pg_mirror_count);
-
 	nfs_page_group_lock(req, false);
 
 	subreq = req;
@@ -1162,7 +1160,8 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		} else
 			dupreq = req;
 
-		desc->pg_mirror_idx = midx;
+		if (nfs_pgio_has_mirroring(desc))
+			desc->pg_mirror_idx = midx;
 		if (!nfs_pageio_add_request_mirror(desc, dupreq))
 			return 0;
 	}
@@ -1181,7 +1180,8 @@ static void nfs_pageio_complete_mirror(struct nfs_pageio_descriptor *desc,
 	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[mirror_idx];
 	u32 restore_idx = desc->pg_mirror_idx;
 
-	desc->pg_mirror_idx = mirror_idx;
+	if (nfs_pgio_has_mirroring(desc))
+		desc->pg_mirror_idx = mirror_idx;
 	for (;;) {
 		nfs_pageio_doio(desc);
 		if (!mirror->pg_recoalesce)
-- 
1.9.3

