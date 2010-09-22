Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54920 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab0IVC6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:58:11 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:07 +1000
Subject: [PATCH 6/7] nfsd: formally deprecate legacy nfsd syscall interface
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025507.31745.57024.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The syscall interface is has been replaced by a more flexible
interface since 2.6.0.  It is time to work towards discarding
the old interface.

So add a entry in feature-removal-schedule.txt and print a warning
when the interface is used.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 Documentation/feature-removal-schedule.txt |   10 ++++++++++
 fs/nfsd/nfsctl.c                           |   10 ++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 842aa9d..076a2c0 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -564,3 +564,13 @@ Who:	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
 
 ----------------------------
 
+What:   access to nfsd auth cache through sys_nfsservctl or '.' files
+        in the 'nfsd' filesystem.
+When:   2.6.40
+Why:    This is a legacy interface which have been replaced by a more
+        dynamic cache.  Continuing to maintain this interface is an
+        unnecessary burden.
+Who:    NeilBrown <neilb@suse.de>
+
+----------------------------
+	
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b53b1d0..7f0fc88 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -121,6 +121,16 @@ static ssize_t nfsctl_transaction_write(struct file *file, const char __user *bu
 
 static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
 {
+	static int warned;
+	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
+		char name[sizeof(current->comm)];
+		printk(KERN_INFO
+		       "Warning: \"%s\" uses deprecated NFSD interface: %s."
+		       "  This will be removed in 2.6.40\n",
+		       get_task_comm(name, current),
+		       file->f_dentry->d_name.name);
+		warned = 1;
+	}
 	if (! file->private_data) {
 		/* An attempt to read a transaction file without writing
 		 * causes a 0-byte write so that the file can return


