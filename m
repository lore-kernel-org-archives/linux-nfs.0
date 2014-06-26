Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755871AbaFZBsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/8] nfsd4: remove unused defer_free argument
Date: Wed, 25 Jun 2014 21:48:05 -0400
Message-Id: <1403747288-21590-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

28e05dd8457c "knfsd: nfsd4: represent nfsv4 acl with array instead of
linked list" removed the last user that wanted a custom free function.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   21 +++++++++------------
 fs/nfsd/xdr4.h    |    1 -
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3d07496..13f91ce 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -182,16 +182,14 @@ static int zero_clientid(clientid_t *clid)
 
 /**
  * defer_free - mark an allocation as deferred freed
- * @argp: NFSv4 compound argument structure to be freed with
- * @release: release callback to free @p, typically kfree()
- * @p: pointer to be freed
+ * @argp: NFSv4 compound argument structure
+ * @p: pointer to be freed (with kfree())
  *
  * Marks @p to be freed when processing the compound operation
  * described in @argp finishes.
  */
 static int
-defer_free(struct nfsd4_compoundargs *argp,
-		void (*release)(const void *), void *p)
+defer_free(struct nfsd4_compoundargs *argp, void *p)
 {
 	struct tmpbuf *tb;
 
@@ -199,7 +197,6 @@ defer_free(struct nfsd4_compoundargs *argp,
 	if (!tb)
 		return -ENOMEM;
 	tb->buf = p;
-	tb->release = release;
 	tb->next = argp->to_free;
 	argp->to_free = tb;
 	return 0;
@@ -225,7 +222,7 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 		BUG_ON(p != argp->tmpp);
 		argp->tmpp = NULL;
 	}
-	if (defer_free(argp, kfree, p)) {
+	if (defer_free(argp, p)) {
 		kfree(p);
 		return NULL;
 	} else
@@ -296,7 +293,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		if (*acl == NULL)
 			return nfserr_jukebox;
 
-		defer_free(argp, kfree, *acl);
+		defer_free(argp, *acl);
 
 		(*acl)->naces = nace;
 		for (ace = (*acl)->aces; ace < (*acl)->aces + nace; ace++) {
@@ -422,7 +419,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		if (!label->data)
 			return nfserr_jukebox;
 		label->len = dummy32;
-		defer_free(argp, kfree, label->data);
+		defer_free(argp, label->data);
 		memcpy(label->data, buf, dummy32);
 	}
 #endif
@@ -610,7 +607,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 			return nfserr_jukebox;
 		memcpy(create->cr_data, p, create->cr_datalen);
 		create->cr_data[create->cr_datalen] = '\0';
-		defer_free(argp, kfree, create->cr_data);
+		defer_free(argp, create->cr_data);
 		break;
 	case NF4BLK:
 	case NF4CHR:
@@ -1486,7 +1483,7 @@ nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_sta
 			goto out;
 		}
 
-		defer_free(argp, kfree, stateid);
+		defer_free(argp, stateid);
 		INIT_LIST_HEAD(&stateid->ts_id_list);
 		list_add_tail(&stateid->ts_id_list, &test_stateid->ts_stateid_list);
 
@@ -3972,7 +3969,7 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 	while (args->to_free) {
 		struct tmpbuf *tb = args->to_free;
 		args->to_free = tb->next;
-		tb->release(tb->buf);
+		kfree(tb->buf);
 		kfree(tb);
 	}
 	return 1;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b8bf63a..4379cc8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -488,7 +488,6 @@ struct nfsd4_compoundargs {
 	__be32 *			tmpp;
 	struct tmpbuf {
 		struct tmpbuf *next;
-		void (*release)(const void *);
 		void *buf;
 	}				*to_free;
 
-- 
1.7.9.5

