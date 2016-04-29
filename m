Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcD2M6Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 08:58:16 -0400
Subject: [PATCH 5/6] statx: Make windows attributes available for CIFS,
 NTFS and FAT to use
From: David Howells <dhowells@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Date: Fri, 29 Apr 2016 13:58:14 +0100
Message-ID: <20160429125813.23636.49830.stgit@warthog.procyon.org.uk>
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make windows attributes available for CIFS, NTFS and FAT to use in the
statx struct.  The attribute flags map directly by value to those in the
CIFS PDU flags.  Some of these bits can also be used by JFS, UFS and HPFS.

The statx struct acquires:

	__u32	st_win_attrs;

The value in this is present if STATX_WIN_ATTRS is set.

The defined flags in this are:

	STATX_WIN_ATTR_READONLY
	STATX_WIN_ATTR_HIDDEN
	STATX_WIN_ATTR_SYSTEM
	STATX_WIN_ATTR_DIRECTORY
	STATX_WIN_ATTR_ARCHIVE
	STATX_WIN_ATTR_NORMAL
	STATX_WIN_ATTR_TEMPORARY
	STATX_WIN_ATTR_SPARSE_FILE
	STATX_WIN_ATTR_REPARSE_POINT
	STATX_WIN_ATTR_COMPRESSED
	STATX_WIN_ATTR_OFFLINE
	STATX_WIN_ATTR_NOT_CONTENT_INDEXED
	STATX_WIN_ATTR_ENCRYPTED
	STATX_WIN_ATTR_INTEGRITY_STREAM
	STATX_WIN_ATTR_NO_SCRUB_DATA

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/stat.c                  |    5 ++++-
 include/uapi/linux/stat.h  |   30 ++++++++++++++++++++++++++++--
 samples/statx/test-statx.c |   31 +++++++++++++++++++++++++++++++
 3 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index c2f8370dab13..1552bff154e6 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -83,6 +83,7 @@ int vfs_xgetattr_nosec(struct path *path, struct kstat *stat)
 
 	stat->result_mask = 0;
 	stat->information = 0;
+	stat->win_attrs = 0;
 	if (inode->i_op->getattr)
 		return inode->i_op->getattr(path->mnt, path->dentry, stat);
 
@@ -643,7 +644,9 @@ static long statx_set_result(struct kstat *stat, struct statx __user *buffer)
 	    __put_user(stat->blocks,		&buffer->st_blocks	) ||
 	    __put_user(stat->version,		&buffer->st_version	) ||
 	    __put_user(stat->gen,		&buffer->st_gen		) ||
-	    __clear_user(&buffer->__spare1, sizeof(buffer->__spare1)))
+	    __put_user(stat->win_attrs,		&buffer->st_win_attrs	) ||
+	    __clear_user(&buffer->__spare1,
+			 sizeof(buffer->__spare1) + sizeof(buffer->__spare2)))
 		return -EFAULT;
 
 	return 0;
diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
index 55ce6607dab6..64729b0785bf 100644
--- a/include/uapi/linux/stat.h
+++ b/include/uapi/linux/stat.h
@@ -106,7 +106,10 @@ struct statx {
 	__u32	st_dev_major;	/* ID of device containing file [uncond] */
 	__u32	st_dev_minor;
 	/* 0x80 */
-	__u64	__spare1[16];	/* Spare space for future expansion */
+	__u32	st_win_attrs;	/* Windows file attributes */
+	__u32	__spare1[3];
+	/* 0x90 */
+	__u64	__spare2[14];	/* Spare space for future expansion */
 	/* 0x100 */
 };
 
@@ -133,7 +136,8 @@ struct statx {
 #define STATX_BTIME		0x00000800U	/* Want/got st_btime */
 #define STATX_VERSION		0x00001000U	/* Want/got st_version */
 #define STATX_GEN		0x00002000U	/* Want/got st_gen */
-#define STATX_ALL_STATS		0x00003fffU	/* All supported stats */
+#define STATX_WIN_ATTRS		0x00004000U	/* Want/got st_win_attrs */
+#define STATX_ALL_STATS		0x00007fffU	/* All supported stats */
 
 /*
  * Flags to be found in st_information
@@ -151,4 +155,26 @@ struct statx {
 #define STATX_INFO_AUTODIR		0x00000040U /* Dir provides unlisted automounts */
 #define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000080U /* File has non-system ownership details */
 
+/*
+ * Flags to be found in st_win_attrs.
+ *
+ * These give information about the state of a file on a Windows filesystem
+ * (such as. FAT, NTFS, CIFS).  These values are borrowed from the CIFS fs.
+ */
+#define STATX_WIN_ATTR_READONLY			0x00000001
+#define STATX_WIN_ATTR_HIDDEN			0x00000002
+#define STATX_WIN_ATTR_SYSTEM			0x00000004
+#define STATX_WIN_ATTR_DIRECTORY		0x00000010
+#define STATX_WIN_ATTR_ARCHIVE			0x00000020
+#define STATX_WIN_ATTR_NORMAL			0x00000080
+#define STATX_WIN_ATTR_TEMPORARY		0x00000100
+#define STATX_WIN_ATTR_SPARSE_FILE		0x00000200
+#define STATX_WIN_ATTR_REPARSE_POINT		0x00000400
+#define STATX_WIN_ATTR_COMPRESSED		0x00000800
+#define STATX_WIN_ATTR_OFFLINE			0x00001000
+#define STATX_WIN_ATTR_NOT_CONTENT_INDEXED	0x00002000
+#define STATX_WIN_ATTR_ENCRYPTED		0x00004000
+#define STATX_WIN_ATTR_INTEGRITY_STREAM		0x00008000
+#define STATX_WIN_ATTR_NO_SCRUB_DATA		0x00020000
+
 #endif /* _UAPI_LINUX_STAT_H */
diff --git a/samples/statx/test-statx.c b/samples/statx/test-statx.c
index 38ef23c12e7d..86eac7d16c32 100644
--- a/samples/statx/test-statx.c
+++ b/samples/statx/test-statx.c
@@ -134,6 +134,37 @@ static void dump_statx(struct statx *stx)
 	if (stx->st_mask & STATX_GEN)
 		printf("Inode gen   : %xh\n", stx->st_gen);
 
+	if (stx->st_mask & STATX_WIN_ATTRS) {
+		unsigned char bits;
+		int loop, byte;
+
+		static char wattr_representation[32 + 1] =
+			/* STATX_WIN_ATTR_ flags: */
+			"????????"	/* 31-24	0x00000000-ff000000 */
+			"??????N?"	/* 23-16	0x00000000-00ff0000 */
+			"ieNocrst"	/* 15- 8	0x00000000-0000ff00 */
+			"n?Ad?SHR"	/*  7- 0	0x00000000-000000ff */
+			;
+
+		printf("Win attrs  : %08llx (",
+		       (unsigned long long)stx->st_win_attrs);
+		for (byte = 32 - 8; byte >= 0; byte -= 8) {
+			bits = stx->st_win_attrs >> byte;
+			for (loop = 7; loop >= 0; loop--) {
+				int bit = byte + loop;
+
+				if (bits & 0x80)
+					putchar(wattr_representation[31 - bit]);
+				else
+					putchar('-');
+				bits <<= 1;
+			}
+			if (byte)
+				putchar(' ');
+		}
+		printf(")\n");
+	}
+
 	if (stx->st_information) {
 		unsigned char bits;
 		int loop, byte;

