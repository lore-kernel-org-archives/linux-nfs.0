Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f170.google.com ([209.85.214.170]:34684 "EHLO
	mail-iw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab0LLNCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Dec 2010 08:02:38 -0500
Received: by mail-iw0-f170.google.com with SMTP id 6so7769892iwn.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Dec 2010 05:02:37 -0800 (PST)
From: bookjovi@gmail.com
To: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Jovi Zhang <bookjovi@gmail.com>
Subject: [PATCH] nfs: add missed CONFIG_NFSD_DEPRECATED
Date: Sat, 11 Dec 2010 00:21:17 -0500
Message-Id: <1292044877-4701-1-git-send-email-bookjovi@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

these pieces of code only make sense when CONFIG_NFSD_DEPRECATED enabled

Signed-off-by: Jovi Zhang <bookjovi@gmail.com>

 fs/nfsd/nfsctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4514ebb..6840ec3 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -127,6 +127,7 @@ static ssize_t nfsctl_transaction_write(struct file *file, const char __user *bu
 
 static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
 {
+#ifdef CONFIG_NFSD_DEPRECATED
 	static int warned;
 	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
 		printk(KERN_INFO
@@ -135,6 +136,7 @@ static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size
 		       current->comm, file->f_dentry->d_name.name);
 		warned = 1;
 	}
+#endif
 	if (! file->private_data) {
 		/* An attempt to read a transaction file without writing
 		 * causes a 0-byte write so that the file can return
