From: James Morris <jmorris@namei.org>
Subject: [PATCH 7/8][RFC v05] NFSv3: Add xattr and xattrsec mount options to
 support XATTR protocol
Date: Mon, 21 Jun 2010 21:32:16 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1006212131320.13583@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: linux-nfs@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add xattr and xattrsec mount options to allow administrative support
for the XATTR protocol.

Option use:

   xattr        Enable the XATTR protocol (default if supported)
   noxattr      Disable the XATTR protocol

   xattrsec     Utilize security xattrs via the XATTR protocol
   noxattrsec   Do not utilize security xattrs (default)

The default is to have xattrs enabled by default if they're supported
at the client and the server.

The xattrsec option is used to indicate to the security subsystem on
the client that security labels for the mounted fs should be conveyed
via the XATTR protocol.

Note that the use of these options requires an updated userspace mount
utility (patch available separately).

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/nfsroot.c          |   12 ++++++++++++
 fs/nfs/super.c            |   19 +++++++++++++++++++
 include/linux/nfs_fs.h    |    6 ++++++
 include/linux/nfs_mount.h |   13 ++++++-------
 4 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 6bd19d8..cdc9644 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -128,6 +128,8 @@ enum {
 	Opt_nointr, Opt_posix, Opt_noposix, Opt_cto, Opt_nocto, Opt_ac, 
 	Opt_noac, Opt_lock, Opt_nolock, Opt_v2, Opt_v3, Opt_udp, Opt_tcp,
 	Opt_acl, Opt_noacl,
+	Opt_xattr, Opt_noxattr,
+	Opt_xattrsec, Opt_noxattrsec,
 	/* Error token */
 	Opt_err
 };
@@ -164,6 +166,10 @@ static const match_table_t tokens __initconst = {
 	{Opt_tcp, "tcp"},
 	{Opt_acl, "acl"},
 	{Opt_noacl, "noacl"},
+	{Opt_xattr, "xattr"},
+	{Opt_noxattr, "noxattr"},
+	{Opt_xattrsec, "xattrsec"},
+	{Opt_noxattrsec, "noxattrsec"},
 	{Opt_err, NULL}
 	
 };
@@ -275,6 +281,12 @@ static int __init root_nfs_parse(char *name, char *buf)
 			case Opt_noacl:
 				nfs_data.flags |= NFS_MOUNT_NOACL;
 				break;
+			case Opt_xattr:
+				nfs_data.flags &= ~NFS_MOUNT_NOXATTR;
+				break;
+			case Opt_noxattr:
+				nfs_data.flags |= NFS_MOUNT_NOXATTR;
+				break;
 			default:
 				printk(KERN_WARNING "Root-NFS: unknown "
 					"option: %s\n", p);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b1368c2..f3def8c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -77,6 +77,8 @@ enum {
 	Opt_v2, Opt_v3, Opt_v4,
 	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
+	Opt_xattr, Opt_noxattr,
+	Opt_xattrsec, Opt_noxattrsec,
 	Opt_rdirplus, Opt_nordirplus,
 	Opt_sharecache, Opt_nosharecache,
 	Opt_resvport, Opt_noresvport,
@@ -134,6 +136,10 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_rdma, "rdma" },
 	{ Opt_acl, "acl" },
 	{ Opt_noacl, "noacl" },
+	{ Opt_xattr, "xattr" },
+	{ Opt_noxattr, "noxattr" },
+	{ Opt_xattrsec, "xattrsec" },
+	{ Opt_noxattrsec, "noxattrsec" },
 	{ Opt_rdirplus, "rdirplus" },
 	{ Opt_nordirplus, "nordirplus" },
 	{ Opt_sharecache, "sharecache" },
@@ -755,6 +761,7 @@ static void nfs_umount_begin(struct super_block *sb)
 
 	server = NFS_SB(sb);
 	/* -EIO all pending I/O */
+	/* FIXME: client_xattr ? */
 	rpc = server->client_acl;
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
@@ -1022,6 +1029,18 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_noacl:
 			mnt->flags |= NFS_MOUNT_NOACL;
 			break;
+		case Opt_xattr:
+			mnt->flags &= ~NFS_MOUNT_NOXATTR;
+			break;
+		case Opt_noxattr:
+			mnt->flags |= NFS_MOUNT_NOXATTR;
+			break;
+		case Opt_xattrsec:
+			mnt->flags |= NFS_MOUNT_XATTRSEC;
+			break;
+		case Opt_noxattrsec:
+			mnt->flags &= ~NFS_MOUNT_XATTRSEC;
+			break;
 		case Opt_rdirplus:
 			mnt->flags &= ~NFS_MOUNT_NORDIRPLUS;
 			break;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9b0d2de..7bf0aa5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -53,6 +53,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
 #include <linux/nfs_fs_sb.h>
+#include <linux/nfs_mount.h>
 
 #include <linux/mempool.h>
 
@@ -294,6 +295,11 @@ static inline int nfs_server_capable(struct inode *inode, int cap)
 	return NFS_SERVER(inode)->caps & cap;
 }
 
+static inline bool nfs_server_xattrsec(struct inode *inode)
+{
+	return NFS_SERVER(inode)->flags & NFS_MOUNT_XATTRSEC;
+}
+
 static inline int NFS_USE_READDIRPLUS(struct inode *inode)
 {
 	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 04bb4ee..c44355b 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -63,14 +63,13 @@ struct nfs_mount_data {
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
 #define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
 #define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
-#define NFS_MOUNT_FLAGMASK	0xFFFF
+#define NFS_MOUNT_NOXATTR	0x10000	/* 6 */
+#define NFS_MOUNT_XATTRSEC	0x20000	/* 6 */ /* utilize security xattrs */
+#define NFS_MOUNT_FLAGMASK	0x3FFFF
 
 /* The following are for internal use only */
-#define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
-#define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
-#define NFS_MOUNT_NORESVPORT		0x40000
-
-/* FIXME: determine semantics and modify flagmask if exposed to userland */
-#define NFS_MOUNT_NOXATTR		0x80000
+#define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x100000
+#define NFS_MOUNT_LOOKUP_CACHE_NONE	0x200000
+#define NFS_MOUNT_NORESVPORT		0x400000
 
 #endif
-- 
1.7.0.1

