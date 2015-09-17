Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36767 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbIQL6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 07:58:30 -0400
Received: by ykdt18 with SMTP id t18so14100411ykd.3
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 04:58:30 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Date: Thu, 17 Sep 2015 07:58:24 -0400
Message-Id: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to allow the client to make a sane determination of what
happened with racing LAYOUTGET/LAYOUTRETURN/CB_LAYOUTRECALL calls, we
must ensure that the seqids return accurately represent the order of
operations. The simplest way to do that is to ensure that operations on
a single stateid are serialized.

This patch adds a mutex to the layout stateid, and locks it when
checking the layout stateid's seqid. The mutex is held over the entire
operation and released after the seqid is bumped.

Note that in the case of CB_LAYOUTRECALL we must move the increment of
the seqid and setting into a new cb "prepare" operation. The lease
infrastructure will call the lm_break callback with a spinlock held, so
and we can't take the mutex in that codepath.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4layouts.c | 25 +++++++++++++++++++++----
 fs/nfsd/nfs4proc.c    |  4 ++++
 fs/nfsd/state.h       |  1 +
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index ebf90e487c75..4a68ab901b4b 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -201,6 +201,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	INIT_LIST_HEAD(&ls->ls_perfile);
 	spin_lock_init(&ls->ls_lock);
 	INIT_LIST_HEAD(&ls->ls_layouts);
+	mutex_init(&ls->ls_mutex);
 	ls->ls_layout_type = layout_type;
 	nfsd4_init_cb(&ls->ls_recall, clp, &nfsd4_cb_layout_ops,
 			NFSPROC4_CLNT_CB_LAYOUT);
@@ -262,19 +263,23 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		status = nfserr_jukebox;
 		if (!ls)
 			goto out;
+		mutex_lock(&ls->ls_mutex);
 	} else {
 		ls = container_of(stid, struct nfs4_layout_stateid, ls_stid);
 
 		status = nfserr_bad_stateid;
+		mutex_lock(&ls->ls_mutex);
 		if (stateid->si_generation > stid->sc_stateid.si_generation)
-			goto out_put_stid;
+			goto out_unlock_stid;
 		if (layout_type != ls->ls_layout_type)
-			goto out_put_stid;
+			goto out_unlock_stid;
 	}
 
 	*lsp = ls;
 	return 0;
 
+out_unlock_stid:
+	mutex_unlock(&ls->ls_mutex);
 out_put_stid:
 	nfs4_put_stid(stid);
 out:
@@ -296,8 +301,6 @@ nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
 	trace_layout_recall(&ls->ls_stid.sc_stateid);
 
 	atomic_inc(&ls->ls_stid.sc_count);
-	update_stateid(&ls->ls_stid.sc_stateid);
-	memcpy(&ls->ls_recall_sid, &ls->ls_stid.sc_stateid, sizeof(stateid_t));
 	nfsd4_run_cb(&ls->ls_recall);
 
 out_unlock:
@@ -494,6 +497,7 @@ nfsd4_return_file_layouts(struct svc_rqst *rqstp,
 	}
 	spin_unlock(&ls->ls_lock);
 
+	mutex_unlock(&ls->ls_mutex);
 	nfs4_put_stid(&ls->ls_stid);
 	nfsd4_free_layouts(&reaplist);
 	return nfs_ok;
@@ -608,6 +612,17 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
 	}
 }
 
+static void
+nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
+{
+	struct nfs4_layout_stateid *ls =
+		container_of(cb, struct nfs4_layout_stateid, ls_recall);
+
+	mutex_lock(&ls->ls_mutex);
+	update_stateid(&ls->ls_stid.sc_stateid);
+	memcpy(&ls->ls_recall_sid, &ls->ls_stid.sc_stateid, sizeof(stateid_t));
+}
+
 static int
 nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 {
@@ -649,12 +664,14 @@ nfsd4_cb_layout_release(struct nfsd4_callback *cb)
 
 	trace_layout_recall_release(&ls->ls_stid.sc_stateid);
 
+	mutex_unlock(&ls->ls_mutex);
 	nfsd4_return_all_layouts(ls, &reaplist);
 	nfsd4_free_layouts(&reaplist);
 	nfs4_put_stid(&ls->ls_stid);
 }
 
 static struct nfsd4_callback_ops nfsd4_cb_layout_ops = {
+	.prepare	= nfsd4_cb_layout_prepare,
 	.done		= nfsd4_cb_layout_done,
 	.release	= nfsd4_cb_layout_release,
 };
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4ce6b97b31ad..a9f096c7e99f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1309,6 +1309,7 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 	nfserr = nfsd4_insert_layout(lgp, ls);
 
 out_put_stid:
+	mutex_unlock(&ls->ls_mutex);
 	nfs4_put_stid(&ls->ls_stid);
 out:
 	return nfserr;
@@ -1362,6 +1363,9 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
 		goto out;
 	}
 
+	/* LAYOUTCOMMIT does not require any serialization */
+	mutex_unlock(&ls->ls_mutex);
+
 	if (new_size > i_size_read(inode)) {
 		lcp->lc_size_chg = 1;
 		lcp->lc_newsize = new_size;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 31bde12feefe..1fa0f3848d4e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -562,6 +562,7 @@ struct nfs4_layout_stateid {
 	struct nfsd4_callback		ls_recall;
 	stateid_t			ls_recall_sid;
 	bool				ls_recalled;
+	struct mutex			ls_mutex;
 };
 
 static inline struct nfs4_layout_stateid *layoutstateid(struct nfs4_stid *s)
-- 
2.4.3

