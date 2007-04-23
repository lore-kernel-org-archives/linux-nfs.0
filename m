From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] NFS: Remake nfsroot_mount as a permanent part of
	NFS	client
Date: Mon, 23 Apr 2007 18:04:24 -0400
Message-ID: <20070423220424.24305.61692.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6e8-0003QM-RH
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:32 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6eB-0008RF-5U
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:35 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

In preparation for supporting NFSv2 and NFSv3 mount option handling in the
kernel NFS client, convert mount_clnt.c to be a permanent part of the NFS
client, instead of built only when CONFIG_ROOT_NFS is enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/Makefile        |    4 +-
 fs/nfs/mount_clnt.c    |   82 +++++++++++++++++++++++++-----------------------
 fs/nfs/nfsroot.c       |    2 +
 include/linux/nfs_fs.h |    5 +--
 4 files changed, 47 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index f4580b4..b55cb23 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -6,8 +6,8 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 			   pagelist.o proc.o read.o symlink.o unlink.o \
-			   write.o namespace.o
-nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o mount_clnt.o      
+			   write.o namespace.o mount_clnt.o
+nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index ca5a266..073ccfa 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -1,7 +1,5 @@
 /*
- * linux/fs/nfs/mount_clnt.c
- *
- * MOUNT client to support NFSroot.
+ * In-kernel MOUNT protocol client
  *
  * Copyright (C) 1997, Olaf Kirch <okir@monad.swb.de>
  */
@@ -18,18 +16,10 @@
 #include <linux/nfs_fs.h>
 
 #ifdef RPC_DEBUG
-# define NFSDBG_FACILITY	NFSDBG_ROOT
+# define NFSDBG_FACILITY	NFSDBG_MOUNT
 #endif
 
-/*
-#define MOUNT_PROGRAM		100005
-#define MOUNT_VERSION		1
-#define MOUNT_MNT		1
-#define MOUNT_UMNT		3
- */
 
-static struct rpc_clnt *	mnt_create(char *, struct sockaddr_in *,
-								int, int);
 static struct rpc_program	mnt_program;
 
 struct mnt_fhstatus {
@@ -37,12 +27,39 @@ struct mnt_fhstatus {
 	struct nfs_fh *		fh;
 };
 
-/*
- * Obtain an NFS file handle for the given host and path
+static struct rpc_clnt *mnt_create(char *hostname,
+				   struct sockaddr_in *srvaddr,
+				   int version,
+				   int protocol)
+{
+	struct rpc_create_args args = {
+		.protocol	= protocol,
+		.address	= (struct sockaddr *)srvaddr,
+		.addrsize	= sizeof(*srvaddr),
+		.servername	= hostname,
+		.program	= &mnt_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT |
+				   RPC_CLNT_CREATE_INTR),
+	};
+
+	return rpc_create(&args);
+}
+
+/**
+ * nfs_mount - Obtain an NFS file handle for the given host and path
+ * @addr: pointer to server's address
+ * @path: pointer to string containing export path to mount
+ * @fh: pointer to location to place returned file handle
+ * @version: mount version to use for this request
+ * @protocol: transport protocol to use for thie request
+ *
+ * XXX: Mount requests through this interface are interruptible, but
+ *      this also needs to timeout after a bit
  */
-int
-nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
-		int version, int protocol)
+int nfs_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
+	      int version, int protocol)
 {
 	struct rpc_clnt		*mnt_clnt;
 	struct mnt_fhstatus	result = {
@@ -55,10 +72,10 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 	char			hostname[32];
 	int			status;
 
-	dprintk("NFS:      nfs_mount(%08x:%s)\n",
-			(unsigned)ntohl(addr->sin_addr.s_addr), path);
+	dprintk("NFS:       %s(" NIPQUAD_FMT ":%s)\n",
+		__FUNCTION__, NIPQUAD(addr->sin_addr.s_addr), path);
 
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr->sin_addr.s_addr));
+	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(addr->sin_addr.s_addr));
 	mnt_clnt = mnt_create(hostname, addr, version, protocol);
 	if (IS_ERR(mnt_clnt))
 		return PTR_ERR(mnt_clnt);
@@ -69,26 +86,11 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MNTPROC_MNT];
 
 	status = rpc_call_sync(mnt_clnt, &msg, 0);
-	return status < 0? status : (result.status? -EACCES : 0);
-}
-
-static struct rpc_clnt *
-mnt_create(char *hostname, struct sockaddr_in *srvaddr, int version,
-		int protocol)
-{
-	struct rpc_create_args args = {
-		.protocol	= protocol,
-		.address	= (struct sockaddr *)srvaddr,
-		.addrsize	= sizeof(*srvaddr),
-		.servername	= hostname,
-		.program	= &mnt_program,
-		.version	= version,
-		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= (RPC_CLNT_CREATE_ONESHOT |
-				   RPC_CLNT_CREATE_INTR),
-	};
-
-	return rpc_create(&args);
+	if (status < 0)
+		return status;
+	if (result.status != 0)
+		return -EACCES;
+	return 0;
 }
 
 /*
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index f0db470..a52c891 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -496,7 +496,7 @@ static int __init root_nfs_get_handle(void)
 					NFS_MNT3_VERSION : NFS_MNT_VERSION;
 
 	set_sockaddr(&sin, servaddr, htons(mount_port));
-	status = nfsroot_mount(&sin, nfs_path, &fh, version, protocol);
+	status = nfs_mount(&sin, nfs_path, &fh, version, protocol);
 	if (status < 0)
 		printk(KERN_ERR "Root-NFS: Server returned error %d "
 				"while mounting %s\n", status, nfs_path);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e9ae0c6..acfead8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -496,10 +496,8 @@ static inline void nfs3_forget_cached_acls(struct inode *inode)
 
 /*
  * linux/fs/mount_clnt.c
- * (Used only by nfsroot module)
  */
-extern int  nfsroot_mount(struct sockaddr_in *, char *, struct nfs_fh *,
-		int, int);
+extern int  nfs_mount(struct sockaddr_in *, char *, struct nfs_fh *, int, int);
 
 /*
  * inline functions
@@ -557,6 +555,7 @@ extern void * nfs_root_data(void);
 #define NFSDBG_ROOT		0x0080
 #define NFSDBG_CALLBACK		0x0100
 #define NFSDBG_CLIENT		0x0200
+#define NFSDBG_MOUNT		0x0400
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
