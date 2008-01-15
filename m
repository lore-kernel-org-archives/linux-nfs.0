From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Tue, 15 Jan 2008 11:30:14 -0500
Message-ID: <20080115163013.GC18911@newbie.thebellsplace.net>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:57347 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbYAOQaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 11:30:15 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0FGW5fk020511
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2008 11:32:05 -0500
In-Reply-To: <20080115162658.GA18911-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bob Bell <bell_robert@emc.com>

Add NFS_MOUNT_NONEGDE mount flag.  When this flag is set on a mounted
NFS filesystem, negative dentries for that filesystem will not be 
cached.  This can help address cache coherency when the NFS server does 
not provide sufficiently fine-grained timestamps to consistently 
distinguish when a directory has been modified, though performance when 
repeatedly accessing filenames for files that do not exist may be 
impacted.

Signed-off-by: Bob Bell <bell_robert@emc.com>
---
 fs/nfs/dir.c              |    5 +++++
 fs/nfs/nfsroot.c          |   10 +++++++++-
 fs/nfs/super.c            |    9 +++++++++
 include/linux/nfs_mount.h |   35 ++++++++++++++++++-----------------
 4 files changed, 41 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 410449d..9419f55 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -851,6 +851,11 @@ static int nfs_dentry_delete(struct dentry *dentry)
 		 * files will be cleaned up during umount */
 		return 1;
 	}
+	if (dentry->d_inode == NULL &&
+	    (NFS_SB(dentry->d_sb)->flags & NFS_MOUNT_NONEGDE)) {
+		/* Unhash it, so that negative dentries won't be cached */
+		return 1;
+	}
 	return 0;
 
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 4b03345..1c8e7ee 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -124,7 +124,7 @@ enum {
 	Opt_soft, Opt_hard, Opt_intr,
 	Opt_nointr, Opt_posix, Opt_noposix, Opt_cto, Opt_nocto, Opt_ac, 
 	Opt_noac, Opt_lock, Opt_nolock, Opt_v2, Opt_v3, Opt_udp, Opt_tcp,
-	Opt_acl, Opt_noacl,
+	Opt_acl, Opt_noacl, Opt_negde, Opt_nonegde,
 	/* Error token */
 	Opt_err
 };
@@ -161,6 +161,8 @@ static match_table_t __initdata tokens = {
 	{Opt_tcp, "tcp"},
 	{Opt_acl, "acl"},
 	{Opt_noacl, "noacl"},
+	{Opt_negde, "negde"},
+	{Opt_nonegde, "nonegde"},
 	{Opt_err, NULL}
 	
 };
@@ -275,6 +277,12 @@ static int __init root_nfs_parse(char *name, char *buf)
 			case Opt_noacl:
 				nfs_data.flags |= NFS_MOUNT_NOACL;
 				break;
+			case Opt_negde:
+				nfs_data.flags &= ~NFS_MOUNT_NONEGDE;
+				break;
+			case Opt_nonegde:
+				nfs_data.flags |= NFS_MOUNT_NONEGDE;
+				break;
 			default:
 				printk(KERN_WARNING "Root-NFS: unknown "
 					"option: %s\n", p);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0d1bc61..7043a07 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -75,6 +75,7 @@ enum {
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
 	Opt_sharecache, Opt_nosharecache,
+	Opt_negde, Opt_nonegde,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -124,6 +125,8 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_nordirplus, "nordirplus" },
 	{ Opt_sharecache, "sharecache" },
 	{ Opt_nosharecache, "nosharecache" },
+	{ Opt_negde, "negde" },
+	{ Opt_nonegde, "nonegde" },
 
 	{ Opt_port, "port=%u" },
 	{ Opt_rsize, "rsize=%u" },
@@ -455,6 +458,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NOACL, ",noacl", "" },
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", ""},
+		{ NFS_MOUNT_NONEGDE, ",nonegde", ""},
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -779,6 +783,11 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nosharecache:
 			mnt->flags |= NFS_MOUNT_UNSHARED;
 			break;
+		case Opt_negde:
+			mnt->flags &= ~NFS_MOUNT_NONEGDE;
+			break;
+		case Opt_nonegde:
+			mnt->flags |= NFS_MOUNT_NONEGDE;
 
 		case Opt_port:
 			if (match_int(args, &option))
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index a3ade89..44ffb60 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -47,22 +47,23 @@ struct nfs_mount_data {
 
 /* bits in the flags field */
 
-#define NFS_MOUNT_SOFT		0x0001	/* 1 */
-#define NFS_MOUNT_INTR		0x0002	/* 1 */
-#define NFS_MOUNT_SECURE	0x0004	/* 1 */
-#define NFS_MOUNT_POSIX		0x0008	/* 1 */
-#define NFS_MOUNT_NOCTO		0x0010	/* 1 */
-#define NFS_MOUNT_NOAC		0x0020	/* 1 */
-#define NFS_MOUNT_TCP		0x0040	/* 2 */
-#define NFS_MOUNT_VER3		0x0080	/* 3 */
-#define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
-#define NFS_MOUNT_NONLM		0x0200	/* 3 */
-#define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
-#define NFS_MOUNT_NOACL		0x0800	/* 4 */
-#define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
-#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
-#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
-#define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
-#define NFS_MOUNT_FLAGMASK	0xFFFF
+#define NFS_MOUNT_SOFT		0x00001	/* 1 */
+#define NFS_MOUNT_INTR		0x00002	/* 1 */
+#define NFS_MOUNT_SECURE	0x00004	/* 1 */
+#define NFS_MOUNT_POSIX		0x00008	/* 1 */
+#define NFS_MOUNT_NOCTO		0x00010	/* 1 */
+#define NFS_MOUNT_NOAC		0x00020	/* 1 */
+#define NFS_MOUNT_TCP		0x00040	/* 2 */
+#define NFS_MOUNT_VER3		0x00080	/* 3 */
+#define NFS_MOUNT_KERBEROS	0x00100	/* 3 */
+#define NFS_MOUNT_NONLM		0x00200	/* 3 */
+#define NFS_MOUNT_BROKEN_SUID	0x00400	/* 4 */
+#define NFS_MOUNT_NOACL		0x00800	/* 4 */
+#define NFS_MOUNT_STRICTLOCK	0x01000	/* reserved for NFSv4 */
+#define NFS_MOUNT_SECFLAVOUR	0x02000	/* 5 */
+#define NFS_MOUNT_NORDIRPLUS	0x04000	/* 5 */
+#define NFS_MOUNT_UNSHARED	0x08000	/* 5 */
+#define NFS_MOUNT_NONEGDE	0x10000	/* 5 */
+#define NFS_MOUNT_FLAGMASK	0x1FFFF
 
 #endif
