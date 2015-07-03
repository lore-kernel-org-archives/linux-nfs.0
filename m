Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33483 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823AbbGCLcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 07:32:19 -0400
Received: by pdjd13 with SMTP id d13so62602469pdj.0
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 04:32:18 -0700 (PDT)
Message-ID: <559672B7.4010802@gmail.com>
Date: Fri, 03 Jul 2015 19:32:07 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH 1/5] nfsd: Fix a file leak of ls_file if nfsd4_layout_setlease
 fail
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfsd4_layout_setlease fail, nfsd will not put ls->ls_file.

Fix commit c5c707f96f "nfsd: implement pNFS layout recalls".

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6904213..367a65a 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -212,8 +212,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	BUG_ON(!ls->ls_file);
 
 	if (nfsd4_layout_setlease(ls)) {
-		put_nfs4_file(fp);
-		kmem_cache_free(nfs4_layout_stateid_cache, ls);
+		nfs4_put_stid(stp);
 		return NULL;
 	}
 
-- 
2.4.3

