Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30069 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbFHFbY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 01:31:24 -0400
Message-ID: <557528A8.6070404@oracle.com>
Date: Sun, 07 Jun 2015 22:31:20 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V3 6/7] nfsd/sunrpc: move pool_mode definitions into svc.h
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sunrpc: move pool_mode definitions into svc.h
  
In later patches, we're going to need to allow code external to svc.c
to figure out what pool_mode is in use. Move these definitions into
svc.h to prepare for that.
   
Also, make the svc_pool_map object available and exported so that other
modules can peek in there to get insight into what pool mode is in use.
Likewise, export svc_pool_map_get/put function to make it safe to do so.
    
Author: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
---
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 12941f6..758b4eb 100644
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
index 5ae9d63..3c658c4 100644
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
