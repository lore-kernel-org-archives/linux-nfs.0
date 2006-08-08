From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 4 of 5] knfsd: add RPC pool thread stats
Date: Tue, 08 Aug 2006 14:07:56 +1000
Message-ID: <1155010075.29877.237.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIsu-00028a-JF
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:08:04 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIsu-0006yK-Ml
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:08:05 -0700
To: Neil Brown <neilb@suse.de>
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

knfsd: Add /proc/fs/nfsd/pool_stats to export to userspace various
statistics about the operation of rpc server thread pools.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfsctl.c           |   12 ++++
 fs/nfsd/nfssvc.c           |    5 +
 include/linux/sunrpc/svc.h |   11 +++
 net/sunrpc/sunrpc_syms.c   |    1 
 net/sunrpc/svcsock.c       |   96 +++++++++++++++++++++++++++++++++-
 5 files changed, 124 insertions(+), 1 deletion(-)

Index: linux-2.6.18-rc2/fs/nfsd/nfsctl.c
===================================================================
--- linux-2.6.18-rc2.orig/fs/nfsd/nfsctl.c	2006-08-03 13:30:34.512176399 +1000
+++ linux-2.6.18-rc2/fs/nfsd/nfsctl.c	2006-08-04 16:09:30.526634953 +1000
@@ -55,6 +55,7 @@ enum {
 	NFSD_Fh,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
+	NFSD_Pool_Stats,
 	NFSD_Versions,
 	NFSD_Ports,
 	/*
@@ -160,6 +161,16 @@ static const struct file_operations expo
 	.release	= seq_release,
 };
 
+extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
+
+static struct file_operations pool_stats_operations = {
+	.owner		= THIS_MODULE,
+	.open		= nfsd_pool_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 /*----------------------------------------------------------------------------*/
 /*
  * payload - write methods
@@ -611,6 +622,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
Index: linux-2.6.18-rc2/fs/nfsd/nfssvc.c
===================================================================
--- linux-2.6.18-rc2.orig/fs/nfsd/nfssvc.c	2006-08-03 13:30:34.516175879 +1000
+++ linux-2.6.18-rc2/fs/nfsd/nfssvc.c	2006-08-04 16:09:30.526634953 +1000
@@ -543,3 +543,8 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
 	return 1;
 }
+
+int nfsd_pool_stats_open(struct inode *inode, struct file *file)
+{
+	return svc_pool_stats_open(nfsd_serv, file);
+}
Index: linux-2.6.18-rc2/include/linux/sunrpc/svc.h
===================================================================
--- linux-2.6.18-rc2.orig/include/linux/sunrpc/svc.h	2006-08-04 16:08:35.253729312 +1000
+++ linux-2.6.18-rc2/include/linux/sunrpc/svc.h	2006-08-04 16:09:30.586627253 +1000
@@ -23,6 +23,15 @@
  */
 typedef void		(*svc_thread_fn)(struct svc_rqst *);
 
+/* statistics for svc_pool structures */
+struct svc_pool_stats {
+	unsigned long	packets;
+	unsigned long	sockets_queued;
+	unsigned long	threads_woken;
+	unsigned long	overloads_avoided;
+	unsigned long	threads_timedout;
+};
+
 /*
  *
  * RPC service thread pool.
@@ -41,6 +50,7 @@ struct svc_pool {
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
 	struct list_head	sp_all_threads;	/* all server threads */
 	int			sp_nwaking;	/* number of threads woken but not yet active */
+	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -386,6 +396,7 @@ struct svc_serv *  svc_create_pooled(str
 			void (*shutdown)(struct svc_serv*),
 			svc_thread_fn, int sig, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
+int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_serv *, struct svc_rqst *);
 int		   svc_register(struct svc_serv *, int, unsigned short);
Index: linux-2.6.18-rc2/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.18-rc2.orig/net/sunrpc/svcsock.c	2006-08-04 16:08:35.297723665 +1000
+++ linux-2.6.18-rc2/net/sunrpc/svcsock.c	2006-08-04 16:09:30.638620579 +1000
@@ -21,6 +21,7 @@
 
 #include <linux/sched.h>
 #include <linux/errno.h>
+#include <linux/smp_lock.h>
 #include <linux/fcntl.h>
 #include <linux/net.h>
 #include <linux/in.h>
@@ -176,6 +177,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		goto out_unlock;
 	}
 
+	pool->sp_stats.packets++;
+
 	/* Mark socket as busy. It will remain in this state until the
 	 * server has processed all pending data and put the socket back
 	 * on the idle list.  We update SK_BUSY atomically because
@@ -210,6 +213,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (pool->sp_nwaking >= SVC_MAX_WAKING) {
 		/* too many threads are runnable and trying to wake up */
 		thread_avail = 0;
+		pool->sp_stats.overloads_avoided++;
 	}
 
 	if (thread_avail) {
@@ -229,11 +233,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		rqstp->rq_waking = 1;
 		pool->sp_nwaking++;
+		pool->sp_stats.threads_woken++;
 		BUG_ON(svsk->sk_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
 		list_add_tail(&svsk->sk_ready, &pool->sp_sockets);
+		pool->sp_stats.sockets_queued++;
 		BUG_ON(svsk->sk_pool != pool);
 	}
 
@@ -1244,6 +1250,7 @@ svc_recv(struct svc_serv *serv, struct s
 	int 			pages;
 	struct xdr_buf		*arg;
 	DECLARE_WAITQUEUE(wait, current);
+	long			time_left;
 
 	dprintk("svc: server %p waiting for data (to = %ld)\n",
 		rqstp, timeout);
@@ -1307,12 +1314,14 @@ svc_recv(struct svc_serv *serv, struct s
 		add_wait_queue(&rqstp->rq_wait, &wait);
 		spin_unlock_bh(&pool->sp_lock);
 
-		schedule_timeout(timeout);
+ 		time_left = schedule_timeout(timeout);
 
 		try_to_freeze();
 
 		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
+		if (!time_left)
+			pool->sp_stats.threads_timedout++;
 
 		if (rqstp->rq_waking) {
 			rqstp->rq_waking = 0;
@@ -1767,3 +1776,88 @@ static struct svc_deferred_req *svc_defe
 	spin_unlock_bh(&svsk->sk_defer_lock);
 	return dr;
 }
+
+
+/*----------------------------------------------------------------------------*/
+
+static void *svc_pool_stats_start(struct seq_file *m, loff_t *pos)
+{
+	unsigned int pidx = (unsigned int)*pos;
+	struct svc_serv *serv = m->private;
+
+	lock_kernel();
+	/* bump up the pseudo refcount while traversing */
+	svc_get(serv);
+	unlock_kernel();
+
+	if (!pidx)
+		return SEQ_START_TOKEN;
+	return (pidx > serv->sv_nrpools ? NULL : &serv->sv_pools[pidx-1]);
+}
+
+static void *svc_pool_stats_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct svc_pool *pool = p;
+	struct svc_serv *serv = m->private;
+
+	if (p == SEQ_START_TOKEN) {
+		pool = &serv->sv_pools[0];
+	} else {
+		unsigned int pidx = (pool - &serv->sv_pools[0]);
+		if (pidx < serv->sv_nrpools-1)
+			pool = &serv->sv_pools[pidx+1];
+		else
+			pool = NULL;
+	}
+	++*pos;
+	return pool;
+}
+
+static void svc_pool_stats_stop(struct seq_file *m, void *p)
+{
+	struct svc_serv *serv = m->private;
+
+	lock_kernel();
+	/* this function really, really should have been called svc_put() */
+	svc_destroy(serv);
+	unlock_kernel();
+}
+
+static int svc_pool_stats_show(struct seq_file *m, void *p)
+{
+	struct svc_pool *pool = p;
+
+	if (p == SEQ_START_TOKEN) {
+		seq_puts(m, "# Version 1.0\n");
+		return 0;
+	}
+
+	seq_printf(m, "id %u\nps %lu %lu %lu %lu %lu\n",
+		pool->sp_id,
+		pool->sp_stats.packets,
+		pool->sp_stats.sockets_queued,
+		pool->sp_stats.threads_woken,
+		pool->sp_stats.overloads_avoided,
+		pool->sp_stats.threads_timedout);
+
+	return 0;
+}
+
+static struct seq_operations svc_pool_stats_seq_ops = {
+	.start	= svc_pool_stats_start,
+	.next	= svc_pool_stats_next,
+	.stop	= svc_pool_stats_stop,
+	.show	= svc_pool_stats_show,
+};
+
+int svc_pool_stats_open(struct svc_serv *serv, struct file *file)
+{
+	int err;
+
+	err = seq_open(file, &svc_pool_stats_seq_ops);
+	if (!err)
+		((struct seq_file *) file->private_data)->private = serv;
+	return err;
+}
+
+/*----------------------------------------------------------------------------*/
Index: linux-2.6.18-rc2/net/sunrpc/sunrpc_syms.c
===================================================================
--- linux-2.6.18-rc2.orig/net/sunrpc/sunrpc_syms.c	2006-08-04 16:00:10.990398061 +1000
+++ linux-2.6.18-rc2/net/sunrpc/sunrpc_syms.c	2006-08-04 16:09:30.638620579 +1000
@@ -76,6 +76,7 @@ EXPORT_SYMBOL(svc_create_thread);
 EXPORT_SYMBOL(svc_create_pooled);
 EXPORT_SYMBOL(svc_set_num_threads);
 EXPORT_SYMBOL(svc_exit_thread);
+EXPORT_SYMBOL(svc_pool_stats_open);
 EXPORT_SYMBOL(svc_destroy);
 EXPORT_SYMBOL(svc_drop);
 EXPORT_SYMBOL(svc_process);

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
