Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46400 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752346AbdLKGEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 01:04:47 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 11 Dec 2017 17:04:05 +1100
Subject: [PATCH 4/4] fhandle: Improve error responses in name_to_handle_at()
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Message-ID: <151297224523.7818.12267549679803980398.stgit@noble>
In-Reply-To: <151297214390.7818.7216826079527521005.stgit@noble>
References: <151297214390.7818.7216826079527521005.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1/ Always return the mnt_id, even if some other error occurs.
   It can be useful without the file handle.
   An application can initialise the memory to, e.g. -1
   and if there is some other value after name_to_handle_at()
   returns, then it is a valid mnt_id.
   If the value is unchanged, then the kernel does not
   have this patch.

2/ Don't return -EINVAL if the requested handle_bytes is
   larger than MAX_HANDLE_SZ.  There is no need for an
   error and it causes unnecessary behavior change
   in the kernel ever needs to increase MAX_HANDLE_SZ.
   Simple limit handle_bytes to MAX_HANDLE_SZ silently.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/fhandle.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 0ace128f5d23..04afffaeb742 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -23,9 +23,16 @@ static long do_sys_name_to_handle(struct path *path,
 	int handle_dwords, handle_bytes;
 	struct file_handle *handle = NULL;
 
+	/*
+	 * Always return the mnt_id, it might be useful even
+	 * without the file handle
+	 */
+	if (copy_to_user(mnt_id, &real_mount(path->mnt)->mnt_id,
+			 sizeof(*mnt_id)))
+		return -EFAULT;
 	/*
 	 * We need to make sure whether the file system
-	 * support decoding of the file handle
+	 * supports decoding of the file handle.
 	 */
 	if (!path->dentry->d_sb->s_export_op ||
 	    !path->dentry->d_sb->s_export_op->fh_to_dentry)
@@ -35,7 +42,7 @@ static long do_sys_name_to_handle(struct path *path,
 		return -EFAULT;
 
 	if (f_handle.handle_bytes > MAX_HANDLE_SZ)
-		return -EINVAL;
+		f_handle.handle_bytes = MAX_HANDLE_SZ;
 
 	handle = kmalloc(sizeof(struct file_handle) + f_handle.handle_bytes,
 			 GFP_KERNEL);
@@ -68,10 +75,7 @@ static long do_sys_name_to_handle(struct path *path,
 		retval = -EOVERFLOW;
 	} else
 		retval = 0;
-	/* copy the mount id */
-	if (copy_to_user(mnt_id, &real_mount(path->mnt)->mnt_id,
-			 sizeof(*mnt_id)) ||
-	    copy_to_user(ufh, handle,
+	if (copy_to_user(ufh, handle,
 			 sizeof(struct file_handle) + handle_bytes))
 		retval = -EFAULT;
 	kfree(handle);


