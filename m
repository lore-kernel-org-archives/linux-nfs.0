Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy9.bluehost.com ([69.89.24.6]:55811 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753685Ab3EIQig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:38:36 -0400
Message-ID: <1368117511.5695.34.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 3/5] hfsplus: add all neccessary declarations for ACLs
 support
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:38:31 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vyacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v4 3/5] hfsplus: add all neccessary declarations for ACLs support

This patch adds declaration of all necessary structures that are necessary for ACLs support, special ACL-related flag for debug output and dprint_hexdump() macro.

Signed-off-by: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
CC: Hin-Tak Leung <htl10@users.sourceforge.net>
---
 fs/hfsplus/hfsplus_fs.h  |    8 ++++++++
 fs/hfsplus/hfsplus_raw.h |   26 ++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/fs/hfsplus/hfsplus_fs.h b/fs/hfsplus/hfsplus_fs.h
index 60b0a33..3b3896a 100644
--- a/fs/hfsplus/hfsplus_fs.h
+++ b/fs/hfsplus/hfsplus_fs.h
@@ -30,6 +30,7 @@
 #define DBG_EXTENT	0x00000020
 #define DBG_BITMAP	0x00000040
 #define DBG_ATTR_MOD	0x00000080
+#define DBG_ACL_MOD	0x00000100
 
 #if 0
 #define DBG_MASK	(DBG_EXTENT|DBG_INODE|DBG_BNODE_MOD)
@@ -50,6 +51,13 @@ do {								\
 		pr_cont(fmt, ##__VA_ARGS__);			\
 } while (0)
 
+#define hfs_dbg_hexdump(flg, prefix, ptr, size)			\
+do {								\
+	if (DBG_##flg & DBG_MASK)				\
+		print_hex_dump_bytes(prefix,			\
+				DUMP_PREFIX_NONE, ptr, size);	\
+} while (0)
+
 /* Runtime config options */
 #define HFSPLUS_DEF_CR_TYPE    0x3F3F3F3F  /* '????' */
 
diff --git a/fs/hfsplus/hfsplus_raw.h b/fs/hfsplus/hfsplus_raw.h
index 452ede0..758b7ad 100644
--- a/fs/hfsplus/hfsplus_raw.h
+++ b/fs/hfsplus/hfsplus_raw.h
@@ -382,6 +382,32 @@ struct hfsplus_attr_inline_data {
 	u8 raw_bytes[HFSPLUS_MAX_INLINE_DATA_SIZE];
 } __packed;
 
+#define HFSPLUS_GUID_SIZE 16 /* 128-bit */
+
+/* Access Control List Entry (ACE) */
+struct hfsplus_acl_entry {
+	u8 ace_applicable[HFSPLUS_GUID_SIZE]; /* Apple-style identifier */
+	__be32 ace_flags;
+	__be32 ace_rights;
+} __packed;
+
+/* Access Control List */
+struct hfsplus_acl_record {
+	__be32 acl_entrycount;
+	__be32 acl_flags;
+	struct hfsplus_acl_entry acl_ace[0];
+} __packed;
+
+#define HFSPLUS_FILESEC_MAGIC 0x012cc16d
+
+/* HFS+ File Security information */
+struct hfsplus_filesec {
+	__be32 fsec_magic;
+	u8 fsec_owner[HFSPLUS_GUID_SIZE];
+	u8 fsec_group[HFSPLUS_GUID_SIZE];
+	struct hfsplus_acl_record fsec_acl;
+} __packed;
+
 /* A data record in the attributes tree */
 typedef union {
 	__be32 record_type;
-- 
1.7.9.5



