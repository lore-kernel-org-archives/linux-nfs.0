From: Greg Banks <gnb@sgi.com>
Subject: [PATCH] provide sunrpc pool_mode module option, take 2
Date: Fri, 23 Feb 2007 23:12:44 +1100
Message-ID: <20070223121244.GP19690@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKZIC-00018J-Va
	for nfs@lists.sourceforge.net; Fri, 23 Feb 2007 04:12:53 -0800
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=netops-testserver-4.corp.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HKZIE-0007pl-L7
	for nfs@lists.sourceforge.net; Fri, 23 Feb 2007 04:12:55 -0800
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

Provide a module param "pool_mode" for sunrpc.ko which allows a
sysadmin to choose the mode for mapping NFS thread service pools
to CPUs.  Values are:

auto	    choose a mapping mode heuristically
global	    (default, same as the pre-2.6.19 code) a single global pool
percpu	    one pool per CPU
pernode	    one pool per NUMA node

Note that since 2.6.19 the hardcoded behaviour has been "auto",
this patch makes the default "global".

The pool mode can be changed after boot/modprobe using /sys, if the
NFS and lockd services have been shut down.  A useful side effect of
this change is to fix a small memory leak when unloading the module.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 Documentation/kernel-parameters.txt |   16 ++
 net/sunrpc/svc.c                    |  143 ++++++++++++++++++++-----
 2 files changed, 135 insertions(+), 24 deletions(-)

Index: linux/net/sunrpc/svc.c
===================================================================
--- linux.orig/net/sunrpc/svc.c	2007-02-22 16:30:19.108216194 +1100
+++ linux/net/sunrpc/svc.c	2007-02-23 23:01:54.129092314 +1100
@@ -27,22 +27,26 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
+#define svc_serv_is_pooled(serv)    ((serv)->sv_function)
+
 /*
  * Mode for mapping cpus to pools.
  */
 enum {
-	SVC_POOL_NONE = -1,	/* uninitialised, choose one of the others */
+	SVC_POOL_AUTO = -1,	/* choose one of the others */
 	SVC_POOL_GLOBAL,	/* no mapping, just a single global pool
 				 * (legacy & UP mode) */
 	SVC_POOL_PERCPU,	/* one pool per cpu */
 	SVC_POOL_PERNODE	/* one pool per numa node */
 };
+#define SVC_POOL_DEFAULT	SVC_POOL_GLOBAL
 
 /*
  * Structure for mapping cpus to pools and vice versa.
  * Setup once during sunrpc initialisation.
  */
 static struct svc_pool_map {
+	int count;			/* How many svc_servs use us */
 	int mode;			/* Note: int not enum to avoid
 					 * warnings about "enumeration value
 					 * not handled in switch" */
@@ -50,9 +54,63 @@ static struct svc_pool_map {
 	unsigned int *pool_to;		/* maps pool id to cpu or node */
 	unsigned int *to_pool;		/* maps cpu or node to pool id */
 } svc_pool_map = {
-	.mode = SVC_POOL_NONE
+	.count = 0,
+	.mode = SVC_POOL_DEFAULT
 };
+static DEFINE_MUTEX(svc_pool_map_mutex);/* protects svc_pool_map.count only */
 
+static int
+param_set_pool_mode(const char *val, struct kernel_param *kp)
+{
+	int *ip = (int *)kp->arg;
+	struct svc_pool_map *m = &svc_pool_map;
+	int err;
+
+	mutex_lock(&svc_pool_map_mutex);
+
+	err = -EBUSY;
+	if (m->count)
+		goto out;
+
+	err = 0;
+	if (!strncmp(val, "auto", 4))
+		*ip = SVC_POOL_AUTO;
+	else if (!strncmp(val, "global", 6))
+		*ip = SVC_POOL_GLOBAL;
+	else if (!strncmp(val, "percpu", 6))
+		*ip = SVC_POOL_PERCPU;
+	else if (!strncmp(val, "pernode", 7))
+		*ip = SVC_POOL_PERNODE;
+	else
+		err = -EINVAL;
+
+out:
+	mutex_unlock(&svc_pool_map_mutex);
+	return err;
+}
+
+static int
+param_get_pool_mode(char *buf, struct kernel_param *kp)
+{
+	int *ip = (int *)kp->arg;
+
+	switch (*ip)
+	{
+	case SVC_POOL_AUTO:
+		return strlcpy(buf, "auto", 20);
+	case SVC_POOL_GLOBAL:
+		return strlcpy(buf, "global", 20);
+	case SVC_POOL_PERCPU:
+		return strlcpy(buf, "percpu", 20);
+	case SVC_POOL_PERNODE:
+		return strlcpy(buf, "pernode", 20);
+	default:
+		return sprintf(buf, "%d", *ip);
+	}
+}
+
+module_param_call(pool_mode, param_set_pool_mode, param_get_pool_mode,
+		 &svc_pool_map.mode, 0644);
 
 /*
  * Detect best pool mapping mode heuristically,
@@ -166,18 +224,25 @@ svc_pool_map_init_pernode(struct svc_poo
 
 
 /*
- * Build the global map of cpus to pools and vice versa.
+ * Add a reference to the global map of cpus to pools (and
+ * vice versa).  Initialise the map if we're the first user.
+ * Returns the number of pools.
  */
 static unsigned int
-svc_pool_map_init(void)
+svc_pool_map_get(void)
 {
 	struct svc_pool_map *m = &svc_pool_map;
 	int npools = -1;
 
-	if (m->mode != SVC_POOL_NONE)
+	mutex_lock(&svc_pool_map_mutex);
+
+	if (m->count++) {
+		mutex_unlock(&svc_pool_map_mutex);
 		return m->npools;
+	}
 
-	m->mode = svc_pool_map_choose_mode();
+	if (m->mode == SVC_POOL_AUTO)
+		m->mode = svc_pool_map_choose_mode();
 
 	switch (m->mode) {
 	case SVC_POOL_PERCPU:
@@ -195,9 +260,36 @@ svc_pool_map_init(void)
 	}
 	m->npools = npools;
 
+	mutex_unlock(&svc_pool_map_mutex);
 	return m->npools;
 }
 
+
+/*
+ * Drop a reference to the global map of cpus to pools.
+ * When the last reference is dropped, the map data is
+ * freed; this allows the sysadmin to change the pool
+ * mode using the pool_mode module option without
+ * rebooting or re-loading sunrpc.ko.
+ */
+static void
+svc_pool_map_put(void)
+{
+	struct svc_pool_map *m = &svc_pool_map;
+
+	mutex_lock(&svc_pool_map_mutex);
+
+	if (!--m->count) {
+		m->mode = SVC_POOL_DEFAULT;
+		kfree(m->to_pool);
+		kfree(m->pool_to);
+		m->npools = 0;
+	}
+
+	mutex_unlock(&svc_pool_map_mutex);
+}
+
+
 /*
  * Set the current thread's cpus_allowed mask so that it
  * will only run on cpus in the given pool.
@@ -212,10 +304,9 @@ svc_pool_map_set_cpumask(unsigned int pi
 
 	/*
 	 * The caller checks for sv_nrpools > 1, which
-	 * implies that we've been initialized and the
-	 * map mode is not NONE.
+	 * implies that we've been initialized.
 	 */
-	BUG_ON(m->mode == SVC_POOL_NONE);
+	BUG_ON(m->count == 0);
 
 	switch (m->mode)
 	{
@@ -246,18 +337,19 @@ svc_pool_for_cpu(struct svc_serv *serv, 
 	unsigned int pidx = 0;
 
 	/*
-	 * SVC_POOL_NONE happens in a pure client when
+	 * An uninitialised map happens in a pure client when
 	 * lockd is brought up, so silently treat it the
 	 * same as SVC_POOL_GLOBAL.
 	 */
-
-	switch (m->mode) {
-	case SVC_POOL_PERCPU:
-		pidx = m->to_pool[cpu];
-		break;
-	case SVC_POOL_PERNODE:
-		pidx = m->to_pool[cpu_to_node(cpu)];
-		break;
+	if (svc_serv_is_pooled(serv)) {
+		switch (m->mode) {
+		case SVC_POOL_PERCPU:
+			pidx = m->to_pool[cpu];
+			break;
+		case SVC_POOL_PERNODE:
+			pidx = m->to_pool[cpu_to_node(cpu)];
+			break;
+		}
 	}
 	return &serv->sv_pools[pidx % serv->sv_nrpools];
 }
@@ -347,7 +439,7 @@ svc_create_pooled(struct svc_program *pr
 		  svc_thread_fn func, int sig, struct module *mod)
 {
 	struct svc_serv *serv;
-	unsigned int npools = svc_pool_map_init();
+	unsigned int npools = svc_pool_map_get();
 
 	serv = __svc_create(prog, bufsize, npools, shutdown);
 
@@ -397,9 +489,12 @@ svc_destroy(struct svc_serv *serv)
 				  sk_list);
 		svc_delete_socket(svsk);
 	}
-	
+
 	cache_clean_deferred(serv);
 
+	if (svc_serv_is_pooled(serv))
+		svc_pool_map_put();
+
 	/* Unregister service with the portmapper */
 	svc_register(serv, 0, 0);
 	kfree(serv->sv_pools);
@@ -415,7 +510,7 @@ svc_init_buffer(struct svc_rqst *rqstp, 
 {
 	int pages;
 	int arghi;
-	
+
 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
 				       * We assume one is at most one page
 				       */
@@ -636,7 +731,7 @@ svc_exit_thread(struct svc_rqst *rqstp)
 
 /*
  * Register an RPC service with the local portmapper.
- * To unregister a service, call this routine with 
+ * To unregister a service, call this routine with
  * proto and port == 0.
  */
 int
@@ -709,7 +804,7 @@ svc_process(struct svc_rqst *rqstp)
 		goto err_short_len;
 
 	/* setup response xdr_buf.
-	 * Initially it has just one page 
+	 * Initially it has just one page
 	 */
 	rqstp->rq_resused = 1;
 	resv->iov_base = page_address(rqstp->rq_respages[0]);
@@ -811,7 +906,7 @@ svc_process(struct svc_rqst *rqstp)
 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
 	memset(rqstp->rq_resp, 0, procp->pc_ressize);
 
-	/* un-reserve some of the out-queue now that we have a 
+	/* un-reserve some of the out-queue now that we have a
 	 * better idea of reply size
 	 */
 	if (procp->pc_xdrressize)
Index: linux/Documentation/kernel-parameters.txt
===================================================================
--- linux.orig/Documentation/kernel-parameters.txt	2007-02-05 05:44:54.000000000 +1100
+++ linux/Documentation/kernel-parameters.txt	2007-02-23 23:03:06.427516877 +1100
@@ -1649,6 +1649,22 @@ and is between 256 and 4096 characters. 
 	stifb=		[HW]
 			Format: bpp:<bpp1>[:<bpp2>[:<bpp3>...]]
 
+	sunrpc.pool_mode=
+			[NFS]
+			Control how the NFS server code allocates CPUs to
+			service thread pools.  Depending on how many NICs
+			you have and where their interrupts are bound, this
+			option will affect which CPUs will do NFS serving.
+			Note: this parameter cannot be changed while the
+			NFS server is running.
+
+			auto	    the server chooses an appropriate mode
+				    automatically using heuristics
+			global	    a single global pool contains all CPUs
+			percpu	    one pool for each CPU
+			pernode	    one pool for each NUMA node (equivalent
+				    to global on non-NUMA machines)
+
 	swiotlb=	[IA-64] Number of I/O TLB slabs
 
 	switches=	[HW,M68k]


Greg.
-- 
Greg (not Dave) Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
