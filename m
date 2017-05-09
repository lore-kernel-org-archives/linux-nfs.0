Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50517 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdEINb0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 09:31:26 -0400
From: Colin King <colin.king@canonical.com>
To: Ari Kauppi <ari@synopsys.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: avoid out of bounds read on array nfsd4_layout_ops
Date: Tue,  9 May 2017 14:31:21 +0100
Message-Id: <20170509133121.26529-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Array nfsd4_layout_ops has LAYOUT_TYPE_MAX elements (which is currently
just 6), so check for this upper bound rather than the hard coded upper
bound of 32 to avoid an out of bounds read on array nfsd4_layout_ops.

Detected by CoverityScan, CID#1433518 ("Out-of-bounds read")

Fixes: e79104c9bd2d26 ("nfsd: fix undefined behavior in nfsd4_layout_verify")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1dbf62190bee..c453a1998e00 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1259,7 +1259,8 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
 		return NULL;
 	}
 
-	if (layout_type >= 32 || !(exp->ex_layout_types & (1 << layout_type))) {
+	if (layout_type >= LAYOUT_TYPE_MAX ||
+	    !(exp->ex_layout_types & (1 << layout_type))) {
 		dprintk("%s: layout type %d not supported\n",
 			__func__, layout_type);
 		return NULL;
-- 
2.11.0

