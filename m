Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:54525 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756939Ab2J0Meo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:44 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so690987yhm.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:44 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 32/32] vfs: make number of ESTALE retries tunable
Date: Sat, 27 Oct 2012 08:33:39 -0400
Message-Id: <1351341219-17837-33-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         | 2 ++
 include/linux/fs.h | 4 +++-
 kernel/sysctl.c    | 7 +++++++
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6886630..1ae2c06 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -110,6 +110,8 @@
  * any extra contention...
  */
 
+unsigned int estale_retries __read_mostly = 1;
+
 /* In order to reduce some races, while at the same time doing additional
  * checking and hopefully speeding things up, we copy filenames to the
  * kernel data space before using them..
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 01ff902..119a0f0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2023,6 +2023,8 @@ extern int finish_open(struct file *file, struct dentry *dentry,
 			int *opened);
 extern int finish_no_open(struct file *file, struct dentry *dentry);
 
+extern unsigned int estale_retries;
+
 /**
  * retry_estale - determine whether the caller should retry an operation
  *
@@ -2041,7 +2043,7 @@ retry_estale(const long error, const unsigned int try)
 	if (likely(error != -ESTALE))
 		return false;
 
-	return !try;
+	return (try <= estale_retries);
 }
 
 /* fs/ioctl.c */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..24735db 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1545,6 +1545,13 @@ static struct ctl_table fs_table[] = {
 		.proc_handler	= &pipe_proc_fn,
 		.extra1		= &pipe_min_size,
 	},
+	{
+		.procname	= "estale_retries",
+		.data		= &estale_retries,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
-- 
1.7.11.7

