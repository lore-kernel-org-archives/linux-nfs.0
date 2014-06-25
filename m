Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:50030 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372AbaFYK76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 06:59:58 -0400
Received: by mail-pd0-f182.google.com with SMTP id y13so1508769pdi.41
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 03:59:57 -0700 (PDT)
Message-ID: <53AAAB93.9030307@gmail.com>
Date: Wed, 25 Jun 2014 18:59:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 1/4] NFSD: Fix missing reset creds in nfsd4_create_clid_dir
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4recover.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9c271f4..e37ac1c 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -188,7 +188,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 
 	status = mnt_want_write_file(nn->rec_file);
 	if (status)
-		return;
+		goto out_creds;
 
 	dir = nn->rec_file->f_path.dentry;
 	/* lock the parent */
@@ -228,6 +228,7 @@ out_unlock:
 				user_recovery_dirname);
 	}
 	mnt_drop_write_file(nn->rec_file);
+out_creds:
 	nfs4_reset_creds(original_cred);
 }
 
-- 
1.9.3

