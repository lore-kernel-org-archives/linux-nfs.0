From: Olaf Kirch <okir@suse.de>
Subject: statd simplified
Date: Mon, 2 Feb 2004 15:08:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040202140851.GH3145@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="s/l3CgOIzMHHjg/5"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Anekx-0006Vj-Bh
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 06:08:55 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Anekw-00077P-1M
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 06:08:54 -0800
Received: from Hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 67603109A2B
	for <nfs@lists.sourceforge.net>; Mon,  2 Feb 2004 15:08:51 +0100 (CET)
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


--s/l3CgOIzMHHjg/5
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi all,

I've never really liked statd for a number of reasons (the following
list is not exhaustive):

 -	50% of all bug reports I get conerning "NFS file locking
 	broken" is due to people forgetting to start statd
	(the other half is people trying to do flock over NFS :)
 -	lockd having to do upcalls to user space is ugly
 -	user space doing RPC callbacks to the kernel is even uglier
 -	statd isn't really used by anything but lockd, so the
 	only reason for making things so complex is probably because
	the folks creating NFS locking _liked_ complexity.

So I sat down last week and dusted off some old ideas how to simplify
NLM/NSM interaction quite a bit.

The approach I implemented was to get rid of all the SM_MON/SM_UNMON
calls completely. If lockd wants a remote host to be "monitored", simply
add it's IP address to /var/lib/nfs/sm. This used to be statd's job,
but there's no reason why we cannot do that in the kernel.

In addition, lockd now understands a very limited subset of NSM
procedures: NULL, and SM_NOTIFY. If it receives an SM_NOTIFY message,
it initiated reclaim for all locks we hold on that server (if any)
and ditch all locks this client holds on our box (if any).

(As a special bonus, the new code actually initializes nsm_local_state
from /var/lib/nfs/state, which we previously didn't).

That is almost all there is to statd. The only piece of the puzzle
missing is a facility to send out NSM notifications when we reboot.
That can be done in user space by running "rpc.statd -N" (notify-only
mode) every time we boot.

Please find attached two kernel patches. The first is from Andreas
Gruenbacher implementing several RPC programs sharing a single server
socket (he wrote the patch for his NFS ACL implementation); the second
is my kernel-statd patch.

Feedback welcome!

Cheers,
Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--s/l3CgOIzMHHjg/5
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sunrpc-multiple-programs

Support multiple program numbers on one RPC transport

The NFS and NFSACL programs run on the same RPC transport. This patch
adds support for this by changing svc_program into a chained list of
programs instead of a single program (on the server side).

On the client side, the same RPC transport can now be shared among
multiple RPC clients, so reference count the transport to determine
when it can be destroyed.

  Andreas Gruenbacher <agruen@suse.de>, SuSE Labs


Index: linux-2.6.0-test11/fs/nfsd/nfsproc.c
===================================================================
--- linux-2.6.0-test11.orig/fs/nfsd/nfsproc.c	2003-12-17 21:37:32.155017440 +0100
+++ linux-2.6.0-test11/fs/nfsd/nfsproc.c	2003-12-17 21:48:01.175256768 +0100
@@ -587,6 +587,8 @@ nfserrno (int errno)
 		{ nfserr_stale, -ESTALE },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
+		{ nfserr_notsupp, -ENOTSUPP },
+		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ -1, -EIO }
 	};
 	int	i;
Index: linux-2.6.0-test11/net/sunrpc/svc.c
===================================================================
--- linux-2.6.0-test11.orig/net/sunrpc/svc.c	2003-11-26 21:45:36.000000000 +0100
+++ linux-2.6.0-test11/net/sunrpc/svc.c	2003-12-17 21:36:49.678474856 +0100
@@ -324,8 +324,10 @@ svc_process(struct svc_serv *serv, struc
 		goto dropit;
 	}
 		
-	progp = serv->sv_program;
-	if (prog != progp->pg_prog)
+	for (progp = serv->sv_program; progp; progp = progp->pg_next)
+		if (prog == progp->pg_prog)
+			break;
+	if (progp == NULL)
 		goto err_bad_prog;
 
 	if (vers >= progp->pg_nvers ||
@@ -438,7 +440,7 @@ err_bad_auth:
 
 err_bad_prog:
 #ifdef RPC_PARANOIA
-	if (prog != 100227 || progp->pg_prog != 100003)
+	if (prog != 100227 || serv->sv_program->pg_prog != 100003)
 		printk("svc: unknown program %d (me %d)\n", prog, progp->pg_prog);
 	/* else it is just a Solaris client seeing if ACLs are supported */
 #endif
Index: linux-2.6.0-test11/include/linux/sunrpc/svc.h
===================================================================
--- linux-2.6.0-test11.orig/include/linux/sunrpc/svc.h	2003-11-26 21:44:18.000000000 +0100
+++ linux-2.6.0-test11/include/linux/sunrpc/svc.h	2003-12-17 21:36:49.689473184 +0100
@@ -231,9 +231,10 @@ struct svc_deferred_req {
 };
 
 /*
- * RPC program
+ * List of RPC programs on the same transport endpoint
  */
 struct svc_program {
+	struct svc_program *	pg_next;	/* other programs (same xprt) */
 	u32			pg_prog;	/* program number */
 	unsigned int		pg_lovers;	/* lowest version */
 	unsigned int		pg_hivers;	/* lowest version */

--s/l3CgOIzMHHjg/5
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=kernel-statd

diff -pNaur linux-2.6.1.statd/fs/Kconfig linux-2.6.1/fs/Kconfig
--- linux-2.6.1.statd/fs/Kconfig	2004-02-02 10:27:46.000000000 +0100
+++ linux-2.6.1/fs/Kconfig	2004-02-02 10:28:13.000000000 +0100
@@ -1466,6 +1466,10 @@ config ROOT_NFS
 config LOCKD
 	tristate
 
+config STATD
+	bool "Use kernel statd implementation"
+	depends on LOCKD && EXPERIMENTAL
+
 config LOCKD_V4
 	bool
 	depends on NFSD_V3 || NFS_V3
--- linux-2.6.1.statd/fs/buffer.c	2004-02-02 10:27:42.000000000 +0100
+++ linux-2.6.1/fs/buffer.c	2004-02-02 11:40:29.000000000 +0100
@@ -242,6 +242,7 @@
 
 	return sync_blockdev(sb->s_bdev);
 }
+EXPORT_SYMBOL(fsync_super);
 
 /*
  * Write out and wait upon all dirty data associated with this
diff -pNaur linux-2.6.1.statd/fs/lockd/Makefile linux-2.6.1/fs/lockd/Makefile
--- linux-2.6.1.statd/fs/lockd/Makefile	2004-01-09 07:59:08.000000000 +0100
+++ linux-2.6.1/fs/lockd/Makefile	2004-02-02 10:28:13.000000000 +0100
@@ -5,6 +5,12 @@
 obj-$(CONFIG_LOCKD) += lockd.o
 
 lockd-objs-y := clntlock.o clntproc.o host.o svc.o svclock.o svcshare.o \
-	        svcproc.o svcsubs.o mon.o xdr.o lockd_syms.o
+	        svcproc.o svcsubs.o xdr.o lockd_syms.o
+ifeq ($(CONFIG_STATD),y)
+lockd-objs-y += statd.o
+else
+lockd-objs-y += mon.o
+endif
+
 lockd-objs-$(CONFIG_LOCKD_V4) += xdr4.o svc4proc.o
 lockd-objs		      := $(lockd-objs-y)
diff -pNaur linux-2.6.1.statd/fs/lockd/host.c linux-2.6.1/fs/lockd/host.c
--- linux-2.6.1.statd/fs/lockd/host.c	2004-01-09 07:59:43.000000000 +0100
+++ linux-2.6.1/fs/lockd/host.c	2004-02-02 10:28:13.000000000 +0100
@@ -253,6 +253,56 @@ void nlm_release_host(struct nlm_host *h
 }
 
 /*
+ * Given an IP address, initiate recovery and ditch all locks.
+ */
+void
+nlm_host_rebooted(struct sockaddr_in *sin, u32 new_state)
+{
+	struct nlm_host	*host, **hp;
+	int		hash;
+
+	dprintk("lockd: nlm_host_rebooted(%u.%u.%u.%u)\n",
+			NIPQUAD(sin->sin_addr));
+
+	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
+
+	/* Lock hash table */
+	down(&nlm_host_sema);
+	for (hp = &nlm_hosts[hash]; (host = *hp); hp = &host->h_next) {
+		if (nlm_cmp_addr(&host->h_addr, sin))
+			host->h_rebooted = 1;
+	}
+
+again:
+	for (hp = &nlm_hosts[hash]; (host = *hp); hp = &host->h_next) {
+		if (nlm_cmp_addr(&host->h_addr, sin) && host->h_rebooted) {
+			host->h_rebooted = 0;
+			host->h_count++;
+			up(&nlm_host_sema);
+
+			/* If we're server for this guy, just ditch
+			 * all the locks he held.
+			 * If he's the server, initiate lock recovery.
+			 */
+			if (host->h_server) {
+				nlmsvc_free_host_resources(host);
+			} else {
+				nlmclnt_recovery(host, new_state);
+			}
+
+			down(&nlm_host_sema);
+			nlm_release_host(host);
+
+			/* Host table may have changed in the meanwhile,
+			 * start over */
+			goto again;
+		}
+	}
+
+	up(&nlm_host_sema);
+}
+
+/*
  * Shut down the hosts module.
  * Note that this routine is called only at server shutdown time.
  */
diff -pNaur linux-2.6.1.statd/fs/lockd/mon.c linux-2.6.1/fs/lockd/mon.c
--- linux-2.6.1.statd/fs/lockd/mon.c	2004-01-09 07:59:47.000000000 +0100
+++ linux-2.6.1/fs/lockd/mon.c	2004-02-02 10:28:13.000000000 +0100
@@ -3,6 +3,10 @@
  *
  * The kernel statd client.
  *
+ * When using the kernel statd implementation, none of the
+ * stuff inside this file is used. 
+ * Instead look at statd.c
+ *
  * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
 
@@ -15,6 +19,9 @@
 #include <linux/lockd/sm_inter.h>
 
 
+
+#ifndef CONFIG_STATD
+
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
 static struct rpc_clnt *	nsm_create(void);
@@ -22,7 +29,8 @@ static struct rpc_clnt *	nsm_create(void
 extern struct rpc_program	nsm_program;
 
 /*
- * Local NSM state
+ * Local NSM state.
+ * This should really be initialized somehow.
  */
 u32				nsm_local_state;
 
@@ -246,3 +254,5 @@ struct rpc_program		nsm_program = {
 		.version	= nsm_version,
 		.stats		= &nsm_stats
 };
+
+#endif
diff -pNaur linux-2.6.1.statd/fs/lockd/statd.c linux-2.6.1/fs/lockd/statd.c
--- linux-2.6.1.statd/fs/lockd/statd.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.1/fs/lockd/statd.c	2004-02-02 10:28:13.000000000 +0100
@@ -0,0 +1,278 @@
+/*
+ * linux/fs/lockd/nsmproc.c
+ *
+ * Kernel-based status monitor. This is an alternative to
+ * the stuff in mon.c.
+ *
+ * When asked to monitor a host, we add it to /var/lib/nsm/sm
+ * ourselves, and that's it. In order to catch SM_NOTIFY calls
+ * we implement a minimal statd.
+ *
+ * Minimal user space requirements for this implementation:
+ *  /var/lib/nfs/state
+ *	must exist, and must contain the NSM state as a 32bit
+ *	binary counter.
+ * /var/lib/nfs/sm
+ *	must exist
+ *
+ * Copyright (C) 2004, Olaf Kirch <okir@suse.de>
+ */
+
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/time.h>
+#include <linux/slab.h>
+#include <linux/in.h>
+#include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfsd/nfsd.h>
+#include <linux/lockd/lockd.h>
+#include <linux/lockd/share.h>
+#include <linux/lockd/sm_inter.h>
+#include <linux/file.h>
+#include <asm/uaccess.h>
+#include <linux/buffer_head.h>
+
+
+/* XXX make this a module parameter? */
+#define NSM_BASE_PATH		"/var/lib/nfs"
+#define NSM_SM_PATH		NSM_BASE_PATH "/sm"
+#define NSM_STATE_PATH		NSM_BASE_PATH "/state"
+
+#define NLMDBG_FACILITY		NLMDBG_CLIENT
+
+/*
+ * Local NSM state.
+ */
+u32				nsm_local_state;
+
+/*
+ * Initialize local NSM state variable
+ */
+int
+nsm_init(void)
+{
+	struct file	*filp;
+	char		buffer[32];
+	mm_segment_t	fs;
+	int		res;
+
+	dprintk("lockd: nsm_init()\n");
+	filp = filp_open(NSM_STATE_PATH, O_RDONLY, 0444);
+	if (IS_ERR(filp)) {
+		res = PTR_ERR(filp);
+		printk(KERN_NOTICE "lockd: failed to open %s: err=%d\n",
+				NSM_STATE_PATH, res);
+		return res;
+	}
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	res = vfs_read(filp, buffer, sizeof(buffer), &filp->f_pos);
+	set_fs(fs);
+	filp_close(filp, NULL);
+
+	if (res < 0)
+		return res;
+	if (res == 4)
+		nsm_local_state = *(u32 *) buffer;
+	else
+		nsm_local_state = simple_strtol(buffer, NULL, 10);
+	return 0;
+}
+
+/*
+ * Build the path name for this lockd peer.
+ *
+ * We keep it extremely simple. Since we can have more
+ * than one nlm_host object peer (depending on whether
+ * it's server or client, and what proto/version of NLM
+ * we use to communicate), we cannot create a file named
+ * $IPADDR and remove it when the nlm_host is unmonitored.
+ * Besides, unlink() is tricky (there's no kernel_syscall
+ * for it), so we just create the file and leave it.
+ *
+ * When we reboot, the notifier should sort the IPs by
+ * descending mtime so that the most recent hosts get
+ * notified first.
+ */
+static char *
+nsm_filename(struct nlm_host *host)
+{
+	struct in_addr	addr = host->h_addr.sin_addr;
+	char		*name;
+
+	name = (char *) __get_free_page(GFP_KERNEL);
+	if (name == NULL)
+		return NULL;
+
+	/* FIXME IPV6 */
+	snprintf(name, PAGE_SIZE, "%s/%u.%u.%u.%u",
+			NSM_SM_PATH, NIPQUAD(addr));
+	return name;
+}
+
+/*
+ * Set up monitoring of a remote host
+ */
+int
+nsm_monitor(struct nlm_host *host)
+{
+	char		*name;
+	struct file	*filp;
+	int		res = 0;
+	kernel_cap_t	cap = current->cap_effective;
+
+	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
+
+	if (!(name = nsm_filename(host)))
+		return -ENOMEM;
+
+	dprintk("lockd: creating statd monitor file %s\n", name);
+	
+	/* Raise capability to that we're able to create the file */
+	cap_raise(current->cap_effective, CAP_DAC_OVERRIDE);
+	filp = filp_open(name, O_CREAT|O_SYNC|O_RDWR, 0644);
+	if (IS_ERR(filp)) {
+		res = PTR_ERR(filp);
+		printk(KERN_NOTICE
+			"lockd/statd: failed to create %s: err=%d\n",
+			name, res);
+	} else {
+		host->h_monitored = 1;
+		fsync_super(filp->f_dentry->d_inode->i_sb);
+		filp_close(filp, NULL);
+	}
+
+	current->cap_effective = cap;
+	free_page((long) name);
+	return res;
+}
+
+/*
+ * Cease to monitor remote host
+ * As explained above, do nothing.
+ */
+int
+nsm_unmonitor(struct nlm_host *host)
+{
+	dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
+	return 0;
+}
+
+/*
+ * NSM server implementation starts here
+ */
+
+/*
+ * NULL: Test for presence of service
+ */
+static int
+nsmsvc_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+{
+	dprintk("statd: NULL          called\n");
+	return rpc_success;
+}
+
+/*
+ * NOTIFY: receive notification that remote host rebooted
+ */
+static int
+nsmsvc_proc_notify(struct svc_rqst *rqstp, struct nsm_args *argp,
+				           struct nsm_res  *resp)
+{
+	struct sockaddr_in	saddr = rqstp->rq_addr;
+
+	dprintk("statd: NOTIFY        called\n");
+	if (ntohs(saddr.sin_port) >= 1024) {
+		printk(KERN_WARNING
+			"statd: rejected NSM_NOTIFY from %08x:%d\n",
+			ntohl(rqstp->rq_addr.sin_addr.s_addr),
+			ntohs(rqstp->rq_addr.sin_port));
+		return rpc_system_err;
+	}
+
+	nlm_host_rebooted(&saddr, argp->state);
+	return rpc_success;
+}
+
+/*
+ * All other operations: return failure
+ */
+static int
+nsmsvc_proc_fail(struct svc_rqst *rqstp, struct nsm_args *argp,
+				         struct nsm_res  *resp)
+{
+	dprintk("statd: proc %u        called\n", rqstp->rq_proc);
+	resp->status = 0;
+	resp->state = -1;
+	return rpc_success;
+}
+
+/*
+ * NSM XDR routines
+ */
+int
+nsmsvc_decode_void(struct svc_rqst *rqstp, u32 *p, void *dummy)
+{
+	return xdr_argsize_check(rqstp, p);
+}
+
+int
+nsmsvc_encode_void(struct svc_rqst *rqstp, u32 *p, void *dummy)
+{
+	return xdr_ressize_check(rqstp, p);
+}
+
+int
+nsmsvc_decode_stat_chge(struct svc_rqst *rqstp, u32 *p, struct nsm_args *argp)
+{
+	char	*mon_name;
+	__u32	mon_name_len;
+
+	/* Skip over the client's mon_name */
+	p = xdr_decode_string_inplace(p, &mon_name, &mon_name_len, SM_MAXSTRLEN);
+	if (p == NULL)
+		return 0;
+
+	argp->state = ntohl(*p++);
+	return xdr_argsize_check(rqstp, p);
+}
+
+int
+nsmsvc_encode_res(struct svc_rqst *rqstp, u32 *p, struct nsm_res *resp)
+{
+	*p++ = resp->status;
+	return xdr_ressize_check(rqstp, p);
+}
+
+int
+nsmsvc_encode_stat_res(struct svc_rqst *rqstp, u32 *p, struct nsm_res *resp)
+{
+	*p++ = resp->status;
+	*p++ = resp->state;
+	return xdr_ressize_check(rqstp, p);
+}
+
+struct nsm_void			{ int dummy; };
+
+#define PROC(name, xargt, xrest, argt, rest, respsize)	\
+ { .pc_func	= (svc_procfunc) nsmsvc_proc_##name,	\
+   .pc_decode	= (kxdrproc_t) nsmsvc_decode_##xargt,	\
+   .pc_encode	= (kxdrproc_t) nsmsvc_encode_##xrest,	\
+   .pc_release	= NULL,					\
+   .pc_argsize	= sizeof(struct nsm_##argt),		\
+   .pc_ressize	= sizeof(struct nsm_##rest),		\
+   .pc_xdrressize = respsize,				\
+ }
+
+struct svc_procedure		nsmsvc_procedures[] = {
+  PROC(null,		void,		void,		void,	void, 1),
+  PROC(fail,		void,		stat_res,	void,	res, 2),
+  PROC(fail,		void,		stat_res,	void,	res, 2),
+  PROC(fail,		void,		res,		void,	res, 1),
+  PROC(fail,		void,		res,		void,	res, 1),
+  PROC(fail,		void,		res,		void,	res, 1),
+  PROC(notify,		stat_chge,	void,		args,	void, 1)
+};
diff -pNaur linux-2.6.1.statd/fs/lockd/svc.c linux-2.6.1/fs/lockd/svc.c
--- linux-2.6.1.statd/fs/lockd/svc.c	2004-01-09 07:59:45.000000000 +0100
+++ linux-2.6.1/fs/lockd/svc.c	2004-02-02 10:28:29.000000000 +0100
@@ -34,6 +34,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
+#include <linux/lockd/sm_inter.h>
 #include <linux/nfs.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
@@ -115,6 +116,11 @@ lockd(struct svc_rqst *rqstp)
 
 	daemonize("lockd");
 
+#ifdef CONFIG_STATD
+	/* Set up statd */
+	nsm_init();
+#endif
+
 	/* Process request with signals blocked, but allow SIGKILL.  */
 	allow_signal(SIGKILL);
 
@@ -439,6 +445,37 @@ static void __exit exit_nlm(void)
 module_init(init_nlm);
 module_exit(exit_nlm);
 
+#ifdef CONFIG_STATD
+/*
+ * Define NSM program and procedures
+ */
+static struct svc_version	nsmsvc_version1 = {
+		.vs_vers	= 1,
+		.vs_nproc	= 5,
+		.vs_proc	= nsmsvc_procedures,
+		.vs_xdrsize	= SMSVC_XDRSIZE,
+};
+static struct svc_version *	nsmsvc_version[] = {
+	[1] = &nsmsvc_version1,
+};
+
+static struct svc_stat		nsmsvc_stats;
+
+#define SM_NRVERS	(sizeof(nsmsvc_version)/sizeof(nsmsvc_version[0]))
+static struct svc_program	nsmsvc_program = {
+	.pg_prog	= SM_PROGRAM,		/* program number */
+	.pg_nvers	= SM_NRVERS,		/* number of entries in nlmsvc_version */
+	.pg_vers	= nsmsvc_version,	/* version table */
+	.pg_name	= "statd",		/* service name */
+	.pg_class	= "nfsd",		/* share authentication with nfsd */
+	.pg_stats	= &nsmsvc_stats,	/* stats table */
+};
+
+#define nsmsvc_program_p &nsmsvc_program
+#else
+#define nsmsvc_program_p NULL
+#endif
+
 /*
  * Define NLM program and procedures
  */
@@ -474,6 +511,7 @@ static struct svc_stat		nlmsvc_stats;
 
 #define NLM_NRVERS	(sizeof(nlmsvc_version)/sizeof(nlmsvc_version[0]))
 struct svc_program	nlmsvc_program = {
+	.pg_next	= nsmsvc_program_p,
 	.pg_prog	= NLM_PROGRAM,		/* program number */
 	.pg_nvers	= NLM_NRVERS,		/* number of entries in nlmsvc_version */
 	.pg_vers	= nlmsvc_version,	/* version table */
diff -pNaur linux-2.6.1.statd/include/linux/lockd/lockd.h linux-2.6.1/include/linux/lockd/lockd.h
--- linux-2.6.1.statd/include/linux/lockd/lockd.h	2004-01-09 07:59:10.000000000 +0100
+++ linux-2.6.1/include/linux/lockd/lockd.h	2004-02-02 10:28:13.000000000 +0100
@@ -48,7 +48,8 @@ struct nlm_host {
 				h_server     : 1, /* server side, not client side */
 				h_inuse      : 1,
 				h_killed     : 1,
-				h_monitored  : 1;
+				h_monitored  : 1,
+				h_rebooted   : 1;
 	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
 	u32			h_state;	/* pseudo-state counter */
 	u32			h_nsmstate;	/* true remote NSM state */
@@ -121,6 +122,9 @@ extern struct svc_procedure	nlmsvc_proce
 #ifdef CONFIG_LOCKD_V4
 extern struct svc_procedure	nlmsvc_procedures4[];
 #endif
+#ifdef CONFIG_STATD
+extern struct svc_procedure	nsmsvc_procedures[];
+#endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 
@@ -150,6 +154,7 @@ struct nlm_host * nlm_get_host(struct nl
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 extern struct nlm_host *nlm_find_client(void);
+extern void	  nlm_host_rebooted(struct sockaddr_in *, u32);
 
 
 /*
diff -pNaur linux-2.6.1.statd/include/linux/lockd/sm_inter.h linux-2.6.1/include/linux/lockd/sm_inter.h
--- linux-2.6.1.statd/include/linux/lockd/sm_inter.h	2004-01-09 07:59:42.000000000 +0100
+++ linux-2.6.1/include/linux/lockd/sm_inter.h	2004-02-02 10:28:29.000000000 +0100
@@ -19,6 +19,7 @@
 #define SM_NOTIFY	6
 
 #define SM_MAXSTRLEN	1024
+#define SMSVC_XDRSIZE	sizeof(struct nsm_args)
 
 /*
  * Arguments for all calls to statd
@@ -29,6 +30,7 @@ struct nsm_args {
 	u32		vers;
 	u32		proc;
 	u32		proto;		/* protocol (udp/tcp) plus server/client flag */
+	u32		state;		/* in NOTIFY calls */
 };
 
 /*
@@ -39,6 +41,7 @@ struct nsm_res {
 	u32		state;
 };
 
+extern int	nsm_init(void);
 int		nsm_monitor(struct nlm_host *);
 int		nsm_unmonitor(struct nlm_host *);
 extern u32	nsm_local_state;
diff -pNaur linux-2.6.1.statd/net/sunrpc/svc.c linux-2.6.1/net/sunrpc/svc.c
--- linux-2.6.1.statd/net/sunrpc/svc.c	2004-02-02 10:27:46.000000000 +0100
+++ linux-2.6.1/net/sunrpc/svc.c	2004-02-02 10:28:13.000000000 +0100
@@ -221,22 +221,27 @@ svc_register(struct svc_serv *serv, int 
 
 	progp = serv->sv_program;
 
-	dprintk("RPC: svc_register(%s, %s, %d)\n",
-		progp->pg_name, proto == IPPROTO_UDP? "udp" : "tcp", port);
-
 	if (!port)
 		clear_thread_flag(TIF_SIGPENDING);
 
-	for (i = 0; i < progp->pg_nvers; i++) {
-		if (progp->pg_vers[i] == NULL)
-			continue;
-		error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
-		if (error < 0)
-			break;
-		if (port && !dummy) {
-			error = -EACCES;
-			break;
+	while (progp) {
+		dprintk("RPC: svc_register(%s, %s, %d)\n",
+			progp->pg_name,
+			proto == IPPROTO_UDP?  "udp" : "tcp",
+			port);
+
+		for (i = 0; i < progp->pg_nvers; i++) {
+			if (progp->pg_vers[i] == NULL)
+				continue;
+			error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
+			if (error < 0)
+				break;
+			if (port && !dummy) {
+				error = -EACCES;
+				break;
+			}
 		}
+		progp = progp->pg_next;
 	}
 
 	if (!port) {

--s/l3CgOIzMHHjg/5--


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
