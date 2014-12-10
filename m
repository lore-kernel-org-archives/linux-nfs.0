Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:34851 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932721AbaLJTIR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:17 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so2411840qap.8
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:17 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 06/16] sunrpc: move pool_mode definitions into svc.h
Date: Wed, 10 Dec 2014 14:07:50 -0500
Message-Id: <1418238480-18857-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In later patches, we're going to need to allow code external to svc.c
to figure out what pool_mode is in use. Move these definitions into
svc.h to prepare for that.

Also, make the svc_pool_map object available and exported so that other
modules can peek in there to get insight into what pool mode is in use.
Likewise, export svc_pool_map_get/put function to make it safe to do so.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h | 25 +++++++++++++++++++++++++
 net/sunrpc/svc.c           | 31 +++++++------------------------
 2 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5e172c8329f8..28e5f5716a87 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -428,6 +428,29 @@ struct svc_procedure {
 };
 
 /*
+ * Mode for mapping cpus to pools.
+ */
+enum {
+	SVC_POOL_AUTO = -1,	/* choose one of the others */
+	SVC_POOL_GLOBAL,	/* no mapping, just a single global pool
+				 * (legacy & UP mode) */
+	SVC_POOL_PERCPU,	/* one pool per cpu */
+	SVC_POOL_PERNODE	/* one pool per numa node */
+};
+
+struct svc_pool_map {
+	int count;			/* How many svc_servs use us */
+	int mode;			/* Note: int not enum to avoid
+					 * warnings about "enumeration value
+					 * not handled in switch" */
+	unsigned int npools;
+	unsigned int *pool_to;		/* maps pool id to cpu or node */
+	unsigned int *to_pool;		/* maps cpu or node to pool id */
+};
+
+extern struct svc_pool_map svc_pool_map;
+
+/*
  * Function prototypes.
  */
 int svc_rpcb_setup(struct svc_serv *serv, struct net *net);
@@ -438,6 +461,8 @@ struct svc_serv *svc_create(struct svc_program *, unsigned int,
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
+unsigned int	   svc_pool_map_get(void);
+void		   svc_pool_map_put(void);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 			struct svc_serv_ops *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 9b4b4d8d109a..04c083a53121 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -36,34 +36,17 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net);
 
 #define svc_serv_is_pooled(serv)    ((serv)->sv_ops->svo_function)
 
-/*
- * Mode for mapping cpus to pools.
- */
-enum {
-	SVC_POOL_AUTO = -1,	/* choose one of the others */
-	SVC_POOL_GLOBAL,	/* no mapping, just a single global pool
-				 * (legacy & UP mode) */
-	SVC_POOL_PERCPU,	/* one pool per cpu */
-	SVC_POOL_PERNODE	/* one pool per numa node */
-};
 #define SVC_POOL_DEFAULT	SVC_POOL_GLOBAL
 
 /*
  * Structure for mapping cpus to pools and vice versa.
  * Setup once during sunrpc initialisation.
  */
-static struct svc_pool_map {
-	int count;			/* How many svc_servs use us */
-	int mode;			/* Note: int not enum to avoid
-					 * warnings about "enumeration value
-					 * not handled in switch" */
-	unsigned int npools;
-	unsigned int *pool_to;		/* maps pool id to cpu or node */
-	unsigned int *to_pool;		/* maps cpu or node to pool id */
-} svc_pool_map = {
-	.count = 0,
+struct svc_pool_map svc_pool_map = {
 	.mode = SVC_POOL_DEFAULT
 };
+EXPORT_SYMBOL_GPL(svc_pool_map);
+
 static DEFINE_MUTEX(svc_pool_map_mutex);/* protects svc_pool_map.count only */
 
 static int
@@ -236,7 +219,7 @@ svc_pool_map_init_pernode(struct svc_pool_map *m)
  * vice versa).  Initialise the map if we're the first user.
  * Returns the number of pools.
  */
-static unsigned int
+unsigned int
 svc_pool_map_get(void)
 {
 	struct svc_pool_map *m = &svc_pool_map;
@@ -271,7 +254,7 @@ svc_pool_map_get(void)
 	mutex_unlock(&svc_pool_map_mutex);
 	return m->npools;
 }
-
+EXPORT_SYMBOL_GPL(svc_pool_map_get);
 
 /*
  * Drop a reference to the global map of cpus to pools.
@@ -280,7 +263,7 @@ svc_pool_map_get(void)
  * mode using the pool_mode module option without
  * rebooting or re-loading sunrpc.ko.
  */
-static void
+void
 svc_pool_map_put(void)
 {
 	struct svc_pool_map *m = &svc_pool_map;
@@ -297,7 +280,7 @@ svc_pool_map_put(void)
 
 	mutex_unlock(&svc_pool_map_mutex);
 }
-
+EXPORT_SYMBOL_GPL(svc_pool_map_put);
 
 static int svc_pool_map_get_node(unsigned int pidx)
 {
-- 
2.1.0

