Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46921 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbaFZBsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/8] nfsd4: replace defer_free by svcxdr_tmpalloc
Date: Wed, 25 Jun 2014 21:48:08 -0400
Message-Id: <1403747288-21590-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Avoid an extra allocation for the tmpbuf struct itself, and stop
ignoring some allocation failures.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   46 +++++++++++++++++-----------------------------
 fs/nfsd/xdr4.h    |   13 +++++++++----
 2 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index be4f19c..46115f2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -181,25 +181,24 @@ static int zero_clientid(clientid_t *clid)
 }
 
 /**
- * defer_free - mark an allocation as deferred freed
+ * svcxdr_tmpalloc - allocate memory to be freed after compound processing
  * @argp: NFSv4 compound argument structure
  * @p: pointer to be freed (with kfree())
  *
  * Marks @p to be freed when processing the compound operation
  * described in @argp finishes.
  */
-static int
-defer_free(struct nfsd4_compoundargs *argp, void *p)
+static void *
+svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, u32 len)
 {
-	struct tmpbuf *tb;
+	struct svcxdr_tmpbuf *tb;
 
-	tb = kmalloc(sizeof(*tb), GFP_KERNEL);
+	tb = kmalloc(sizeof(*tb) + len, GFP_KERNEL);
 	if (!tb)
-		return -ENOMEM;
-	tb->buf = p;
+		return NULL;
 	tb->next = argp->to_free;
 	argp->to_free = tb;
-	return 0;
+	return tb->buf;
 }
 
 /*
@@ -212,13 +211,12 @@ defer_free(struct nfsd4_compoundargs *argp, void *p)
 static char *
 svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
 {
-	char *p = kmalloc(len + 1, GFP_KERNEL);
+	char *p = svcxdr_tmpalloc(argp, len + 1);
 
 	if (!p)
 		return NULL;
 	memcpy(p, buf, len);
 	p[len] = '\0';
-	defer_free(argp, p);
 	return p;
 }
 
@@ -234,19 +232,13 @@ svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
  */
 static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 {
-	if (p == argp->tmp) {
-		p = kmemdup(argp->tmp, nbytes, GFP_KERNEL);
-		if (!p)
-			return NULL;
-	} else {
-		BUG_ON(p != argp->tmpp);
-		argp->tmpp = NULL;
-	}
-	if (defer_free(argp, p)) {
-		kfree(p);
+	void *ret;
+
+	ret = svcxdr_tmpalloc(argp, nbytes);
+	if (!ret)
 		return NULL;
-	} else
-		return (char *)p;
+	memcpy(ret, p, nbytes);
+	return ret;
 }
 
 static __be32
@@ -309,12 +301,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		if (nace > NFS4_ACL_MAX)
 			return nfserr_fbig;
 
-		*acl = kmalloc(nfs4_acl_size(nace), GFP_KERNEL);
+		*acl = svcxdr_tmpalloc(argp, nfs4_acl_bytes(nace));
 		if (*acl == NULL)
 			return nfserr_jukebox;
 
-		defer_free(argp, *acl);
-
 		(*acl)->naces = nace;
 		for (ace = (*acl)->aces; ace < (*acl)->aces + nace; ace++) {
 			READ_BUF(16); len += 16;
@@ -1487,13 +1477,12 @@ nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_sta
 	INIT_LIST_HEAD(&test_stateid->ts_stateid_list);
 
 	for (i = 0; i < test_stateid->ts_num_ids; i++) {
-		stateid = kmalloc(sizeof(struct nfsd4_test_stateid_id), GFP_KERNEL);
+		stateid = svcxdr_tmpalloc(argp, sizeof(*stateid));
 		if (!stateid) {
 			status = nfserrno(-ENOMEM);
 			goto out;
 		}
 
-		defer_free(argp, stateid);
 		INIT_LIST_HEAD(&stateid->ts_id_list);
 		list_add_tail(&stateid->ts_id_list, &test_stateid->ts_stateid_list);
 
@@ -3977,9 +3966,8 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 	kfree(args->tmpp);
 	args->tmpp = NULL;
 	while (args->to_free) {
-		struct tmpbuf *tb = args->to_free;
+		struct svcxdr_tmpbuf *tb = args->to_free;
 		args->to_free = tb->next;
-		kfree(tb->buf);
 		kfree(tb);
 	}
 	return 1;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 4379cc8..efce901 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -478,6 +478,14 @@ struct nfsd4_op {
 
 bool nfsd4_cache_this_op(struct nfsd4_op *);
 
+/*
+ * Memory needed just for the duration of processing one compound:
+ */
+struct svcxdr_tmpbuf {
+	struct svcxdr_tmpbuf *next;
+	char buf[];
+};
+
 struct nfsd4_compoundargs {
 	/* scratch variables for XDR decode */
 	__be32 *			p;
@@ -486,10 +494,7 @@ struct nfsd4_compoundargs {
 	int				pagelen;
 	__be32				tmp[8];
 	__be32 *			tmpp;
-	struct tmpbuf {
-		struct tmpbuf *next;
-		void *buf;
-	}				*to_free;
+	struct svcxdr_tmpbuf		*to_free;
 
 	struct svc_rqst			*rqstp;
 
-- 
1.7.9.5

