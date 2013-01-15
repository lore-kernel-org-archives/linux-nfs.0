Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:57966 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab3AODR0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 22:17:26 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so2646935pad.16
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2013 19:17:26 -0800 (PST)
From: ycnian@gmail.com
To: bhalevy@tonian.com
Cc: linux-nfs@vger.kernel.org, Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] pnfsd: Fix unlock bug on error path
Date: Tue, 15 Jan 2013 11:07:41 +0800
Message-Id: <1358219261-19974-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

LAYOUTGET procedure fails if the layout requested conflicts with the recalled.
It needs to put the reference and unlock the state before exiting.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4pnfsd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index dd7856c..4a1e17b 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -760,7 +760,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 
 	if (is_layout_recalled(clp, lgp->lg_fhp, &lgp->lg_seg)) {
 		nfserr = nfserr_recallconflict;
-		goto out;
+		goto out_unlock;
 	}
 
 	/* pre-alloc layout in case we can't merge after we call
-- 
1.7.4.4

