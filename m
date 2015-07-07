Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34810 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbbGGCNI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 22:13:08 -0400
Received: by pdbep18 with SMTP id ep18so116007718pdb.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jul 2015 19:13:07 -0700 (PDT)
Message-ID: <559B35AE.60301@gmail.com>
Date: Tue, 07 Jul 2015 10:13:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 2/3] nfsd: Fix a memory leak in nfsd4_list_rec_dir()
References: <559B3573.4090307@gmail.com>
In-Reply-To: <559B3573.4090307@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If lookup_one_len() failed, nfsd should free those memory allocated for fname.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4recover.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d88ea7b..591bfbd 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -272,6 +272,7 @@ nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 		.ctx.actor = nfsd4_build_namelist,
 		.names = LIST_HEAD_INIT(ctx.names)
 	};
+	struct name_list *entry, *tmp;
 	int status;
 
 	status = nfs4_save_creds(&original_cred);
@@ -286,9 +287,8 @@ nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 
 	status = iterate_dir(nn->rec_file, &ctx.ctx);
 	mutex_lock_nested(&d_inode(dir)->i_mutex, I_MUTEX_PARENT);
-	while (!list_empty(&ctx.names)) {
-		struct name_list *entry;
-		entry = list_entry(ctx.names.next, struct name_list, list);
+
+	list_for_each_entry_safe(entry, tmp, &ctx.names, list) {
 		if (!status) {
 			struct dentry *dentry;
 			dentry = lookup_one_len(entry->name, dir, HEXDIR_LEN-1);
@@ -304,6 +304,12 @@ nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 	}
 	mutex_unlock(&d_inode(dir)->i_mutex);
 	nfs4_reset_creds(original_cred);
+
+	list_for_each_entry_safe(entry, tmp, &ctx.names, list) {
+		dprintk("NFSD: %s. Left entry %s\n", __func__, entry->name);
+		list_del(&entry->list);
+		kfree(entry);
+	}
 	return status;
 }
 
-- 
2.4.3

