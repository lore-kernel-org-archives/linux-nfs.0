From: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
Subject: [PATCH] Extract of the read/write processing time of nfs
Date: Fri, 26 Nov 2004 10:21:57 +0900
Message-ID: <20041126102157.313c31a9.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXUpO-0001Fc-Vn
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 17:23:14 -0800
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CXUpM-0004tD-Iz
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 17:23:13 -0800
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id iAQ1N4OP029959 for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 10:23:04 +0900
	(envelope-from s-sagawa@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id iAQ1N4lr023266 for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 10:23:04 +0900
	(envelope-from s-sagawa@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA8E81F724B
	for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 10:23:03 +0900 (JST)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 062AE1F724C
	for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 10:23:03 +0900 (JST)
Received: from bahamut (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122])
 by fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with SMTP id <0I7R00IDSIIEY5@fjmail505.fjmail.jp.fujitsu.com> for
 nfs@lists.sourceforge.net; Fri, 26 Nov 2004 10:23:02 +0900 (JST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi, 

This patch extracts the read/write performance information on the
exported directories.

These performance information is very useful.
For example:

- Each client could choose a NFS server based on these performance
  information. We can expect that each client's performance improvement
  will bring system-wide optimization. It is a necessary nature for
  building a large-scale system which consists of many CPU clusters
  and network storages.

- We can analyze the tendency of stored data.
  and improve the system performance.

- We can improve the efficiency in file access.
  and It is distinguishable whether it accesses by the built-in disk 
  or it accesses by NFS.

These information should be collected by the client.
The NFS's performance will be influenced by the server and the network.


1. Design
   I want to output the following information from /proc file system.

   1) nfs server and export directory.
   2) Output the processing time of NFS read access.
   3) Output the processing time of NFS write access.

2. Usage
   1) System parameter
      Extraction of performance information can be performed 
      by confirming the following system parameter.

      [on]
      sysctl -w sunrpc.nfs_perf=1

      [off](default)
      sysctl -w sunrpc.nfs_perf=0

   2) Performance information
      Performance information /proc/net/rpc/nfs_perf file is referred to.

      nfsserver:exportdir:  0   0
         (1)       (2)     (3) (4)

         (1) nfs server name.
         (2) export directory name.
         (3) processing time of nfs read access.
         (4) processing time of nfs write access.

Signed-off-by: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
--- patch start ---
diff -Nur linux-2.6.9.org/fs/nfs/file.c linux-2.6.9.new/fs/nfs/file.c
--- linux-2.6.9.org/fs/nfs/file.c	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/fs/nfs/file.c	2004-11-17 16:27:55.275274584 +0900
@@ -30,6 +30,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
+#include <linux/mount.h>
 
 #include "delegation.h"
 
@@ -142,6 +143,13 @@
 	struct dentry * dentry = iocb->ki_filp->f_dentry;
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct timeval tvf;
+	struct timeval tvb;
+
+	if (nfs_perf) {
+		do_gettimeofday(&tvf);
+	}
 
 #ifdef CONFIG_NFS_DIRECTIO
 	if (iocb->ki_filp->f_flags & O_DIRECT)
@@ -155,6 +163,13 @@
 	result = nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (!result)
 		result = generic_file_aio_read(iocb, buf, count, pos);
+
+	if (nfs_perf && server) {
+		do_gettimeofday(&tvb);
+		server->perfdata->iotime[NFSPROC_READ] += 
+			((tvb.tv_sec - tvf.tv_sec) * 1000000) +
+			(tvb.tv_usec - tvf.tv_usec);
+	}
 	return result;
 }
 
@@ -263,6 +278,14 @@
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
 
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct timeval tvf;
+	struct timeval tvb;
+
+	if (nfs_perf) {
+		do_gettimeofday(&tvf);
+	}
+
 #ifdef CONFIG_NFS_DIRECTIO
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, buf, count, pos);
@@ -284,6 +307,12 @@
 		goto out;
 
 	result = generic_file_aio_write(iocb, buf, count, pos);
+	if (nfs_perf && server) {
+		do_gettimeofday(&tvb);
+		server->perfdata->iotime[NFSPROC_WRITE] += 
+			((tvb.tv_sec - tvf.tv_sec) * 1000000) +
+			(tvb.tv_usec - tvf.tv_usec);
+	}
 out:
 	return result;
 
diff -Nur linux-2.6.9.org/fs/nfs/inode.c linux-2.6.9.new/fs/nfs/inode.c
--- linux-2.6.9.org/fs/nfs/inode.c	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/fs/nfs/inode.c	2004-11-17 16:27:55.278274128 +0900
@@ -64,6 +64,9 @@
 static int  nfs_statfs(struct super_block *, struct kstatfs *);
 static int  nfs_show_options(struct seq_file *, struct vfsmount *);
 
+static int nfs_perfdelete(struct super_block *);
+static int nfs_perfcreate(char *, struct nfs_server *);
+
 static struct super_operations nfs_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
@@ -79,8 +82,10 @@
  * RPC cruft for NFS
  */
 struct rpc_stat			nfs_rpcstat = {
-	.program		= &nfs_program
+	.program		= &nfs_program,
+	.nfsfilename		= "nfs_perf",
 };
+
 static struct rpc_version *	nfs_version[] = {
 	NULL,
 	NULL,
@@ -1360,6 +1365,84 @@
 	return !nfs_compare_fh(&old->fh, &server->fh);
 }
 
+/*
+ *  Allocate NFS performace data(read/write) structure.
+ */
+static int nfs_perfcreate(char * exportpath, struct nfs_server * server)
+{
+	struct nfs_performance * allocp;
+	struct nfs_performance * lastp;
+	char * path;
+	int ret;
+
+	if(!nfs_perf) {
+		return 0;
+	}
+	if((ret = strlen(exportpath)) == 0) {
+		dfprintk(VFS, "nfs_perfcreate error\n");
+		return -1;
+	}
+	allocp = kmalloc(sizeof(struct nfs_performance), GFP_KERNEL);
+	if (!server)
+		return ENOMEM;
+	memset(allocp, 0, sizeof(struct nfs_performance));
+	path = (char *)kmalloc(strlen(exportpath), GFP_KERNEL);
+	if (!path)
+		return ENOMEM;
+	strncpy(path, exportpath, strlen(exportpath));
+
+	allocp->export_path = path;
+	allocp->iotime[0] = 0;
+	allocp->next = NULL;
+
+	lastp = &nfs_perfhead;
+	while (lastp->next) {
+		lastp = lastp->next;
+	}
+	lastp->next = allocp;
+	server->perfdata = allocp;
+
+	return 0;
+}
+
+/*
+ *  Delete NFS performace data(read/write) structure.
+ */
+static int nfs_perfdelete(struct super_block *sb)
+{
+	struct nfs_server      * server = NFS_SB(sb);
+	struct nfs_performance * search = &nfs_perfhead;
+	struct nfs_performance * before = search;
+	struct nfs_performance * target = 0;
+	int ret = -1;
+
+	target = server->perfdata;
+	if (!target) {
+		dfprintk(VFS, "nfs_kill_super not data.\n");
+		return -1;
+	}
+	while (search) {
+		if (target == search) { 
+			ret = strncmp(target->export_path, 
+				search->export_path, 
+				strlen(target->export_path));
+			if(!ret) {
+				before->next = search->next;
+				kfree(server->perfdata->export_path);
+				kfree(server->perfdata);
+				break;
+			}
+		}
+		before = search;
+		search = search->next;
+	}
+	if(ret) {
+		dfprintk(VFS, "nfs_kill_super found data. but dificult name\n");
+		return -1;
+	}
+	return 0;
+}
+
 static struct super_block *nfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
@@ -1440,6 +1523,9 @@
 		return ERR_PTR(error);
 	}
 	s->s_flags |= MS_ACTIVE;
+	if (nfs_perf) {
+		nfs_perfcreate((char *)dev_name, server);
+	}
 	return s;
 }
 
@@ -1447,6 +1533,9 @@
 {
 	struct nfs_server *server = NFS_SB(s);
 
+	if (nfs_perf) {
+		nfs_perfdelete(s);
+	}
 	kill_anon_super(s);
 
 	nfs4_renewd_prepare_shutdown(server);
diff -Nur linux-2.6.9.org/include/linux/nfs_fs_sb.h linux-2.6.9.new/include/linux/nfs_fs_sb.h
--- linux-2.6.9.org/include/linux/nfs_fs_sb.h	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/include/linux/nfs_fs_sb.h	2004-11-17 16:27:55.255277624 +0900
@@ -29,6 +29,7 @@
 	char *			hostname;	/* remote hostname */
 	struct nfs_fh		fh;
 	struct sockaddr_in	addr;
+	struct nfs_performance * perfdata;
 #ifdef CONFIG_NFS_V4
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the clientid, and the callback address.
diff -Nur linux-2.6.9.org/include/linux/nfs_xdr.h linux-2.6.9.new/include/linux/nfs_xdr.h
--- linux-2.6.9.org/include/linux/nfs_xdr.h	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/include/linux/nfs_xdr.h	2004-11-17 16:27:55.250278384 +0900
@@ -733,5 +733,7 @@
 extern struct rpc_version	nfs_version4;
 extern struct rpc_program	nfs_program;
 extern struct rpc_stat		nfs_rpcstat;
+extern struct rpc_program	nfsperf_program;
+extern struct rpc_stat		nfsperf_rpcstat;
 
 #endif
diff -Nur linux-2.6.9.org/include/linux/sunrpc/debug.h linux-2.6.9.new/include/linux/sunrpc/debug.h
--- linux-2.6.9.org/include/linux/sunrpc/debug.h	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/include/linux/sunrpc/debug.h	2004-11-17 16:27:55.242279600 +0900
@@ -13,6 +13,7 @@
 
 #include <linux/timer.h>
 #include <linux/workqueue.h>
+#include <linux/nfs3.h>
 
 /*
  * Enable RPC debugging/profiling.
@@ -48,6 +49,8 @@
 extern unsigned int		nfs_debug;
 extern unsigned int		nfsd_debug;
 extern unsigned int		nlm_debug;
+extern unsigned int		nfs_perf;
+extern struct nfs_performance nfs_perfhead;
 #endif
 
 #define dprintk(args...)	dfprintk(FACILITY, ## args)
@@ -96,4 +99,10 @@
 	CTL_SLOTTABLE_TCP,
 };
 
+struct nfs_performance {
+	char *  export_path;
+	long   iotime[NFS3_POST_OP_ATTR_WORDS];
+	struct nfs_performance *        next;
+};
+
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff -Nur linux-2.6.9.org/include/linux/sunrpc/stats.h linux-2.6.9.new/include/linux/sunrpc/stats.h
--- linux-2.6.9.org/include/linux/sunrpc/stats.h	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/include/linux/sunrpc/stats.h	2004-11-17 16:27:55.245279144 +0900
@@ -24,6 +24,7 @@
 				rpcretrans,
 				rpcauthrefresh,
 				rpcgarbage;
+	char *			nfsfilename;
 };
 
 struct svc_stat {
diff -Nur linux-2.6.9.org/net/sunrpc/stats.c linux-2.6.9.new/net/sunrpc/stats.c
--- linux-2.6.9.org/net/sunrpc/stats.c	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/net/sunrpc/stats.c	2004-11-17 16:27:55.261276712 +0900
@@ -21,6 +21,7 @@
 #include <linux/seq_file.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/nfs2.h>
 
 #define RPCDBG_FACILITY	RPCDBG_MISC
 
@@ -60,11 +61,32 @@
 	return 0;
 }
 
+// /proc/net/rpc/nfs_perf create function.
+int rpcperf_proc_show(struct seq_file *seq, void *v) 
+{
+        struct nfs_performance *nfsperfp = nfs_perfhead.next;
+
+        for(; nfsperfp != NULL;) {
+		seq_printf(seq, "%s: ", nfsperfp->export_path);
+		seq_printf(seq, "%ld %ld\n", 
+			nfsperfp->iotime[NFSPROC_READ], 
+			nfsperfp->iotime[NFSPROC_WRITE]);
+		nfsperfp = nfsperfp->next;
+	}
+        return 0;
+}
+
 static int rpc_proc_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, rpc_proc_show, PDE(inode)->data);
 }
 
+int rpcperf_proc_open(struct inode *inode, struct file *file)
+{
+        return single_open(file, rpcperf_proc_show, PDE(inode)->data);
+}
+// sagawea end
+
 static struct file_operations rpc_proc_fops = {
 	.owner = THIS_MODULE,
 	.open = rpc_proc_open,
@@ -73,6 +95,14 @@
 	.release = single_release,
 };
 
+struct file_operations rpcperf_proc_fops = {
+        .owner = THIS_MODULE,
+        .open = rpcperf_proc_open,
+        .read  = seq_read,
+        .llseek = seq_lseek,
+        .release = single_release,
+};
+
 /*
  * Get RPC server stats
  */
@@ -128,6 +158,7 @@
 struct proc_dir_entry *
 rpc_proc_register(struct rpc_stat *statp)
 {
+        do_register(statp->nfsfilename, statp, &rpcperf_proc_fops);
 	return do_register(statp->program->name, statp, &rpc_proc_fops);
 }
 
diff -Nur linux-2.6.9.org/net/sunrpc/sunrpc_syms.c linux-2.6.9.new/net/sunrpc/sunrpc_syms.c
--- linux-2.6.9.org/net/sunrpc/sunrpc_syms.c	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/net/sunrpc/sunrpc_syms.c	2004-11-17 16:27:55.258277168 +0900
@@ -140,6 +140,8 @@
 EXPORT_SYMBOL(nfs_debug);
 EXPORT_SYMBOL(nfsd_debug);
 EXPORT_SYMBOL(nlm_debug);
+EXPORT_SYMBOL(nfs_perf);
+EXPORT_SYMBOL(nfs_perfhead);
 #endif
 
 extern int register_rpc_pipefs(void);
diff -Nur linux-2.6.9.org/net/sunrpc/sysctl.c linux-2.6.9.new/net/sunrpc/sysctl.c
--- linux-2.6.9.org/net/sunrpc/sysctl.c	2004-11-05 13:13:58.000000000 +0900
+++ linux-2.6.9.new/net/sunrpc/sysctl.c	2004-11-17 16:27:55.263276408 +0900
@@ -28,6 +28,8 @@
 unsigned int	nfs_debug;
 unsigned int	nfsd_debug;
 unsigned int	nlm_debug;
+unsigned int	nfs_perf;
+struct nfs_performance nfs_perfhead;
 
 #ifdef RPC_DEBUG
 
@@ -140,6 +142,14 @@
 		.proc_handler	= &proc_dodebug
 	}, 
 	{
+		.ctl_name	= CTL_NFSDEBUG,
+		.procname	= "nfs_perf",
+		.data		= &nfs_perf,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dodebug
+	}, 
+	{
 		.ctl_name	= CTL_NFSDDEBUG,
 		.procname	= "nfsd_debug",
 		.data		= &nfsd_debug,

--- patch end ---
Best Regards,
Shunichi Sagawa
------------------------------------------
Shunichi Sagawa
s-sagawa@jp.fujitsu.com


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
