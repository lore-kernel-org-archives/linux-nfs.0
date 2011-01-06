Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6000 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932Ab1AFLgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 06:36:37 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/15] pnfs: fix incorrect comment in destroy_lseg
Date: Thu,  6 Jan 2011 06:36:18 -0500
Message-Id: <1294313792-14280-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
References: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Comment references get_layout_hdr_locked, which never existed in
submitted code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index db77342..6e9daff 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -225,7 +225,7 @@ destroy_lseg(struct kref *kref)
 
 	dprintk("--> %s\n", __func__);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+	/* Matched by get_layout_hdr in pnfs_insert_layout */
 	put_layout_hdr(ino);
 }
 
-- 
1.7.2.1

