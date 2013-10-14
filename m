Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:52142 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab3JNTMK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 15:12:10 -0400
From: "Geyslan G. Bem" <geyslan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-br@googlegroups.com, "Geyslan G. Bem" <geyslan@gmail.com>
Subject: [PATCH] nfs: Use PTR_ERR_OR_ZERO in 'nfs/nfs4super.c'
Date: Mon, 14 Oct 2013 16:07:41 -0300
Message-Id: <1381777661-28780-2-git-send-email-geyslan@gmail.com>
In-Reply-To: <1381777661-28780-1-git-send-email-geyslan@gmail.com>
References: <1381777661-28780-1-git-send-email-geyslan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use 'PTR_ERR_OR_ZERO()' rather than 'IS_ERR(...) ? PTR_ERR(...) : 0'.

Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
---
 fs/nfs/nfs4super.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index e26acdd..ef71077 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -262,8 +262,8 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	res = nfs_follow_remote_path(root_mnt, export_path);
 
 	dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
+		 PTR_ERR_OR_ZERO(res),
+		 IS_ERR(res) ? " [error]" : "");
 	return res;
 }
 
@@ -320,8 +320,8 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 
 	res = nfs_follow_remote_path(root_mnt, export_path);
 	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
+		PTR_ERR_OR_ZERO(res),
+		IS_ERR(res) ? " [error]" : "");
 	return res;
 }
 
-- 
1.8.4

