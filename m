From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 18/19] A basic NFSv4 client for 2.5.x
Date: Tue, 15 Oct 2002 00:35:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15787.18075.529388.84987@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Do1-00046p-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 15:35:22 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Define the new NFSv4 data structure for passing user information
from the 'mount' program in nfs4_mount.h.

If CONFIG_NFS_V4 is defined
        Add code to parse the mount structure into the superblock.
        Declare the NFSv4 filesystem to the VFS.

diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/fs/nfs/inode.c linux-2.5.42-nfsv4-E03/fs/nfs/inode.c
--- linux-2.5.42-nfsv4-E02/fs/nfs/inode.c	2002-10-14 10:03:01.000000000 -0400
+++ linux-2.5.42-nfsv4-E03/fs/nfs/inode.c	2002-10-14 14:38:48.000000000 -0400
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
+#include <linux/nfs4_mount.h>
 #include <linux/nfs_flushd.h>
 #include <linux/lockd/bind.h>
 #include <linux/smp_lock.h>
@@ -157,6 +158,7 @@
 		lockd_down();	/* release rpc.lockd */
 	rpciod_down();		/* release rpciod */
 
+	destroy_nfsv4_state(server);
 	kfree(server->hostname);
 }
 
@@ -1283,6 +1285,239 @@
 	.fs_flags	= FS_ODD_RENAME,
 };
 
+#ifdef CONFIG_NFS_V4
+
+static int nfs4_fill_super(struct super_block *sb, struct nfs4_mount_data *data, int silent)
+{
+	struct nfs_server *server;
+	struct rpc_xprt *xprt = NULL;
+	struct rpc_clnt *clnt = NULL;
+	struct rpc_timeout timeparms;
+	rpc_authflavor_t authflavour;
+	int proto, err = -EIO;
+
+	sb->s_blocksize_bits = 0;
+	sb->s_blocksize = 0;
+	server = NFS_SB(sb);
+	if (data->rsize != 0)
+		server->rsize = nfs_block_size(data->rsize, NULL);
+	if (data->wsize != 0)
+		server->wsize = nfs_block_size(data->wsize, NULL);
+	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+
+	/* NFSv4 doesn't use NLM locking */
+	server->flags |= NFS_MOUNT_NONLM;
+
+	server->acregmin = data->acregmin*HZ;
+	server->acregmax = data->acregmax*HZ;
+	server->acdirmin = data->acdirmin*HZ;
+	server->acdirmax = data->acdirmax*HZ;
+
+	server->rpc_ops = &nfs_v4_clientops;
+	/* Initialize timeout values */
+
+	timeparms.to_initval = data->timeo * HZ / 10;
+	timeparms.to_retries = data->retrans;
+	timeparms.to_exponential = 1;
+	if (!timeparms.to_retries)
+		timeparms.to_retries = 5;
+
+	proto = data->proto;
+	/* Which IP protocol do we use? */
+	switch (proto) {
+	case IPPROTO_TCP:
+		timeparms.to_maxval  = RPC_MAX_TCP_TIMEOUT;
+		if (!timeparms.to_initval)
+			timeparms.to_initval = 600 * HZ / 10;
+		break;
+	case IPPROTO_UDP:
+		timeparms.to_maxval  = RPC_MAX_UDP_TIMEOUT;
+		if (!timeparms.to_initval)
+			timeparms.to_initval = 11 * HZ / 10;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Now create transport and client */
+	xprt = xprt_create_proto(proto, &server->addr, &timeparms);
+	if (xprt == NULL) {
+		printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
+		goto out_fail;
+	}
+
+	authflavour = RPC_AUTH_UNIX;
+	if (data->auth_flavourlen != 0) {
+		if (data->auth_flavourlen > 1)
+			printk(KERN_INFO "NFS: cannot yet deal with multiple auth flavours.\n");
+		if (copy_from_user(authflavour, data->auth_flavours, sizeof(authflavour))) {
+			err = -EFAULT;
+			goto out_fail;
+		}
+	}
+	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
+				 server->rpc_ops->version, authflavour);
+	if (clnt == NULL) {
+		printk(KERN_WARNING "NFS: cannot create RPC client.\n");
+		xprt_destroy(xprt);
+		goto out_fail;
+	}
+
+	clnt->cl_intr     = (server->flags & NFS4_MOUNT_INTR) ? 1 : 0;
+	clnt->cl_softrtry = (server->flags & NFS4_MOUNT_SOFT) ? 1 : 0;
+	clnt->cl_chatty   = 1;
+	server->client    = clnt;
+
+	/* Fire up rpciod if not yet running */
+	if (rpciod_up() != 0) {
+		printk(KERN_WARNING "NFS: couldn't start rpciod!\n");
+		goto out_shutdown;
+	}
+
+	if (create_nfsv4_state(server, data))
+		goto out_shutdown;
+
+	err = nfs_sb_init(sb);
+	if (err == 0)
+		return 0;
+	rpciod_down();
+	destroy_nfsv4_state(server);
+out_shutdown:
+	rpc_shutdown_client(server->client);
+out_fail:
+	return err;
+}
+
+static int nfs4_compare_super(struct super_block *sb, void *data)
+{
+	struct nfs_server *server = data;
+	struct nfs_server *old = NFS_SB(sb);
+
+	if (strcmp(server->hostname, old->hostname) != 0)
+		return 0;
+	if (strcmp(server->mnt_path, old->mnt_path) != 0)
+		return 0;
+	return 1;
+}
+
+static void *
+nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
+{
+	void *p = NULL;
+
+	if (!src->len)
+		return ERR_PTR(-EINVAL);
+	if (src->len < maxlen)
+		maxlen = src->len;
+	if (dst == NULL) {
+		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
+		if (p == NULL)
+			return ERR_PTR(-ENOMEM);
+	}
+	if (copy_from_user(dst, src->data, maxlen)) {
+		if (p != NULL)
+			kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+	dst[maxlen] = '\0';
+	return dst;
+}
+
+static struct super_block *nfs4_get_sb(struct file_system_type *fs_type,
+	int flags, char *dev_name, void *raw_data)
+{
+	int error;
+	struct nfs_server *server;
+	struct super_block *s;
+	struct nfs4_mount_data *data = raw_data;
+	void *p;
+
+	if (!data) {
+		printk("nfs_read_super: missing data argument\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	server = kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (!server)
+		return ERR_PTR(-ENOMEM);
+	memset(server, 0, sizeof(struct nfs_server));
+
+	if (data->version != NFS4_MOUNT_VERSION) {
+		printk("nfs warning: mount version %s than kernel\n",
+			data->version < NFS_MOUNT_VERSION ? "older" : "newer");
+	}
+
+	p = nfs_copy_user_string(NULL, &data->hostname, 256);
+	if (IS_ERR(p))
+		goto out_err;
+	server->hostname = p;
+
+	p = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
+	if (IS_ERR(p))
+		goto out_err;
+	server->mnt_path = p;
+
+	p = nfs_copy_user_string(server->ip_addr, &data->client_addr,
+			sizeof(server->ip_addr));
+	if (IS_ERR(p))
+		goto out_err;
+
+	/* We now require that the mount process passes the remote address */
+	if (data->host_addrlen != sizeof(server->addr)) {
+		s = ERR_PTR(-EINVAL);
+		goto out_free;
+	}
+	if (copy_from_user(&server->addr, data->host_addr, sizeof(server->addr))) {
+		s = ERR_PTR(-EFAULT);
+		goto out_free;
+	}
+	if (server->addr.sin_family != AF_INET ||
+	    server->addr.sin_addr.s_addr == INADDR_ANY) {
+		printk("NFS: mount program didn't pass remote IP address!\n");
+		s = ERR_PTR(-EINVAL);
+		goto out_free;
+	}
+
+	s = sget(fs_type, nfs4_compare_super, nfs_set_super, server);
+
+	if (IS_ERR(s) || s->s_root)
+		goto out_free;
+
+	s->s_flags = flags;
+
+	error = nfs4_fill_super(s, data, flags & MS_VERBOSE ? 1 : 0);
+	if (error) {
+		up_write(&s->s_umount);
+		deactivate_super(s);
+		return ERR_PTR(error);
+	}
+	s->s_flags |= MS_ACTIVE;
+	return s;
+out_err:
+	s = (struct super_block *)p;
+out_free:
+	if (server->mnt_path)
+		kfree(server->mnt_path);
+	if (server->hostname)
+		kfree(server->hostname);
+	kfree(server);
+	return s;
+}
+
+static struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs4_get_sb,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_ODD_RENAME,
+};
+#define register_nfs4fs() register_filesystem(&nfs4_fs_type)
+#define unregister_nfs4fs() unregister_filesystem(&nfs4_fs_type)
+#else
+#define register_nfs4fs() (0)
+#define unregister_nfs4fs()
+#endif
+
 extern int nfs_init_nfspagecache(void);
 extern void nfs_destroy_nfspagecache(void);
 extern int nfs_init_readpagecache(void);
@@ -1374,6 +1609,8 @@
         err = register_filesystem(&nfs_fs_type);
 	if (err)
 		goto out;
+	if ((err = register_nfs4fs()) != 0)
+		goto out;
 	return 0;
 out:
 	rpc_proc_unregister("nfs");
@@ -1398,6 +1635,7 @@
 	rpc_proc_unregister("nfs");
 #endif
 	unregister_filesystem(&nfs_fs_type);
+	unregister_nfs4fs();
 }
 
 /* Not quite true; I just maintain it */
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs3.h linux-2.5.42-nfsv4-E03/include/linux/nfs3.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs3.h	2002-10-10 19:24:44.000000000 -0400
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs3.h	2002-10-14 10:03:25.000000000 -0400
@@ -59,6 +59,11 @@
 	NF3BAD  = 8
 };
 
+struct nfs3_fh {
+	unsigned short size;
+	unsigned char  data[NFS3_FHSIZE];
+};
+
 #define NFS3_VERSION		3
 #define NFS3PROC_NULL		0
 #define NFS3PROC_GETATTR	1
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs4_mount.h linux-2.5.42-nfsv4-E03/include/linux/nfs4_mount.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs4_mount.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs4_mount.h	2002-10-14 14:39:05.000000000 -0400
@@ -0,0 +1,70 @@
+#ifndef _LINUX_NFS4_MOUNT_H
+#define _LINUX_NFS4_MOUNT_H
+
+/*
+ *  linux/include/linux/nfs4_mount.h
+ *
+ *  Copyright (C) 2002  Trond Myklebust
+ *
+ *  structure passed from user-space to kernel-space during an nfsv4 mount
+ */
+
+/*
+ * WARNING!  Do not delete or change the order of these fields.  If
+ * a new field is required then add it to the end.  The version field
+ * tracks which fields are present.  This will ensure some measure of
+ * mount-to-kernel version compatibility.  Some of these aren't used yet
+ * but here they are anyway.
+ */
+#define NFS4_MOUNT_VERSION	1
+
+struct nfs_string {
+	unsigned int len;
+	const char* data;
+};
+
+struct nfs4_mount_data {
+	int version;				/* 1 */
+	int flags;				/* 1 */
+	int rsize;				/* 1 */
+	int wsize;				/* 1 */
+	int timeo;				/* 1 */
+	int retrans;				/* 1 */
+	int acregmin;				/* 1 */
+	int acregmax;				/* 1 */
+	int acdirmin;				/* 1 */
+	int acdirmax;				/* 1 */
+
+	/* see the definition of 'struct clientaddr4' in RFC3010 */
+	struct nfs_string client_addr;		/* 1 */
+
+	/* Mount path */
+	struct nfs_string mnt_path;		/* 1 */
+
+	/* Server details */
+	struct nfs_string hostname;		/* 1 */
+	/* Server IP address */
+	unsigned int host_addrlen;		/* 1 */
+	struct sockaddr* host_addr;		/* 1 */
+
+	/* Transport protocol to use */
+	int proto;				/* 1 */
+
+	/* Pseudo-flavours to use for authentication. See RFC2623 */
+	int auth_flavourlen;			/* 1 */
+	int *auth_flavours;			/* 1 */
+};
+
+/* bits in the flags field */
+/* Note: the fields that correspond to existing NFSv2/v3 mount options
+ * 	 should mirror the values from include/linux/nfs_mount.h
+ */
+
+#define NFS4_MOUNT_SOFT		0x0001	/* 1 */
+#define NFS4_MOUNT_INTR		0x0002	/* 1 */
+#define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
+#define NFS4_MOUNT_NOAC		0x0020	/* 1 */
+#define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
+#define NFS4_MOUNT_FLAGMASK	0xFFFF
+
+#endif
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs_fs.h linux-2.5.42-nfsv4-E03/include/linux/nfs_fs.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs_fs.h	2002-10-11 18:22:38.000000000 -0400
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs_fs.h	2002-10-14 10:03:25.000000000 -0400
@@ -472,6 +472,36 @@
 
 #define NFS_JUKEBOX_RETRY_TIME (5 * HZ)
 
+#ifdef CONFIG_NFS_V4
+
+extern struct nfs4_client *nfs4_get_client(void);
+extern void nfs4_put_client(struct nfs4_client *clp);
+
+struct nfs4_mount_data;
+static inline int
+create_nfsv4_state(struct nfs_server *server, struct nfs4_mount_data *data)
+{
+	server->nfs4_state = NULL;
+	return 0;
+}
+
+static inline void
+destroy_nfsv4_state(struct nfs_server *server)
+{
+	if (server->mnt_path) {
+		kfree(server->mnt_path);
+		server->mnt_path = NULL;
+	}
+	if (server->nfs4_state) {
+		nfs4_put_client(server->nfs4_state);
+		server->nfs4_state = NULL;
+	}
+}
+#else
+#define create_nfsv4_state(server, data)  0
+#define destroy_nfsv4_state(server)       do { } while (0)
+#endif
+
 #endif /* __KERNEL__ */
 
 /*
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs_fs_sb.h linux-2.5.42-nfsv4-E03/include/linux/nfs_fs_sb.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs_fs_sb.h	2002-07-27 14:56:14.000000000 -0400
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs_fs_sb.h	2002-10-14 10:03:25.000000000 -0400
@@ -30,6 +30,16 @@
 				lru_busy;
 	struct nfs_fh		fh;
 	struct sockaddr_in	addr;
+#if CONFIG_NFS_V4
+	/* Our own IP address, as a null-terminated string.
+	 * This is used to generate the clientid, and the callback address.
+	 */
+	char			ip_addr[16];
+	char *			mnt_path;
+	struct nfs4_client *	nfs4_state;	/* all NFSv4 state starts here */
+	unsigned long		lease_time;	/* in jiffies */
+	unsigned long		last_renewal;	/* in jiffies */
+#endif
 };
 
 /* Server capabilities */
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs.h linux-2.5.42-nfsv4-E03/include/linux/nfs.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs.h	2002-08-21 19:21:27.000000000 -0400
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs.h	2002-10-14 10:03:25.000000000 -0400
@@ -120,7 +120,7 @@
 /*
  * This is the kernel NFS client file handle representation
  */
-#define NFS_MAXFHSIZE		64
+#define NFS_MAXFHSIZE		128
 struct nfs_fh {
 	unsigned short		size;
 	unsigned char		data[NFS_MAXFHSIZE];
diff -u --recursive --new-file linux-2.5.42-nfsv4-E02/include/linux/nfs_mount.h linux-2.5.42-nfsv4-E03/include/linux/nfs_mount.h
--- linux-2.5.42-nfsv4-E02/include/linux/nfs_mount.h	2002-02-05 12:39:40.000000000 -0500
+++ linux-2.5.42-nfsv4-E03/include/linux/nfs_mount.h	2002-10-14 10:03:25.000000000 -0400
@@ -10,6 +10,8 @@
  */
 #include <linux/in.h>
 #include <linux/nfs.h>
+#include <linux/nfs2.h>
+#include <linux/nfs3.h>
 
 /*
  * WARNING!  Do not delete or change the order of these fields.  If
@@ -37,7 +39,7 @@
 	char		hostname[256];		/* 1 */
 	int		namlen;			/* 2 */
 	unsigned int	bsize;			/* 3 */
-	struct nfs_fh	root;			/* 4 */
+	struct nfs3_fh	root;			/* 4 */
 };
 
 /* bits in the flags field */
@@ -53,6 +55,10 @@
 #define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
 #define NFS_MOUNT_NONLM		0x0200	/* 3 */
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
+#if 0
+#define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
+#define NFS_MOUNT_SECFLAVOUR	0x2000	/* reserved */
+#endif
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
 #endif


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
