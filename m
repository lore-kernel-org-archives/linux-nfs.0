Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:49366 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728469AbeGTXJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Jul 2018 19:09:26 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v10 8/9] NFSD support OFFLOAD_STATUS
Date: Fri, 20 Jul 2018 18:19:24 -0400
Message-ID: <20180720221925.50744-9-kolga@netapp.com>
In-Reply-To: <20180720221925.50744-1-kolga@netapp.com>
References: <20180720221925.50744-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Search the list for the asynchronous copy based on the stateid,
then lookup the number of bytes copied so far.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 45 ++++++++++++++++++++++++++++++++-------------
 fs/nfsd/state.h    |  2 ++
 2 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c375520..c122153 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1275,6 +1275,23 @@ static int nfsd4_do_async_copy(void *data)
 	goto out;
 }
 
+struct nfsd4_copy *
+find_async_copy(struct nfs4_client *clp, stateid_t *stateid)
+{
+	struct nfsd4_copy *copy;
+
+	spin_lock(&clp->async_lock);
+	list_for_each_entry(copy, &clp->async_copies, copies) {
+		if (memcmp(&copy->cp_stateid, stateid, NFS4_STATEID_SIZE))
+			continue;
+		refcount_inc(&copy->refcount);
+		spin_unlock(&clp->async_lock);
+		return copy;
+	}
+	spin_unlock(&clp->async_lock);
+	return NULL;
+}
+
 static __be32
 nfsd4_offload_cancel(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1283,20 +1300,10 @@ static int nfsd4_do_async_copy(void *data)
 	struct nfsd4_offload_status *os = &u->offload_status;
 	__be32 status = 0;
 	struct nfsd4_copy *copy;
-	bool found = false;
 	struct nfs4_client *clp = cstate->clp;
 
-	spin_lock(&clp->async_lock);
-	list_for_each_entry(copy, &clp->async_copies, copies) {
-		if (memcmp(&copy->cp_stateid, &os->stateid,
-				NFS4_STATEID_SIZE))
-			continue;
-		found = true;
-		refcount_inc(&copy->refcount);
-		break;
-	}
-	spin_unlock(&clp->async_lock);
-	if (found) {
+	copy = find_async_copy(clp, &os->stateid);
+	if (copy) {
 		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
 		kthread_stop(copy->copy_task);
 		nfs4_put_copy(copy);
@@ -1333,7 +1340,19 @@ static int nfsd4_do_async_copy(void *data)
 		     struct nfsd4_compound_state *cstate,
 		     union nfsd4_op_u *u)
 {
-	return nfserr_notsupp;
+	struct nfsd4_offload_status *os = &u->offload_status;
+	__be32 status = 0;
+	struct nfsd4_copy *copy;
+	struct nfs4_client *clp = cstate->clp;
+
+	copy = find_async_copy(clp, &os->stateid);
+	if (copy) {
+		os->count = copy->cp_res.wr_bytes_written;
+		nfs4_put_copy(copy);
+	} else
+		status = nfserr_bad_stateid;
+
+	return status;
 }
 
 static __be32
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0ee2ed3..0bd4329 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -642,6 +642,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
 extern void nfs4_put_copy(struct nfsd4_copy *copy);
+extern struct nfsd4_copy *
+find_async_copy(struct nfs4_client *clp, stateid_t *staetid);
 static inline void get_nfs4_file(struct nfs4_file *fi)
 {
 	refcount_inc(&fi->fi_ref);
-- 
1.8.3.1

