Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:29097 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab3IZTjk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 15:39:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>, <jlayton@redhat.com>
Subject: [PATCH 1/3] NFSv4.1: filelayout_check_layout: don't set the layout devinfo data on failure
Date: Thu, 26 Sep 2013 15:39:25 -0400
Message-ID: <1380224367-10939-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b86464b..c456482 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -669,8 +669,6 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	if (filelayout_test_devid_unavailable(&dsaddr->id_node))
 			goto out_put;
 
-	fl->dsaddr = dsaddr;
-
 	if (fl->first_stripe_index >= dsaddr->stripe_count) {
 		dprintk("%s Bad first_stripe_index %u\n",
 				__func__, fl->first_stripe_index);
@@ -692,6 +690,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			nfss->wsize);
 	}
 
+	fl->dsaddr = dsaddr;
+
 	status = 0;
 out:
 	dprintk("--> %s returns %d\n", __func__, status);
-- 
1.8.3.1

