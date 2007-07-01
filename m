From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/21] NFS: Remake nfsroot_mount as a permanent part
	of NFS	client
Date: Sun, 01 Jul 2007 12:13:27 -0400
Message-ID: <20070701161327.2786.92192.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52is-00008I-5y
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:30 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52iv-0007W6-Cj
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:33 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

In preparation for supporting NFSv2 and NFSv3 mount option handling in the
kernel NFS client, convert mount_clnt.c to be a permanent part of the NFS
client, instead of built only when CONFIG_ROOT_NFS is enabled.

In addition, we also replace the "struct sockaddr_in *" argument with
something more generic, to help support IPv6 at some later point.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/Makefile        |    4 ++-
 fs/nfs/mount_clnt.c    |   55 ++++++++++++++++++++++++------------------------
 fs/nfs/nfsroot.c       |    3 ++-
 include/linux/nfs_fs.h |    5 ++--
 4 files changed, 34 insertions(+), 33 deletions(-)

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
index 2892ec8..ee4899d 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -18,7 +18,7 @@
 #include <linux/nfs_fs.h>
 
 #ifdef RPC_DEBUG
-# define NFSDBG_FACILITY	NFSDBG_ROOT
+# define NFSDBG_FACILITY	NFSDBG_MOUNT
 #endif
 
 /*
@@ -28,7 +28,6 @@
 #define MOUNT_UMNT		3
  */
 
-static struct rpc_clnt *	mnt_create(struct sockaddr_in *, int, int);
 static struct rpc_program	mnt_program;
 
 struct mnt_fhstatus {
@@ -36,14 +35,21 @@ struct mnt_fhstatus {
 	struct nfs_fh *		fh;
 };
 
-/*
- * Obtain an NFS file handle for the given host and path
+/**
+ * nfs_mount - Obtain an NFS file handle for the given host and path
+ * @addr: pointer to server's address
+ * @len: size of server's address
+ * @hostname: name of server host, or NULL
+ * @path: pointer to string containing export path to mount
+ * @version: mount version to use for this request
+ * @protocol: transport protocol to use for thie request
+ * @fh: pointer to location to place returned file handle
+ *
+ * Uses default timeout parameters specified by underlying transport.
  */
-int
-nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
-		int version, int protocol)
+int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
+	      int version, int protocol, struct nfs_fh *fh)
 {
-	struct rpc_clnt		*mnt_clnt;
 	struct mnt_fhstatus	result = {
 		.fh		= fh
 	};
@@ -51,12 +57,23 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 		.rpc_argp	= path,
 		.rpc_resp	= &result,
 	};
+	struct rpc_create_args args = {
+		.protocol	= protocol,
+		.address	= addr,
+		.addrsize	= len,
+		.servername	= hostname,
+		.program	= &mnt_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= RPC_CLNT_CREATE_INTR,
+	};
+	struct rpc_clnt		*mnt_clnt;
 	int			status;
 
-	dprintk("NFS:      nfs_mount(%08x:%s)\n",
-			(unsigned)ntohl(addr->sin_addr.s_addr), path);
+	dprintk("NFS: sending MNT request for %s:%s\n",
+		(hostname ? hostname : "server"), path);
 
-	mnt_clnt = mnt_create(addr, version, protocol);
+	mnt_clnt = rpc_create(&args);
 	if (IS_ERR(mnt_clnt))
 		return PTR_ERR(mnt_clnt);
 
@@ -70,22 +87,6 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 	return status < 0? status : (result.status? -EACCES : 0);
 }
 
-static struct rpc_clnt *mnt_create(struct sockaddr_in *srvaddr, int version,
-				   int protocol)
-{
-	struct rpc_create_args args = {
-		.protocol	= protocol,
-		.address	= (struct sockaddr *)srvaddr,
-		.addrsize	= sizeof(*srvaddr),
-		.program	= &mnt_program,
-		.version	= version,
-		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= RPC_CLNT_CREATE_INTR,
-	};
-
-	return rpc_create(&args);
-}
-
 /*
  * XDR encode/decode functions for MOUNT
  */
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index f0db470..3490322 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -496,7 +496,8 @@ static int __init root_nfs_get_handle(void)
 					NFS_MNT3_VERSION : NFS_MNT_VERSION;
 
 	set_sockaddr(&sin, servaddr, htons(mount_port));
-	status = nfsroot_mount(&sin, nfs_path, &fh, version, protocol);
+	status = nfs_mount((struct sockaddr *) &sin, sizeof(sin), NULL,
+			   nfs_path, version, protocol, &fh);
 	if (status < 0)
 		printk(KERN_ERR "Root-NFS: Server returned error %d "
 				"while mounting %s\n", status, nfs_path);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 589ea69..6f10cb4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -494,10 +494,9 @@ static inline void nfs3_forget_cached_acls(struct inode *inode)
 
 /*
  * linux/fs/mount_clnt.c
- * (Used only by nfsroot module)
  */
-extern int  nfsroot_mount(struct sockaddr_in *, char *, struct nfs_fh *,
-		int, int);
+extern int  nfs_mount(struct sockaddr *, size_t, char *, char *,
+		      int, int, struct nfs_fh *);
 
 /*
  * inline functions


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
