Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53981 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729Ab1FSWdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2011 18:33:51 -0400
Received: by pvg12 with SMTP id 12so277653pvg.19
        for <linux-nfs@vger.kernel.org>; Sun, 19 Jun 2011 15:33:51 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4.1: file layout must consider pg_bsize for coalescing
Date: Sun, 19 Jun 2011 18:33:46 -0400
Message-Id: <1308522826-17268-1-git-send-email-benny@tonian.com>
In-Reply-To: <1308520693-31114-1-git-send-email-benny@tonian.com>
References: <1308520693-31114-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Otherwise we end up overflowing the rpc buffer size on the receive end.

Signed-off-by: Benny Halevy <benny@tonian.com>
---

v2: Rebased onto nfs-2.6/bugfixes df18d12

 fs/nfs/nfs4filelayout.c  |    6 ++++--
 fs/nfs/pagelist.c        |    3 ++-
 include/linux/nfs_page.h |    3 +++
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 1aca430..f9d03ab 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -30,6 +30,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 
 #include "internal.h"
 #include "nfs4filelayout.h"
@@ -665,8 +666,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	u64 p_stripe, r_stripe;
 	u32 stripe_unit;
 
-	if (!pnfs_generic_pg_test(pgio, prev, req))
-		return 0;
+	if (!pnfs_generic_pg_test(pgio, prev, req) ||
+	    !nfs_generic_pg_test(pgio, prev, req))
+		return false;
 
 	if (!pgio->pg_lseg)
 		return 1;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7913961..0098557 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -204,7 +204,7 @@ nfs_wait_on_request(struct nfs_page *req)
 			TASK_UNINTERRUPTIBLE);
 }
 
-static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
+bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
 {
 	/*
 	 * FIXME: ideally we should be able to coalesce all requests
@@ -218,6 +218,7 @@ static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_p
 
 	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
 
 /**
  * nfs_pageio_init - initialise a page io descriptor
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 3a34e80..25311b3 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -92,6 +92,9 @@ extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
+extern bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
+				struct nfs_page *prev,
+				struct nfs_page *req);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern	int nfs_set_page_tag_locked(struct nfs_page *req);
-- 
1.7.4.4

