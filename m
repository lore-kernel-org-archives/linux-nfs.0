From: Olaf Kirch <okir@suse.de>
Subject: Chuck's iostat patch
Date: Mon, 8 Mar 2004 17:46:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040308164612.GO16369@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="eAbsdosE1cNLO4uF"
Cc: Charles.Lever@netapp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0O2I-0000r8-7V
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 08:55:26 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0Ntw-0001QC-Uc
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 08:46:49 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--eAbsdosE1cNLO4uF
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi Chuck, hi all,

I took Chuck's iostat patch and played with it a little. Attached
you can find the results of this playing around.

This patch changes Chuck's work in two ways - one, all iostat sampling
happens in the RPC layer now, rather than having to add "nfs_count_call"
to every NFS function. This changes some things, e.g. the way in/out
bytes are counted. Chuck's patch counts the payload bytes of a read/write
request only, while my approach includes the RPC overhead.

Second, I ported it to 2.6, and made it use a seqfile for reading the
proc file.

There is still the open question whether the proc file interface to
retrieving and zapping the iostat counters is appropriate. It's
probably not too hard to extend this stuff to have a timer printk
the iostat values every second or so - the question is do we really
want this, or isn't the procfs approach sufficient?

Comments?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--eAbsdosE1cNLO4uF
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-iostat

diff -X excl -purNa linux-2.6.3-iostat/fs/Kconfig linux-2.6.3/fs/Kconfig
--- linux-2.6.3-iostat/fs/Kconfig	2004-03-05 12:06:23.000000000 +0100
+++ linux-2.6.3/fs/Kconfig	2004-03-08 17:28:36.000000000 +0100
@@ -1543,6 +1543,30 @@ config RPCSEC_GSS_KRB5
 	  Note: If you select this option, please ensure that you also
 	  enable the MD5 and DES crypto ciphers.
 
+config SUNRPC_IOSTATS
+	bool "Per-client I/O statistics (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL && PROC_FS
+	help
+	  When this option is enabled, user-level tools can access I/O
+	  statistics for each NFS mount point via /proc.  The NFS client
+	  creates a tree of files under /proc/net/rpc/iostat that contain
+	  statistics on NFS read and write operations such as how many
+	  reads and writes have occurred, how long the NFS client has
+	  waited for them to complete (in total), and how many bytes have
+	  been read or written.  There is one such file for each mounted
+	  NFS file system.  The counters in each file can be zeroed at
+	  any time by writing to that file as root.
+
+	  Note that on SMP systems, the total I/O wait time includes the
+	  time the process had to wait for the big kernel lock before it
+	  could schedule the RPC for that I/O.  At this time the wait
+	  time is measured in microseconds.
+
+	  To use tools like iostat or sar to monitor your NFS client,
+	  you must enable this option by saying Y.  Saying N will result
+	  in an ever-so-slightly smaller and ever-so-slightly less
+	  CPU-intensive NFS client.
+
 config SMB_FS
 	tristate "SMB file system support (to mount Windows shares etc.)"
 	depends on INET
diff -X excl -purNa linux-2.6.3-iostat/fs/nfs/inode.c linux-2.6.3/fs/nfs/inode.c
--- linux-2.6.3-iostat/fs/nfs/inode.c	2004-03-05 12:06:22.000000000 +0100
+++ linux-2.6.3/fs/nfs/inode.c	2004-03-08 15:55:48.000000000 +0100
@@ -119,6 +119,22 @@ struct rpc_program		nfsacl_program = {
 };
 #endif  /* CONFIG_NFS_ACL */
 
+/*
+ * Names for iostat buckets
+ */
+static const char	*nfs_iostat_names[nfs_count_max] = {
+	[nfs_count_other]	= "other",
+	[nfs_count_read]	= "read",
+	[nfs_count_write]	= "write",
+	[nfs_count_commit]	= "commit",
+	[nfs_count_getattr]	= "getattr",
+	[nfs_count_lookup]	= "lookup",
+	[nfs_count_readdir]	= "readdir",
+	[nfs_count_symlink]	= "symlink",
+	[nfs_count_readlink]	= "readlink",
+	[nfs_count_remove]	= "remove",
+};
+
 static inline unsigned long
 nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 {
@@ -440,6 +456,12 @@ __nfs_create_client(struct nfs_server *s
 	clnt->cl_droppriv = (server->flags & NFS_MOUNT_BROKEN_SUID) ? 1 : 0;
 	clnt->cl_chatty   = 1;
 
+#ifdef CONFIG_SUNRPC_IOSTATS
+	/* For now, enable iostat unconditionally.
+	 * Not sure if we should have a sysctl to control this */
+	rpc_enable_iostats(clnt, nfs_count_max, nfs_iostat_names);
+#endif
+
 	return clnt;
 
 out_fail:
diff -X excl -purNa linux-2.6.3-iostat/fs/nfs/nfs2xdr.c linux-2.6.3/fs/nfs/nfs2xdr.c
--- linux-2.6.3-iostat/fs/nfs/nfs2xdr.c	2004-02-04 04:43:42.000000000 +0100
+++ linux-2.6.3/fs/nfs/nfs2xdr.c	2004-03-08 16:13:12.000000000 +0100
@@ -651,30 +651,31 @@ nfs_stat_to_errno(int stat)
 # define MAX(a, b)	(((a) > (b))? (a) : (b))
 #endif
 
-#define PROC(proc, argtype, restype, timer)				\
+#define PROC(proc, argtype, restype, timer, op)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
 	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
 	.p_bufsiz   =  MAX(NFS_##argtype##_sz,NFS_##restype##_sz) << 2,	\
-	.p_timer    =  timer						\
+	.p_timer    =  timer,						\
+	.p_metrics  =  nfs_count_##op					\
 	}
 struct rpc_procinfo	nfs_procedures[] = {
-    PROC(GETATTR,	fhandle,	attrstat, 1),
-    PROC(SETATTR,	sattrargs,	attrstat, 0),
-    PROC(LOOKUP,	diropargs,	diropres, 2),
-    PROC(READLINK,	readlinkargs,	readlinkres, 3),
-    PROC(READ,		readargs,	readres, 3),
-    PROC(WRITE,		writeargs,	writeres, 4),
-    PROC(CREATE,	createargs,	diropres, 0),
-    PROC(REMOVE,	diropargs,	stat, 0),
-    PROC(RENAME,	renameargs,	stat, 0),
-    PROC(LINK,		linkargs,	stat, 0),
-    PROC(SYMLINK,	symlinkargs,	stat, 0),
-    PROC(MKDIR,		createargs,	diropres, 0),
-    PROC(RMDIR,		diropargs,	stat, 0),
-    PROC(READDIR,	readdirargs,	readdirres, 3),
-    PROC(STATFS,	fhandle,	statfsres, 0),
+    PROC(GETATTR,	fhandle,	attrstat, 1, getattr),
+    PROC(SETATTR,	sattrargs,	attrstat, 0, other),
+    PROC(LOOKUP,	diropargs,	diropres, 2, lookup),
+    PROC(READLINK,	readlinkargs,	readlinkres, 3, readlink),
+    PROC(READ,		readargs,	readres, 3, read),
+    PROC(WRITE,		writeargs,	writeres, 4, write),
+    PROC(CREATE,	createargs,	diropres, 0, other),
+    PROC(REMOVE,	diropargs,	stat, 0, remove),
+    PROC(RENAME,	renameargs,	stat, 0, other),
+    PROC(LINK,		linkargs,	stat, 0, other),
+    PROC(SYMLINK,	symlinkargs,	stat, 0, symlink),
+    PROC(MKDIR,		createargs,	diropres, 0, other),
+    PROC(RMDIR,		diropargs,	stat, 0, other),
+    PROC(READDIR,	readdirargs,	readdirres, 3, readdir),
+    PROC(STATFS,	fhandle,	statfsres, 0, other),
 };
 
 struct rpc_version		nfs_version2 = {
diff -X excl -purNa linux-2.6.3-iostat/fs/nfs/nfs3xdr.c linux-2.6.3/fs/nfs/nfs3xdr.c
--- linux-2.6.3-iostat/fs/nfs/nfs3xdr.c	2004-03-05 12:06:21.000000000 +0100
+++ linux-2.6.3/fs/nfs/nfs3xdr.c	2004-03-08 12:38:45.000000000 +0100
@@ -1086,37 +1086,38 @@ nfs3_xdr_setaclres(struct rpc_rqst *req,
 # define MAX(a, b)	(((a) > (b))? (a) : (b))
 #endif
 
-#define PROC(proc, argtype, restype, timer)				\
+#define PROC(proc, argtype, restype, timer, op)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
 	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
 	.p_bufsiz    = MAX(NFS3_##argtype##_sz,NFS3_##restype##_sz) << 2,	\
-	.p_timer     = timer						\
+	.p_timer     = timer,						\
+	.p_metrics   = nfs_count_##op					\
 	}
 
 struct rpc_procinfo	nfs3_procedures[] = {
-  PROC(GETATTR,		fhandle,	attrstat, 1),
-  PROC(SETATTR, 	sattrargs,	wccstat, 0),
-  PROC(LOOKUP,		diropargs,	lookupres, 2),
-  PROC(ACCESS,		accessargs,	accessres, 1),
-  PROC(READLINK,	readlinkargs,	readlinkres, 3),
-  PROC(READ,		readargs,	readres, 3),
-  PROC(WRITE,		writeargs,	writeres, 4),
-  PROC(CREATE,		createargs,	createres, 0),
-  PROC(MKDIR,		mkdirargs,	createres, 0),
-  PROC(SYMLINK,		symlinkargs,	createres, 0),
-  PROC(MKNOD,		mknodargs,	createres, 0),
-  PROC(REMOVE,		diropargs,	wccstat, 0),
-  PROC(RMDIR,		diropargs,	wccstat, 0),
-  PROC(RENAME,		renameargs,	renameres, 0),
-  PROC(LINK,		linkargs,	linkres, 0),
-  PROC(READDIR,		readdirargs,	readdirres, 3),
-  PROC(READDIRPLUS,	readdirargs,	readdirres, 3),
-  PROC(FSSTAT,		fhandle,	fsstatres, 0),
-  PROC(FSINFO,  	fhandle,	fsinfores, 0),
-  PROC(PATHCONF,	fhandle,	pathconfres, 0),
-  PROC(COMMIT,		commitargs,	commitres, 5),
+  PROC(GETATTR,		fhandle,	attrstat, 1, getattr),
+  PROC(SETATTR, 	sattrargs,	wccstat, 0, other),
+  PROC(LOOKUP,		diropargs,	lookupres, 2, lookup),
+  PROC(ACCESS,		accessargs,	accessres, 1, getattr),
+  PROC(READLINK,	readlinkargs,	readlinkres, 3, readlink),
+  PROC(READ,		readargs,	readres, 3, read),
+  PROC(WRITE,		writeargs,	writeres, 4, write),
+  PROC(CREATE,		createargs,	createres, 0, other),
+  PROC(MKDIR,		mkdirargs,	createres, 0, other),
+  PROC(SYMLINK,		symlinkargs,	createres, 0, symlink),
+  PROC(MKNOD,		mknodargs,	createres, 0, other),
+  PROC(REMOVE,		diropargs,	wccstat, 0, remove),
+  PROC(RMDIR,		diropargs,	wccstat, 0, other),
+  PROC(RENAME,		renameargs,	renameres, 0, other),
+  PROC(LINK,		linkargs,	linkres, 0, other),
+  PROC(READDIR,		readdirargs,	readdirres, 3, readdir),
+  PROC(READDIRPLUS,	readdirargs,	readdirres, 3, other),
+  PROC(FSSTAT,		fhandle,	fsstatres, 0, other),
+  PROC(FSINFO,  	fhandle,	fsinfores, 0, other),
+  PROC(PATHCONF,	fhandle,	pathconfres, 0, other),
+  PROC(COMMIT,		commitargs,	commitres, 5, commit),
 };
 
 struct rpc_version		nfs_version3 = {
diff -X excl -purNa linux-2.6.3-iostat/include/linux/nfs_fs_sb.h linux-2.6.3/include/linux/nfs_fs_sb.h
--- linux-2.6.3-iostat/include/linux/nfs_fs_sb.h	2004-03-05 12:06:21.000000000 +0100
+++ linux-2.6.3/include/linux/nfs_fs_sb.h	2004-03-08 15:55:19.000000000 +0100
@@ -44,6 +44,22 @@ struct nfs_server {
 #endif
 };
 
+/* iostat counters */
+enum {
+	nfs_count_other = 0,
+	nfs_count_read,
+	nfs_count_write,
+	nfs_count_commit,
+	nfs_count_getattr,
+	nfs_count_lookup,
+	nfs_count_readdir,
+	nfs_count_symlink,
+	nfs_count_readlink,
+	nfs_count_remove,
+
+	nfs_count_max,
+};
+
 /* Server capabilities */
 #define NFS_CAP_READDIRPLUS	(1)
 
diff -X excl -purNa linux-2.6.3-iostat/include/linux/sunrpc/clnt.h linux-2.6.3/include/linux/sunrpc/clnt.h
--- linux-2.6.3-iostat/include/linux/sunrpc/clnt.h	2004-02-19 11:36:36.000000000 +0100
+++ linux-2.6.3/include/linux/sunrpc/clnt.h	2004-03-08 13:09:12.000000000 +0100
@@ -66,6 +66,11 @@ struct rpc_clnt {
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_portmap	cl_pmap_default;
 	char			cl_inline_name[32];
+
+	/* NFS iostat support */
+#ifdef CONFIG_SUNRPC_IOSTATS
+	struct rpc_iostat *	cl_iostat;
+#endif
 };
 #define cl_timeout		cl_xprt->timeout
 #define cl_prog			cl_pmap->pm_prog
@@ -102,6 +107,7 @@ struct rpc_procinfo {
 	unsigned int		p_bufsiz;	/* req. buffer size */
 	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
+	unsigned int		p_metrics;	/* iostat */
 };
 
 #define RPC_CONGESTED(clnt)	(RPCXPRT_CONGESTED((clnt)->cl_xprt))
@@ -130,6 +136,8 @@ void		rpc_clnt_sigmask(struct rpc_clnt *
 void		rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 
+void		rpc_init_iostat(struct rpc_clnt *clnt, unsigned int num_ops);
+
 static __inline__
 int rpc_call(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp, int flags)
 {
diff -X excl -purNa linux-2.6.3-iostat/include/linux/sunrpc/metrics.h linux-2.6.3/include/linux/sunrpc/metrics.h
--- linux-2.6.3-iostat/include/linux/sunrpc/metrics.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.3/include/linux/sunrpc/metrics.h	2004-03-08 17:34:24.000000000 +0100
@@ -0,0 +1,83 @@
+/*
+ *  linux/include/linux/sunrpc/metrics.h
+ *
+ *  Declarations for the RPC client per-operation metrics
+ *
+ *  Copyright (C) 2004	Chuck Lever <cel@netapp.com>
+ */
+
+#ifndef _LINUX_SUNRPC_METRICS_H
+#define _LINUX_SUNRPC_METRICS_H
+
+#include <linux/time.h>
+
+/*
+ * Metrics reported for each RPC request
+ */
+struct rpc_metrics {
+	unsigned long		rm_rtt,		/* RPC RTT, in usecs */
+				rm_execute;	/* execute time, in usecs */
+	unsigned int		rm_slots,	/* slot table utilization */
+				rm_sndq,	/* send queue utilization */
+				rm_backlog,	/* backlog utilization */
+				rm_retrans;	/* retries for this RPC */
+};
+
+struct rpc_op_iostat {
+	unsigned long		ns_ops,		/* count of operations */
+				ns_slot_u,	/* slot table utilization */
+				ns_sndq_u,	/* send queue utilization */
+				ns_bklog_u,	/* backlog utilization */
+				ns_retrans,	/* count of RPC retries */
+				ns_errors;	/* count of EIO errors */
+	unsigned long long	ns_bytes_in,	/* count of bytes in */
+				ns_bytes_out,	/* count of bytes out */
+				ns_rtt,		/* usecs for RPC RTT */
+				ns_rtt_s,	/* sum(rtt**2) */
+				ns_execute,	/* usecs for RPC execution */
+				ns_execute_s;	/* sum(execute**2) */
+};
+
+struct rpc_iostat {
+	struct timeval		io_begin;
+	unsigned int		io_num_ops;
+	const char **		io_names;
+	struct rpc_op_iostat *	io_data;
+
+	struct proc_dir_entry *	io_file;
+};
+
+#define RPC_USECS_PER_SEC	(1000000ULL)
+#define RPC_USECS_PER_HOUR	(3600ULL * RPC_USECS_PER_SEC)
+
+/*
+ * This computes the elapsed time from then til now,
+ * in microseconds.  We cap this at one hour.
+ */
+static inline unsigned long
+rpc_calc_latency(const struct timeval *then)
+{
+	struct timeval now;
+	long secs, usecs;
+	unsigned long long result;
+
+	do_gettimeofday(&now);
+
+	secs = now.tv_sec - then->tv_sec;
+	usecs = now.tv_usec - then->tv_usec;
+	result = ((secs * RPC_USECS_PER_SEC) + usecs);
+	if (result > RPC_USECS_PER_HOUR)
+		result = 0ULL;
+
+	return (unsigned long) result;
+}
+
+struct rpc_clnt;
+struct rpc_task;
+
+extern int	rpc_enable_iostats(struct rpc_clnt *, unsigned int, const char **);
+extern void	rpc_disable_iostats(struct rpc_clnt *);
+extern void	rpc_update_iostat(struct rpc_iostat *stats, struct rpc_task *task);
+extern void	rpc_clear_iostats(struct rpc_clnt *);
+
+#endif /* _LINUX_SUNRPC_METRICS_H */
diff -X excl -purNa linux-2.6.3-iostat/include/linux/sunrpc/sched.h linux-2.6.3/include/linux/sunrpc/sched.h
--- linux-2.6.3-iostat/include/linux/sunrpc/sched.h	2004-02-19 11:36:36.000000000 +0100
+++ linux-2.6.3/include/linux/sunrpc/sched.h	2004-03-08 13:57:39.000000000 +0100
@@ -13,6 +13,7 @@
 #include <linux/sunrpc/types.h>
 #include <linux/wait.h>
 #include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/metrics.h>
 
 /*
  * This is the actual RPC procedure call info.
@@ -73,6 +74,13 @@ struct rpc_task {
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned char		tk_active   : 1;/* Task has been activated */
 	unsigned long		tk_runstate;	/* Task run status */
+
+	/* IO stats support */
+#ifdef CONFIG_SUNRPC_IOSTATS
+	struct timeval		tk_inittime;
+	struct rpc_metrics	tk_metrics;
+#endif
+
 #ifdef RPC_DEBUG
 	unsigned short		tk_pid;		/* debugging aid */
 #endif
diff -X excl -purNa linux-2.6.3-iostat/include/linux/sunrpc/stats.h linux-2.6.3/include/linux/sunrpc/stats.h
--- linux-2.6.3-iostat/include/linux/sunrpc/stats.h	2004-03-05 12:06:01.000000000 +0100
+++ linux-2.6.3/include/linux/sunrpc/stats.h	2004-03-08 13:47:54.000000000 +0100
@@ -57,6 +57,7 @@ void			svc_seq_show(struct seq_file *,
 				     const struct svc_stat *);
 
 extern struct proc_dir_entry	*proc_net_rpc;
+extern struct proc_dir_entry	*proc_net_rpc_iostat;
 
 #else
 
diff -X excl -purNa linux-2.6.3-iostat/include/linux/sunrpc/xprt.h linux-2.6.3/include/linux/sunrpc/xprt.h
--- linux-2.6.3-iostat/include/linux/sunrpc/xprt.h	2004-03-05 12:06:22.000000000 +0100
+++ linux-2.6.3/include/linux/sunrpc/xprt.h	2004-03-08 14:08:50.000000000 +0100
@@ -117,6 +117,7 @@ struct rpc_rqst {
 	u32			rq_bytes_sent;	/* Bytes we have sent */
 
 	unsigned long		rq_xtime;	/* when transmitted */
+	struct timeval		rq_xmittime;
 	int			rq_ntimeo;
 	int			rq_ntrans;
 };
@@ -150,6 +151,7 @@ struct rpc_xprt {
 	struct rpc_wait_queue	backlog;	/* waiting for slot */
 	struct rpc_rqst *	free;		/* free slots */
 	unsigned int		max_reqs;	/* total slots */
+	unsigned int		slots_inuse;
 	unsigned long		sockstate;	/* Socket state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				nocong	   : 1,	/* no congestion control */
@@ -178,6 +180,15 @@ struct rpc_xprt {
 	spinlock_t		sock_lock;	/* lock socket info */
 	spinlock_t		xprt_lock;	/* lock xprt info */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
+	unsigned int		sndq_len;	/* length of send queue */
+
+	struct timeval		connectstart;
+	unsigned long long	connectwait;	/* total connect wait time */
+	unsigned long		connects;	/* total count of connects */
+	struct timeval		idlestart;
+	unsigned long		idle_secs;	/* total idle time */
+	unsigned long		major_timeouts;	/* total major timeouts */
+	unsigned int		backlog_len;	/* length of backlog queue */
 
 	struct list_head	recv;
 
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/Makefile linux-2.6.3/net/sunrpc/Makefile
--- linux-2.6.3-iostat/net/sunrpc/Makefile	2004-03-05 12:06:13.000000000 +0100
+++ linux-2.6.3/net/sunrpc/Makefile	2004-03-08 14:13:03.000000000 +0100
@@ -13,3 +13,4 @@ sunrpc-y := clnt.o xprt.o sched.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+sunrpc-$(CONFIG_SUNRPC_IOSTATS) += iostats.o
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/clnt.c linux-2.6.3/net/sunrpc/clnt.c
--- linux-2.6.3-iostat/net/sunrpc/clnt.c	2004-03-05 12:06:23.000000000 +0100
+++ linux-2.6.3/net/sunrpc/clnt.c	2004-03-08 16:36:06.000000000 +0100
@@ -198,6 +198,7 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	atomic_inc(&new->cl_parent->cl_count);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
+	new->cl_iostat = NULL;
 out:
 	return new;
 out_no_clnt:
@@ -250,6 +251,7 @@ rpc_destroy_client(struct rpc_clnt *clnt
 
 	dprintk("RPC: destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
+	rpc_disable_iostats(clnt);
 	if (clnt->cl_auth) {
 		rpcauth_destroy(clnt->cl_auth);
 		clnt->cl_auth = NULL;
@@ -362,7 +364,7 @@ int rpc_call_sync(struct rpc_clnt *clnt,
 		rpc_release_task(task);
 	}
 
-	rpc_clnt_sigunmask(clnt, &oldset);		
+	rpc_clnt_sigunmask(clnt, &oldset);
 
 	return status;
 }
@@ -795,6 +797,7 @@ call_timeout(struct rpc_task *task)
 	to->to_retries = clnt->cl_timeout.to_retries;
 
 	dprintk("RPC: %4d call_timeout (major)\n", task->tk_pid);
+	clnt->cl_xprt->major_timeouts++;
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty)
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/iostats.c linux-2.6.3/net/sunrpc/iostats.c
--- linux-2.6.3-iostat/net/sunrpc/iostats.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.3/net/sunrpc/iostats.c	2004-03-08 17:34:06.000000000 +0100
@@ -0,0 +1,322 @@
+/*
+ *  linux/net/sunrpc/iostats.c
+ *
+ *  Copyright (C) 2004  Chuck Lever <cel@netapp.com>
+ *  Copyright (C) 2004  Olaf Kirch <okir@suse.de>
+ *
+ *  NFS client performance instrumentation.
+ *
+ *  Report per-mount statistics on bytes read and written, and count
+ *  and latency of NFS read and write operations.
+ *
+ *  Scaling issues:
+ *  This solution does not scale with the number of NFS mounts.  The
+ *  stat file naming scheme depends on the sb's minor device number,
+ *  which is only 8 bits.
+ *
+ *  For 2.6, we should address this limit.
+ *
+ *  This prototype also has no way to prevent a race with umount that
+ *  can leave a stat file with no associated superblock.  If a user
+ *  program keeps a stat file open when the associate mount point is
+ *  umounted, the superblock will go away, but the stat file will
+ *  remain.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+
+#include <linux/stddef.h>
+#include <linux/unistd.h>
+#include <linux/threads.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
+#include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/metrics.h>
+
+void
+rpc_update_iostat(struct rpc_iostat *stats, struct rpc_task *task)
+{
+	struct rpc_metrics *m = &task->tk_metrics;
+	struct rpc_op_iostat *s;
+	unsigned long long tmp;
+	unsigned int op;
+
+	op = task->tk_msg.rpc_proc->p_metrics;
+	if (!stats || !m || op >= stats->io_num_ops)
+		return;
+
+	s = stats->io_data + op * NR_CPUS + smp_processor_id();
+
+	s->ns_ops++;
+	s->ns_slot_u += m->rm_slots;
+	s->ns_sndq_u += m->rm_sndq;
+	s->ns_bklog_u += m->rm_backlog;
+	s->ns_retrans += m->rm_retrans;
+
+	if (task->tk_status == -EIO) {
+		s->ns_errors++;
+	} else if (task->tk_status >= 0 && task->tk_rqstp) {
+		struct rpc_rqst	*req = task->tk_rqstp;
+
+		s->ns_bytes_in += (unsigned long long) req->rq_received;
+		s->ns_bytes_out += (unsigned long long) req->rq_slen;
+		printk(KERN_DEBUG "iostat op %s slen %u\n",
+				stats->io_names[op], req->rq_slen);
+	} else {
+		printk(KERN_DEBUG "iostat op %s stat %d rqbuf %p\n",
+			stats->io_names[op], task->tk_status, task->tk_rqstp);
+	}
+
+	tmp = (unsigned long long) m->rm_rtt;
+	s->ns_rtt += tmp;
+	s->ns_rtt_s += tmp * tmp;
+	tmp = (unsigned long long) m->rm_execute;
+	s->ns_execute += tmp;
+	s->ns_execute_s += tmp * tmp;
+}
+
+static int
+rpc_iostat_show(struct seq_file *seq, void *v)
+{
+	const struct rpc_clnt	*clnt = seq->private;
+	const struct rpc_iostat	*stats = clnt->cl_iostat;
+	const struct rpc_xprt	*xprt = clnt->cl_xprt;
+	unsigned int		op;
+
+	seq_printf(seq, "sunrpc/stats format version: 1.0\n");
+	seq_printf(seq, "hostname: %s\n", clnt->cl_server);
+	seq_printf(seq, "%s version: %d\n", clnt->cl_protname, clnt->cl_vers);
+
+	if (stats == NULL) {
+		seq_printf(seq, "\niostats disabled\n");
+		return 0;
+	}
+
+	/*
+	 * Transport stats
+	 */
+	seq_printf(seq, "\nSampling interval: %lu millisec\n",
+				rpc_calc_latency(&stats->io_begin) / 1000);
+	seq_printf(seq, "transport idle time: %lu seconds\n", xprt->idle_secs);
+	seq_printf(seq, "major timeouts: %lu\n", xprt->major_timeouts);
+	if (xprt->stream) {
+		seq_printf(seq, "transport socket type: tcp\n");
+		seq_printf(seq, "connect attempts: %lu\n", xprt->connects);
+		seq_printf(seq, "total connect wait time: %Lu usecs\n", xprt->connectwait);
+	} else {
+		seq_printf(seq, "transport socket type: udp\n");
+	}
+
+	/*
+	 * Op rate and byte rate stats
+	 */
+	seq_printf(seq, "\n# optype   op count");
+	seq_printf(seq, "             bytes in");
+	seq_printf(seq, "            bytes out");
+	seq_printf(seq, "    retrans     errors\n");
+
+	for (op = 0; op < stats->io_num_ops; op++) {
+		struct rpc_op_iostat total, *s;
+		int i;
+
+		memset(&total, 0, sizeof(total));
+
+		s = stats->io_data + op * NR_CPUS;
+		for (i = 0; i < NR_CPUS; i++, s++) {
+			total.ns_ops += s->ns_ops;
+			total.ns_retrans += s->ns_retrans;
+			total.ns_errors += s->ns_errors;
+			total.ns_bytes_in += s->ns_bytes_in;
+			total.ns_bytes_out += s->ns_bytes_out;
+		}
+
+		seq_printf(seq, "%8s %10lu %20Lu %20Lu %10lu %10lu\n",
+				stats->io_names[op], total.ns_ops,
+				total.ns_bytes_in, total.ns_bytes_out,
+			       	total.ns_retrans, total.ns_errors);
+	}
+
+	/*
+	 * latency stats
+	 */
+	seq_printf(seq, "\nticks/sec: %Lu\n", RPC_USECS_PER_SEC);
+	seq_printf(seq, "# optype      rtt total ticks");
+	seq_printf(seq, "         sum rtt ** 2");
+	seq_printf(seq, "  execute total ticks");
+	seq_printf(seq, "     sum execute ** 2\n");
+
+	for (op = 0; op < stats->io_num_ops; op++) {
+		struct rpc_op_iostat total, *s;
+		int i;
+
+		memset(&total, 0, sizeof(total));
+
+		s = stats->io_data + op * NR_CPUS;
+		for (i = 0; i < NR_CPUS; i++, s++) {
+			total.ns_rtt += s->ns_rtt;
+			total.ns_rtt_s += s->ns_rtt_s;
+			total.ns_execute += s->ns_execute;
+			total.ns_execute_s += s->ns_execute_s;
+		}
+
+		seq_printf(seq, "%8s %20Lu %20Lu %20Lu %20Lu\n",
+				stats->io_names[op],
+				total.ns_rtt, total.ns_rtt_s,
+				total.ns_execute, total.ns_execute_s);
+	}
+
+	/*
+	 * queue stats
+	 */
+	seq_printf(seq, "\n# optype  slot util");
+	seq_printf(seq, "    backlog  sndq util\n");
+	for (op = 0; op < stats->io_num_ops; op++) {
+		struct rpc_op_iostat total, *s;
+		int i;
+
+		memset(&total, 0, sizeof(total));
+
+		s = stats->io_data + op * NR_CPUS;
+		for (i = 0; i < NR_CPUS; i++, s++) {
+			total.ns_slot_u += s->ns_slot_u;
+			total.ns_sndq_u += s->ns_sndq_u;
+			total.ns_bklog_u += s->ns_bklog_u;
+		}
+
+		seq_printf(seq, "%8s %10lu %10lu %10lu\n",
+				stats->io_names[op], total.ns_slot_u,
+				total.ns_bklog_u, total.ns_sndq_u);
+	}
+
+	return 0;
+}
+
+/*
+ * any write to a stat file will cause us to clear the counters
+ */
+static ssize_t
+rpc_iostat_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+{
+	struct rpc_clnt	*clnt = PDE(file->f_dentry->d_inode)->data;
+	struct rpc_xprt *xprt = clnt->cl_xprt;
+
+	xprt->idle_secs = 0UL;
+	xprt->major_timeouts = 0UL;
+	xprt->connects = 0UL;
+	xprt->connectwait = 0ULL;
+
+	rpc_clear_iostats(clnt);
+
+	*ppos += count;
+	return count;
+}
+
+
+/*
+ * Open/close iostat file
+ */
+static int
+rpc_iostat_open(struct inode *inode, struct file *file)
+{
+	struct rpc_clnt *clnt = PDE(inode)->data;
+
+	atomic_inc(&clnt->cl_users);
+	return single_open(file, rpc_iostat_show, clnt);
+}
+
+static int
+rpc_iostat_release(struct inode *inode, struct file *file)
+{
+	struct rpc_clnt *clnt = PDE(inode)->data;
+
+	rpc_release_client(clnt);
+	return single_release(inode, file);
+}
+
+static struct file_operations rpc_iostat_fops = {
+	.owner = THIS_MODULE,
+	.open = rpc_iostat_open,
+	.read  = seq_read,
+	.write = rpc_iostat_write,
+	.llseek = seq_lseek,
+	.release = rpc_iostat_release,
+};
+
+/*
+ * Enable iostats for this RPC client
+ */
+int
+rpc_enable_iostats(struct rpc_clnt *clnt, unsigned int num_ops, const char **names)
+{
+	struct rpc_iostat *stats;
+	unsigned int	size;
+	char		name[256];
+	void		*p;
+
+	if (clnt->cl_iostat)
+		return -EPERM;
+
+	size = sizeof(struct rpc_iostat) +
+			num_ops * NR_CPUS * sizeof(struct rpc_op_iostat);
+	p = kmalloc(size, GFP_KERNEL);
+	if (p == 0)
+		return -ENOMEM;
+
+	memset(p, 0, size);
+
+	stats = (struct rpc_iostat *) p;
+	do_gettimeofday(&stats->io_begin);
+	stats->io_num_ops = num_ops;
+	stats->io_names = names;
+	stats->io_data = (struct rpc_op_iostat *) (stats + 1);
+
+	snprintf(name, sizeof(name), "%s-%p", clnt->cl_server, clnt);
+	stats->io_file = create_proc_entry(name, 0, proc_net_rpc_iostat);
+	if (stats->io_file) {
+		stats->io_file->proc_fops = &rpc_iostat_fops;
+		stats->io_file->data = clnt;
+	}
+
+	clnt->cl_iostat = stats;
+	return 0;
+}
+EXPORT_SYMBOL(rpc_enable_iostats);
+
+/*
+ * Disable iostats for this client
+ */
+void
+rpc_disable_iostats(struct rpc_clnt *clnt)
+{
+	struct rpc_iostat *stats = clnt->cl_iostat;
+	char		name[256];
+
+	if (stats) {
+		clnt->cl_iostat = NULL;
+		if (stats->io_file) {
+			snprintf(name, sizeof(name), "%s-%p",
+					clnt->cl_server, clnt);
+			remove_proc_entry(name, proc_net_rpc_iostat);
+			stats->io_file = NULL;
+		}
+		kfree(stats);
+	}
+}
+EXPORT_SYMBOL(rpc_disable_iostats);
+
+void
+rpc_clear_iostats(struct rpc_clnt *clnt)
+{
+	struct rpc_iostat *stats = clnt->cl_iostat;
+
+	if (stats) {
+		memset(stats->io_data, 0,
+				stats->io_num_ops * NR_CPUS * sizeof(struct rpc_op_iostat));
+		do_gettimeofday(&stats->io_begin);
+	}
+}
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/sched.c linux-2.6.3/net/sunrpc/sched.c
--- linux-2.6.3-iostat/net/sunrpc/sched.c	2004-03-05 12:06:23.000000000 +0100
+++ linux-2.6.3/net/sunrpc/sched.c	2004-03-08 17:09:57.000000000 +0100
@@ -540,6 +540,10 @@ __rpc_execute(struct rpc_task *task)
 			rpc_set_sleeping(task);
 			if (RPC_IS_ASYNC(task)) {
 				spin_unlock_bh(&rpc_queue_lock);
+#ifdef CONFIG_SUNRPC_IOSTATS
+				task->tk_metrics.rm_execute =
+					rpc_calc_latency(&task->tk_inittime);
+#endif
 				return 0;
 			}
 		}
@@ -577,11 +581,18 @@ __rpc_execute(struct rpc_task *task)
 		}
 	}
 
+#ifdef CONFIG_SUNRPC_IOSTATS
+	task->tk_metrics.rm_execute = rpc_calc_latency(&task->tk_inittime);
+#endif
 	if (task->tk_exit) {
 		task->tk_exit(task);
 		/* If tk_action is non-null, the user wants us to restart */
 		if (task->tk_action) {
 			if (!RPC_ASSASSINATED(task)) {
+#ifdef CONFIG_SUNRPC_IOSTATS
+				if (task->tk_client && task->tk_client->cl_iostat)
+					rpc_update_iostat(task->tk_client->cl_iostat, task);
+#endif
 				/* Release RPC slot and buffer memory */
 				if (task->tk_rqstp)
 					xprt_release(task);
@@ -592,6 +603,11 @@ __rpc_execute(struct rpc_task *task)
 		}
 	}
 
+#ifdef CONFIG_SUNRPC_IOSTATS
+	if (task->tk_client && task->tk_client->cl_iostat)
+		rpc_update_iostat(task->tk_client->cl_iostat, task);
+#endif
+
 	dprintk("RPC: %4d exit() = %d\n", task->tk_pid, task->tk_status);
 	status = task->tk_status;
 
@@ -625,6 +641,9 @@ rpc_execute(struct rpc_task *task)
 		goto out_err;
 	}
 
+#ifdef CONFIG_SUNRPC_IOSTATS
+	do_gettimeofday(&task->tk_inittime);
+#endif
 	task->tk_active = 1;
 	rpc_set_running(task);
 	return __rpc_execute(task);
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/stats.c linux-2.6.3/net/sunrpc/stats.c
--- linux-2.6.3-iostat/net/sunrpc/stats.c	2004-03-05 12:06:02.000000000 +0100
+++ linux-2.6.3/net/sunrpc/stats.c	2004-03-08 16:03:53.000000000 +0100
@@ -25,6 +25,7 @@
 #define RPCDBG_FACILITY	RPCDBG_MISC
 
 struct proc_dir_entry	*proc_net_rpc = NULL;
+struct proc_dir_entry	*proc_net_rpc_iostat = NULL;
 
 /*
  * Get RPC client stats
@@ -160,6 +161,14 @@ rpc_proc_init(void)
 			ent->owner = THIS_MODULE;
 			proc_net_rpc = ent;
 		}
+
+#ifdef CONFIG_SUNRPC_IOSTATS
+		ent = proc_mkdir("iostat", proc_net_rpc);
+		if (ent) {
+			ent->owner = THIS_MODULE;
+			proc_net_rpc_iostat = ent;
+		}
+#endif
 	}
 }
 
@@ -167,6 +176,12 @@ void
 rpc_proc_exit(void)
 {
 	dprintk("RPC: unregistering /proc/net/rpc\n");
+#ifdef CONFIG_SUNRPC_IOSTATS
+	if (proc_net_rpc_iostat) {
+		proc_net_rpc_iostat = NULL;
+		remove_proc_entry("iostat", proc_net_rpc);
+	}
+#endif
 	if (proc_net_rpc) {
 		proc_net_rpc = NULL;
 		remove_proc_entry("net/rpc", 0);
diff -X excl -purNa linux-2.6.3-iostat/net/sunrpc/xprt.c linux-2.6.3/net/sunrpc/xprt.c
--- linux-2.6.3-iostat/net/sunrpc/xprt.c	2004-03-05 12:06:23.000000000 +0100
+++ linux-2.6.3/net/sunrpc/xprt.c	2004-03-08 16:20:34.000000000 +0100
@@ -160,9 +160,10 @@ out_sleep:
 	dprintk("RPC: %4d failed to lock socket %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req && req->rq_ntrans)
+	if (req && req->rq_ntrans) {
+		xprt->sndq_len++;
 		rpc_sleep_on(&xprt->resend, task, NULL, NULL);
-	else
+	} else
 		rpc_sleep_on(&xprt->sending, task, NULL, NULL);
 	return 0;
 }
@@ -193,7 +194,8 @@ __xprt_lock_write_next(struct rpc_xprt *
 		task = rpc_wake_up_next(&xprt->sending);
 		if (!task)
 			goto out_unlock;
-	}
+	} else
+		xprt->sndq_len--;
 	if (xprt->nocong || __xprt_get_cong(xprt, task)) {
 		struct rpc_rqst *req = task->tk_rqstp;
 		xprt->snd_task = task;
@@ -505,13 +507,18 @@ xprt_connect(struct rpc_task *task)
 	/*
 	 * Tell the socket layer to start connecting...
 	 */
+	xprt->connects++;
+	do_gettimeofday(&xprt->connectstart);
 	status = sock->ops->connect(sock, (struct sockaddr *) &xprt->addr,
 				sizeof(xprt->addr), O_NONBLOCK);
 	dprintk("RPC: %4d  connect status %d connected %d sock state %d\n",
 		task->tk_pid, -status, xprt_connected(xprt), inet->sk_state);
 
-	if (status >= 0)
+	if (status >= 0) {
+		xprt->connectwait +=
+			(unsigned long long) rpc_calc_latency(&xprt->connectstart);
 		return;
+	}
 
 	switch (status) {
 	case -EINPROGRESS:
@@ -528,6 +535,9 @@ xprt_connect(struct rpc_task *task)
 				task->tk_timeout = RPC_REESTABLISH_TIMEOUT;
 			rpc_sleep_on(&xprt->pending, task, xprt_connect_status,
 									NULL);
+		} else {
+			xprt->connectwait +=
+				(unsigned long long) rpc_calc_latency(&xprt->connectstart);
 		}
 		release_sock(inet);
 		break;
@@ -570,6 +580,8 @@ xprt_connect_status(struct rpc_task *tas
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
 	if (task->tk_status >= 0) {
+		xprt->connectwait +=
+			(unsigned long long) rpc_calc_latency(&xprt->connectstart);
 		dprintk("RPC: %4d xprt_connect_status: connection established\n",
 				task->tk_pid);
 		return;
@@ -622,6 +634,15 @@ xprt_complete_rqst(struct rpc_xprt *xprt
 {
 	struct rpc_task	*task = req->rq_task;
 	struct rpc_clnt *clnt = task->tk_client;
+#ifdef CONFIG_SUNRPC_IOSTATS
+	struct rpc_metrics *metrics = &task->tk_metrics;
+
+	metrics->rm_rtt = rpc_calc_latency(&req->rq_xmittime);
+	metrics->rm_retrans = req->rq_ntrans - 1;
+	metrics->rm_slots = xprt->slots_inuse;
+	metrics->rm_sndq = xprt->sndq_len;
+	metrics->rm_backlog = xprt->backlog_len;
+#endif
 
 	/* Adjust congestion window */
 	if (!xprt->nocong) {
@@ -1198,6 +1219,9 @@ xprt_transmit(struct rpc_task *task)
 	 * called xprt_sendmsg().
 	 */
 	while (1) {
+#ifdef CONFIG_SUNRPC_IOSTATS
+		do_gettimeofday(&req->rq_xmittime);
+#endif
 		req->rq_xtime = jiffies;
 		status = xprt_sendmsg(xprt, req);
 
@@ -1319,11 +1343,17 @@ do_xprt_reserve(struct rpc_task *task)
 		req->rq_next = NULL;
 		task->tk_rqstp = req;
 		xprt_request_init(task, xprt);
+		if (++xprt->slots_inuse == 1) {
+			struct timeval now;
+			do_gettimeofday(&now);
+			xprt->idle_secs += now.tv_sec - xprt->idlestart.tv_sec;
+		}
 		return;
 	}
 	dprintk("RPC:      waiting for request slot\n");
 	task->tk_status = -EAGAIN;
 	task->tk_timeout = 0;
+	xprt->backlog_len++;
 	rpc_sleep_on(&xprt->backlog, task, NULL, NULL);
 }
 
@@ -1393,6 +1423,8 @@ xprt_release(struct rpc_task *task)
 	spin_lock(&xprt->xprt_lock);
 	req->rq_next = xprt->free;
 	xprt->free   = req;
+	if (--xprt->slots_inuse == 0);
+		do_gettimeofday(&xprt->idlestart);
 
 	xprt_clear_backlog(xprt);
 	spin_unlock(&xprt->xprt_lock);
@@ -1482,6 +1514,13 @@ xprt_setup(int proto, struct sockaddr_in
 	INIT_RPC_WAITQ(&xprt->resend, "xprt_resend");
 	INIT_RPC_WAITQ(&xprt->backlog, "xprt_backlog");
 
+#ifdef CONFIG_SUNRPC_IOSTATS
+	xprt->sndq_len = 0;
+	xprt->backlog_len = 0;
+	xprt->slots_inuse = 0;
+	do_gettimeofday(&xprt->idlestart);
+#endif
+
 	/* initialize free list */
 	entries--;
 	req = xprt->free;
@@ -1658,8 +1697,10 @@ xprt_shutdown(struct rpc_xprt *xprt)
  * Clear the xprt backlog queue
  */
 int
-xprt_clear_backlog(struct rpc_xprt *xprt) {
-	rpc_wake_up_next(&xprt->backlog);
+xprt_clear_backlog(struct rpc_xprt *xprt)
+{
+	if (rpc_wake_up_next(&xprt->backlog))
+		xprt->backlog_len--;
 	if (waitqueue_active(&xprt->cong_wait))
 		wake_up(&xprt->cong_wait);
 	return 1;

--eAbsdosE1cNLO4uF--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
