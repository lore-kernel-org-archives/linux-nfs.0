Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:18961 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739Ab1EaR0g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 13:26:36 -0400
Subject: Re: infinite getdents64 loop
Content-Type: multipart/mixed; boundary=Apple-Mail-20--9407446
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20110531123518.GB4215@thunk.org>
Date: Tue, 31 May 2011 11:26:30 -0600
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org,
        "linux-ext4@vger.kernel.org List" <linux-ext4@vger.kernel.org>,
        Fan Yong <yong.fan@whamcloud.com>
Message-Id: <D598829B-FB36-4DA8-978E-8C689940D0FA@dilger.ca>
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org>
To: "Ted Ts'o" <tytso@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Apple-Mail-20--9407446
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On 2011-05-31, at 6:35 AM, Ted Ts'o wrote:
> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
>> 
>> Out of interest, did anyone ever benchmark if dirindex provides any
>> advantages to readdir?  And did those benchmarks include the
>> disadvantages of the present implementation (non-linear inode
>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
>> 'rm -fr $dir')?
> 
> The problem is that seekdir/telldir is terminally broken (and so is
> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
> a linear data structure.  If you're going to use any kind of
> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
> doesn't cut it.  We actually play games where we memoize the low
> 32-bits of the hash and keep track of which cookies we hand out via
> seekdir/telldir so that things mostly work --- except for NFSv2, where
> with the 32-bit cookie, you're just hosed.
> 
> The reason why we have to iterate over the directory in hash tree
> order is because if we have a leaf node split, half the directories
> entries get copied to another directory entry, given the promises made
> by seekdir() and telldir() about directory entries appearing exactly
> once during a readdir() stream, even if you hold the fd open for weeks
> or days, mean that you really have to iterate over things in hash
> order.
> 
> I'd have to look, since it's been too many years, but as I recall the
> problem was that there is a common path for NFSv2 and NFSv3/v4, so we
> don't know whether we can hand back a 32-bit cookie or a 64-bit
> cookie, so we're always handing the NFS server a 32-bit "offset", even
> though ew could do better.  Actually, if we had an interface where we
> could give you a 128-bit "offset" into the directory, we could
> probably eliminate the duplicate cookie problem entirely.  We just
> send 64-bits worth of hash, plus the first two bytes of the of file
> name.

If it's of interest, we've implemented a 64-bit hash mode for ext4 to
solve just this problem for Lustre.  The llseek() code will return a
64-bit hash value on 64-bit systems, unless it is running for some
process that needs a 32-bit hash value (only NFSv2, AFAIK).

The attached patch can at least form the basis for being able to return
64-bit hash values for userspace/NFSv3/v4 when usable.  The patch
is NOT usable as it stands now, since I've had to modify it from the
version that we are currently using for Lustre (this version hasn't
actually been compiled), but it at least shows the outline of what needs
to be done to get this working.  None of the NFS side is implemented.

>> 3) Disable dirindexing for readdirs
> 
> That won't work, since it will break POSIX compliance.  Once again,
> we're tied by the decisions made decades ago...


Cheers, Andreas





--Apple-Mail-20--9407446
Content-Disposition: attachment;
	filename=ext4-export-64bit-name-hash.patch
Content-Type: application/octet-stream;
	name="ext4-export-64bit-name-hash.patch"
Content-Transfer-Encoding: 7bit

Return 32/64-bit dir name hash according to usage type

Traditionally ext2/3/4 has returned a 32-bit hash value from llseek()
to appease NFSv2, which can only handle a 32-bit cookie for seekdir()
and telldir().  However, this causes problems if there are 32-bit hash
collisions, since the NFSv2 server can get stuck resending the same
entries from the directory repeatedly.

Allow ext4 to return a full 64-bit hash (both major and minor) for
telldir to decrease the chance of hash collisions.  This still needs
integration on the NFS side and 

Signed-off-by: Fan Yong <yong.fan@whamcloud.com>
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>

diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 164c560..580f4e8 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -32,24 +32,8 @@ static unsigned char ext4_filetype_table[] = {
 	DT_UNKNOWN, DT_REG, DT_DIR, DT_CHR, DT_BLK, DT_FIFO, DT_SOCK, DT_LNK
 };
 
-static int ext4_readdir(struct file *, void *, filldir_t);
 static int ext4_dx_readdir(struct file *filp,
 			   void *dirent, filldir_t filldir);
-static int ext4_release_dir(struct inode *inode,
-				struct file *filp);
-
-const struct file_operations ext4_dir_operations = {
-	.llseek		= ext4_llseek,
-	.read		= generic_read_dir,
-	.readdir	= ext4_readdir,		/* we take BKL. needed?*/
-	.unlocked_ioctl = ext4_ioctl,
-#ifdef CONFIG_COMPAT
-	.compat_ioctl	= ext4_compat_ioctl,
-#endif
-	.fsync		= ext4_sync_file,
-	.release	= ext4_release_dir,
-};
-
 
 static unsigned char get_dtype(struct super_block *sb, int filetype)
 {
@@ -254,22 +238,91 @@ out:
 	return ret;
 }
 
+static inline int is_32bit_api(void)
+{
+#ifdef HAVE_IS_COMPAT_TASK
+        return is_compat_task();
+#else
+        return (BITS_PER_LONG == 32);
+#endif
+}
+
 /*
  * These functions convert from the major/minor hash to an f_pos
  * value.
  *
- * Currently we only use major hash numer.  This is unfortunate, but
- * on 32-bit machines, the same VFS interface is used for lseek and
- * llseek, so if we use the 64 bit offset, then the 32-bit versions of
- * lseek/telldir/seekdir will blow out spectacularly, and from within
- * the ext2 low-level routine, we don't know if we're being called by
- * a 64-bit version of the system call or the 32-bit version of the
- * system call.  Worse yet, NFSv2 only allows for a 32-bit readdir
- * cookie.  Sigh.
+ * Upper layer should specify O_32BITHASH or O_64BITHASH explicitly.
+ * On the other hand, we allow ext4 to be mounted directly on both 32-bit
+ * and 64-bit nodes, under such case, neither O_32BITHASH nor O_64BITHASH
+ * is specified.
+ */
+static inline loff_t hash2pos(struct file *filp, __u32 major, __u32 minor)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return (major >> 1);
+	else
+		return (((__u64)(major >> 1) << 32) | (__u64)minor);
+}
+
+static inline __u32 pos2maj_hash(struct file *filp, loff_t pos)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return ((pos << 1) & 0xffffffff);
+	else
+		return (((pos >> 32) << 1) & 0xffffffff);
+}
+
+static inline __u32 pos2min_hash(struct file *filp, loff_t pos)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return (0);
+	else
+		return (pos & 0xffffffff);
+}
+
+/*
+ * ext4_dir_llseek() based on generic_file_llseek() to handle both
+ * non-htree and htree directories, where the "offset" is in terms
+ * of the filename hash value instead of the byte offset.
  */
-#define hash2pos(major, minor)	(major >> 1)
-#define pos2maj_hash(pos)	((pos << 1) & 0xffffffff)
-#define pos2min_hash(pos)	(0)
+loff_t ext4_llseek(struct file *file, loff_t offset, int origin)
+{
+	struct inode *inode = file->f_mapping->host;
+	int need_32bit = is_32bit_api();
+	loff_t max_off, ret = -EINVAL;
+
+	mutex_lock(&inode->i_mutex);
+	switch (origin) {
+	case SEEK_SET:
+		break;
+	case SEEK_CUR:
+		offset += file->f_pos;
+		break;
+	case SEEK_END:
+		if (offset > 0)
+			goto out;
+		if (ext4_test_inode_flag(inode, EXT4_INODE_INDEX))
+			max_off = hash2pos(file, 0xffffffff, 0xffffffff);
+		else
+			max_off = inode->i_size;
+		offset += max_off;
+		break;
+	default:
+		goto out;
+	}
+
+	if (offset >= 0 && offset < max_off && offset != file->f_pos) {
+		file->f_pos = offset;
+		file->f_version = 0;
+	}
+out:
+	mutex_unlock(&inode->i_mutex);
+
+	return ret;
+}
 
 /*
  * This structure holds the nodes of the red-black tree used to store
@@ -330,15 +383,16 @@ static void free_rb_tree_fname(struct rb_root *root)
 }
 
 
-static struct dir_private_info *ext4_htree_create_dir_info(loff_t pos)
+static struct dir_private_info *ext4_htree_create_dir_info(struct file *filp,
+							   loff_t pos)
 {
 	struct dir_private_info *p;
 
 	p = kzalloc(sizeof(struct dir_private_info), GFP_KERNEL);
 	if (!p)
 		return NULL;
-	p->curr_hash = pos2maj_hash(pos);
-	p->curr_minor_hash = pos2min_hash(pos);
+	p->curr_hash = pos2maj_hash(filp, pos);
+	p->curr_minor_hash = pos2min_hash(filp, pos);
 	return p;
 }
 
@@ -429,7 +483,7 @@ static int call_filldir(struct file *filp, void *dirent,
 		       "null fname?!?\n");
 		return 0;
 	}
-	curr_pos = hash2pos(fname->hash, fname->minor_hash);
+	curr_pos = hash2pos(filp, fname->hash, fname->minor_hash);
 	while (fname) {
 		error = filldir(dirent, fname->name,
 				fname->name_len, curr_pos,
@@ -454,7 +508,7 @@ static int ext4_dx_readdir(struct file *filp,
 	int	ret;
 
 	if (!info) {
-		info = ext4_htree_create_dir_info(filp->f_pos);
+		info = ext4_htree_create_dir_info(filp, filp->f_pos);
 		if (!info)
 			return -ENOMEM;
 		filp->private_data = info;
@@ -468,8 +522,8 @@ static int ext4_dx_readdir(struct file *filp,
 		free_rb_tree_fname(&info->root);
 		info->curr_node = NULL;
 		info->extra_fname = NULL;
-		info->curr_hash = pos2maj_hash(filp->f_pos);
-		info->curr_minor_hash = pos2min_hash(filp->f_pos);
+		info->curr_hash = pos2maj_hash(filp, filp->f_pos);
+		info->curr_minor_hash = pos2min_hash(filp, filp->f_pos);
 	}
 
 	/*
@@ -540,3 +594,15 @@ static int ext4_release_dir(struct inode *inode, struct file *filp)
 
 	return 0;
 }
+
+const struct file_operations ext4_dir_operations = {
+	.llseek		= ext4_dir_llseek,
+	.read		= generic_read_dir,
+	.readdir	= ext4_readdir,		/* we take BKL. needed?*/
+	.unlocked_ioctl = ext4_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ext4_compat_ioctl,
+#endif
+	.fsync		= ext4_sync_file,
+	.release	= ext4_release_dir,
+};
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 1921392..50e5b1b 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -56,6 +56,14 @@
 #define ext4_debug(f, a...)	do {} while (0)
 #endif
 
+#ifndef O_32BITHASH
+# define O_32BITHASH	02000000000
+#endif
+
+#ifndef O_64BITHASH
+# define O_64BITHASH	04000000000
+#endif
+
 #define EXT4_ERROR_INODE(inode, fmt, a...) \
 	ext4_error_inode((inode), __func__, __LINE__, 0, (fmt), ## a)
 
diff --git a/include/linux/netfilter/xt_CONNMARK.h b/include/linux/netfilter/xt_CONNMARK.h
index 2f2e48e..efc17a8 100644
--- a/include/linux/netfilter/xt_CONNMARK.h
+++ b/include/linux/netfilter/xt_CONNMARK.h
@@ -1,6 +1,31 @@
-#ifndef _XT_CONNMARK_H_target
-#define _XT_CONNMARK_H_target
+#ifndef _XT_CONNMARK_H
+#define _XT_CONNMARK_H
 
-#include <linux/netfilter/xt_connmark.h>
+#include <linux/types.h>
 
-#endif /*_XT_CONNMARK_H_target*/
+/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+enum {
+	XT_CONNMARK_SET = 0,
+	XT_CONNMARK_SAVE,
+	XT_CONNMARK_RESTORE
+};
+
+struct xt_connmark_tginfo1 {
+	__u32 ctmark, ctmask, nfmask;
+	__u8 mode;
+};
+
+struct xt_connmark_mtinfo1 {
+	__u32 mark, mask;
+	__u8 invert;
+};
+
+#endif /*_XT_CONNMARK_H*/
diff --git a/include/linux/netfilter/xt_DSCP.h b/include/linux/netfilter/xt_DSCP.h
index 648e0b3..15f8932 100644
--- a/include/linux/netfilter/xt_DSCP.h
+++ b/include/linux/netfilter/xt_DSCP.h
@@ -1,26 +1,31 @@
-/* x_tables module for setting the IPv4/IPv6 DSCP field
+/* x_tables module for matching the IPv4/IPv6 DSCP field
  *
  * (C) 2002 Harald Welte <laforge@gnumonks.org>
- * based on ipt_FTOS.c (C) 2000 by Matthew G. Marsh <mgm@paktronix.com>
  * This software is distributed under GNU GPL v2, 1991
  *
  * See RFC2474 for a description of the DSCP field within the IP Header.
  *
- * xt_DSCP.h,v 1.7 2002/03/14 12:03:13 laforge Exp
+ * xt_dscp.h,v 1.3 2002/08/05 19:00:21 laforge Exp
 */
-#ifndef _XT_DSCP_TARGET_H
-#define _XT_DSCP_TARGET_H
-#include <linux/netfilter/xt_dscp.h>
+#ifndef _XT_DSCP_H
+#define _XT_DSCP_H
+
 #include <linux/types.h>
 
-/* target info */
-struct xt_DSCP_info {
+#define XT_DSCP_MASK	0xfc	/* 11111100 */
+#define XT_DSCP_SHIFT	2
+#define XT_DSCP_MAX	0x3f	/* 00111111 */
+
+/* match info */
+struct xt_dscp_info {
 	__u8 dscp;
+	__u8 invert;
 };
 
-struct xt_tos_target_info {
-	__u8 tos_value;
+struct xt_tos_match_info {
 	__u8 tos_mask;
+	__u8 tos_value;
+	__u8 invert;
 };
 
-#endif /* _XT_DSCP_TARGET_H */
+#endif /* _XT_DSCP_H */
diff --git a/include/linux/netfilter/xt_MARK.h b/include/linux/netfilter/xt_MARK.h
index 41c456d..ecadc40 100644
--- a/include/linux/netfilter/xt_MARK.h
+++ b/include/linux/netfilter/xt_MARK.h
@@ -1,6 +1,15 @@
-#ifndef _XT_MARK_H_target
-#define _XT_MARK_H_target
+#ifndef _XT_MARK_H
+#define _XT_MARK_H
 
-#include <linux/netfilter/xt_mark.h>
+#include <linux/types.h>
 
-#endif /*_XT_MARK_H_target */
+struct xt_mark_tginfo2 {
+	__u32 mark, mask;
+};
+
+struct xt_mark_mtinfo1 {
+	__u32 mark, mask;
+	__u8 invert;
+};
+
+#endif /*_XT_MARK_H*/
diff --git a/include/linux/netfilter/xt_RATEEST.h b/include/linux/netfilter/xt_RATEEST.h
index 6605e20..d40a619 100644
--- a/include/linux/netfilter/xt_RATEEST.h
+++ b/include/linux/netfilter/xt_RATEEST.h
@@ -1,15 +1,37 @@
-#ifndef _XT_RATEEST_TARGET_H
-#define _XT_RATEEST_TARGET_H
+#ifndef _XT_RATEEST_MATCH_H
+#define _XT_RATEEST_MATCH_H
 
 #include <linux/types.h>
 
-struct xt_rateest_target_info {
-	char			name[IFNAMSIZ];
-	__s8			interval;
-	__u8		ewma_log;
+enum xt_rateest_match_flags {
+	XT_RATEEST_MATCH_INVERT	= 1<<0,
+	XT_RATEEST_MATCH_ABS	= 1<<1,
+	XT_RATEEST_MATCH_REL	= 1<<2,
+	XT_RATEEST_MATCH_DELTA	= 1<<3,
+	XT_RATEEST_MATCH_BPS	= 1<<4,
+	XT_RATEEST_MATCH_PPS	= 1<<5,
+};
+
+enum xt_rateest_match_mode {
+	XT_RATEEST_MATCH_NONE,
+	XT_RATEEST_MATCH_EQ,
+	XT_RATEEST_MATCH_LT,
+	XT_RATEEST_MATCH_GT,
+};
+
+struct xt_rateest_match_info {
+	char			name1[IFNAMSIZ];
+	char			name2[IFNAMSIZ];
+	__u16		flags;
+	__u16		mode;
+	__u32		bps1;
+	__u32		pps1;
+	__u32		bps2;
+	__u32		pps2;
 
 	/* Used internally by the kernel */
-	struct xt_rateest	*est __attribute__((aligned(8)));
+	struct xt_rateest	*est1 __attribute__((aligned(8)));
+	struct xt_rateest	*est2 __attribute__((aligned(8)));
 };
 
-#endif /* _XT_RATEEST_TARGET_H */
+#endif /* _XT_RATEEST_MATCH_H */
diff --git a/include/linux/netfilter/xt_TCPMSS.h b/include/linux/netfilter/xt_TCPMSS.h
index 9a6960a..fbac56b 100644
--- a/include/linux/netfilter/xt_TCPMSS.h
+++ b/include/linux/netfilter/xt_TCPMSS.h
@@ -1,12 +1,11 @@
-#ifndef _XT_TCPMSS_H
-#define _XT_TCPMSS_H
+#ifndef _XT_TCPMSS_MATCH_H
+#define _XT_TCPMSS_MATCH_H
 
 #include <linux/types.h>
 
-struct xt_tcpmss_info {
-	__u16 mss;
+struct xt_tcpmss_match_info {
+    __u16 mss_min, mss_max;
+    __u8 invert;
 };
 
-#define XT_TCPMSS_CLAMP_PMTU 0xffff
-
-#endif /* _XT_TCPMSS_H */
+#endif /*_XT_TCPMSS_MATCH_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_ECN.h b/include/linux/netfilter_ipv4/ipt_ECN.h
index bb88d53..eabf95f 100644
--- a/include/linux/netfilter_ipv4/ipt_ECN.h
+++ b/include/linux/netfilter_ipv4/ipt_ECN.h
@@ -1,33 +1,35 @@
-/* Header file for iptables ipt_ECN target
+/* iptables module for matching the ECN header in IPv4 and TCP header
  *
- * (C) 2002 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2002 Harald Welte <laforge@gnumonks.org>
  *
  * This software is distributed under GNU GPL v2, 1991
  * 
- * ipt_ECN.h,v 1.3 2002/05/29 12:17:40 laforge Exp
+ * ipt_ecn.h,v 1.4 2002/08/05 19:39:00 laforge Exp
 */
-#ifndef _IPT_ECN_TARGET_H
-#define _IPT_ECN_TARGET_H
+#ifndef _IPT_ECN_H
+#define _IPT_ECN_H
 
 #include <linux/types.h>
-#include <linux/netfilter/xt_DSCP.h>
+#include <linux/netfilter/xt_dscp.h>
 
 #define IPT_ECN_IP_MASK	(~XT_DSCP_MASK)
 
-#define IPT_ECN_OP_SET_IP	0x01	/* set ECN bits of IPv4 header */
-#define IPT_ECN_OP_SET_ECE	0x10	/* set ECE bit of TCP header */
-#define IPT_ECN_OP_SET_CWR	0x20	/* set CWR bit of TCP header */
+#define IPT_ECN_OP_MATCH_IP	0x01
+#define IPT_ECN_OP_MATCH_ECE	0x10
+#define IPT_ECN_OP_MATCH_CWR	0x20
 
-#define IPT_ECN_OP_MASK		0xce
+#define IPT_ECN_OP_MATCH_MASK	0xce
 
-struct ipt_ECN_info {
-	__u8 operation;	/* bitset of operations */
-	__u8 ip_ect;	/* ECT codepoint of IPv4 header, pre-shifted */
+/* match info */
+struct ipt_ecn_info {
+	__u8 operation;
+	__u8 invert;
+	__u8 ip_ect;
 	union {
 		struct {
-			__u8 ece:1, cwr:1; /* TCP ECT bits */
+			__u8 ect;
 		} tcp;
 	} proto;
 };
 
-#endif /* _IPT_ECN_TARGET_H */
+#endif /* _IPT_ECN_H */
diff --git a/include/linux/netfilter_ipv4/ipt_TTL.h b/include/linux/netfilter_ipv4/ipt_TTL.h
index f6ac169..37bee44 100644
--- a/include/linux/netfilter_ipv4/ipt_TTL.h
+++ b/include/linux/netfilter_ipv4/ipt_TTL.h
@@ -1,5 +1,5 @@
-/* TTL modification module for IP tables
- * (C) 2000 by Harald Welte <laforge@netfilter.org> */
+/* IP tables module for matching the value of the TTL
+ * (C) 2000 by Harald Welte <laforge@gnumonks.org> */
 
 #ifndef _IPT_TTL_H
 #define _IPT_TTL_H
@@ -7,14 +7,14 @@
 #include <linux/types.h>
 
 enum {
-	IPT_TTL_SET = 0,
-	IPT_TTL_INC,
-	IPT_TTL_DEC
+	IPT_TTL_EQ = 0,		/* equals */
+	IPT_TTL_NE,		/* not equals */
+	IPT_TTL_LT,		/* less than */
+	IPT_TTL_GT,		/* greater than */
 };
 
-#define IPT_TTL_MAXMODE	IPT_TTL_DEC
 
-struct ipt_TTL_info {
+struct ipt_ttl_info {
 	__u8	mode;
 	__u8	ttl;
 };
diff --git a/include/linux/netfilter_ipv6/ip6t_HL.h b/include/linux/netfilter_ipv6/ip6t_HL.h
index ebd8ead..6e76dbc 100644
--- a/include/linux/netfilter_ipv6/ip6t_HL.h
+++ b/include/linux/netfilter_ipv6/ip6t_HL.h
@@ -1,6 +1,6 @@
-/* Hop Limit modification module for ip6tables
+/* ip6tables module for matching the Hop Limit value
  * Maciej Soltysiak <solt@dns.toxicfilms.tv>
- * Based on HW's TTL module */
+ * Based on HW's ttl module */
 
 #ifndef _IP6T_HL_H
 #define _IP6T_HL_H
@@ -8,14 +8,14 @@
 #include <linux/types.h>
 
 enum {
-	IP6T_HL_SET = 0,
-	IP6T_HL_INC,
-	IP6T_HL_DEC
+	IP6T_HL_EQ = 0,		/* equals */
+	IP6T_HL_NE,		/* not equals */
+	IP6T_HL_LT,		/* less than */
+	IP6T_HL_GT,		/* greater than */
 };
 
-#define IP6T_HL_MAXMODE	IP6T_HL_DEC
 
-struct ip6t_HL_info {
+struct ip6t_hl_info {
 	__u8	mode;
 	__u8	hop_limit;
 };
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4bf3dc4..af6e9c7 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -1,138 +1,128 @@
-/* iptables module for the IPv4 and TCP ECN bits, Version 1.5
+/* IP tables module for matching the value of the IPv4 and TCP ECN bits
  *
- * (C) 2002 by Harald Welte <laforge@netfilter.org>
+ * (C) 2002 by Harald Welte <laforge@gnumonks.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
-*/
+ */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/in.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <net/ip.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
 #include <linux/tcp.h>
-#include <net/checksum.h>
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_ECN.h>
+#include <linux/netfilter_ipv4/ipt_ecn.h>
 
-MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag modification");
+MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag match for IPv4");
+MODULE_LICENSE("GPL");
 
-/* set ECT codepoint from IP header.
- * 	return false if there was an error. */
-static inline bool
-set_ect_ip(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
+static inline bool match_ip(const struct sk_buff *skb,
+			    const struct ipt_ecn_info *einfo)
 {
-	struct iphdr *iph = ip_hdr(skb);
-
-	if ((iph->tos & IPT_ECN_IP_MASK) != (einfo->ip_ect & IPT_ECN_IP_MASK)) {
-		__u8 oldtos;
-		if (!skb_make_writable(skb, sizeof(struct iphdr)))
-			return false;
-		iph = ip_hdr(skb);
-		oldtos = iph->tos;
-		iph->tos &= ~IPT_ECN_IP_MASK;
-		iph->tos |= (einfo->ip_ect & IPT_ECN_IP_MASK);
-		csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
-	}
-	return true;
+	return (ip_hdr(skb)->tos & IPT_ECN_IP_MASK) == einfo->ip_ect;
 }
 
-/* Return false if there was an error. */
-static inline bool
-set_ect_tcp(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
+static inline bool match_tcp(const struct sk_buff *skb,
+			     const struct ipt_ecn_info *einfo,
+			     bool *hotdrop)
 {
-	struct tcphdr _tcph, *tcph;
-	__be16 oldval;
-
-	/* Not enough header? */
-	tcph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
-	if (!tcph)
+	struct tcphdr _tcph;
+	const struct tcphdr *th;
+
+	/* In practice, TCP match does this, so can't fail.  But let's
+	 * be good citizens.
+	 */
+	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	if (th == NULL) {
+		*hotdrop = false;
 		return false;
+	}
 
-	if ((!(einfo->operation & IPT_ECN_OP_SET_ECE) ||
-	     tcph->ece == einfo->proto.tcp.ece) &&
-	    (!(einfo->operation & IPT_ECN_OP_SET_CWR) ||
-	     tcph->cwr == einfo->proto.tcp.cwr))
-		return true;
-
-	if (!skb_make_writable(skb, ip_hdrlen(skb) + sizeof(*tcph)))
-		return false;
-	tcph = (void *)ip_hdr(skb) + ip_hdrlen(skb);
+	if (einfo->operation & IPT_ECN_OP_MATCH_ECE) {
+		if (einfo->invert & IPT_ECN_OP_MATCH_ECE) {
+			if (th->ece == 1)
+				return false;
+		} else {
+			if (th->ece == 0)
+				return false;
+		}
+	}
 
-	oldval = ((__be16 *)tcph)[6];
-	if (einfo->operation & IPT_ECN_OP_SET_ECE)
-		tcph->ece = einfo->proto.tcp.ece;
-	if (einfo->operation & IPT_ECN_OP_SET_CWR)
-		tcph->cwr = einfo->proto.tcp.cwr;
+	if (einfo->operation & IPT_ECN_OP_MATCH_CWR) {
+		if (einfo->invert & IPT_ECN_OP_MATCH_CWR) {
+			if (th->cwr == 1)
+				return false;
+		} else {
+			if (th->cwr == 0)
+				return false;
+		}
+	}
 
-	inet_proto_csum_replace2(&tcph->check, skb,
-				 oldval, ((__be16 *)tcph)[6], 0);
 	return true;
 }
 
-static unsigned int
-ecn_tg(struct sk_buff *skb, const struct xt_action_param *par)
+static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct ipt_ECN_info *einfo = par->targinfo;
+	const struct ipt_ecn_info *info = par->matchinfo;
 
-	if (einfo->operation & IPT_ECN_OP_SET_IP)
-		if (!set_ect_ip(skb, einfo))
-			return NF_DROP;
+	if (info->operation & IPT_ECN_OP_MATCH_IP)
+		if (!match_ip(skb, info))
+			return false;
 
-	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR) &&
-	    ip_hdr(skb)->protocol == IPPROTO_TCP)
-		if (!set_ect_tcp(skb, einfo))
-			return NF_DROP;
+	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR)) {
+		if (ip_hdr(skb)->protocol != IPPROTO_TCP)
+			return false;
+		if (!match_tcp(skb, info, &par->hotdrop))
+			return false;
+	}
 
-	return XT_CONTINUE;
+	return true;
 }
 
-static int ecn_tg_check(const struct xt_tgchk_param *par)
+static int ecn_mt_check(const struct xt_mtchk_param *par)
 {
-	const struct ipt_ECN_info *einfo = par->targinfo;
-	const struct ipt_entry *e = par->entryinfo;
+	const struct ipt_ecn_info *info = par->matchinfo;
+	const struct ipt_ip *ip = par->entryinfo;
 
-	if (einfo->operation & IPT_ECN_OP_MASK) {
-		pr_info("unsupported ECN operation %x\n", einfo->operation);
+	if (info->operation & IPT_ECN_OP_MATCH_MASK)
 		return -EINVAL;
-	}
-	if (einfo->ip_ect & ~IPT_ECN_IP_MASK) {
-		pr_info("new ECT codepoint %x out of mask\n", einfo->ip_ect);
+
+	if (info->invert & IPT_ECN_OP_MATCH_MASK)
 		return -EINVAL;
-	}
-	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR)) &&
-	    (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
-		pr_info("cannot use TCP operations on a non-tcp rule\n");
+
+	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR) &&
+	    ip->proto != IPPROTO_TCP) {
+		pr_info("cannot match TCP bits in rule for non-tcp packets\n");
 		return -EINVAL;
 	}
+
 	return 0;
 }
 
-static struct xt_target ecn_tg_reg __read_mostly = {
-	.name		= "ECN",
+static struct xt_match ecn_mt_reg __read_mostly = {
+	.name		= "ecn",
 	.family		= NFPROTO_IPV4,
-	.target		= ecn_tg,
-	.targetsize	= sizeof(struct ipt_ECN_info),
-	.table		= "mangle",
-	.checkentry	= ecn_tg_check,
+	.match		= ecn_mt,
+	.matchsize	= sizeof(struct ipt_ecn_info),
+	.checkentry	= ecn_mt_check,
 	.me		= THIS_MODULE,
 };
 
-static int __init ecn_tg_init(void)
+static int __init ecn_mt_init(void)
 {
-	return xt_register_target(&ecn_tg_reg);
+	return xt_register_match(&ecn_mt_reg);
 }
 
-static void __exit ecn_tg_exit(void)
+static void __exit ecn_mt_exit(void)
 {
-	xt_unregister_target(&ecn_tg_reg);
+	xt_unregister_match(&ecn_mt_reg);
 }
 
-module_init(ecn_tg_init);
-module_exit(ecn_tg_exit);
+module_init(ecn_mt_init);
+module_exit(ecn_mt_exit);
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index ae82716..64670fc 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -1,14 +1,11 @@
-/* x_tables module for setting the IPv4/IPv6 DSCP field, Version 1.8
+/* IP tables module for matching the value of the IPv4/IPv6 DSCP field
  *
  * (C) 2002 by Harald Welte <laforge@netfilter.org>
- * based on ipt_FTOS.c (C) 2000 by Matthew G. Marsh <mgm@paktronix.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- *
- * See RFC2474 for a description of the DSCP field within the IP Header.
-*/
+ */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -17,148 +14,102 @@
 #include <net/dsfield.h>
 
 #include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/xt_DSCP.h>
+#include <linux/netfilter/xt_dscp.h>
 
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: DSCP/TOS field modification");
+MODULE_DESCRIPTION("Xtables: DSCP/TOS field match");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("ipt_DSCP");
-MODULE_ALIAS("ip6t_DSCP");
-MODULE_ALIAS("ipt_TOS");
-MODULE_ALIAS("ip6t_TOS");
+MODULE_ALIAS("ipt_dscp");
+MODULE_ALIAS("ip6t_dscp");
+MODULE_ALIAS("ipt_tos");
+MODULE_ALIAS("ip6t_tos");
 
-static unsigned int
-dscp_tg(struct sk_buff *skb, const struct xt_action_param *par)
+static bool
+dscp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_DSCP_info *dinfo = par->targinfo;
+	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(skb)) >> XT_DSCP_SHIFT;
 
-	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(skb, sizeof(struct iphdr)))
-			return NF_DROP;
-
-		ipv4_change_dsfield(ip_hdr(skb), (__u8)(~XT_DSCP_MASK),
-				    dinfo->dscp << XT_DSCP_SHIFT);
-
-	}
-	return XT_CONTINUE;
+	return (dscp == info->dscp) ^ !!info->invert;
 }
 
-static unsigned int
-dscp_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+static bool
+dscp_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_DSCP_info *dinfo = par->targinfo;
+	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(skb)) >> XT_DSCP_SHIFT;
 
-	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
-			return NF_DROP;
-
-		ipv6_change_dsfield(ipv6_hdr(skb), (__u8)(~XT_DSCP_MASK),
-				    dinfo->dscp << XT_DSCP_SHIFT);
-	}
-	return XT_CONTINUE;
+	return (dscp == info->dscp) ^ !!info->invert;
 }
 
-static int dscp_tg_check(const struct xt_tgchk_param *par)
+static int dscp_mt_check(const struct xt_mtchk_param *par)
 {
-	const struct xt_DSCP_info *info = par->targinfo;
+	const struct xt_dscp_info *info = par->matchinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
 		pr_info("dscp %x out of range\n", info->dscp);
 		return -EDOM;
 	}
-	return 0;
-}
-
-static unsigned int
-tos_tg(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	const struct xt_tos_target_info *info = par->targinfo;
-	struct iphdr *iph = ip_hdr(skb);
-	u_int8_t orig, nv;
-
-	orig = ipv4_get_dsfield(iph);
-	nv   = (orig & ~info->tos_mask) ^ info->tos_value;
-
-	if (orig != nv) {
-		if (!skb_make_writable(skb, sizeof(struct iphdr)))
-			return NF_DROP;
-		iph = ip_hdr(skb);
-		ipv4_change_dsfield(iph, 0, nv);
-	}
 
-	return XT_CONTINUE;
+	return 0;
 }
 
-static unsigned int
-tos_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+static bool tos_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_tos_target_info *info = par->targinfo;
-	struct ipv6hdr *iph = ipv6_hdr(skb);
-	u_int8_t orig, nv;
-
-	orig = ipv6_get_dsfield(iph);
-	nv   = (orig & ~info->tos_mask) ^ info->tos_value;
-
-	if (orig != nv) {
-		if (!skb_make_writable(skb, sizeof(struct iphdr)))
-			return NF_DROP;
-		iph = ipv6_hdr(skb);
-		ipv6_change_dsfield(iph, 0, nv);
-	}
-
-	return XT_CONTINUE;
+	const struct xt_tos_match_info *info = par->matchinfo;
+
+	if (par->family == NFPROTO_IPV4)
+		return ((ip_hdr(skb)->tos & info->tos_mask) ==
+		       info->tos_value) ^ !!info->invert;
+	else
+		return ((ipv6_get_dsfield(ipv6_hdr(skb)) & info->tos_mask) ==
+		       info->tos_value) ^ !!info->invert;
 }
 
-static struct xt_target dscp_tg_reg[] __read_mostly = {
+static struct xt_match dscp_mt_reg[] __read_mostly = {
 	{
-		.name		= "DSCP",
+		.name		= "dscp",
 		.family		= NFPROTO_IPV4,
-		.checkentry	= dscp_tg_check,
-		.target		= dscp_tg,
-		.targetsize	= sizeof(struct xt_DSCP_info),
-		.table		= "mangle",
+		.checkentry	= dscp_mt_check,
+		.match		= dscp_mt,
+		.matchsize	= sizeof(struct xt_dscp_info),
 		.me		= THIS_MODULE,
 	},
 	{
-		.name		= "DSCP",
+		.name		= "dscp",
 		.family		= NFPROTO_IPV6,
-		.checkentry	= dscp_tg_check,
-		.target		= dscp_tg6,
-		.targetsize	= sizeof(struct xt_DSCP_info),
-		.table		= "mangle",
+		.checkentry	= dscp_mt_check,
+		.match		= dscp_mt6,
+		.matchsize	= sizeof(struct xt_dscp_info),
 		.me		= THIS_MODULE,
 	},
 	{
-		.name		= "TOS",
+		.name		= "tos",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
-		.table		= "mangle",
-		.target		= tos_tg,
-		.targetsize	= sizeof(struct xt_tos_target_info),
+		.match		= tos_mt,
+		.matchsize	= sizeof(struct xt_tos_match_info),
 		.me		= THIS_MODULE,
 	},
 	{
-		.name		= "TOS",
+		.name		= "tos",
 		.revision	= 1,
 		.family		= NFPROTO_IPV6,
-		.table		= "mangle",
-		.target		= tos_tg6,
-		.targetsize	= sizeof(struct xt_tos_target_info),
+		.match		= tos_mt,
+		.matchsize	= sizeof(struct xt_tos_match_info),
 		.me		= THIS_MODULE,
 	},
 };
 
-static int __init dscp_tg_init(void)
+static int __init dscp_mt_init(void)
 {
-	return xt_register_targets(dscp_tg_reg, ARRAY_SIZE(dscp_tg_reg));
+	return xt_register_matches(dscp_mt_reg, ARRAY_SIZE(dscp_mt_reg));
 }
 
-static void __exit dscp_tg_exit(void)
+static void __exit dscp_mt_exit(void)
 {
-	xt_unregister_targets(dscp_tg_reg, ARRAY_SIZE(dscp_tg_reg));
+	xt_unregister_matches(dscp_mt_reg, ARRAY_SIZE(dscp_mt_reg));
 }
 
-module_init(dscp_tg_init);
-module_exit(dscp_tg_exit);
+module_init(dscp_mt_init);
+module_exit(dscp_mt_exit);
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 95b08480..7d12221 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -1,169 +1,96 @@
 /*
- * TTL modification target for IP tables
- * (C) 2000,2005 by Harald Welte <laforge@netfilter.org>
+ * IP tables module for matching the value of the TTL
+ * (C) 2000,2001 by Harald Welte <laforge@netfilter.org>
  *
- * Hop Limit modification target for ip6tables
- * Maciej Soltysiak <solt@dns.toxicfilms.tv>
+ * Hop Limit matching module
+ * (C) 2001-2002 Maciej Soltysiak <solt@dns.toxicfilms.tv>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-#include <linux/module.h>
-#include <linux/skbuff.h>
+
 #include <linux/ip.h>
 #include <linux/ipv6.h>
-#include <net/checksum.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
 
 #include <linux/netfilter/x_tables.h>
-#include <linux/netfilter_ipv4/ipt_TTL.h>
-#include <linux/netfilter_ipv6/ip6t_HL.h>
+#include <linux/netfilter_ipv4/ipt_ttl.h>
+#include <linux/netfilter_ipv6/ip6t_hl.h>
 
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
-MODULE_DESCRIPTION("Xtables: Hoplimit/TTL Limit field modification target");
+MODULE_DESCRIPTION("Xtables: Hoplimit/TTL field match");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_ttl");
+MODULE_ALIAS("ip6t_hl");
 
-static unsigned int
-ttl_tg(struct sk_buff *skb, const struct xt_action_param *par)
+static bool ttl_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct iphdr *iph;
-	const struct ipt_TTL_info *info = par->targinfo;
-	int new_ttl;
-
-	if (!skb_make_writable(skb, skb->len))
-		return NF_DROP;
-
-	iph = ip_hdr(skb);
+	const struct ipt_ttl_info *info = par->matchinfo;
+	const u8 ttl = ip_hdr(skb)->ttl;
 
 	switch (info->mode) {
-		case IPT_TTL_SET:
-			new_ttl = info->ttl;
-			break;
-		case IPT_TTL_INC:
-			new_ttl = iph->ttl + info->ttl;
-			if (new_ttl > 255)
-				new_ttl = 255;
-			break;
-		case IPT_TTL_DEC:
-			new_ttl = iph->ttl - info->ttl;
-			if (new_ttl < 0)
-				new_ttl = 0;
-			break;
-		default:
-			new_ttl = iph->ttl;
-			break;
-	}
-
-	if (new_ttl != iph->ttl) {
-		csum_replace2(&iph->check, htons(iph->ttl << 8),
-					   htons(new_ttl << 8));
-		iph->ttl = new_ttl;
+		case IPT_TTL_EQ:
+			return ttl == info->ttl;
+		case IPT_TTL_NE:
+			return ttl != info->ttl;
+		case IPT_TTL_LT:
+			return ttl < info->ttl;
+		case IPT_TTL_GT:
+			return ttl > info->ttl;
 	}
 
-	return XT_CONTINUE;
+	return false;
 }
 
-static unsigned int
-hl_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+static bool hl_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct ipv6hdr *ip6h;
-	const struct ip6t_HL_info *info = par->targinfo;
-	int new_hl;
-
-	if (!skb_make_writable(skb, skb->len))
-		return NF_DROP;
-
-	ip6h = ipv6_hdr(skb);
+	const struct ip6t_hl_info *info = par->matchinfo;
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 
 	switch (info->mode) {
-		case IP6T_HL_SET:
-			new_hl = info->hop_limit;
-			break;
-		case IP6T_HL_INC:
-			new_hl = ip6h->hop_limit + info->hop_limit;
-			if (new_hl > 255)
-				new_hl = 255;
-			break;
-		case IP6T_HL_DEC:
-			new_hl = ip6h->hop_limit - info->hop_limit;
-			if (new_hl < 0)
-				new_hl = 0;
-			break;
-		default:
-			new_hl = ip6h->hop_limit;
-			break;
+		case IP6T_HL_EQ:
+			return ip6h->hop_limit == info->hop_limit;
+		case IP6T_HL_NE:
+			return ip6h->hop_limit != info->hop_limit;
+		case IP6T_HL_LT:
+			return ip6h->hop_limit < info->hop_limit;
+		case IP6T_HL_GT:
+			return ip6h->hop_limit > info->hop_limit;
 	}
 
-	ip6h->hop_limit = new_hl;
-
-	return XT_CONTINUE;
-}
-
-static int ttl_tg_check(const struct xt_tgchk_param *par)
-{
-	const struct ipt_TTL_info *info = par->targinfo;
-
-	if (info->mode > IPT_TTL_MAXMODE) {
-		pr_info("TTL: invalid or unknown mode %u\n", info->mode);
-		return -EINVAL;
-	}
-	if (info->mode != IPT_TTL_SET && info->ttl == 0)
-		return -EINVAL;
-	return 0;
-}
-
-static int hl_tg6_check(const struct xt_tgchk_param *par)
-{
-	const struct ip6t_HL_info *info = par->targinfo;
-
-	if (info->mode > IP6T_HL_MAXMODE) {
-		pr_info("invalid or unknown mode %u\n", info->mode);
-		return -EINVAL;
-	}
-	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
-		pr_info("increment/decrement does not "
-			"make sense with value 0\n");
-		return -EINVAL;
-	}
-	return 0;
+	return false;
 }
 
-static struct xt_target hl_tg_reg[] __read_mostly = {
+static struct xt_match hl_mt_reg[] __read_mostly = {
 	{
-		.name       = "TTL",
+		.name       = "ttl",
 		.revision   = 0,
 		.family     = NFPROTO_IPV4,
-		.target     = ttl_tg,
-		.targetsize = sizeof(struct ipt_TTL_info),
-		.table      = "mangle",
-		.checkentry = ttl_tg_check,
+		.match      = ttl_mt,
+		.matchsize  = sizeof(struct ipt_ttl_info),
 		.me         = THIS_MODULE,
 	},
 	{
-		.name       = "HL",
+		.name       = "hl",
 		.revision   = 0,
 		.family     = NFPROTO_IPV6,
-		.target     = hl_tg6,
-		.targetsize = sizeof(struct ip6t_HL_info),
-		.table      = "mangle",
-		.checkentry = hl_tg6_check,
+		.match      = hl_mt6,
+		.matchsize  = sizeof(struct ip6t_hl_info),
 		.me         = THIS_MODULE,
 	},
 };
 
-static int __init hl_tg_init(void)
+static int __init hl_mt_init(void)
 {
-	return xt_register_targets(hl_tg_reg, ARRAY_SIZE(hl_tg_reg));
+	return xt_register_matches(hl_mt_reg, ARRAY_SIZE(hl_mt_reg));
 }
 
-static void __exit hl_tg_exit(void)
+static void __exit hl_mt_exit(void)
 {
-	xt_unregister_targets(hl_tg_reg, ARRAY_SIZE(hl_tg_reg));
+	xt_unregister_matches(hl_mt_reg, ARRAY_SIZE(hl_mt_reg));
 }
 
-module_init(hl_tg_init);
-module_exit(hl_tg_exit);
-MODULE_ALIAS("ipt_TTL");
-MODULE_ALIAS("ip6t_HL");
+module_init(hl_mt_init);
+module_exit(hl_mt_exit);
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index de079abd..76a0831 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -8,194 +8,151 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/gen_stats.h>
-#include <linux/jhash.h>
-#include <linux/rtnetlink.h>
-#include <linux/random.h>
-#include <linux/slab.h>
-#include <net/gen_stats.h>
-#include <net/netlink.h>
 
 #include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/xt_RATEEST.h>
+#include <linux/netfilter/xt_rateest.h>
 #include <net/netfilter/xt_rateest.h>
 
-static DEFINE_MUTEX(xt_rateest_mutex);
 
-#define RATEEST_HSIZE	16
-static struct hlist_head rateest_hash[RATEEST_HSIZE] __read_mostly;
-static unsigned int jhash_rnd __read_mostly;
-static bool rnd_inited __read_mostly;
-
-static unsigned int xt_rateest_hash(const char *name)
-{
-	return jhash(name, FIELD_SIZEOF(struct xt_rateest, name), jhash_rnd) &
-	       (RATEEST_HSIZE - 1);
-}
-
-static void xt_rateest_hash_insert(struct xt_rateest *est)
-{
-	unsigned int h;
-
-	h = xt_rateest_hash(est->name);
-	hlist_add_head(&est->list, &rateest_hash[h]);
-}
-
-struct xt_rateest *xt_rateest_lookup(const char *name)
+static bool
+xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct xt_rateest *est;
-	struct hlist_node *n;
-	unsigned int h;
-
-	h = xt_rateest_hash(name);
-	mutex_lock(&xt_rateest_mutex);
-	hlist_for_each_entry(est, n, &rateest_hash[h], list) {
-		if (strcmp(est->name, name) == 0) {
-			est->refcnt++;
-			mutex_unlock(&xt_rateest_mutex);
-			return est;
+	const struct xt_rateest_match_info *info = par->matchinfo;
+	struct gnet_stats_rate_est *r;
+	u_int32_t bps1, bps2, pps1, pps2;
+	bool ret = true;
+
+	spin_lock_bh(&info->est1->lock);
+	r = &info->est1->rstats;
+	if (info->flags & XT_RATEEST_MATCH_DELTA) {
+		bps1 = info->bps1 >= r->bps ? info->bps1 - r->bps : 0;
+		pps1 = info->pps1 >= r->pps ? info->pps1 - r->pps : 0;
+	} else {
+		bps1 = r->bps;
+		pps1 = r->pps;
+	}
+	spin_unlock_bh(&info->est1->lock);
+
+	if (info->flags & XT_RATEEST_MATCH_ABS) {
+		bps2 = info->bps2;
+		pps2 = info->pps2;
+	} else {
+		spin_lock_bh(&info->est2->lock);
+		r = &info->est2->rstats;
+		if (info->flags & XT_RATEEST_MATCH_DELTA) {
+			bps2 = info->bps2 >= r->bps ? info->bps2 - r->bps : 0;
+			pps2 = info->pps2 >= r->pps ? info->pps2 - r->pps : 0;
+		} else {
+			bps2 = r->bps;
+			pps2 = r->pps;
 		}
+		spin_unlock_bh(&info->est2->lock);
 	}
-	mutex_unlock(&xt_rateest_mutex);
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(xt_rateest_lookup);
 
-static void xt_rateest_free_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct xt_rateest, rcu));
-}
-
-void xt_rateest_put(struct xt_rateest *est)
-{
-	mutex_lock(&xt_rateest_mutex);
-	if (--est->refcnt == 0) {
-		hlist_del(&est->list);
-		gen_kill_estimator(&est->bstats, &est->rstats);
-		/*
-		 * gen_estimator est_timer() might access est->lock or bstats,
-		 * wait a RCU grace period before freeing 'est'
-		 */
-		call_rcu(&est->rcu, xt_rateest_free_rcu);
+	switch (info->mode) {
+	case XT_RATEEST_MATCH_LT:
+		if (info->flags & XT_RATEEST_MATCH_BPS)
+			ret &= bps1 < bps2;
+		if (info->flags & XT_RATEEST_MATCH_PPS)
+			ret &= pps1 < pps2;
+		break;
+	case XT_RATEEST_MATCH_GT:
+		if (info->flags & XT_RATEEST_MATCH_BPS)
+			ret &= bps1 > bps2;
+		if (info->flags & XT_RATEEST_MATCH_PPS)
+			ret &= pps1 > pps2;
+		break;
+	case XT_RATEEST_MATCH_EQ:
+		if (info->flags & XT_RATEEST_MATCH_BPS)
+			ret &= bps1 == bps2;
+		if (info->flags & XT_RATEEST_MATCH_PPS)
+			ret &= pps1 == pps2;
+		break;
 	}
-	mutex_unlock(&xt_rateest_mutex);
+
+	ret ^= info->flags & XT_RATEEST_MATCH_INVERT ? true : false;
+	return ret;
 }
-EXPORT_SYMBOL_GPL(xt_rateest_put);
 
-static unsigned int
-xt_rateest_tg(struct sk_buff *skb, const struct xt_action_param *par)
+static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 {
-	const struct xt_rateest_target_info *info = par->targinfo;
-	struct gnet_stats_basic_packed *stats = &info->est->bstats;
-
-	spin_lock_bh(&info->est->lock);
-	stats->bytes += skb->len;
-	stats->packets++;
-	spin_unlock_bh(&info->est->lock);
+	struct xt_rateest_match_info *info = par->matchinfo;
+	struct xt_rateest *est1, *est2;
+	int ret = false;
 
-	return XT_CONTINUE;
-}
+	if (hweight32(info->flags & (XT_RATEEST_MATCH_ABS |
+				     XT_RATEEST_MATCH_REL)) != 1)
+		goto err1;
 
-static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
-{
-	struct xt_rateest_target_info *info = par->targinfo;
-	struct xt_rateest *est;
-	struct {
-		struct nlattr		opt;
-		struct gnet_estimator	est;
-	} cfg;
-	int ret;
-
-	if (unlikely(!rnd_inited)) {
-		get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
-		rnd_inited = true;
-	}
+	if (!(info->flags & (XT_RATEEST_MATCH_BPS | XT_RATEEST_MATCH_PPS)))
+		goto err1;
 
-	est = xt_rateest_lookup(info->name);
-	if (est) {
-		/*
-		 * If estimator parameters are specified, they must match the
-		 * existing estimator.
-		 */
-		if ((!info->interval && !info->ewma_log) ||
-		    (info->interval != est->params.interval ||
-		     info->ewma_log != est->params.ewma_log)) {
-			xt_rateest_put(est);
-			return -EINVAL;
-		}
-		info->est = est;
-		return 0;
+	switch (info->mode) {
+	case XT_RATEEST_MATCH_EQ:
+	case XT_RATEEST_MATCH_LT:
+	case XT_RATEEST_MATCH_GT:
+		break;
+	default:
+		goto err1;
 	}
 
-	ret = -ENOMEM;
-	est = kzalloc(sizeof(*est), GFP_KERNEL);
-	if (!est)
+	ret  = -ENOENT;
+	est1 = xt_rateest_lookup(info->name1);
+	if (!est1)
 		goto err1;
 
-	strlcpy(est->name, info->name, sizeof(est->name));
-	spin_lock_init(&est->lock);
-	est->refcnt		= 1;
-	est->params.interval	= info->interval;
-	est->params.ewma_log	= info->ewma_log;
+	if (info->flags & XT_RATEEST_MATCH_REL) {
+		est2 = xt_rateest_lookup(info->name2);
+		if (!est2)
+			goto err2;
+	} else
+		est2 = NULL;
 
-	cfg.opt.nla_len		= nla_attr_size(sizeof(cfg.est));
-	cfg.opt.nla_type	= TCA_STATS_RATE_EST;
-	cfg.est.interval	= info->interval;
-	cfg.est.ewma_log	= info->ewma_log;
 
-	ret = gen_new_estimator(&est->bstats, &est->rstats,
-				&est->lock, &cfg.opt);
-	if (ret < 0)
-		goto err2;
-
-	info->est = est;
-	xt_rateest_hash_insert(est);
+	info->est1 = est1;
+	info->est2 = est2;
 	return 0;
 
 err2:
-	kfree(est);
+	xt_rateest_put(est1);
 err1:
-	return ret;
+	return -EINVAL;
 }
 
-static void xt_rateest_tg_destroy(const struct xt_tgdtor_param *par)
+static void xt_rateest_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	struct xt_rateest_target_info *info = par->targinfo;
+	struct xt_rateest_match_info *info = par->matchinfo;
 
-	xt_rateest_put(info->est);
+	xt_rateest_put(info->est1);
+	if (info->est2)
+		xt_rateest_put(info->est2);
 }
 
-static struct xt_target xt_rateest_tg_reg __read_mostly = {
-	.name       = "RATEEST",
+static struct xt_match xt_rateest_mt_reg __read_mostly = {
+	.name       = "rateest",
 	.revision   = 0,
 	.family     = NFPROTO_UNSPEC,
-	.target     = xt_rateest_tg,
-	.checkentry = xt_rateest_tg_checkentry,
-	.destroy    = xt_rateest_tg_destroy,
-	.targetsize = sizeof(struct xt_rateest_target_info),
+	.match      = xt_rateest_mt,
+	.checkentry = xt_rateest_mt_checkentry,
+	.destroy    = xt_rateest_mt_destroy,
+	.matchsize  = sizeof(struct xt_rateest_match_info),
 	.me         = THIS_MODULE,
 };
 
-static int __init xt_rateest_tg_init(void)
+static int __init xt_rateest_mt_init(void)
 {
-	unsigned int i;
-
-	for (i = 0; i < ARRAY_SIZE(rateest_hash); i++)
-		INIT_HLIST_HEAD(&rateest_hash[i]);
-
-	return xt_register_target(&xt_rateest_tg_reg);
+	return xt_register_match(&xt_rateest_mt_reg);
 }
 
-static void __exit xt_rateest_tg_fini(void)
+static void __exit xt_rateest_mt_fini(void)
 {
-	xt_unregister_target(&xt_rateest_tg_reg);
-	rcu_barrier(); /* Wait for completion of call_rcu()'s (xt_rateest_free_rcu) */
+	xt_unregister_match(&xt_rateest_mt_reg);
 }
 
-
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Xtables: packet rate estimator");
-MODULE_ALIAS("ipt_RATEEST");
-MODULE_ALIAS("ip6t_RATEEST");
-module_init(xt_rateest_tg_init);
-module_exit(xt_rateest_tg_fini);
+MODULE_DESCRIPTION("xtables rate estimator match");
+MODULE_ALIAS("ipt_rateest");
+MODULE_ALIAS("ip6t_rateest");
+module_init(xt_rateest_mt_init);
+module_exit(xt_rateest_mt_fini);
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 9e63b43..c53d4d1 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -1,319 +1,110 @@
-/*
- * This is a module which is used for setting the MSS option in TCP packets.
- *
- * Copyright (C) 2000 Marc Boucher <marc@mbsi.ca>
+/* Kernel module to match TCP MSS values. */
+
+/* Copyright (C) 2000 Marc Boucher <marc@mbsi.ca>
+ * Portions (C) 2005 by Harald Welte <laforge@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <linux/gfp.h>
-#include <linux/ipv6.h>
-#include <linux/tcp.h>
-#include <net/dst.h>
-#include <net/flow.h>
-#include <net/ipv6.h>
-#include <net/route.h>
 #include <net/tcp.h>
 
+#include <linux/netfilter/xt_tcpmss.h>
+#include <linux/netfilter/x_tables.h>
+
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/xt_tcpudp.h>
-#include <linux/netfilter/xt_TCPMSS.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("Xtables: TCP Maximum Segment Size (MSS) adjustment");
-MODULE_ALIAS("ipt_TCPMSS");
-MODULE_ALIAS("ip6t_TCPMSS");
+MODULE_DESCRIPTION("Xtables: TCP MSS match");
+MODULE_ALIAS("ipt_tcpmss");
+MODULE_ALIAS("ip6t_tcpmss");
 
-static inline unsigned int
-optlen(const u_int8_t *opt, unsigned int offset)
+static bool
+tcpmss_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	/* Beware zero-length options: make finite progress */
-	if (opt[offset] <= TCPOPT_NOP || opt[offset+1] == 0)
-		return 1;
-	else
-		return opt[offset+1];
-}
-
-static int
-tcpmss_mangle_packet(struct sk_buff *skb,
-		     const struct xt_tcpmss_info *info,
-		     unsigned int in_mtu,
-		     unsigned int tcphoff,
-		     unsigned int minlen)
-{
-	struct tcphdr *tcph;
-	unsigned int tcplen, i;
-	__be16 oldval;
-	u16 newmss;
-	u8 *opt;
-
-	if (!skb_make_writable(skb, skb->len))
-		return -1;
-
-	tcplen = skb->len - tcphoff;
-	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
-
-	/* Header cannot be larger than the packet */
-	if (tcplen < tcph->doff*4)
-		return -1;
-
-	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		if (dst_mtu(skb_dst(skb)) <= minlen) {
-			if (net_ratelimit())
-				pr_err("unknown or invalid path-MTU (%u)\n",
-				       dst_mtu(skb_dst(skb)));
-			return -1;
-		}
-		if (in_mtu <= minlen) {
-			if (net_ratelimit())
-				pr_err("unknown or invalid path-MTU (%u)\n",
-				       in_mtu);
-			return -1;
-		}
-		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
-	} else
-		newmss = info->mss;
-
-	opt = (u_int8_t *)tcph;
-	for (i = sizeof(struct tcphdr); i < tcph->doff*4; i += optlen(opt, i)) {
-		if (opt[i] == TCPOPT_MSS && tcph->doff*4 - i >= TCPOLEN_MSS &&
-		    opt[i+1] == TCPOLEN_MSS) {
-			u_int16_t oldmss;
-
-			oldmss = (opt[i+2] << 8) | opt[i+3];
-
-			/* Never increase MSS, even when setting it, as
-			 * doing so results in problems for hosts that rely
-			 * on MSS being set correctly.
-			 */
-			if (oldmss <= newmss)
-				return 0;
-
-			opt[i+2] = (newmss & 0xff00) >> 8;
-			opt[i+3] = newmss & 0x00ff;
-
-			inet_proto_csum_replace2(&tcph->check, skb,
-						 htons(oldmss), htons(newmss),
-						 0);
-			return 0;
+	const struct xt_tcpmss_match_info *info = par->matchinfo;
+	const struct tcphdr *th;
+	struct tcphdr _tcph;
+	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
+	const u_int8_t *op;
+	u8 _opt[15 * 4 - sizeof(_tcph)];
+	unsigned int i, optlen;
+
+	/* If we don't have the whole header, drop packet. */
+	th = skb_header_pointer(skb, par->thoff, sizeof(_tcph), &_tcph);
+	if (th == NULL)
+		goto dropit;
+
+	/* Malformed. */
+	if (th->doff*4 < sizeof(*th))
+		goto dropit;
+
+	optlen = th->doff*4 - sizeof(*th);
+	if (!optlen)
+		goto out;
+
+	/* Truncated options. */
+	op = skb_header_pointer(skb, par->thoff + sizeof(*th), optlen, _opt);
+	if (op == NULL)
+		goto dropit;
+
+	for (i = 0; i < optlen; ) {
+		if (op[i] == TCPOPT_MSS
+		    && (optlen - i) >= TCPOLEN_MSS
+		    && op[i+1] == TCPOLEN_MSS) {
+			u_int16_t mssval;
+
+			mssval = (op[i+2] << 8) | op[i+3];
+
+			return (mssval >= info->mss_min &&
+				mssval <= info->mss_max) ^ info->invert;
 		}
+		if (op[i] < 2)
+			i++;
+		else
+			i += op[i+1] ? : 1;
 	}
+out:
+	return info->invert;
 
-	/* There is data after the header so the option can't be added
-	   without moving it, and doing so may make the SYN packet
-	   itself too large. Accept the packet unmodified instead. */
-	if (tcplen > tcph->doff*4)
-		return 0;
-
-	/*
-	 * MSS Option not found ?! add it..
-	 */
-	if (skb_tailroom(skb) < TCPOLEN_MSS) {
-		if (pskb_expand_head(skb, 0,
-				     TCPOLEN_MSS - skb_tailroom(skb),
-				     GFP_ATOMIC))
-			return -1;
-		tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
-	}
-
-	skb_put(skb, TCPOLEN_MSS);
-
-	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
-	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
-
-	inet_proto_csum_replace2(&tcph->check, skb,
-				 htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
-	opt[0] = TCPOPT_MSS;
-	opt[1] = TCPOLEN_MSS;
-	opt[2] = (newmss & 0xff00) >> 8;
-	opt[3] = newmss & 0x00ff;
-
-	inet_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
-
-	oldval = ((__be16 *)tcph)[6];
-	tcph->doff += TCPOLEN_MSS/4;
-	inet_proto_csum_replace2(&tcph->check, skb,
-				 oldval, ((__be16 *)tcph)[6], 0);
-	return TCPOLEN_MSS;
-}
-
-static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
-				    unsigned int family)
-{
-	struct flowi fl;
-	const struct nf_afinfo *ai;
-	struct rtable *rt = NULL;
-	u_int32_t mtu     = ~0U;
-
-	if (family == PF_INET) {
-		struct flowi4 *fl4 = &fl.u.ip4;
-		memset(fl4, 0, sizeof(*fl4));
-		fl4->daddr = ip_hdr(skb)->saddr;
-	} else {
-		struct flowi6 *fl6 = &fl.u.ip6;
-
-		memset(fl6, 0, sizeof(*fl6));
-		ipv6_addr_copy(&fl6->daddr, &ipv6_hdr(skb)->saddr);
-	}
-	rcu_read_lock();
-	ai = nf_get_afinfo(family);
-	if (ai != NULL)
-		ai->route(&init_net, (struct dst_entry **)&rt, &fl, false);
-	rcu_read_unlock();
-
-	if (rt != NULL) {
-		mtu = dst_mtu(&rt->dst);
-		dst_release(&rt->dst);
-	}
-	return mtu;
-}
-
-static unsigned int
-tcpmss_tg4(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 newlen;
-	int ret;
-
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
-				   tcpmss_reverse_mtu(skb, PF_INET),
-				   iph->ihl * 4,
-				   sizeof(*iph) + sizeof(struct tcphdr));
-	if (ret < 0)
-		return NF_DROP;
-	if (ret > 0) {
-		iph = ip_hdr(skb);
-		newlen = htons(ntohs(iph->tot_len) + ret);
-		csum_replace2(&iph->check, iph->tot_len, newlen);
-		iph->tot_len = newlen;
-	}
-	return XT_CONTINUE;
-}
-
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
-static unsigned int
-tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-	u8 nexthdr;
-	int tcphoff;
-	int ret;
-
-	nexthdr = ipv6h->nexthdr;
-	tcphoff = ipv6_skip_exthdr(skb, sizeof(*ipv6h), &nexthdr);
-	if (tcphoff < 0)
-		return NF_DROP;
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
-				   tcpmss_reverse_mtu(skb, PF_INET6),
-				   tcphoff,
-				   sizeof(*ipv6h) + sizeof(struct tcphdr));
-	if (ret < 0)
-		return NF_DROP;
-	if (ret > 0) {
-		ipv6h = ipv6_hdr(skb);
-		ipv6h->payload_len = htons(ntohs(ipv6h->payload_len) + ret);
-	}
-	return XT_CONTINUE;
-}
-#endif
-
-/* Must specify -p tcp --syn */
-static inline bool find_syn_match(const struct xt_entry_match *m)
-{
-	const struct xt_tcp *tcpinfo = (const struct xt_tcp *)m->data;
-
-	if (strcmp(m->u.kernel.match->name, "tcp") == 0 &&
-	    tcpinfo->flg_cmp & TCPHDR_SYN &&
-	    !(tcpinfo->invflags & XT_TCP_INV_FLAGS))
-		return true;
-
+dropit:
+	par->hotdrop = true;
 	return false;
 }
 
-static int tcpmss_tg4_check(const struct xt_tgchk_param *par)
-{
-	const struct xt_tcpmss_info *info = par->targinfo;
-	const struct ipt_entry *e = par->entryinfo;
-	const struct xt_entry_match *ematch;
-
-	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
-	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
-			   (1 << NF_INET_LOCAL_OUT) |
-			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		pr_info("path-MTU clamping only supported in "
-			"FORWARD, OUTPUT and POSTROUTING hooks\n");
-		return -EINVAL;
-	}
-	xt_ematch_foreach(ematch, e)
-		if (find_syn_match(ematch))
-			return 0;
-	pr_info("Only works on TCP SYN packets\n");
-	return -EINVAL;
-}
-
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
-static int tcpmss_tg6_check(const struct xt_tgchk_param *par)
-{
-	const struct xt_tcpmss_info *info = par->targinfo;
-	const struct ip6t_entry *e = par->entryinfo;
-	const struct xt_entry_match *ematch;
-
-	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
-	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
-			   (1 << NF_INET_LOCAL_OUT) |
-			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		pr_info("path-MTU clamping only supported in "
-			"FORWARD, OUTPUT and POSTROUTING hooks\n");
-		return -EINVAL;
-	}
-	xt_ematch_foreach(ematch, e)
-		if (find_syn_match(ematch))
-			return 0;
-	pr_info("Only works on TCP SYN packets\n");
-	return -EINVAL;
-}
-#endif
-
-static struct xt_target tcpmss_tg_reg[] __read_mostly = {
+static struct xt_match tcpmss_mt_reg[] __read_mostly = {
 	{
+		.name		= "tcpmss",
 		.family		= NFPROTO_IPV4,
-		.name		= "TCPMSS",
-		.checkentry	= tcpmss_tg4_check,
-		.target		= tcpmss_tg4,
-		.targetsize	= sizeof(struct xt_tcpmss_info),
+		.match		= tcpmss_mt,
+		.matchsize	= sizeof(struct xt_tcpmss_match_info),
 		.proto		= IPPROTO_TCP,
 		.me		= THIS_MODULE,
 	},
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	{
+		.name		= "tcpmss",
 		.family		= NFPROTO_IPV6,
-		.name		= "TCPMSS",
-		.checkentry	= tcpmss_tg6_check,
-		.target		= tcpmss_tg6,
-		.targetsize	= sizeof(struct xt_tcpmss_info),
+		.match		= tcpmss_mt,
+		.matchsize	= sizeof(struct xt_tcpmss_match_info),
 		.proto		= IPPROTO_TCP,
 		.me		= THIS_MODULE,
 	},
-#endif
 };
 
-static int __init tcpmss_tg_init(void)
+static int __init tcpmss_mt_init(void)
 {
-	return xt_register_targets(tcpmss_tg_reg, ARRAY_SIZE(tcpmss_tg_reg));
+	return xt_register_matches(tcpmss_mt_reg, ARRAY_SIZE(tcpmss_mt_reg));
 }
 
-static void __exit tcpmss_tg_exit(void)
+static void __exit tcpmss_mt_exit(void)
 {
-	xt_unregister_targets(tcpmss_tg_reg, ARRAY_SIZE(tcpmss_tg_reg));
+	xt_unregister_matches(tcpmss_mt_reg, ARRAY_SIZE(tcpmss_mt_reg));
 }
 
-module_init(tcpmss_tg_init);
-module_exit(tcpmss_tg_exit);
+module_init(tcpmss_mt_init);
+module_exit(tcpmss_mt_exit);

--Apple-Mail-20--9407446--
