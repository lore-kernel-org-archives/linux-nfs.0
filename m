Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34024 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbbGAD4d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:56:33 -0400
Received: by pabvl15 with SMTP id vl15so15904804pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:56:32 -0700 (PDT)
Message-ID: <559364E9.1070808@gmail.com>
Date: Wed, 01 Jul 2015 11:56:25 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 3/8] nfs: Use remove_proc_subtree() instead remove_proc_entry()
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/client.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a13fada..52488ec 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1447,13 +1447,11 @@ int __init nfs_fs_proc_init(void)
 	/* a file of volumes that we have mounted */
 	p = proc_symlink("volumes", proc_fs_nfs, "../../net/nfsfs/volumes");
 	if (!p)
-		goto error_2;
+		goto error_1;
 	return 0;
 
-error_2:
-	remove_proc_entry("servers", proc_fs_nfs);
 error_1:
-	remove_proc_entry("fs/nfsfs", NULL);
+	remove_proc_subtree("fs/nfsfs", NULL);
 error_0:
 	return -ENOMEM;
 }
@@ -1463,9 +1461,7 @@ error_0:
  */
 void nfs_fs_proc_exit(void)
 {
-	remove_proc_entry("volumes", proc_fs_nfs);
-	remove_proc_entry("servers", proc_fs_nfs);
-	remove_proc_entry("fs/nfsfs", NULL);
+	remove_proc_subtree("fs/nfsfs", NULL);
 }
 
 #endif /* CONFIG_PROC_FS */
-- 
2.4.3

