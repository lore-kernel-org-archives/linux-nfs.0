Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35182 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758112AbbFQHv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 03:51:29 -0400
Message-ID: <558126FA.8050608@gmail.com>
Date: Wed, 17 Jun 2015 15:51:22 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 3/6 v5] fs_pin: Kill fs_pin under a reference of vfsmnt
References: <5581266C.9080404@gmail.com>
In-Reply-To: <5581266C.9080404@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v5, new patch

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namespace.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 1b9e111..3f08a48 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1049,8 +1049,6 @@ static void cleanup_mnt(struct mount *mnt)
 	 * so mnt_get_writers() below is safe.
 	 */
 	WARN_ON(mnt_get_writers(mnt));
-	if (unlikely(mnt->mnt_pins.first))
-		mnt_pin_kill(mnt);
 	fsnotify_vfsmount_delete(&mnt->mnt);
 	dput(mnt->mnt.mnt_root);
 	deactivate_super(mnt->mnt.mnt_sb);
@@ -1078,6 +1076,7 @@ static DECLARE_DELAYED_WORK(delayed_mntput_work, delayed_mntput);
 
 static void mntput_no_expire(struct mount *mnt)
 {
+put_again:
 	rcu_read_lock();
 	mnt_add_count(mnt, -1);
 	if (likely(mnt->mnt_ns)) { /* shouldn't be the last one */
@@ -1090,6 +1089,13 @@ static void mntput_no_expire(struct mount *mnt)
 		unlock_mount_hash();
 		return;
 	}
+	if (unlikely(mnt->mnt_pins.first)) {
+		mnt_add_count(mnt, 1);
+		rcu_read_unlock();
+		unlock_mount_hash();
+		mnt_pin_kill(mnt);
+		goto put_again;
+	}
 	if (unlikely(mnt->mnt.mnt_flags & MNT_DOOMED)) {
 		rcu_read_unlock();
 		unlock_mount_hash();
-- 
2.4.3

