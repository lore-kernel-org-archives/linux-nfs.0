From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 5 of 5] knfsd: remove nfsd threadstats
Date: Tue, 08 Aug 2006 14:08:40 +1000
Message-ID: <1155010120.29877.239.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAItc-00029c-7r
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:08:48 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIta-000778-Da
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:08:48 -0700
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

knfsd: remove the nfsd thread busy histogram (the 'th' line
in /proc/net/rc/nfsd) because the questionable data it provides
is not worth the scalability impact of calculating it.  It
suffers from three major issues:

1. update_thread_usage() increments buckets by call service
   time or call arrival time...in jiffies.  On lightly loaded
   machines, call service times are usually < 1 jiffy; on
   heavily loaded machines call arrival times will be << 1 jiffy.
   So a large portion of the updates to the buckets are rounded
   down to zero, and the histogram is undercounting.

2. As seen recently on the nfs mailing list, the format in which
   the histogram is presented is cryptic, difficult to explain,
   and difficult to use.

3. Updating the histogram requires taking a global spinlock and
   dirtying the global variables nfsd_last_call, nfsd_busy, and
   nfsdstats twice on every RPC call, which is a significant
   scaling limitation.

Testing on a 4 CPU 4 NIC Altix using 4 IRIX clients each doing
1K streaming reads at full line rate, shows the stats update code
(inlined into nfsd()) takes about 1.7% of each CPU.  This patch drops
the contribution from nfsd() into the profile noise.



Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfssvc.c           |   32 --------------------------------
 fs/nfsd/stats.c            |    9 +--------
 include/linux/nfsd/stats.h |    4 ----
 3 files changed, 1 insertion(+), 44 deletions(-)

Index: linux-2.6.18-rc2/fs/nfsd/nfssvc.c
===================================================================
--- linux-2.6.18-rc2.orig/fs/nfsd/nfssvc.c	2006-08-04 16:09:30.526634953 +1000
+++ linux-2.6.18-rc2/fs/nfsd/nfssvc.c	2006-08-04 16:11:02.214864181 +1000
@@ -53,9 +53,6 @@ extern struct svc_program	nfsd_program;
 static void			nfsd(struct svc_rqst *rqstp);
 struct timeval			nfssvc_boot;
        struct svc_serv 		*nfsd_serv;
-static atomic_t			nfsd_busy;
-static unsigned long		nfsd_last_call;
-static DEFINE_SPINLOCK(nfsd_call_lock);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
@@ -199,7 +196,6 @@ int nfsd_create_serv(void)
 		return 0;
 	}
 
-	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, NFSD_BUFSIZE,
 				      nfsd_last_thread, nfsd,
 				      SIG_NOCLEAN, THIS_MODULE);
@@ -347,26 +343,6 @@ nfsd_svc(unsigned short port, int nrserv
 	return error;
 }
 
-static inline void
-update_thread_usage(int busy_threads)
-{
-	unsigned long prev_call;
-	unsigned long diff;
-	int decile;
-
-	spin_lock(&nfsd_call_lock);
-	prev_call = nfsd_last_call;
-	nfsd_last_call = jiffies;
-	decile = busy_threads*10/nfsdstats.th_cnt;
-	if (decile>0 && decile <= 10) {
-		diff = nfsd_last_call - prev_call;
-		if ( (nfsdstats.th_usage[decile-1] += diff) >= NFSD_USAGE_WRAP)
-			nfsdstats.th_usage[decile-1] -= NFSD_USAGE_WRAP;
-		if (decile == 10)
-			nfsdstats.th_fullcnt++;
-	}
-	spin_unlock(&nfsd_call_lock);
-}
 
 /*
  * This is the NFS server kernel thread
@@ -398,8 +374,6 @@ nfsd(struct svc_rqst *rqstp)
 	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
 	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
 
-	nfsdstats.th_cnt++;
-
 	rqstp->rq_task = current;
 
 	unlock_kernel();
@@ -427,8 +401,6 @@ nfsd(struct svc_rqst *rqstp)
 			;
 		if (err < 0)
 			break;
-		update_thread_usage(atomic_read(&nfsd_busy));
-		atomic_inc(&nfsd_busy);
 
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
@@ -440,8 +412,6 @@ nfsd(struct svc_rqst *rqstp)
 
 		/* Unlock export hash tables */
 		exp_readunlock();
-		update_thread_usage(atomic_read(&nfsd_busy));
-		atomic_dec(&nfsd_busy);
 	}
 
 	if (err != -EINTR) {
@@ -460,8 +430,6 @@ nfsd(struct svc_rqst *rqstp)
 
 	lock_kernel();
 
-	nfsdstats.th_cnt --;
-
 out:
 	/* Release the thread */
 	svc_exit_thread(rqstp);
Index: linux-2.6.18-rc2/fs/nfsd/stats.c
===================================================================
--- linux-2.6.18-rc2.orig/fs/nfsd/stats.c	2006-07-16 07:53:08.000000000 +1000
+++ linux-2.6.18-rc2/fs/nfsd/stats.c	2006-08-04 16:11:02.218863668 +1000
@@ -55,16 +55,9 @@ static int nfsd_proc_show(struct seq_fil
 		      nfsdstats.fh_nocache_nondir,
 		      nfsdstats.io_read,
 		      nfsdstats.io_write);
-	/* thread usage: */
-	seq_printf(seq, "th %u %u", nfsdstats.th_cnt, nfsdstats.th_fullcnt);
-	for (i=0; i<10; i++) {
-		unsigned int jifs = nfsdstats.th_usage[i];
-		unsigned int sec = jifs / HZ, msec = (jifs % HZ)*1000/HZ;
-		seq_printf(seq, " %u.%03u", sec, msec);
-	}
 
 	/* newline and ra-cache */
-	seq_printf(seq, "\nra %u", nfsdstats.ra_size);
+	seq_printf(seq, "ra %u", nfsdstats.ra_size);
 	for (i=0; i<11; i++)
 		seq_printf(seq, " %u", nfsdstats.ra_depth[i]);
 	seq_putc(seq, '\n');
Index: linux-2.6.18-rc2/include/linux/nfsd/stats.h
===================================================================
--- linux-2.6.18-rc2.orig/include/linux/nfsd/stats.h	2006-07-16 07:53:08.000000000 +1000
+++ linux-2.6.18-rc2/include/linux/nfsd/stats.h	2006-08-04 16:11:02.234861613 +1000
@@ -22,10 +22,6 @@ struct nfsd_stats {
 	unsigned int	fh_nocache_nondir;	/* filehandle not found in dcache */
 	unsigned int	io_read;	/* bytes returned to read requests */
 	unsigned int	io_write;	/* bytes passed in write requests */
-	unsigned int	th_cnt;		/* number of available threads */
-	unsigned int	th_usage[10];	/* number of ticks during which n perdeciles
-					 * of available threads were in use */
-	unsigned int	th_fullcnt;	/* number of times last free thread was used */
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */


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
