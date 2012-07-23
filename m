Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:63631 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410Ab2GWTqe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jul 2012 15:46:34 -0400
Received: by gglu4 with SMTP id u4so5884605ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jul 2012 12:46:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: viro@ZenIV.linux.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: explicitly reject LOCK_MAND flock() requests
Date: Mon, 23 Jul 2012 15:46:23 -0400
Message-Id: <1343072783-29737-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have no mechanism to emulate LOCK_MAND locks on NFSv4, so explicitly
return -EINVAL if someone requests it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 61d3670..15f4bbb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -834,6 +834,15 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (!(fl->fl_flags & FL_FLOCK))
 		return -ENOLCK;
 
+	/*
+	 * The NFSv4 protocol doesn't support LOCK_MAND, which is not part of
+	 * any standard. In principle we might be able to support LOCK_MAND
+	 * on NFSv2/3 since NLMv3/4 support DOS share modes, but for now the
+	 * NFS code is not set up for it.
+	 */
+	if (fl->fl_type & LOCK_MAND)
+		return -EINVAL;
+
 	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
 		is_local = 1;
 
-- 
1.7.10.4

