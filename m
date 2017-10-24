Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:5499 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932124AbdJXRsC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Oct 2017 13:48:02 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 09/10] NFSD support OFFLOAD_STATUS
Date: Tue, 24 Oct 2017 13:47:51 -0400
Message-ID: <20171024174752.74910-10-kolga@netapp.com>
In-Reply-To: <20171024174752.74910-1-kolga@netapp.com>
References: <20171024174752.74910-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Search the list for the asynchronous copy based on the stateid,
then lookup the number of bytes copied so far.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 44 ++++++++++++++++++++++++++++++++------------
 1 file changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3b0bb54..b2f6549 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1299,28 +1299,36 @@ static int nfsd4_do_async_copy(void *data)
 	goto out;
 }
 
-static __be32
-nfsd4_offload_cancel(struct svc_rqst *rqstp,
-		     struct nfsd4_compound_state *cstate,
-		     union nfsd4_op_u *u)
+static struct nfsd4_copy *
+find_async_copy(struct nfs4_client *clp, struct nfsd4_offload_status *os)
 {
-	struct nfsd4_offload_status *os = &u->offload_status;
-	__be32 status = 0;
 	struct nfsd4_copy *copy;
-	bool found = false;
-	struct nfs4_client *clp = cstate->clp;
 
 	spin_lock(&clp->async_lock);
 	list_for_each_entry(copy, &clp->async_copies, copies) {
 		if (memcmp(&copy->cps->cp_stateid, &os->stateid,
 				NFS4_STATEID_SIZE))
 			continue;
-		found = true;
 		atomic_inc(&copy->refcount);
-		break;
+		spin_unlock(&clp->async_lock);
+		return copy;
 	}
 	spin_unlock(&clp->async_lock);
-	if (found) {
+	return NULL;
+}
+
+static __be32
+nfsd4_offload_cancel(struct svc_rqst *rqstp,
+		     struct nfsd4_compound_state *cstate,
+		     union nfsd4_op_u *u)
+{
+	struct nfsd4_offload_status *os = &u->offload_status;
+	__be32 status = 0;
+	struct nfsd4_copy *copy;
+	struct nfs4_client *clp = cstate->clp;
+
+	copy = find_async_copy(clp, os);
+	if (copy) {
 		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
 		kthread_stop(copy->copy_task);
 		nfs4_put_copy(copy);
@@ -1357,7 +1365,19 @@ static int nfsd4_do_async_copy(void *data)
 		     struct nfsd4_compound_state *cstate,
 		     union nfsd4_op_u *u)
 {
-	return nfserr_notsupp;
+	struct nfsd4_offload_status *os = &u->offload_status;
+	__be32 status = 0;
+	struct nfsd4_copy *copy;
+	struct nfs4_client *clp = cstate->clp;
+
+	copy = find_async_copy(clp, os);
+	if (copy) {
+		os->count = copy->cp_res.wr_bytes_written;
+		nfs4_put_copy(copy);
+	} else
+		status = nfserr_bad_stateid;
+
+	return status;
 }
 
 static __be32
-- 
1.8.3.1

