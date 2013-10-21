Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f173.google.com ([209.85.213.173]:61094 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab3JUNwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 09:52:30 -0400
Received: by mail-ye0-f173.google.com with SMTP id m4so1602000yen.32
        for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 06:52:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix handling of invalid mount options in nfs_remount
Date: Mon, 21 Oct 2013 09:52:19 -0400
Message-Id: <1382363539-6549-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_parse_mount_options returns 0 on error, not -errno.

Reported-by: Karel Zak <kzak@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 137572b..3f5a7a8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2205,8 +2205,8 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 		data->nfs_server.addrlen);
 
 	/* overwrite those values with any that were specified */
-	error = nfs_parse_mount_options((char *)options, data);
-	if (error < 0)
+	error = -EINVAL;
+	if (!nfs_parse_mount_options((char *)options, data))
 		goto out;
 
 	/*
-- 
1.8.3.1

