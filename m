Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35101 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbbDEOJx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Apr 2015 10:09:53 -0400
Received: by patj18 with SMTP id j18so18225953pat.2
        for <linux-nfs@vger.kernel.org>; Sun, 05 Apr 2015 07:09:52 -0700 (PDT)
Message-ID: <5521422A.7080005@gmail.com>
Date: Sun, 05 Apr 2015 22:09:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, kinglongmee@gmail.com
Subject: [PATCH] nfs-utils: add missing comma for exports ent
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using pnfs with "fsid=0", exportfs prints error as, 

# exportfs -a
exportfs: /var/lib/nfs/etab:1: unknown keyword "no_pnfsfsid=0"

Commit cdd16bef98 ("nfs-utils: add support for the "pnfs" export option")
miss the comma after "pnfs"/"on_pnfs" operation.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 support/nfs/exports.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 9b325b9..761a046 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -275,7 +275,7 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
 		fprintf(fp, "nordirplus,");
-	fprintf(fp, "%spnfs", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
+	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
-- 
2.3.4

