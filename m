Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19426 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932884Ab1CWN2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:05 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/12] NFSv4.1: shift filelayout_free_lseg
Date: Wed, 23 Mar 2011 09:27:49 -0400
Message-Id: <1300886875-5016-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move it up to avoid forward declaration in later patch.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4285584..9401afd 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -496,6 +496,16 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 	return 0;
 }
 
+static void
+filelayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+
+	dprintk("--> %s\n", __func__);
+	nfs4_fl_put_deviceid(fl->dsaddr);
+	_filelayout_free_lseg(fl);
+}
+
 static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		      struct nfs4_layoutget_res *lgr)
@@ -517,16 +527,6 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 	return &fl->generic_hdr;
 }
 
-static void
-filelayout_free_lseg(struct pnfs_layout_segment *lseg)
-{
-	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
-
-	dprintk("--> %s\n", __func__);
-	nfs4_fl_put_deviceid(fl->dsaddr);
-	_filelayout_free_lseg(fl);
-}
-
 /*
  * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
-- 
1.7.2.1

