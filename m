From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Tue, 13 Jul 2004 08:24:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40F3D483.8020507@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070804010500020401020904"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkMKz-00018F-SO
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 05:24:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BkMKz-0001OE-54
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 05:24:45 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i6DCOce1021710
	for <nfs@lists.sourceforge.net>; Tue, 13 Jul 2004 08:24:38 -0400
Received: from RedHat.com (vpn64-18.boston.redhat.com [172.16.66.18])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i6DCOb008255
	for <nfs@lists.sourceforge.net>; Tue, 13 Jul 2004 08:24:37 -0400
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

This is a multi-part message in MIME format.
--------------070804010500020401020904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a patch I've been using for quite a while now
that will zero out the nfs stats on both the server
and client side.

There are two interface: nfsstat and /proc.
The nfstat interface looks like (from the manpage):
-z     Zeros out all or some of the statistics. Typical uses would be:
     nfsstat -z  - zeros all statistics
     nfsstat -zc - zeros only client statistics
     nfsstat -zs - zeros only server statistics
     nfsstat -zr - zeros only RPC statistics
     nfsstat -zn - zeros only NFS call statistics

Note: the nfs-utils in the Fedora Core 2/3 release already have
this support.

The /proc interface look something like:

echo nfs > /proc/net/rpc/nfs[d] # zeros calls stats
echo rpc > /proc/net/rpc/nfs[d] # zeros rpc stats
echo net > /proc/net/rpc/nfs[d] # zeros connection stats
echo rc  > /proc/net/rpc/nfsd   # zeros server cache stats
echo fh  > /proc/net/rpc/nfsd   # zeros server fh stats

Again this is a patch I've had kicking around for sometime
so its pretty well tested... and I'm a bit dependent on it
in the sense its annoying when I go to zero the stats
and I can't because I forgot to apply the patch...

I'm hopeful that other people will also find this patch useful
as well and it will make its way into an upstream kernel
in the very near future....

SteveD.

--------------070804010500020401020904
Content-Type: text/plain;
 name="linux-2.6.7-nfs-zerostats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.7-nfs-zerostats.patch"

--- linux-2.6.7/include/linux/sunrpc/stats.h.orig	2004-06-23 11:00:20.000000000 -0400
+++ linux-2.6.7/include/linux/sunrpc/stats.h	2004-06-23 11:32:09.000000000 -0400
@@ -48,21 +48,34 @@ void			rpc_modcount(struct inode *, int)
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *	rpc_proc_register(struct rpc_stat *);
 void			rpc_proc_unregister(const char *);
-void			rpc_proc_zero(struct rpc_program *);
 struct proc_dir_entry *	svc_proc_register(struct svc_stat *,
 					  struct file_operations *);
 void			svc_proc_unregister(const char *);
 
 void			svc_seq_show(struct seq_file *,
 				     const struct svc_stat *);
+void			svc_seq_zero(struct seq_file *,
+				     struct svc_stat *, unsigned int);
 
 extern struct proc_dir_entry	*proc_net_rpc;
+/*
+ * Bits used to zero out status
+ */
+#define PRNT_CALLS  0x0001
+#define PRNT_RPC    0x0002
+#define PRNT_NET    0x0004
+#define PRNT_FH     0x0008
+#define PRNT_RC     0x0010
+#define PRNT_IO     0x0020
+#define PRNT_ALL    0xffff
+
+unsigned int rpc_proc_getval(char *, int , const char *, size_t);
 
 #else
 
 static inline struct proc_dir_entry *rpc_proc_register(struct rpc_stat *s) { return NULL; }
 static inline void rpc_proc_unregister(const char *p) {}
-static inline void rpc_proc_zero(struct rpc_program *p) {}
+static inline rpc_proc_getval(char *, int , const char *, unsigned long) {}
 
 static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s,
 						       struct file_operations *f) { return NULL; }
@@ -70,6 +83,8 @@ static inline void svc_proc_unregister(c
 
 static inline void svc_seq_show(struct seq_file *seq,
 				const struct svc_stat *st) {}
+static inline void svc_seq_zero(struct seq_file *seq,
+				const struct svc_stat *st, unsigned int opt) {}
 
 #define proc_net_rpc NULL
 
--- linux-2.6.7/fs/nfsd/stats.c.orig	2004-06-23 11:00:20.000000000 -0400
+++ linux-2.6.7/fs/nfsd/stats.c	2004-06-23 11:29:31.000000000 -0400
@@ -74,6 +74,42 @@ static int nfsd_proc_show(struct seq_fil
 
 	return 0;
 }
+#define HEX_DIGITS 8
+
+static ssize_t
+nfsd_proc_zero(struct file *file, const char *buffer, 
+	size_t count, loff_t *data)
+{
+	struct seq_file *seq = (struct seq_file *)file->private_data;
+	char hexnum [HEX_DIGITS];
+	unsigned int opt_prt;
+
+	opt_prt = rpc_proc_getval(hexnum, HEX_DIGITS, buffer, count);
+	if (opt_prt < 0) 
+		return opt_prt;
+
+	if (opt_prt & PRNT_RC) {
+		nfsdstats.rchits = 0;
+		nfsdstats.rcmisses = 0;
+		nfsdstats.rcnocache = 0;
+	}
+	if (opt_prt & PRNT_FH) {
+		nfsdstats.fh_stale = 0;
+		nfsdstats.fh_lookup = 0;
+		nfsdstats.fh_anon = 0;
+		nfsdstats.fh_nocache_dir = 0;
+		nfsdstats.fh_nocache_nondir = 0;
+	}
+	if (opt_prt & PRNT_IO) {
+		nfsdstats.io_read = 0;
+		nfsdstats.io_write = 0;
+	}
+
+	/* zero my rpc info */
+	svc_seq_zero(seq, &nfsd_svcstats, opt_prt);
+
+	return opt_prt;
+}
 
 static int nfsd_proc_open(struct inode *inode, struct file *file)
 {
@@ -84,6 +120,7 @@ static struct file_operations nfsd_proc_
 	.owner = THIS_MODULE,
 	.open = nfsd_proc_open,
 	.read  = seq_read,
+	.write  = nfsd_proc_zero,
 	.llseek = seq_lseek,
 	.release = single_release,
 };
--- linux-2.6.7/net/sunrpc/sunrpc_syms.c.orig	2004-06-16 01:19:52.000000000 -0400
+++ linux-2.6.7/net/sunrpc/sunrpc_syms.c	2004-06-23 11:31:35.000000000 -0400
@@ -94,9 +94,11 @@ EXPORT_SYMBOL(auth_domain_lookup);
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(rpc_proc_register);
 EXPORT_SYMBOL(rpc_proc_unregister);
+EXPORT_SYMBOL_GPL(rpc_proc_getval);
 EXPORT_SYMBOL(svc_proc_register);
 EXPORT_SYMBOL(svc_proc_unregister);
 EXPORT_SYMBOL(svc_seq_show);
+EXPORT_SYMBOL_GPL(svc_seq_zero);
 #endif
 
 /* caching... */
--- linux-2.6.7/net/sunrpc/stats.c.orig	2004-06-23 11:00:20.000000000 -0400
+++ linux-2.6.7/net/sunrpc/stats.c	2004-06-23 11:18:55.000000000 -0400
@@ -21,9 +21,55 @@
 #include <linux/seq_file.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
+#include <asm/uaccess.h>
 
 #define RPCDBG_FACILITY	RPCDBG_MISC
 
+
+#define HEX_DIGITS 8
+unsigned int 
+rpc_proc_getval(char *val, int vallen, const char *buf, size_t cnt)
+{
+	unsigned int new_value = 0;
+	int i;
+
+	if (!cnt)
+		return -EINVAL;
+	if (cnt > vallen)
+		cnt = vallen;
+	if (copy_from_user(val, buf, cnt))
+		return -EFAULT;
+	val[vallen-1] = '\0';
+
+	if (strcmp(val, "nfs") == 0) {
+		new_value = PRNT_CALLS;
+	} else if (strcmp(val, "rpc") == 0) {
+		new_value = PRNT_RPC;
+	} else if (strcmp(val, "net") == 0) {
+		new_value = PRNT_NET;
+	} else if (strcmp(val, "fh") == 0) {
+		new_value = PRNT_FH;
+	} else if (strcmp(val, "rc") == 0) {
+		new_value = PRNT_RC;
+	} else {
+		new_value = 0;
+		for (i = 0; i < cnt; i++) {
+			unsigned int c = val[i];
+
+			switch (c) {
+				case '0' ... '9': c -= '0'; break;
+				case 'a' ... 'f': c -= 'a'-10; break;
+				case 'A' ... 'F': c -= 'A'-10; break;
+			default:
+				goto out;
+			}
+			new_value = (new_value << 4) | c;
+		}
+	}
+out:
+	return new_value;
+}
+
 struct proc_dir_entry	*proc_net_rpc = NULL;
 
 /*
@@ -60,6 +106,45 @@ static int rpc_proc_show(struct seq_file
 	return 0;
 }
 
+static ssize_t
+rpc_proc_zero(struct file *file, const char *buffer, 
+	size_t count, loff_t *data)
+{
+	struct rpc_stat *statp = ((struct seq_file *)file->private_data)->private;
+	struct rpc_program *prog = statp->program;
+	char hexnum [HEX_DIGITS];
+	unsigned int opt_prt;
+	int i, j;
+
+	opt_prt = rpc_proc_getval(hexnum, HEX_DIGITS, buffer, count);
+	if (opt_prt < 0) 
+		return opt_prt;
+
+	dprintk("RPC: zeroing bits 0x%x\n", opt_prt);
+
+	if (opt_prt & PRNT_NET) {
+		statp->netcnt = 0,
+		statp->netudpcnt = 0,
+		statp->nettcpcnt = 0,
+		statp->nettcpconn = 0;
+	}
+	if (opt_prt & PRNT_RPC) {
+		statp->rpccnt = 0,
+		statp->rpcretrans = 0,
+		statp->rpcauthrefresh = 0;
+	}
+	if (opt_prt & PRNT_CALLS) {
+		for (i = 0; i < prog->nrvers; i++) {
+			const struct rpc_version *vers = prog->version[i];
+			if (!vers)
+				continue;
+			for (j = 0; j < vers->nrprocs; j++)
+					vers->procs[j].p_count = 0;
+		}
+	}
+	return opt_prt;
+}
+
 static int rpc_proc_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, rpc_proc_show, PDE(inode)->data);
@@ -69,6 +154,7 @@ static struct file_operations rpc_proc_f
 	.owner = THIS_MODULE,
 	.open = rpc_proc_open,
 	.read  = seq_read,
+	.write  = rpc_proc_zero,
 	.llseek = seq_lseek,
 	.release = single_release,
 };
@@ -105,6 +191,36 @@ void svc_seq_show(struct seq_file *seq, 
 		seq_putc(seq, '\n');
 	}
 }
+/*
+ * Zero RPC server stats
+ */
+void svc_seq_zero(struct seq_file *seq, struct svc_stat *statp, unsigned int opt_prt) {
+	struct svc_program *prog = statp->program;
+	struct svc_procedure *proc;
+	const struct svc_version *vers;
+	int		i, j;
+
+	if (opt_prt & PRNT_NET) {
+		statp->netcnt = 0;
+		statp->netudpcnt = 0;
+		statp->nettcpcnt = 0;
+		statp->nettcpconn = 0;
+	}
+	if (opt_prt & PRNT_RPC) {
+		statp->rpccnt = 0;
+		statp->rpcbadfmt = statp->rpcbadauth = statp->rpcbadclnt = 0;
+		statp->rpcbadfmt = 0;
+		statp->rpcbadauth = 0;
+		statp->rpcbadclnt = 0;;
+	}
+
+	for (i = 0; i < prog->pg_nvers; i++) {
+		if (!(vers = prog->pg_vers[i]) || !(proc = vers->vs_proc))
+			continue;
+		for (j = 0; j < vers->vs_nproc; j++, proc++)
+			proc->pc_count = 0;
+	}
+}
 
 /*
  * Register/unregister RPC proc files
@@ -113,11 +229,12 @@ static inline struct proc_dir_entry *
 do_register(const char *name, void *data, struct file_operations *fops)
 {
 	struct proc_dir_entry *ent;
+	mode_t mode;
 
 	rpc_proc_init();
 	dprintk("RPC: registering /proc/net/rpc/%s\n", name);
-
-	ent = create_proc_entry(name, 0, proc_net_rpc);
+	mode = (fops->write != NULL ? 0644 : 0);
+	ent = create_proc_entry(name, mode, proc_net_rpc);
 	if (ent) {
 		ent->proc_fops = fops;
 		ent->data = data;

--------------070804010500020401020904--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
