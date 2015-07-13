Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34367 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbbGMJda (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:33:30 -0400
Received: by pacan13 with SMTP id an13so13084301pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:33:30 -0700 (PDT)
Message-ID: <55A385E4.7070309@gmail.com>
Date: Mon, 13 Jul 2015 17:33:24 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 10/14] nfsd: Remove unused values in nfs4_setlease()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f3c38e3..8205542 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3919,7 +3919,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
-	struct file_lock *fl, *ret;
+	struct file_lock *fl;
 	struct file *filp;
 	int status = 0;
 
@@ -3934,7 +3934,6 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 		return -EBADF;
 	}
 	fl->fl_file = filp;
-	ret = fl;
 	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
 	if (fl)
 		locks_free_lock(fl);
-- 
2.4.3

