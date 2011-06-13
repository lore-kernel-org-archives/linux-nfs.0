Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38546 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab1FMUmm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 16:42:42 -0400
Received: by iyb14 with SMTP id 14so4143509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 13:42:41 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfsd-lexp: return only nfs4errs from pnfsd_lexp_layout_get
Date: Mon, 13 Jun 2011 16:42:38 -0400
Message-Id: <1307997758-21235-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfsd/pnfsd_lexp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 4d8bceb..52ab2d2 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -156,7 +156,7 @@ pnfsd_lexp_layout_get(struct inode *inode,
 
 	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
 	if (layout == NULL) {
-		rc = -ENOMEM;
+		rc = NFS4ERR_DELAY;
 		goto error;
 	}
 
@@ -173,7 +173,7 @@ pnfsd_lexp_layout_get(struct inode *inode,
 
 	fhp = kmalloc(sizeof(*fhp), GFP_KERNEL);
 	if (fhp == NULL) {
-		rc = -ENOMEM;
+		rc = NFS4ERR_DELAY;
 		goto error;
 	}
 
-- 
1.7.4.4

