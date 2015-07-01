Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33603 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbGAPAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jul 2015 11:00:37 -0400
Received: by pdjd13 with SMTP id d13so27263492pdj.0
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jul 2015 08:00:36 -0700 (PDT)
Message-ID: <5594008D.8080909@gmail.com>
Date: Wed, 01 Jul 2015 23:00:29 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 3/8 v2] nfs: Use remove_proc_subtree() instead remove_proc_entry()
References: <5593648D.7020804@gmail.com> <559364E9.1070808@gmail.com> <20150701052007.GA17109@ZenIV.linux.org.uk>
In-Reply-To: <20150701052007.GA17109@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for Al Viro's comments of killing proc_fs_nfs completely.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/client.c | 25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 892aeff..3e8781d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1193,8 +1193,6 @@ void nfs_clients_init(struct net *net)
 }
 
 #ifdef CONFIG_PROC_FS
-static struct proc_dir_entry *proc_fs_nfs;
-
 static int nfs_server_list_open(struct inode *inode, struct file *file);
 static void *nfs_server_list_start(struct seq_file *p, loff_t *pos);
 static void *nfs_server_list_next(struct seq_file *p, void *v, loff_t *pos);
@@ -1434,27 +1432,20 @@ void nfs_fs_proc_net_exit(struct net *net)
  */
 int __init nfs_fs_proc_init(void)
 {
-	struct proc_dir_entry *p;
-
-	proc_fs_nfs = proc_mkdir("fs/nfsfs", NULL);
-	if (!proc_fs_nfs)
+	if (!proc_mkdir("fs/nfsfs", NULL))
 		goto error_0;
 
 	/* a file of servers with which we're dealing */
-	p = proc_symlink("servers", proc_fs_nfs, "../../net/nfsfs/servers");
-	if (!p)
+	if (!proc_symlink("fs/nfsfs/servers", NULL, "../../net/nfsfs/servers"))
 		goto error_1;
 
 	/* a file of volumes that we have mounted */
-	p = proc_symlink("volumes", proc_fs_nfs, "../../net/nfsfs/volumes");
-	if (!p)
-		goto error_2;
-	return 0;
+	if (!proc_symlink("fs/nfsfs/volumes", NULL, "../../net/nfsfs/volumes"))
+		goto error_1;
 
-error_2:
-	remove_proc_entry("servers", proc_fs_nfs);
+	return 0;
 error_1:
-	remove_proc_entry("fs/nfsfs", NULL);
+	remove_proc_subtree("fs/nfsfs", NULL);
 error_0:
 	return -ENOMEM;
 }
@@ -1464,9 +1455,7 @@ error_0:
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

