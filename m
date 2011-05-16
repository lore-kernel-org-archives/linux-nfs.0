Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24132 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab1EPN7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 09:59:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/4] SQUASHME: pnfs: fix lseg ordering
Date: Mon, 16 May 2011 06:59:31 -0700
Message-Id: <1305554371-29159-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DCC715C.1090101@panasas.com>
References: <4DCC715C.1090101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

As noted by Fred Isaman, we prefer seeing the longer lsegs to the shorter.
Otherwise, we prefer seeing RW lsegs to RO ones.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 589989d..9d41cab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -686,19 +686,18 @@ cmp_layout(struct pnfs_layout_range *l1,
 {
 	s64 d;
 
-	/* higher offset > lower offset */
+	/* high offset > low offset */
 	d = l1->offset - l2->offset;
 	if (d)
 		return d;
 
-	/* longer length > shorter length */
-	d = l1->length - l2->length;
+	/* short length > long length */
+	d = l2->length - l1->length;
 	if (d)
 		return d;
 
 	/* read > read/write */
-	return (int)(l2->iomode == IOMODE_READ) -
-		(int)(l1->iomode == IOMODE_READ);
+	return (int)(l1->iomode == IOMODE_READ) - (int)(l2->iomode == IOMODE_READ);
 }
 
 static void
-- 
1.7.3.4

