From: Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 1/2] NFS:Prevent infinite loop in decode_attr_fs_locations.
Date: Fri, 17 Oct 2008 11:17:47 -0700
Message-ID: <1224267468-775-1-git-send-email-dhildeb@us.ibm.com>
Cc: Dean Hildebrand <dhildeb@us.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:42657 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbYJQSRx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2008 14:17:53 -0400
Received: by gxk9 with SMTP id 9so1499013gxk.13
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2008 11:17:52 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An infinite loop could occur if n > NFS4_FS_LOCATIONS_MAXENTRIES.

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
---
 fs/nfs/nfs4xdr.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..5e59481 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2577,6 +2577,16 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	READ32(n);
 	if (n <= 0)
 		goto out_eio;
+
+	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
+		dprintk("%s: using first %u of %d fs locations\n",
+			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
+		n = NFS4_FS_LOCATIONS_MAXENTRIES;
+	} else {
+		dprintk("%s: using %d fs locations\n",
+			__func__, n);
+	}
+
 	res->nlocations = 0;
 	while (res->nlocations < n) {
 		u32 m;
@@ -2614,8 +2624,8 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		status = decode_pathname(xdr, &loc->rootpath);
 		if (unlikely(status != 0))
 			goto out_eio;
-		if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
-			res->nlocations++;
+
+		res->nlocations++;
 	}
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
-- 
1.5.3.3

