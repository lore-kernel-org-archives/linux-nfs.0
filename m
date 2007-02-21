From: Greg Banks <gnb@sgi.com>
Subject: [PATCH] provide sunrpc pool_mode module option
Date: Thu, 22 Feb 2007 01:58:18 +1100
Message-ID: <20070221145818.GC23394@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJsvO-0004Fa-DZ
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 06:58:30 -0800
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=netops-testserver-4.corp.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJsvO-0007Gv-8w
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 06:58:32 -0800
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


Provide a module option "pool_mode" for sunrpc.ko which allows a
sysadmin to choose the mode for mapping svc_pools to CPUs.  Values are:

auto	    choose a mapping mode heuristically
global	    (default, same as the pre-2.6.19 code) a single global pool
percpu	    one pool per CPU
pernode	    one pool per NUMA node

Note that since 2.6.19 the hardcoded behaviour has been "auto",
this patch makes the default "global".

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svc.c |   76 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 60 insertions(+), 16 deletions(-)

Index: linux/net/sunrpc/svc.c
===================================================================
--- linux.orig/net/sunrpc/svc.c	2007-02-05 05:44:54.000000000 +1100
+++ linux/net/sunrpc/svc.c	2007-02-22 01:17:24.971676217 +1100
@@ -31,7 +31,7 @@
  * Mode for mapping cpus to pools.
  */
 enum {
-	SVC_POOL_NONE = -1,	/* uninitialised, choose one of the others */
+	SVC_POOL_AUTO = -1,	/* choose one of the others */
 	SVC_POOL_GLOBAL,	/* no mapping, just a single global pool
 				 * (legacy & UP mode) */
 	SVC_POOL_PERCPU,	/* one pool per cpu */
@@ -46,13 +46,55 @@ static struct svc_pool_map {
 	int mode;			/* Note: int not enum to avoid
 					 * warnings about "enumeration value
 					 * not handled in switch" */
+	int initialised;
 	unsigned int npools;
 	unsigned int *pool_to;		/* maps pool id to cpu or node */
 	unsigned int *to_pool;		/* maps cpu or node to pool id */
 } svc_pool_map = {
-	.mode = SVC_POOL_NONE
+	.mode = SVC_POOL_GLOBAL,
+	.initialised = 0
 };
 
+static int
+param_set_pool_mode(const char *val, struct kernel_param *kp)
+{
+	int *ip = (int *)kp->arg;
+
+	if (!strcmp(val, "auto"))
+		*ip = SVC_POOL_AUTO;
+	else if (!strcmp(val, "global"))
+		*ip = SVC_POOL_GLOBAL;
+	else if (!strcmp(val, "percpu"))
+		*ip = SVC_POOL_PERCPU;
+	else if (!strcmp(val, "pernode"))
+		*ip = SVC_POOL_PERNODE;
+	else
+		return -EINVAL;
+	return 0;
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
@@ -174,10 +216,12 @@ svc_pool_map_init(void)
 	struct svc_pool_map *m = &svc_pool_map;
 	int npools = -1;
 
-	if (m->mode != SVC_POOL_NONE)
+	if (m->initialised)
 		return m->npools;
+	m->initialised = 1;
 
-	m->mode = svc_pool_map_choose_mode();
+	if (m->mode == SVC_POOL_AUTO)
+		m->mode = svc_pool_map_choose_mode();
 
 	switch (m->mode) {
 	case SVC_POOL_PERCPU:
@@ -212,10 +256,9 @@ svc_pool_map_set_cpumask(unsigned int pi
 
 	/*
 	 * The caller checks for sv_nrpools > 1, which
-	 * implies that we've been initialized and the
-	 * map mode is not NONE.
+	 * implies that we've been initialized.
 	 */
-	BUG_ON(m->mode == SVC_POOL_NONE);
+	BUG_ON(!m->initialised);
 
 	switch (m->mode)
 	{
@@ -246,18 +289,19 @@ svc_pool_for_cpu(struct svc_serv *serv, 
 	unsigned int pidx = 0;
 
 	/*
-	 * SVC_POOL_NONE happens in a pure client when
+	 * !m->initialised happens in a pure client when
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
+	if (m->initialised) {
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
