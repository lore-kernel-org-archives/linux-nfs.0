Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36616 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbGMJa4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:30:56 -0400
Received: by pachj5 with SMTP id hj5so29274448pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:30:55 -0700 (PDT)
Message-ID: <55A3854B.7010805@gmail.com>
Date: Mon, 13 Jul 2015 17:30:51 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 04/14] nfsd: Fix a memory leak of struct file_lock
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e5e14fa..998166d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3938,6 +3938,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (!filp) {
 		/* We should always have a readable file here */
 		WARN_ON_ONCE(1);
+		locks_free_lock(fl);
 		return -EBADF;
 	}
 	fl->fl_file = filp;
-- 
2.4.3

