From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 1/5] initial changes for NFS-over-IPv6
 (linux-2.5.66-NFS_IPv6-nfs.dif)
Date: 11 Apr 2003 16:35:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104107.1412.272.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e4.ny.us.ibm.com ([32.97.182.104])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19483A-0006RP-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:35:17 -0700
Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e4.ny.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNZ8sZ143654
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:35:08 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This patch against 2.5.66 provides for IPv6 support for the NFS client.

diff -Naurp linux-2.5.66/fs/nfs/inode.c linux-2.5.66-NFS_IPV6/fs/nfs/inode.c
--- linux-2.5.66/fs/nfs/inode.c	2003-03-24 14:01:15.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/nfs/inode.c	2003-04-07 17:37:15.000000000 -0700
@@ -34,6 +34,7 @@
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/vfs.h>
+#include <net/ipv6.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -404,8 +405,9 @@ int nfs_fill_super(struct super_block *s
 		timeparms.to_retries = 5;
 
 	/* Now create transport and client */
-	xprt = xprt_create_proto(tcp? IPPROTO_TCP : IPPROTO_UDP,
-						&server->addr, &timeparms);
+	xprt = xprt_create_proto(tcp ? IPPROTO_TCP : IPPROTO_UDP,
+				(struct sockaddr *)&server->addr,
+				&timeparms);
 	if (xprt == NULL) {
 		printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
 		goto out_fail;
@@ -1182,11 +1184,36 @@ static int nfs_compare_super(struct supe
 {
 	struct nfs_server *server = data;
 	struct nfs_server *old = NFS_SB(sb);
+	struct sockaddr_in  *old_sin,  *server_sin;
+	struct sockaddr_in6 *old_sin6, *server_sin6;
 
-	if (old->addr.sin_addr.s_addr != server->addr.sin_addr.s_addr)
-		return 0;
-	if (old->addr.sin_port != server->addr.sin_port)
-		return 0;
+	switch ( server->addr.ss_family ) {
+	case AF_INET:
+		old_sin    = (struct sockaddr_in *)&(old->addr);
+		server_sin = (struct sockaddr_in *)&(server->addr);
+
+		if (old_sin->sin_addr.s_addr != server_sin->sin_addr.s_addr)
+			return 0;
+		if (old_sin->sin_port != server_sin->sin_port)
+			return 0;
+		break;
+
+	case AF_INET6:
+		old_sin6    = (struct sockaddr_in6 *)&(old->addr);
+		server_sin6 = (struct sockaddr_in6 *)&(server->addr);
+
+		if (ipv6_addr_cmp(&(old_sin6->sin6_addr),
+				  &(server_sin6->sin6_addr)))
+			return 0;
+		if (old_sin6->sin6_port != server_sin6->sin6_port)
+			return 0;
+		break;
+
+	default:
+		printk("NFS: %s unknown address family %d\n", __FUNCTION__,
+			server->addr.ss_family);
+		break;
+	}
 	return !memcmp(&old->fh, &server->fh, sizeof(struct nfs_fh));
 }
 
@@ -1198,6 +1225,8 @@ static struct super_block *nfs_get_sb(st
 	struct super_block *s;
 	struct nfs_fh *root;
 	struct nfs_mount_data *data = raw_data;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 
 	if (!data) {
 		printk("nfs_read_super: missing data argument\n");
@@ -1236,10 +1265,29 @@ static struct super_block *nfs_get_sb(st
 	}
 	/* We now require that the mount process passes the remote address */
 	memcpy(&server->addr, &data->addr, sizeof(server->addr));
-	if (server->addr.sin_addr.s_addr == INADDR_ANY) {
-		printk("NFS: mount program didn't pass remote address!\n");
-		kfree(server);
-		return ERR_PTR(-EINVAL);
+	switch ( server->addr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&(server->addr);
+
+		if (sin->sin_addr.s_addr == INADDR_ANY) {
+			printk("NFS: mount program didn't pass remote IPv4 address!\n");
+			kfree(server);
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&(server->addr);
+
+		if (ipv6_addr_any(&sin6->sin6_addr)) {
+			printk("NFS: mount program didn't pass remote IPv6 address!\n");
+			kfree(server);
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	default:
+		printk("NFS: %s unknown address family %d\n", __FUNCTION__,
+			server->addr.ss_family);
+		break;
 	}
 
 	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
@@ -1331,7 +1379,8 @@ static int nfs4_fill_super(struct super_
 	}
 
 	/* Now create transport and client */
-	xprt = xprt_create_proto(proto, &server->addr, &timeparms);
+	xprt = xprt_create_proto(proto, (struct sockaddr *)&server->addr,
+			&timeparms);
 	if (xprt == NULL) {
 		printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
 		goto out_fail;
@@ -1422,6 +1471,8 @@ static struct super_block *nfs4_get_sb(s
 	struct super_block *s;
 	struct nfs4_mount_data *data = raw_data;
 	void *p;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 
 	if (!data) {
 		printk("nfs_read_super: missing data argument\n");
@@ -1462,11 +1513,33 @@ static struct super_block *nfs4_get_sb(s
 		s = ERR_PTR(-EFAULT);
 		goto out_free;
 	}
-	if (server->addr.sin_family != AF_INET ||
-	    server->addr.sin_addr.s_addr == INADDR_ANY) {
-		printk("NFS: mount program didn't pass remote IP address!\n");
+
+	switch ( server->addr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&(server->addr);
+
+		if (sin->sin_addr.s_addr == INADDR_ANY) {
+			printk("NFS: mount program didn't pass remote IPv4 address!\n");
+			s = ERR_PTR(-EINVAL);
+			goto out_free;
+		}
+		break;
+
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&(server->addr);
+
+		if (ipv6_addr_any(&sin6->sin6_addr)) {
+			printk("NFS: mount program didn't pass remote IPv6 address!\n");
+			s = ERR_PTR(-EINVAL);
+			goto out_free;
+		}
+		break;
+
+	default:
+		printk("NFS: mount program didn't pass remote IP address and/or address family!\n");
 		s = ERR_PTR(-EINVAL);
 		goto out_free;
+		break;
 	}
 
 	s = sget(fs_type, nfs4_compare_super, nfs_set_super, server);
diff -Naurp linux-2.5.66/fs/nfs/mount_clnt.c linux-2.5.66-NFS_IPV6/fs/nfs/mount_clnt.c
--- linux-2.5.66/fs/nfs/mount_clnt.c	2003-03-24 13:59:56.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/nfs/mount_clnt.c	2003-04-07 17:37:42.000000000 -0700
@@ -29,8 +29,7 @@
 #define MOUNT_UMNT		3
  */
 
-static struct rpc_clnt *	mnt_create(char *, struct sockaddr_in *,
-								int, int);
+static struct rpc_clnt *	mnt_create(char *, struct sockaddr *, int, int);
 struct rpc_program		mnt_program;
 
 struct mnt_fhstatus {
@@ -42,7 +41,7 @@ struct mnt_fhstatus {
  * Obtain an NFS file handle for the given host and path
  */
 int
-nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
+nfsroot_mount(struct sockaddr *addr, char *path, struct nfs_fh *fh,
 		int version, int protocol)
 {
 	struct rpc_clnt		*mnt_clnt;
@@ -66,8 +65,7 @@ nfsroot_mount(struct sockaddr_in *addr, 
 }
 
 static struct rpc_clnt *
-mnt_create(char *hostname, struct sockaddr_in *srvaddr, int version,
-		int protocol)
+mnt_create(char *hostname, struct sockaddr *srvaddr, int version, int protocol)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_clnt	*clnt;
diff -Naurp linux-2.5.66/include/linux/nfs_fs.h linux-2.5.66-NFS_IPV6/include/linux/nfs_fs.h
--- linux-2.5.66/include/linux/nfs_fs.h	2003-03-24 14:00:17.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfs_fs.h	2003-04-07 17:40:03.000000000 -0700
@@ -375,8 +375,7 @@ extern void nfs_readdata_release(struct 
  * linux/fs/mount_clnt.c
  * (Used only by nfsroot module)
  */
-extern int  nfsroot_mount(struct sockaddr_in *, char *, struct nfs_fh *,
-		int, int);
+extern int  nfsroot_mount(struct sockaddr *, char *, struct nfs_fh *, int, int);
 
 /*
  * inline functions
diff -Naurp linux-2.5.66/include/linux/nfs_fs_sb.h linux-2.5.66-NFS_IPV6/include/linux/nfs_fs_sb.h
--- linux-2.5.66/include/linux/nfs_fs_sb.h	2003-03-24 14:01:53.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfs_fs_sb.h	2003-04-07 17:40:24.000000000 -0700
@@ -26,7 +26,7 @@ struct nfs_server {
 	unsigned int		namelen;
 	char *			hostname;	/* remote hostname */
 	struct nfs_fh		fh;
-	struct sockaddr_in	addr;
+	struct sockaddr_storage	addr;
 #if CONFIG_NFS_V4
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the clientid, and the callback address.
diff -Naurp linux-2.5.66/include/linux/nfs.h linux-2.5.66-NFS_IPV6/include/linux/nfs.h
--- linux-2.5.66/include/linux/nfs.h	2003-03-24 14:01:14.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfs.h	2003-04-01 15:10:16.000000000 -0800
@@ -8,6 +8,11 @@
 #define _LINUX_NFS_H
 
 #include <linux/sunrpc/msg_prot.h>
+#ifdef CONFIG_NFS_IPV6
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/socket.h>
+#endif
 
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
@@ -116,6 +121,17 @@ enum nfs_ftype {
 	NFFIFO = 8
 };
 
+#ifdef CONFIG_NFS_IPV6
+/* IP address information */
+struct nfs_addr {
+	sa_family_t		family;
+	union {
+		struct in_addr	v4;
+		struct in6_addr	v6;
+	} addr_u;
+};
+
+#endif
 #if defined(__KERNEL__)
 /*
  * This is the kernel NFS client file handle representation
diff -Naurp linux-2.5.66/include/linux/nfs_mount.h linux-2.5.66-NFS_IPV6/include/linux/nfs_mount.h
--- linux-2.5.66/include/linux/nfs_mount.h	2003-03-24 13:59:54.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfs_mount.h	2003-04-10 16:37:33.000000000 -0700
@@ -20,7 +20,11 @@
  * mount-to-kernel version compatibility.  Some of these aren't used yet
  * but here they are anyway.
  */
+#ifdef CONFIG_NFS_IPV6
+#define NFS_MOUNT_VERSION	5
+#else
 #define NFS_MOUNT_VERSION	4
+#endif
 
 struct nfs_mount_data {
 	int		version;		/* 1 */
@@ -35,12 +39,19 @@ struct nfs_mount_data {
 	int		acregmax;		/* 1 */
 	int		acdirmin;		/* 1 */
 	int		acdirmax;		/* 1 */
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_in old_addr;		/* 1 */
+#else
 	struct sockaddr_in addr;		/* 1 */
+#endif
 	char		hostname[256];		/* 1 */
 	int		namlen;			/* 2 */
 	unsigned int	bsize;			/* 3 */
 	struct nfs3_fh	root;			/* 4 */
 	int		pseudoflavor;		/* 4 */
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_storage addr;		/* 5 */
+#endif
 };
 
 /* bits in the flags field */

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
