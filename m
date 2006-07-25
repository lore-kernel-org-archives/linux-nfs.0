From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 18:02:32 +1000
Message-ID: <17605.53272.237011.603771@cse.unsw.edu.au>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Hso-0000kT-Ji
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 01:03:14 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5Hsm-0006LX-3g
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 01:03:15 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Neil Brown on Tuesday July 25
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

On Tuesday July 25, neilb@suse.de wrote:
> 
> Thanks.  I now have all those patches applied.
> 
> I'll post the interesting revisions in a little while.

You can see them all at 
  http://cgi.cse.unsw.edu.au/~neilb/patches/linux-devel/2.6/2006-07-25-07/

The following patch removes some of the #if's.
Do you agree with it?

NeilBrown
---------------------------------------
Remove some #if tests.

The protected code should just compile away without needing
the #if (I hope).

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svc.c |   39 ++++++++++++++-------------------------
 1 file changed, 14 insertions(+), 25 deletions(-)

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-07-25 17:32:10.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-07-25 17:31:14.000000000 +1000
@@ -28,7 +28,6 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 #define RPC_PARANOIA 1
 
-
 #if SVC_HAVE_MULTIPLE_POOLS
 
 struct svc_pool_map svc_pool_map = { .mode = -1, .init = 0 };
@@ -54,7 +53,6 @@ svc_pool_map_init(void)
 		 * Detect best pool mapping mode heuristically.
 		 */
 		m->mode = 0;	/* default: one global pool */
-#ifdef CONFIG_NUMA
 		if (num_online_nodes() > 1) {
 			/*
 			 * Actually have multiple NUMA nodes,
@@ -73,14 +71,6 @@ svc_pool_map_init(void)
 				m->mode = 1;
 			}
 		}
-#else
-		if (num_online_cpus() > 1) {
-			/*
-			 * Plain SMP with multiple CPUs online.
-			 */
-			m->mode = 1;
-		}
-#endif
 	}
 
 	switch (m->mode) {
@@ -156,8 +146,7 @@ static int
 svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
 {
 	struct svc_pool_map *m = &svc_pool_map;
-	unsigned int node;
-	unsigned int cpu;
+	unsigned int node; /* or cpu */
 
 	BUG_ON(!m->init);
 
@@ -167,9 +156,9 @@ svc_pool_map_set_cpumask(unsigned int pi
 	case 0:
 		return 0;
 	case 1:
-		cpu = m->pool_to_cpu[pidx];
+		node = m->pool_to_cpu[pidx];
 		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, cpumask_of_cpu(cpu));
+		set_cpus_allowed(current, cpumask_of_cpu(node));
 		return 1;
 #ifdef CONFIG_NUMA
 	case 2:
@@ -181,6 +170,16 @@ svc_pool_map_set_cpumask(unsigned int pi
 	}
 }
 
+#else
+static inline int svc_pool_map_init(void)
+{
+	return 1;
+}
+static inline int
+svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
+{
+	return 0;
+}
 #endif /* SVC_HAVE_MULTIPLE_POOLS */
 
 /*
@@ -265,11 +264,7 @@ svc_create_pooled(struct svc_program *pr
 		  svc_thread_fn func, int sig, struct module *mod)
 {
 	struct svc_serv *serv;
-	unsigned int npools = 1;
-
-#if SVC_HAVE_MULTIPLE_POOLS
-	npools = svc_pool_map_init();
-#endif
+	unsigned int npools = svc_pool_map_init();
 
 	serv = __svc_create(prog, bufsize, npools, shutdown);
 
@@ -382,10 +377,8 @@ __svc_create_thread(svc_thread_fn func, 
 {
 	struct svc_rqst	*rqstp;
 	int		error = -ENOMEM;
-#if SVC_HAVE_MULTIPLE_POOLS
 	int		have_oldmask = 0;
 	cpumask_t	oldmask;
-#endif
 
 	rqstp = kmalloc(sizeof(*rqstp), GFP_KERNEL);
 	if (!rqstp)
@@ -407,17 +400,13 @@ __svc_create_thread(svc_thread_fn func, 
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
-#if SVC_HAVE_MULTIPLE_POOLS
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
-#endif
 
 	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
 
-#if SVC_HAVE_MULTIPLE_POOLS
 	if (have_oldmask)
 		set_cpus_allowed(current, oldmask);
-#endif
 
 	if (error < 0)
 		goto out_thread;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
