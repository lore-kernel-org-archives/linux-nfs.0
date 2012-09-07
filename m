Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37611 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760755Ab2IGOTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:19:03 -0400
Received: by vbbff1 with SMTP id ff1so3364273vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:19:02 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 17/20] vfs: make fchmodat retry once on ESTALE errors
Date: Fri,  7 Sep 2012 10:18:24 -0400
Message-Id: <1347027507-20956-18-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index a015cb8..232cbfb 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -506,12 +506,17 @@ SYSCALL_DEFINE3(fchmodat, int, dfd, const char __user *, filename, umode_t, mode
 {
 	struct path path;
 	int error;
+	unsigned int try = 0;
+	int lookup_flags = LOOKUP_FOLLOW;
 
-	error = user_path_at(dfd, filename, LOOKUP_FOLLOW, &path);
-	if (!error) {
+	do {
+		error = user_path_at(dfd, filename, lookup_flags, &path);
+		if (error)
+			break;
 		error = chmod_common(&path, mode);
 		path_put(&path);
-	}
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.4

