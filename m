Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f44.google.com ([209.85.212.44]:55680 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932889Ab3JNU27 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 16:28:59 -0400
From: "Geyslan G. Bem" <geyslan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-br@googlegroups.com,
        "Geyslan G. Bem" <geyslan@gmail.com>
Subject: [PATCH v2] nfs: Use PTR_ERR_OR_ZERO in 'nfs/nfs4super.c'
Date: Mon, 14 Oct 2013 17:24:16 -0300
Message-Id: <1381782256-2434-2-git-send-email-geyslan@gmail.com>
In-Reply-To: <1381782256-2434-1-git-send-email-geyslan@gmail.com>
References: <1381782256-2434-1-git-send-email-geyslan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use 'PTR_ERR_OR_ZERO()' rather than 'IS_ERR(...) ? PTR_ERR(...) : 0'.

Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
---
 fs/nfs/nfs4super.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index e26acdd..65ab0a0 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -261,9 +261,9 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	res = nfs_follow_remote_path(root_mnt, export_path);
 
-	dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
+	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
+		 PTR_ERR_OR_ZERO(res),
+		 IS_ERR(res) ? " [error]" : "");
 	return res;
 }
 
@@ -319,9 +319,9 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	data->mnt_path = export_path;
 
 	res = nfs_follow_remote_path(root_mnt, export_path);
-	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
+	dprintk("<-- nfs4_referral_mount() = %d%s\n",
+		PTR_ERR_OR_ZERO(res),
+		IS_ERR(res) ? " [error]" : "");
 	return res;
 }
 
-- 
1.8.4

