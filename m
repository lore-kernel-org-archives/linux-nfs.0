Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:40830 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbaJGSAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 14:00:09 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so5397593vcb.27
        for <linux-nfs@vger.kernel.org>; Tue, 07 Oct 2014 11:00:08 -0700 (PDT)
From: Thomas Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <loghyr@primarydata.com>
Subject: [PATCH] pnfs: Do not schedule layout segment work if there is no work to be done.
Date: Tue,  7 Oct 2014 10:59:47 -0700
Message-Id: <1412704787-46388-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <loghyr@primarydata.com>

Callers of pnfs_put_lseg_async() might encounter no writes to
be committed, etc. As such, do not attempt to add work if none
is needed. Also, don't oops if that is the case.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/pnfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 76de7f5..08b1060 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -373,6 +373,9 @@ static void pnfs_put_lseg_async_work(struct work_struct *work)
 void
 pnfs_put_lseg_async(struct pnfs_layout_segment *lseg)
 {
+	if (!lseg)
+		return;
+
 	INIT_WORK(&lseg->pls_work, pnfs_put_lseg_async_work);
 	schedule_work(&lseg->pls_work);
 }
-- 
1.9.3

