From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 5 - convert NFS /proc interfaces to seq_file
Date: Fri, 06 Feb 2004 16:13:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AoyIp-0007Fk-00@notabene>
References: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ5-0008Ix-2Q
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:35 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ4-0004hJ-26
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:24 +1100
To: Andrew Morton <akpm@osdl.org>
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


>From shemminger@osdl.org Sat Sep  6 09:19:50 2003
Date: Fri, 5 Sep 2003 16:19:30 -0700

Converts /proc/net/rpc/nfs and /proc/net/rpc/nfsd to use the simpler seq_file interface.

 ----------- Diffstat output ------------
 ./fs/nfsd/stats.c              |   67 +++++++++----------------
 ./include/linux/sunrpc/stats.h |   19 +++----
 ./net/sunrpc/stats.c           |  106 ++++++++++++++++++-----------------------
 ./net/sunrpc/sunrpc_syms.c     |    3 -
 4 files changed, 84 insertions(+), 111 deletions(-)

diff ./fs/nfsd/stats.c~current~ ./fs/nfsd/stats.c
--- ./fs/nfsd/stats.c~current~	2004-02-06 14:14:37.000000000 +1100
+++ ./fs/nfsd/stats.c	2004-02-06 14:14:37.000000000 +1100
@@ -26,6 +26,7 @@
 #include <linux/kernel.h>
 #include <linux/time.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/stat.h>
 #include <linux/module.h>
 
@@ -39,14 +40,11 @@ struct svc_stat		nfsd_svcstats = {
 	.program	= &nfsd_program,
 };
 
-static int
-nfsd_proc_read(char *buffer, char **start, off_t offset, int count,
-				int *eof, void *data)
+static int nfsd_proc_show(struct seq_file *seq, void *v)
 {
-	int	len;
-	int	i;
+	int i;
 
-	len = sprintf(buffer, "rc %u %u %u\nfh %u %u %u %u %u\nio %u %u\n",
+	seq_printf(seq, "rc %u %u %u\nfh %u %u %u %u %u\nio %u %u\n",
 		      nfsdstats.rchits,
 		      nfsdstats.rcmisses,
 		      nfsdstats.rcnocache,
@@ -58,57 +56,42 @@ nfsd_proc_read(char *buffer, char **star
 		      nfsdstats.io_read,
 		      nfsdstats.io_write);
 	/* thread usage: */
-	len += sprintf(buffer+len, "th %u %u", nfsdstats.th_cnt, nfsdstats.th_fullcnt);
+	seq_printf(seq, "th %u %u", nfsdstats.th_cnt, nfsdstats.th_fullcnt);
 	for (i=0; i<10; i++) {
 		unsigned int jifs = nfsdstats.th_usage[i];
 		unsigned int sec = jifs / HZ, msec = (jifs % HZ)*1000/HZ;
-		len += sprintf(buffer+len, " %u.%03u", sec, msec);
+		seq_printf(seq, " %u.%03u", sec, msec);
 	}
 
 	/* newline and ra-cache */
-	len += sprintf(buffer+len, "\nra %u", nfsdstats.ra_size);
+	seq_printf(seq, "\nra %u", nfsdstats.ra_size);
 	for (i=0; i<11; i++)
-		len += sprintf(buffer+len, " %u", nfsdstats.ra_depth[i]);
-	len += sprintf(buffer+len, "\n");
+		seq_printf(seq, " %u", nfsdstats.ra_depth[i]);
+	seq_putc(seq, '\n');
 	
+	/* show my rpc info */
+	svc_seq_show(seq, &nfsd_svcstats);
 
-	/* Assume we haven't hit EOF yet. Will be set by svc_proc_read. */
-	*eof = 0;
-
-	/*
-	 * Append generic nfsd RPC statistics if there's room for it.
-	 */
-	if (len <= offset) {
-		len = svc_proc_read(buffer, start, offset - len, count,
-				    eof, data);
-		return len;
-	}
-
-	if (len < count) {
-		len += svc_proc_read(buffer + len, start, 0, count - len,
-				     eof, data);
-	}
-
-	if (offset >= len) {
-		*start = buffer;
-		return 0;
-	}
+	return 0;
+}
 
-	*start = buffer + offset;
-	if ((len -= offset) > count)
-		return count;
-	return len;
+static int nfsd_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, nfsd_proc_show, NULL);
 }
 
+static struct file_operations nfsd_proc_fops = {
+	.owner = THIS_MODULE,
+	.open = nfsd_proc_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};	
+
 void
 nfsd_stat_init(void)
 {
-	struct proc_dir_entry	*ent;
-
-	if ((ent = svc_proc_register(&nfsd_svcstats)) != 0) {
-		ent->read_proc = nfsd_proc_read;
-		ent->owner = THIS_MODULE;
-	}
+	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
 }
 
 void

diff ./include/linux/sunrpc/stats.h~current~ ./include/linux/sunrpc/stats.h
--- ./include/linux/sunrpc/stats.h~current~	2004-02-06 14:14:37.000000000 +1100
+++ ./include/linux/sunrpc/stats.h	2004-02-06 14:14:37.000000000 +1100
@@ -48,14 +48,13 @@ void			rpc_modcount(struct inode *, int)
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *	rpc_proc_register(struct rpc_stat *);
 void			rpc_proc_unregister(const char *);
-int			rpc_proc_read(char *, char **, off_t, int,
-					int *, void *);
 void			rpc_proc_zero(struct rpc_program *);
-struct proc_dir_entry *	svc_proc_register(struct svc_stat *);
+struct proc_dir_entry *	svc_proc_register(struct svc_stat *, 
+					  struct file_operations *);
 void			svc_proc_unregister(const char *);
-int			svc_proc_read(char *, char **, off_t, int,
-					int *, void *);
-void			svc_proc_zero(struct svc_program *);
+
+void			svc_seq_show(struct seq_file *, 
+				     const struct svc_stat *);
 
 extern struct proc_dir_entry	*proc_net_rpc;
 
@@ -63,13 +62,13 @@ extern struct proc_dir_entry	*proc_net_r
 
 static inline struct proc_dir_entry *rpc_proc_register(struct rpc_stat *s) { return NULL; }
 static inline void rpc_proc_unregister(const char *p) {}
-static inline int rpc_proc_read(char *a, char **b, off_t c, int d, int *e, void *f) { return 0; }
 static inline void rpc_proc_zero(struct rpc_program *p) {}
 
-static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s) { return NULL; }
+static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s
+						       struct file_operations *) { return NULL; }
 static inline void svc_proc_unregister(const char *p) {}
-static inline int svc_proc_read(char *a, char **b, off_t c, int d, int *e, void *f) { return 0; }
-static inline void svc_proc_zero(struct svc_program *p) {}
+
+static inline void svc_seq_show(struct seq_file *, const struct svc_stat *) {}
 
 #define proc_net_rpc NULL
 

diff ./net/sunrpc/stats.c~current~ ./net/sunrpc/stats.c
--- ./net/sunrpc/stats.c~current~	2004-02-06 14:14:37.000000000 +1100
+++ ./net/sunrpc/stats.c	2004-02-06 14:14:37.000000000 +1100
@@ -18,6 +18,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
 
@@ -28,70 +29,66 @@ struct proc_dir_entry	*proc_net_rpc = NU
 /*
  * Get RPC client stats
  */
-int
-rpc_proc_read(char *buffer, char **start, off_t offset, int count,
-				int *eof, void *data)
-{
-	struct rpc_stat	*statp = (struct rpc_stat *) data;
-	struct rpc_program *prog = statp->program;
-	struct rpc_version *vers;
-	int		len, i, j;
+static int rpc_proc_show(struct seq_file *seq, void *v) {
+	const struct rpc_stat	*statp = seq->private;
+	const struct rpc_program *prog = statp->program;
+	int		i, j;
 
-	len = sprintf(buffer,
+	seq_printf(seq, 
 		"net %d %d %d %d\n",
 			statp->netcnt,
 			statp->netudpcnt,
 			statp->nettcpcnt,
 			statp->nettcpconn);
-	len += sprintf(buffer + len,
+	seq_printf(seq, 
 		"rpc %d %d %d\n",
 			statp->rpccnt,
 			statp->rpcretrans,
 			statp->rpcauthrefresh);
 
 	for (i = 0; i < prog->nrvers; i++) {
-		if (!(vers = prog->version[i]))
+		const struct rpc_version *vers = prog->version[i];
+		if (!vers)
 			continue;
-		len += sprintf(buffer + len, "proc%d %d",
+		seq_printf(seq, "proc%d %d",
 					vers->number, vers->nrprocs);
 		for (j = 0; j < vers->nrprocs; j++)
-			len += sprintf(buffer + len, " %d",
+			seq_printf(seq, " %d",
 					vers->procs[j].p_count);
-		buffer[len++] = '\n';
+		seq_putc(seq, '\n');
 	}
+	return 0;
+}
 
-	if (offset >= len) {
-		*start = buffer;
-		*eof = 1;
-		return 0;
-	}
-	*start = buffer + offset;
-	if ((len -= offset) > count)
-		return count;
-	*eof = 1;
-	return len;
+static int rpc_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rpc_proc_show, PDE(inode)->data);
 }
 
+static struct file_operations rpc_proc_fops = {
+	.owner = THIS_MODULE,
+	.open = rpc_proc_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};	
+
 /*
  * Get RPC server stats
  */
-int
-svc_proc_read(char *buffer, char **start, off_t offset, int count,
-				int *eof, void *data)
-{
-	struct svc_stat *statp	= (struct svc_stat *) data;
-	struct svc_program *prog = statp->program;
-	struct svc_procedure *proc;
-	struct svc_version *vers;
-	int		len, i, j;
+void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
+	const struct svc_program *prog = statp->program;
+	const struct svc_procedure *proc;
+	const struct svc_version *vers;
+	int		i, j;
 
-	len = sprintf(buffer,
+	seq_printf(seq, 
 		"net %d %d %d %d\n",
 			statp->netcnt,
 			statp->netudpcnt,
 			statp->nettcpcnt,
 			statp->nettcpconn);
-	len += sprintf(buffer + len,
+	seq_printf(seq, 
 		"rpc %d %d %d %d %d\n",
 			statp->rpccnt,
 			statp->rpcbadfmt+statp->rpcbadauth+statp->rpcbadclnt,
@@ -102,41 +99,36 @@ svc_proc_read(char *buffer, char **start
 	for (i = 0; i < prog->pg_nvers; i++) {
 		if (!(vers = prog->pg_vers[i]) || !(proc = vers->vs_proc))
 			continue;
-		len += sprintf(buffer + len, "proc%d %d", i, vers->vs_nproc);
+		seq_printf(seq, "proc%d %d", i, vers->vs_nproc);
 		for (j = 0; j < vers->vs_nproc; j++, proc++)
-			len += sprintf(buffer + len, " %d", proc->pc_count);
-		buffer[len++] = '\n';
+			seq_printf(seq, " %d", proc->pc_count);
+		seq_putc(seq, '\n');
 	}
-
-	if (offset >= len) {
-		*start = buffer;
-		*eof = 1;
-		return 0;
-	}
-	*start = buffer + offset;
-	if ((len -= offset) > count)
-		return count;
-	*eof = 1;
-	return len;
 }
 
 /*
  * Register/unregister RPC proc files
  */
 static inline struct proc_dir_entry *
-do_register(const char *name, void *data, int issvc)
+do_register(const char *name, void *data, struct file_operations *fops)
 {
+	struct proc_dir_entry *ent;
+
 	rpc_proc_init();
 	dprintk("RPC: registering /proc/net/rpc/%s\n", name);
-	return create_proc_read_entry(name, 0, proc_net_rpc, 
-				      issvc? svc_proc_read : rpc_proc_read,
-				      data);
+
+	ent = create_proc_entry(name, 0, proc_net_rpc);
+	if (ent) {
+		ent->proc_fops = fops;
+		ent->data = data;
+	}
+	return ent;
 }
 
 struct proc_dir_entry *
 rpc_proc_register(struct rpc_stat *statp)
 {
-	return do_register(statp->program->name, statp, 0);
+	return do_register(statp->program->name, statp, &rpc_proc_fops);
 }
 
 void
@@ -146,9 +138,9 @@ rpc_proc_unregister(const char *name)
 }
 
 struct proc_dir_entry *
-svc_proc_register(struct svc_stat *statp)
+svc_proc_register(struct svc_stat *statp, struct file_operations *fops)
 {
-	return do_register(statp->program->pg_name, statp, 1);
+	return do_register(statp->program->pg_name, statp, fops);
 }
 
 void
@@ -163,7 +155,7 @@ rpc_proc_init(void)
 	dprintk("RPC: registering /proc/net/rpc\n");
 	if (!proc_net_rpc) {
 		struct proc_dir_entry *ent;
-		ent = proc_mkdir("net/rpc", 0);
+		ent = proc_mkdir("rpc", proc_net);
 		if (ent) {
 			ent->owner = THIS_MODULE;
 			proc_net_rpc = ent;

diff ./net/sunrpc/sunrpc_syms.c~current~ ./net/sunrpc/sunrpc_syms.c
--- ./net/sunrpc/sunrpc_syms.c~current~	2004-02-06 14:12:14.000000000 +1100
+++ ./net/sunrpc/sunrpc_syms.c	2004-02-06 14:14:37.000000000 +1100
@@ -90,10 +90,9 @@ EXPORT_SYMBOL(svc_reserve);
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(rpc_proc_register);
 EXPORT_SYMBOL(rpc_proc_unregister);
-EXPORT_SYMBOL(rpc_proc_read);
 EXPORT_SYMBOL(svc_proc_register);
 EXPORT_SYMBOL(svc_proc_unregister);
-EXPORT_SYMBOL(svc_proc_read);
+EXPORT_SYMBOL(svc_seq_show);
 #endif
 
 /* caching... */


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
