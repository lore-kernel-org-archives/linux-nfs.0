Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFCD74334A5;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791962999; cv=none; b=tBoILWEoRz/RHQk1wnYjsM7st+LLBNXhvVaN3VE45+DGnRYdoCygJ9BK8/o4o/24pHQLHa83Zp84MjWyyRNPi4V/3kcFxBK5FhsWuPMrbLe5AjqAl6XuiLjth3KRNlburkxosXSYVkvuLQf2WXo0dEGSPy7LIizZNG38YtGdtCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791962999; c=relaxed/simple;
	bh=N7j/2Xe8HPDRSCs5CJTe1Kk/L7NiSyo9qS5yA95fOGM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=r2Wl42OXmNL3chlSFsN6cMd+XYWsjFgkLtKtBskpGOBLbedHXYTJZGU5W1syc2v1a/AtW9r0bEhvJLp2I80pH1GKh9KMtApCVvWOnWJzy/SwtOHh3xGY9JC/s342+Gv+pTzzQxvnXLF57cCk0ERySgdrTnY/eGCSLe0a8BYfMMI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KsldYtk4; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KsldYtk4"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 39C0CC2BCFD;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791962999;
	bh=N7j/2Xe8HPDRSCs5CJTe1Kk/L7NiSyo9qS5yA95fOGM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=KsldYtk4GV4bBxyE9ctzunWF77AKvvV4S0FKw9RAE3xtSo0j09aIAsOnmfQiNaxR9
	 AB6E3y0EdEy4DIxyzGzV3O/oCWyw8hveQ4ZglAIvTEJGUIF7OkhhGPs9wYTuL9/ABM
	 1DBAcdCkuw1KWOVHC5f0B6pBlB5as54midJ+jgxa7DtvkpnD59x77ec2JF+b+k19vn
	 BywiTwJupUOBMkLiHKP3joQqhzgT8a+f5SYCQ//GdHXwGQegAdUqWwVrdZP4Ocmpeq
	 5ZKQq5fBJwgmmY++QKlVoMFiFOMnsFy0yi1Z1Z/+QFplnL2fhQjtt1dH4OnNXQ7Fo/
	 t/Y4+FAMltC/g==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26C3DCC6B1A;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 14 Oct 2026 16:30:02 +0900
Subject: [PATCH v2 6/7] nfsd: poll a layout recall with a new seqid when
 the client is past it
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261014-nfsd-layout-recall-v2-6-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
In-Reply-To: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791962996; l=6775;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=gU0wXq+c9mDN56dXhK6jIXSdZ0Wko5Ybmxjyn3PC428=;
 b=4SuhEw7SDW4KfQDtexhSu08wgo5JvCpqcF8iuSBjd02wuKUcjGDG5Prbq7OfEBKJ5vWLNfeek
 SpiUSxEjlDgBug3GBKyN5BUfLA9IiDpCNg1i2DMuNnlm5betUh086by
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_cb_layout_done() polls a client that answers a CB_LAYOUTRECALL
with NFS4ERR_OLD_STATEID, as "nfsd: keep polling a layout recall
answered with NFS4ERR_OLD_STATEID" has it do, and each poll repeats the
seqid that ->prepare gave the recall. NFS4ERR_OLD_STATEID says that
the client is at or past that seqid. A client that has answered
NFS4_OK to the recall is returning its layouts, and the polls end when
it has. A client that has not is past the seqid without having taken
the recall up. A LAYOUTRETURN that returns some layouts and leaves
others gets a new seqid; if nfsd processes it after ->prepare, the
client takes in a seqid above the recall's from its reply. Such a
client answers every poll with NFS4ERR_OLD_STATEID. The recall goes on
for two lease periods, a LAYOUTGET for the file from another client
gets NFS4ERR_RECALLCONFLICT meanwhile, and the client is then fenced,
although it was never asked for the layouts it still holds.

RFC 8881 section 12.5.3 has a new seqid for each CB_LAYOUTRECALL
request. When a client that has not answered NFS4_OK answers
NFS4ERR_OLD_STATEID, give the next poll a new seqid, which the client
takes up. ->prepare clears ls_recall_accepted, and ->done sets it when
the client answers NFS4_OK. The new seqid is traced as
nfsd_layout_recall_new_seqid.

->done runs in rpciod and does not take ls_mutex, which could block it;
nfs4_inc_and_copy_stateid() takes sc_lock. So
nfsd4_preprocess_layout_stateid(), which checks under ls_mutex that the
seqid a client presents is not above the current one, now reads the
current seqid under sc_lock as well. While a recall is out, only a
LAYOUTRETURN changes the seqid besides, since "nfsd: fail a LAYOUTGET in
progress when the layout lease is broken" keeps LAYOUTGET from adding
layouts to a recalled layout stateid.

A pynfs client that holds a layout answers a recall whose seqid is not
above the first seqid of the recall with NFS4ERR_OLD_STATEID, and
returns the layout on a later one. Without this patch, nfsd sent the
recall 501 times in six seconds, all with the first seqid, and a
LAYOUTGET of another client still got NFS4ERR_RECALLCONFLICT. With it,
the second recall carried a new seqid, 10 ms later, the client returned
the layout, and the LAYOUTGET succeeded. The block layout runs of the
earlier patches give the same results with this one and the next: no
recall failed, and every block written to a new file was found.

This builds on "nfsd: keep polling a layout recall answered with
NFS4ERR_OLD_STATEID" and "nfsd: fail a LAYOUTGET in progress when the
layout lease is broken", earlier in this series, and should go to
stable kernels with them.

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 40 ++++++++++++++++++++++++++++++++++++----
 fs/nfsd/state.h       |  2 ++
 fs/nfsd/trace.h       |  1 +
 3 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 5692d0aee7..f54515e7f6 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -363,6 +363,7 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 	struct nfs4_stid *stid;
 	unsigned short typemask = SC_TYPE_LAYOUT;
 	__be32 status;
+	bool after;
 
 	if (create)
 		typemask |= (SC_TYPE_OPEN | SC_TYPE_LOCK | SC_TYPE_DELEG);
@@ -391,7 +392,15 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 
 		status = nfserr_bad_stateid;
 		mutex_lock(&ls->ls_mutex);
-		if (nfsd4_stateid_generation_after(stateid, &stid->sc_stateid))
+		/*
+		 * The recall callback can move the seqid on without
+		 * ls_mutex, under sc_lock.
+		 */
+		spin_lock(&stid->sc_lock);
+		after = nfsd4_stateid_generation_after(stateid,
+						       &stid->sc_stateid);
+		spin_unlock(&stid->sc_lock);
+		if (after)
 			goto out_unlock_stid;
 		if (layout_type != ls->ls_layout_type)
 			goto out_unlock_stid;
@@ -846,6 +855,7 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 	mutex_lock(&ls->ls_mutex);
 	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
 	mutex_unlock(&ls->ls_mutex);
+	ls->ls_recall_accepted = false;
 	return true;
 }
 
@@ -861,13 +871,35 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 
 	trace_nfsd_cb_layout_done(&ls->ls_stid.sc_stateid, task);
 	switch (task->tk_status) {
-	case 0:
-	case -NFS4ERR_DELAY:
 	case -NFS4ERR_OLD_STATEID:
+		/*
+		 * The client is at or past the seqid of the request. Unless
+		 * it has answered NFS4_OK to this recall and is returning
+		 * layouts, it has not taken the recall up, for instance
+		 * because a LAYOUTRETURN moved it past the seqid. Poll with a
+		 * new seqid then (RFC 8881 section 12.5.3), which such a
+		 * client answers afresh.
+		 *
+		 * ->done runs in rpciod and does not take ls_mutex, which
+		 * could block it. While the recall is out, only a
+		 * LAYOUTRETURN changes the seqid besides, and the check of the
+		 * seqid a client presents only asks whether it is above the
+		 * current one.
+		 */
+		if (!ls->ls_recall_accepted) {
+			nfs4_inc_and_copy_stateid(&ls->ls_recall_sid,
+						  &ls->ls_stid);
+			trace_nfsd_layout_recall_new_seqid(&ls->ls_recall_sid);
+		}
+		fallthrough;
+	case -NFS4ERR_DELAY:
+	case 0:
+		if (!task->tk_status)
+			ls->ls_recall_accepted = true;
 		/*
 		 * RFC 8881 section 12.5.3 wants a new seqid in each
 		 * CB_LAYOUTRECALL request. The poll below sends the request
-		 * again with the seqid of the first one. A client that has
+		 * again with the seqid it last had. A client that has
 		 * processed that one is at its seqid or past it, and the
 		 * Linux client answers the repeat with NFS4ERR_OLD_STATEID
 		 * while it is returning the layouts.
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 45bd5c122c..173c22b880 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -856,6 +856,8 @@ struct nfs4_layout_stateid {
 	struct nfsd4_callback		ls_recall;
 	stateid_t			ls_recall_sid;
 	ktime_t				ls_recall_start;
+	/* The client has answered NFS4_OK to the recall */
+	bool				ls_recall_accepted;
 	bool				ls_recalled;
 	struct mutex			ls_mutex;
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index abfdbc637c..e0908cb21c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -681,6 +681,7 @@ DEFINE_STATEID_EVENT(layout_return_lookup_fail);
 DEFINE_STATEID_EVENT(layout_recall);
 DEFINE_STATEID_EVENT(layout_recall_empty);
 DEFINE_STATEID_EVENT(layout_recall_done);
+DEFINE_STATEID_EVENT(layout_recall_new_seqid);
 DEFINE_STATEID_EVENT(layout_recall_fail);
 DEFINE_STATEID_EVENT(layout_recall_release);
 

-- 
2.43.0


