From: Olaf Kirch <okir@suse.de>
Subject: deadlock in lockd
Date: Thu, 10 Mar 2005 21:44:16 +0100
Message-ID: <20050310204416.GC3424@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="l76fUT7nc3MelDdI"
Cc: Sebastian Hetze <s.hetze@linux-ag.de>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9UW7-0006pf-Dw
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 12:44:23 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D9UW5-0001VD-Gw
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 12:44:23 -0800
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


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

I just debugged a deadlock in lockd in SLES8 (i.e 2.4.21), but
I think the same problem exists in 2.6.

Here's the backtrace courtesy of sysrq:

 lockd         D 00000000  3648   791      1   792     795   783 (L-TLB)
 Call Trace:         [do_schedule+338/608] (36) [__down+131/224] (52) [__down_failed+8/12] (16)
   [.text.lock.svclock+5/150] (04) [vsnprintf+519/1120] (24) [nlm_traverse_files+324/368] (32) [nlmsvc_mark_resources+32/64] (12)
   [nlm_gc_hosts+69/384] (28) [nlm_lookup_host+139/800] (48) [nlmsvc_lookup_host+48/64] (20) [nlmsvc_create_block+145/352] (16)
   [posix_test_lock+132/160] (20) [nlmsvc_lock+222/784] (28) [nlm4svc_retrieve_args+199/288] (40) [nlm4svc_proc_lock+172/256] (44)
   [svc_process+827/1392] (56) [lockd+426/720] (40) [arch_kernel_thread+46/64] (08) [lockd+0/720] (04)

What happens is that nlmsvc_lock takes the f_sema on the file the client wishes to lock,
then calls posix_test_lock, which finds there's a blocking lock. So it calls
nlmsvc_create_block, which calls nlmsvc_lookup_host - and the host code decides
to do a garbage collection pass.

We call nlm_traverse_files, that hits the file we're just trying to lock, and
invokes nlmsvc_traverse_blocks, which will try to down f_sema once more.
And there it hangs...

The attched (untested) patch changes the way we do garbage collection
passes, instead of doing it inside nlm_lookup_host, nlm_gc_hosts is
called from the top-level service loop in lockd now, where we don'T hold any
locks. It looks saner anyway.

Comments?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lockd-gc-deadlock

Index: linux-2.4.21/fs/lockd/host.c
===================================================================
--- linux-2.4.21.orig/fs/lockd/host.c	2005-02-10 10:58:25.000000000 +0100
+++ linux-2.4.21/fs/lockd/host.c	2005-03-10 20:44:43.000000000 +0100
@@ -34,7 +34,7 @@ static int			nrhosts;
 static DECLARE_MUTEX(nlm_host_sema);
 
 
-static void			nlm_gc_hosts(void);
+static void			__nlm_gc_hosts(void);
 
 /*
  * Find an NLM server handle in the cache. If there is none, create it.
@@ -94,9 +94,6 @@ nlm_lookup_host(struct svc_client *clnt,
 	/* Lock hash table */
 	down(&nlm_host_sema);
 
-	if (time_after_eq(jiffies, next_gc))
-		nlm_gc_hosts();
-
 	for (hp = &nlm_hosts[hash]; (host = *hp); hp = &host->h_next) {
 		if (proto && host->h_proto != proto)
 			continue;
@@ -273,7 +270,7 @@ nlm_shutdown_hosts(void)
 	}
 
 	/* Then, perform a garbage collection pass */
-	nlm_gc_hosts();
+	__nlm_gc_hosts();
 	up(&nlm_host_sema);
 
 	/* complain if any hosts are left */
@@ -296,7 +293,7 @@ nlm_shutdown_hosts(void)
  * mark & sweep for resources held by remote clients.
  */
 static void
-nlm_gc_hosts(void)
+__nlm_gc_hosts(void)
 {
 	struct nlm_host	**q, *host;
 	struct rpc_clnt	*clnt;
@@ -341,3 +338,12 @@ nlm_gc_hosts(void)
 	next_gc = jiffies + NLM_HOST_COLLECT;
 }
 
+void
+nlm_gc_hosts()
+{
+	down(&nlm_host_sema);
+	if (time_after_eq(jiffies, next_gc))
+		__nlm_gc_hosts();
+	up(&nlm_host_sema);
+}
+
Index: linux-2.4.21/fs/lockd/svc.c
===================================================================
--- linux-2.4.21.orig/fs/lockd/svc.c	2005-02-10 10:57:58.000000000 +0100
+++ linux-2.4.21/fs/lockd/svc.c	2005-03-10 20:45:53.000000000 +0100
@@ -154,6 +154,9 @@ lockd(struct svc_rqst *rqstp)
 			break;
 		}
 
+		/* Perform hosts cache garbage collection */
+		nlm_gc_hosts();
+
 		dprintk("lockd: request from %08x\n",
 			(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
 
Index: linux-2.4.21/include/linux/lockd/lockd.h
===================================================================
--- linux-2.4.21.orig/include/linux/lockd/lockd.h	2005-02-10 10:57:37.000000000 +0100
+++ linux-2.4.21/include/linux/lockd/lockd.h	2005-03-10 20:43:10.000000000 +0100
@@ -150,6 +150,7 @@ void		  nlm_rebind_host(struct nlm_host 
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
+void		  nlm_gc_hosts(void);
 
 /*
  * Server-side lock handling

--l76fUT7nc3MelDdI--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
