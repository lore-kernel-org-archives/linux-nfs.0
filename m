Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:57451 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdHQOfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Aug 2017 10:35:10 -0400
Subject: [PATCH 2/2] lockd: Adjust 61 checks for null pointers
From: SF Markus Elfring <elfring@users.sourceforge.net>
To: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Christoph Hellwig <hch@lst.de>,
        Colin Ian King <colin.king@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
References: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
Message-ID: <e76e873f-f18e-5bdd-cc93-255321b3d98f@users.sourceforge.net>
Date: Thu, 17 Aug 2017 16:34:51 +0200
MIME-Version: 1.0
In-Reply-To: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 17 Aug 2017 16:00:18 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 fs/lockd/clnt4xdr.c | 12 ++++++------
 fs/lockd/clntlock.c | 10 +++++-----
 fs/lockd/clntproc.c | 12 ++++++------
 fs/lockd/clntxdr.c  | 12 ++++++------
 fs/lockd/host.c     | 22 +++++++++++-----------
 fs/lockd/mon.c      | 16 ++++++++--------
 fs/lockd/svc.c      |  4 ++--
 fs/lockd/svc4proc.c |  6 +++---
 fs/lockd/svclock.c  | 14 +++++++-------
 fs/lockd/svcproc.c  |  6 +++---
 fs/lockd/svcshare.c |  2 +-
 fs/lockd/svcsubs.c  |  3 +--
 12 files changed, 59 insertions(+), 60 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index c349fc0f9b80..ec6473d194fd 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -131,7 +131,7 @@ static int decode_netobj(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	length = be32_to_cpup(p++);
 	if (unlikely(length > XDR_MAX_NETOBJ))
@@ -163,7 +163,7 @@ static int decode_cookie(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	length = be32_to_cpup(p++);
 	/* apparently HPUX can return empty cookies */
@@ -172,7 +172,7 @@ static int decode_cookie(struct xdr_stream *xdr,
 	if (length > NLM_MAXCOOKIELEN)
 		goto out_size;
 	p = xdr_inline_decode(xdr, length);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	cookie->len = length;
 	memcpy(cookie->data, p, length);
@@ -234,7 +234,7 @@ static int decode_nlm4_stat(struct xdr_stream *xdr, __be32 *stat)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	if (unlikely(ntohl(*p) > ntohl(nlm4_failed)))
 		goto out_bad_xdr;
@@ -289,7 +289,7 @@ static int decode_nlm4_holder(struct xdr_stream *xdr, struct nlm_res *result)
 	locks_init_lock(fl);
 
 	p = xdr_inline_decode(xdr, 4 + 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	exclusive = be32_to_cpup(p++);
 	lock->svid = be32_to_cpup(p);
@@ -300,7 +300,7 @@ static int decode_nlm4_holder(struct xdr_stream *xdr, struct nlm_res *result)
 		goto out;
 
 	p = xdr_inline_decode(xdr, 8 + 8);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 
 	fl->fl_flags = FL_POSIX;
diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 96c1d14c18f1..ef0cff53dc83 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -64,9 +64,9 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 				   nlm_init->protocol, nlm_version,
 				   nlm_init->hostname, nlm_init->noresvport,
 				   nlm_init->net);
-	if (host == NULL)
+	if (!host)
 		goto out_nohost;
-	if (host->h_rpcclnt == NULL && nlm_bind_host(host) == NULL)
+	if (!host->h_rpcclnt && !nlm_bind_host(host))
 		goto out_nobind;
 
 	host->h_nlmclnt_ops = nlm_init->nlmclnt_ops;
@@ -101,7 +101,7 @@ struct nlm_wait *nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *
 	struct nlm_wait *block;
 
 	block = kmalloc(sizeof(*block), GFP_KERNEL);
-	if (block != NULL) {
+	if (block) {
 		block->b_host = host;
 		block->b_lock = fl;
 		init_waitqueue_head(&block->b_wait);
@@ -116,7 +116,7 @@ struct nlm_wait *nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *
 
 void nlmclnt_finish_block(struct nlm_wait *block)
 {
-	if (block == NULL)
+	if (!block)
 		return;
 	spin_lock(&nlm_blocked_lock);
 	list_del(&block->b_list);
@@ -134,7 +134,7 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 	/* A borken server might ask us to block even if we didn't
 	 * request it. Just say no!
 	 */
-	if (block == NULL)
+	if (!block)
 		return -EAGAIN;
 
 	/* Go to sleep waiting for GRANT callback. Some servers seem
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac313ae5c..d632d1aa6452 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -98,12 +98,12 @@ static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, fl_owner_
 
 	spin_lock(&host->h_lock);
 	res = __nlm_find_lockowner(host, owner);
-	if (res == NULL) {
+	if (!res) {
 		spin_unlock(&host->h_lock);
 		new = kmalloc(sizeof(*new), GFP_KERNEL);
 		spin_lock(&host->h_lock);
 		res = __nlm_find_lockowner(host, owner);
-		if (res == NULL && new != NULL) {
+		if (!res && new) {
 			res = new;
 			atomic_set(&new->count, 1);
 			new->owner = owner;
@@ -142,7 +142,7 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
 
 static void nlmclnt_release_lockargs(struct nlm_rqst *req)
 {
-	WARN_ON_ONCE(req->a_args.lock.fl.fl_ops != NULL);
+	WARN_ON_ONCE(req->a_args.lock.fl.fl_ops);
 }
 
 /**
@@ -160,7 +160,7 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *dat
 	const struct nlmclnt_operations *nlmclnt_ops = host->h_nlmclnt_ops;
 
 	call = nlm_alloc_call(host);
-	if (call == NULL)
+	if (!call)
 		return -ENOMEM;
 
 	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_alloc_call)
@@ -203,7 +203,7 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 
 	for(;;) {
 		call = kzalloc(sizeof(*call), GFP_KERNEL);
-		if (call != NULL) {
+		if (call) {
 			atomic_set(&call->a_count, 1);
 			locks_init_lock(&call->a_args.lock.fl);
 			locks_init_lock(&call->a_res.lock.fl);
@@ -350,7 +350,7 @@ static struct rpc_task *__nlm_async_call(struct nlm_rqst *req, u32 proc, struct
 
 	/* If we have no RPC client yet, create one. */
 	clnt = nlm_bind_host(host);
-	if (clnt == NULL)
+	if (!clnt)
 		goto out_err;
 	msg->rpc_proc = &clnt->cl_procinfo[proc];
 	task_setup_data.rpc_client = clnt;
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 3b4724a6c4ee..e05124b7897c 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -128,7 +128,7 @@ static int decode_netobj(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	length = be32_to_cpup(p++);
 	if (unlikely(length > XDR_MAX_NETOBJ))
@@ -160,7 +160,7 @@ static int decode_cookie(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	length = be32_to_cpup(p++);
 	/* apparently HPUX can return empty cookies */
@@ -169,7 +169,7 @@ static int decode_cookie(struct xdr_stream *xdr,
 	if (length > NLM_MAXCOOKIELEN)
 		goto out_size;
 	p = xdr_inline_decode(xdr, length);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	cookie->len = length;
 	memcpy(cookie->data, p, length);
@@ -229,7 +229,7 @@ static int decode_nlm_stat(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	if (unlikely(ntohl(*p) > ntohl(nlm_lck_denied_grace_period)))
 		goto out_enum;
@@ -283,7 +283,7 @@ static int decode_nlm_holder(struct xdr_stream *xdr, struct nlm_res *result)
 	locks_init_lock(fl);
 
 	p = xdr_inline_decode(xdr, 4 + 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 	exclusive = be32_to_cpup(p++);
 	lock->svid = be32_to_cpup(p);
@@ -294,7 +294,7 @@ static int decode_nlm_holder(struct xdr_stream *xdr, struct nlm_res *result)
 		goto out;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		goto out_overflow;
 
 	fl->fl_flags = FL_POSIX;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index d716c9993a26..1aea490ba19a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -112,13 +112,13 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	struct nlm_host *host = NULL;
 	unsigned long now = jiffies;
 
-	if (nsm != NULL)
+	if (nsm)
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
 		nsm = nsm_get_handle(ni->net, ni->sap, ni->salen,
 					ni->hostname, ni->hostname_len);
-		if (unlikely(nsm == NULL)) {
+		if (unlikely(!nsm)) {
 			dprintk("lockd: %s failed; no nsm handle\n",
 				__func__);
 			goto out;
@@ -126,7 +126,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	}
 
 	host = kmalloc(sizeof(*host), GFP_KERNEL);
-	if (unlikely(host == NULL)) {
+	if (unlikely(!host)) {
 		dprintk("lockd: %s failed; no memory\n", __func__);
 		nsm_release(nsm);
 		goto out;
@@ -185,7 +185,7 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
 	nsm_release(host->h_nsmhandle);
 
 	clnt = host->h_rpcclnt;
-	if (clnt != NULL)
+	if (clnt)
 		rpc_shutdown_client(clnt);
 	kfree(host);
 
@@ -245,7 +245,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 			continue;
 
 		/* Same address. Share an NSM handle if we already have one */
-		if (nsm == NULL)
+		if (!nsm)
 			nsm = host->h_nsmhandle;
 
 		if (host->h_proto != protocol)
@@ -260,7 +260,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 	}
 
 	host = nlm_alloc_host(&ni, nsm);
-	if (unlikely(host == NULL))
+	if (unlikely(!host))
 		goto out;
 
 	hlist_add_head(&host->h_hash, chain);
@@ -282,7 +282,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
  */
 void nlmclnt_release_host(struct nlm_host *host)
 {
-	if (host == NULL)
+	if (!host)
 		return;
 
 	dprintk("lockd: release client host %s\n", host->h_name);
@@ -357,7 +357,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 			continue;
 
 		/* Same address. Share an NSM handle if we already have one */
-		if (nsm == NULL)
+		if (!nsm)
 			nsm = host->h_nsmhandle;
 
 		if (host->h_proto != ni.protocol)
@@ -378,7 +378,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	}
 
 	host = nlm_alloc_host(&ni, nsm);
-	if (unlikely(host == NULL))
+	if (unlikely(!host))
 		goto out;
 
 	memcpy(nlm_srcaddr(host), src_sap, src_len);
@@ -403,7 +403,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
  */
 void nlmsvc_release_host(struct nlm_host *host)
 {
-	if (host == NULL)
+	if (!host)
 		return;
 
 	dprintk("lockd: release server host %s\n", host->h_name);
@@ -547,7 +547,7 @@ void nlm_host_rebooted(const struct net *net, const struct nlm_reboot *info)
 	struct nlm_host	*host;
 
 	nsm = nsm_reboot_lookup(net, info);
-	if (unlikely(nsm == NULL))
+	if (unlikely(!nsm))
 		return;
 
 	/* Mark all hosts tied to this NSM state as having rebooted.
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 9d8166c39c54..3aa95a7ed4a0 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -274,7 +274,7 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	struct nsm_handle *new;
 
 	new = kzalloc(sizeof(*new) + hostname_len + 1, GFP_KERNEL);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return NULL;
 
 	atomic_set(&new->sm_count, 1);
@@ -328,13 +328,13 @@ struct nsm_handle *nsm_get_handle(const struct net *net,
 retry:
 	spin_lock(&nsm_lock);
 
-	if (nsm_use_hostnames && hostname != NULL)
+	if (nsm_use_hostnames && hostname)
 		cached = nsm_lookup_hostname(&ln->nsm_handles,
 					hostname, hostname_len);
 	else
 		cached = nsm_lookup_addr(&ln->nsm_handles, sap);
 
-	if (cached != NULL) {
+	if (cached) {
 		atomic_inc(&cached->sm_count);
 		spin_unlock(&nsm_lock);
 		kfree(new);
@@ -345,7 +345,7 @@ struct nsm_handle *nsm_get_handle(const struct net *net,
 		return cached;
 	}
 
-	if (new != NULL) {
+	if (new) {
 		list_add(&new->sm_link, &ln->nsm_handles);
 		spin_unlock(&nsm_lock);
 		dprintk("lockd: created nsm_handle for %s (%s)\n",
@@ -356,7 +356,7 @@ struct nsm_handle *nsm_get_handle(const struct net *net,
 	spin_unlock(&nsm_lock);
 
 	new = nsm_create_handle(sap, salen, hostname, hostname_len);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return NULL;
 	goto retry;
 }
@@ -379,7 +379,7 @@ struct nsm_handle *nsm_reboot_lookup(const struct net *net,
 	spin_lock(&nsm_lock);
 
 	cached = nsm_lookup_priv(&ln->nsm_handles, &info->priv);
-	if (unlikely(cached == NULL)) {
+	if (unlikely(!cached)) {
 		spin_unlock(&nsm_lock);
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
 				info->len, info->mon);
@@ -496,7 +496,7 @@ static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		return -EIO;
 	resp->status = be32_to_cpup(p++);
 	resp->state = be32_to_cpup(p);
@@ -514,7 +514,7 @@ static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	if (unlikely(!p))
 		return -EIO;
 	resp->state = be32_to_cpup(p);
 
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 726b6cecf430..8a5d894a4f07 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -190,7 +190,7 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
 	struct svc_xprt *xprt;
 
 	xprt = svc_find_xprt(serv, name, net, family, 0);
-	if (xprt == NULL)
+	if (!xprt)
 		return svc_create_xprt(serv, name, net, family, port,
 						SVC_SOCK_DEFAULTS);
 	svc_xprt_put(xprt);
@@ -699,7 +699,7 @@ static int __init init_nlm(void)
 #ifdef CONFIG_SYSCTL
 	err = -ENOMEM;
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
-	if (nlm_sysctl_table == NULL)
+	if (!nlm_sysctl_table)
 		goto err_sysctl;
 #endif
 	err = register_pernet_subsys(&lockd_net_ops);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 82925f17ec45..b16bdd33e5b8 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -38,7 +38,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	*hostp = host;
 
 	/* Obtain file pointer. Not used by FREE_ALL call. */
-	if (filp != NULL) {
+	if (filp) {
 		if ((error = nlm_lookup_file(rqstp, &file, &lock->fh)) != 0)
 			goto no_locks;
 		*filp = file;
@@ -285,12 +285,12 @@ static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc,
 	host = nlmsvc_lookup_host(rqstp,
 				  argp->lock.caller,
 				  argp->lock.len);
-	if (host == NULL)
+	if (!host)
 		return rpc_system_err;
 
 	call = nlm_alloc_call(host);
 	nlmsvc_release_host(host);
-	if (call == NULL)
+	if (!call)
 		return rpc_system_err;
 
 	stat = func(rqstp, &call->a_res);
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 3507c80d1d4b..8f1c058f16b3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -220,12 +220,12 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
 	struct nlm_rqst		*call = NULL;
 
 	call = nlm_alloc_call(host);
-	if (call == NULL)
+	if (!call)
 		return NULL;
 
 	/* Allocate memory for block, and initialize arguments */
 	block = kzalloc(sizeof(*block), GFP_KERNEL);
-	if (block == NULL)
+	if (!block)
 		goto failed;
 	kref_init(&block->b_count);
 	INIT_LIST_HEAD(&block->b_list);
@@ -299,7 +299,7 @@ static void nlmsvc_free_block(struct kref *kref)
 
 static void nlmsvc_release_block(struct nlm_block *block)
 {
-	if (block != NULL)
+	if (block)
 		kref_put_mutex(&block->b_count, nlmsvc_free_block, &block->b_file->f_mutex);
 }
 
@@ -381,7 +381,7 @@ nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
 	if (rqstp->rq_chandle.defer) {
 		block->b_deferred_req =
 			rqstp->rq_chandle.defer(block->b_cache_req);
-		if (block->b_deferred_req != NULL)
+		if (block->b_deferred_req)
 			status = nlm_drop_reply;
 	}
 	dprintk("lockd: nlmsvc_defer_lock_rqst block %p flags %d status %d\n",
@@ -417,10 +417,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	 * or create new block
 	 */
 	block = nlmsvc_lookup_block(file, lock);
-	if (block == NULL) {
+	if (!block) {
 		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		ret = nlm_lck_denied_nolocks;
-		if (block == NULL)
+		if (!block)
 			goto out;
 		lock = &block->b_call->a_args.lock;
 	} else
@@ -606,7 +606,7 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct nlm_lock *l
 	mutex_lock(&file->f_mutex);
 	block = nlmsvc_lookup_block(file, lock);
 	mutex_unlock(&file->f_mutex);
-	if (block != NULL) {
+	if (block) {
 		vfs_cancel_lock(block->b_file->f_file,
 				&block->b_call->a_args.lock.fl);
 		status = nlmsvc_unlink_block(block);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 07915162581d..548f732c8f8e 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -67,7 +67,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	*hostp = host;
 
 	/* Obtain file pointer. Not used by FREE_ALL call. */
-	if (filp != NULL) {
+	if (filp) {
 		error = cast_status(nlm_lookup_file(rqstp, &file, &lock->fh));
 		if (error != 0)
 			goto no_locks;
@@ -326,12 +326,12 @@ static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc,
 	host = nlmsvc_lookup_host(rqstp,
 				  argp->lock.caller,
 				  argp->lock.len);
-	if (host == NULL)
+	if (!host)
 		return rpc_system_err;
 
 	call = nlm_alloc_call(host);
 	nlmsvc_release_host(host);
-	if (call == NULL)
+	if (!call)
 		return rpc_system_err;
 
 	stat = func(rqstp, &call->a_res);
diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
index b0ae07008700..84b54efee9b6 100644
--- a/fs/lockd/svcshare.c
+++ b/fs/lockd/svcshare.c
@@ -41,7 +41,7 @@ nlmsvc_share_file(struct nlm_host *host, struct nlm_file *file,
 
 	share = kmalloc(sizeof(*share) + oh->len,
 						GFP_KERNEL);
-	if (share == NULL)
+	if (!share)
 		return nlm_lck_denied_nolocks;
 
 	/* Copy owner handle */
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index a563ddbc19e6..507b4c3ff103 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -331,8 +331,7 @@ nlmsvc_mark_host(void *data, struct nlm_host *hint)
 {
 	struct nlm_host *host = data;
 
-	if ((hint->net == NULL) ||
-	    (host->net == hint->net))
+	if (!hint->net || host->net == hint->net)
 		host->h_inuse = 1;
 	return 0;
 }
-- 
2.14.0

