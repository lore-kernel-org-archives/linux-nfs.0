Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:41395 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaIBOLn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:11:43 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so14852528pad.35
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:11:43 -0700 (PDT)
Message-ID: <5405D00F.2040709@gmail.com>
Date: Tue, 02 Sep 2014 22:11:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/6] NFSD: Reset creds after mnt_want_write_file() fail
Content-Type: text/plain; charset=utf-8
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

