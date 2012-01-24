Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56112 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab2AXQfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2012 11:35:05 -0500
Received: by qadc10 with SMTP id c10so274599qad.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 08:35:04 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, eparis@redhat.com
Subject: [PATCH] nfs: remove unneeded NULL pointer check in nfs4_remote_mount
Date: Tue, 24 Jan 2012 11:35:00 -0500
Message-Id: <1327422900-14475-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"data" is never NULL here.

Reported-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3dfa4f1..5499316 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2663,8 +2663,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(
-			s, data ? data->fscache_uniq : NULL, NULL);
+		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
 	}
 
 	mntroot = nfs4_get_root(s, mntfh, dev_name);
-- 
1.7.7.5

