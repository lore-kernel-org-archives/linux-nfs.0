Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162997AbbKTO45 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:57 -0500
Subject: [PATCH 12/12] fsinfo: CIFS: Return information through the
 filesystem info syscall
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:56:51 +0000
Message-ID: <20151120145651.18930.93196.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return CIFS filesystem information through the filesystem info retrieval
system call.  This includes the following:

 (1) information about the capacity and resolution of the inode timestamps;

 (2) information about the supported IOC flags;

and unless AT_NO_ATTR_SYNC is specified:

 (3) the statfs information retrieved from the server.

We could also return the server and/or domain name.

[NOTE: THIS PATCH IS UNTESTED!]

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cifs/cifsfs.c       |   25 +++++++++++++++++++++++++
 fs/cifs/netmisc.c      |    4 ----
 fs/ntfs/time.h         |    2 --
 include/linux/time64.h |    2 ++
 4 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index e739950ca084..213831972164 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -207,6 +207,30 @@ cifs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	return 0;
 }
 
+/*
+ * Read filesystem information.
+ */
+static int cifs_get_fsinfo(struct dentry *dentry, struct fsinfo *f,
+			   unsigned flags)
+{
+	f->f_namelen = PATH_MAX;
+
+	/* Times are signed 64-bit values with a granularity of 100ns
+	 * with a zero point of 1st Jan 1601.
+	 */
+	f->f_min_time = S64_MIN / 10000000 - NTFS_TIME_OFFSET;
+	f->f_max_time = S64_MAX / 10000000 - NTFS_TIME_OFFSET;
+	f->f_atime_gran_exponent = -7;
+	f->f_btime_gran_exponent = -7;
+	f->f_ctime_gran_exponent = -7;
+	f->f_mtime_gran_exponent = -7;
+
+	f->f_supported_ioc_flags =
+		FS_IMMUTABLE_FL | FS_COMPR_FL | FS_HIDDEN_FL |
+		FS_SYSTEM_FL | FS_ARCHIVE_FL;
+	return 0;
+}
+
 static long cifs_fallocate(struct file *file, int mode, loff_t off, loff_t len)
 {
 	struct cifs_sb_info *cifs_sb = CIFS_FILE_SB(file);
@@ -571,6 +595,7 @@ static int cifs_drop_inode(struct inode *inode)
 
 static const struct super_operations cifs_super_ops = {
 	.statfs = cifs_statfs,
+	.get_fsinfo	= cifs_get_fsinfo,
 	.alloc_inode = cifs_alloc_inode,
 	.destroy_inode = cifs_destroy_inode,
 	.drop_inode	= cifs_drop_inode,
diff --git a/fs/cifs/netmisc.c b/fs/cifs/netmisc.c
index abae6dd2c6b9..74fdbd8d824d 100644
--- a/fs/cifs/netmisc.c
+++ b/fs/cifs/netmisc.c
@@ -910,10 +910,6 @@ smbCalcSize(void *buf)
 		2 /* size of the bcc field */ + get_bcc(ptr));
 }
 
-/* The following are taken from fs/ntfs/util.c */
-
-#define NTFS_TIME_OFFSET ((u64)(369*365 + 89) * 24 * 3600 * 10000000)
-
 /*
  * Convert the NT UTC (based 1601-01-01, in hundred nanosecond units)
  * into Unix UTC (based 1970-01-01, in seconds).
diff --git a/fs/ntfs/time.h b/fs/ntfs/time.h
index 01233989d5d1..7b546d0615ca 100644
--- a/fs/ntfs/time.h
+++ b/fs/ntfs/time.h
@@ -27,8 +27,6 @@
 
 #include "endian.h"
 
-#define NTFS_TIME_OFFSET ((s64)(369 * 365 + 89) * 24 * 3600 * 10000000)
-
 /**
  * utc2ntfs - convert Linux UTC time to NTFS time
  * @ts:		Linux UTC time to convert to NTFS time
diff --git a/include/linux/time64.h b/include/linux/time64.h
index 367d5af899e8..a12f6384febf 100644
--- a/include/linux/time64.h
+++ b/include/linux/time64.h
@@ -6,6 +6,8 @@
 
 typedef __s64 time64_t;
 
+#define NTFS_TIME_OFFSET ((u64)(369*365 + 89) * 24 * 3600 * 10000000)
+
 /*
  * This wants to go into uapi/linux/time.h once we agreed about the
  * userspace interfaces.

