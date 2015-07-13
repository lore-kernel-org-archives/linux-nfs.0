Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34297 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbbGMJbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:31:47 -0400
Received: by pacan13 with SMTP id an13so13060030pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:31:47 -0700 (PDT)
Message-ID: <55A3857E.50104@gmail.com>
Date: Mon, 13 Jul 2015 17:31:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 06/14] nfsd: Drop duplicate locks_init_lock()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 5c0f1d6..c5af4ccb 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -162,7 +162,7 @@ nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
 	fl = locks_alloc_lock();
 	if (!fl)
 		return -ENOMEM;
-	locks_init_lock(fl);
+
 	fl->fl_lmops = &nfsd4_layouts_lm_ops;
 	fl->fl_flags = FL_LAYOUT;
 	fl->fl_type = F_RDLCK;
-- 
2.4.3

