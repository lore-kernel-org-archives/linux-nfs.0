Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17351 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbFHTLU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 15:11:20 -0400
Message-ID: <5575E8CE.4030805@oracle.com>
Date: Mon, 08 Jun 2015 12:11:10 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V4 7/7] nfsd/sunrpc: factor svc_rqst allocation and freeing
 from sv_nrthreads refcounting
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

In later patches, we'll want to be able to allocate and free svc_rqst
structures without monkeying with the serv->sv_nrthreads refcount.
    
Factor those pieces out of their respective functions.
    
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Acked-by: Jeff Layton <jlayton@primarydata.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
---
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 758b4eb..8203ec0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -458,8 +458,11 @@ void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net);
 int svc_bind(struct svc_serv *serv, struct net *net);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    struct svc_serv_ops *);
+struct svc_rqst *svc_rqst_alloc(struct svc_serv *serv,
+					struct svc_pool *pool, int node);
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
+void		   svc_rqst_free(struct svc_rqst *);
 void		   svc_exit_thread(struct svc_rqst *);
 unsigned int	   svc_pool_map_get(void);
 void		   svc_pool_map_put(void);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3c658c4..2c76f28 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -583,40 +583,52 @@ svc_release_buffer(struct svc_rqst *rqstp)
 }
 
 struct svc_rqst *
-svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
+svc_rqst_alloc(struct svc_serv *serv, struct svc_pool *pool, int node)
 {
 	struct svc_rqst	*rqstp;
 
 	rqstp = kzalloc_node(sizeof(*rqstp), GFP_KERNEL, node);
 	if (!rqstp)
-		goto out_enomem;
+		return rqstp;
 
-	serv->sv_nrthreads++;
 	__set_bit(RQ_BUSY, &rqstp->rq_flags);
 	spin_lock_init(&rqstp->rq_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
-	spin_lock_bh(&pool->sp_lock);
-	pool->sp_nrthreads++;
-	list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
-	spin_unlock_bh(&pool->sp_lock);
 
 	rqstp->rq_argp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
 	if (!rqstp->rq_argp)
-		goto out_thread;
+		goto out_enomem;
 
 	rqstp->rq_resp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
 	if (!rqstp->rq_resp)
-		goto out_thread;
+		goto out_enomem;
 
 	if (!svc_init_buffer(rqstp, serv->sv_max_mesg, node))
-		goto out_thread;
+		goto out_enomem;
 
 	return rqstp;
-out_thread:
-	svc_exit_thread(rqstp);
 out_enomem:
-	return ERR_PTR(-ENOMEM);
+	svc_rqst_free(rqstp);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(svc_rqst_alloc);
+
+struct svc_rqst *
+svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
+{
+	struct svc_rqst	*rqstp;
+
+	rqstp = svc_rqst_alloc(serv, pool, node);
+	if (!rqstp)
+		return ERR_PTR(-ENOMEM);
+
+	serv->sv_nrthreads++;
+	spin_lock_bh(&pool->sp_lock);
+	pool->sp_nrthreads++;
+	list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
+	spin_unlock_bh(&pool->sp_lock);
+	return rqstp;
 }
 EXPORT_SYMBOL_GPL(svc_prepare_thread);
 
@@ -751,15 +763,21 @@ EXPORT_SYMBOL_GPL(svc_set_num_threads);
  * mutex" for the service.
  */
 void
-svc_exit_thread(struct svc_rqst *rqstp)
+svc_rqst_free(struct svc_rqst *rqstp)
 {
-	struct svc_serv	*serv = rqstp->rq_server;
-	struct svc_pool	*pool = rqstp->rq_pool;
-
 	svc_release_buffer(rqstp);
 	kfree(rqstp->rq_resp);
 	kfree(rqstp->rq_argp);
 	kfree(rqstp->rq_auth_data);
+	kfree_rcu(rqstp, rq_rcu_head);
+}
+EXPORT_SYMBOL_GPL(svc_rqst_free);
+
+void
+svc_exit_thread(struct svc_rqst *rqstp)
+{
+	struct svc_serv	*serv = rqstp->rq_server;
+	struct svc_pool	*pool = rqstp->rq_pool;
 
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads--;
@@ -767,7 +785,7 @@ svc_exit_thread(struct svc_rqst *rqstp)
 		list_del_rcu(&rqstp->rq_all);
 	spin_unlock_bh(&pool->sp_lock);
 
-	kfree_rcu(rqstp, rq_rcu_head);
+	svc_rqst_free(rqstp);
 
 	/* Release the server */
 	if (serv)
