Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53748 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756927Ab2EGOMa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 10:12:30 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so295845ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 May 2012 07:12:30 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 RESEND 09/12] vfs: make do_unlinkat retry on ESTALE errors
Date: Mon,  7 May 2012 10:12:08 -0400
Message-Id: <1336399931-20234-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
References: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 58f5eae..cee62f1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2863,8 +2863,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct dentry *dentry;
 	struct nameidata nd;
 	struct inode *inode = NULL;
-
-	error = user_path_parent(dfd, pathname, &nd, &name, false);
+	unsigned int try = 0;
+retry:
+	error = user_path_parent(dfd, pathname, &nd, &name, try);
 	if (error)
 		return error;
 
@@ -2903,6 +2904,8 @@ exit3:
 exit1:
 	path_put(&nd.path);
 	putname(name);
+	if (retry_estale(error, try++))
+		goto retry;
 	return error;
 
 slashes:
-- 
1.7.7.6

