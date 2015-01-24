Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57814 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbAXFjh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 00:39:37 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so1047744iec.11
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:39:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Check for NULL argument in nfs_*_seqid() functions
Date: Sat, 24 Jan 2015 00:39:27 -0500
Message-Id: <1422077968-116473-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422077968-116473-4-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-3-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 21 ++++++++++++++-------
 fs/nfs/nfs4xdr.c   |  5 ++++-
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b922e43d69b8..590f096fd011 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1015,7 +1015,7 @@ void nfs_release_seqid(struct nfs_seqid *seqid)
 {
 	struct nfs_seqid_counter *sequence;
 
-	if (list_empty(&seqid->list))
+	if (seqid == NULL || list_empty(&seqid->list))
 		return;
 	sequence = seqid->sequence;
 	spin_lock(&sequence->lock);
@@ -1071,13 +1071,15 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 
 void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
 {
-	struct nfs4_state_owner *sp = container_of(seqid->sequence,
-					struct nfs4_state_owner, so_seqid);
-	struct nfs_server *server = sp->so_server;
+	struct nfs4_state_owner *sp;
+
+	if (seqid == NULL)
+		return;
 
+	sp = container_of(seqid->sequence, struct nfs4_state_owner, so_seqid);
 	if (status == -NFS4ERR_BAD_SEQID)
 		nfs4_drop_state_owner(sp);
-	if (!nfs4_has_session(server->nfs_client))
+	if (!nfs4_has_session(sp->so_server->nfs_client))
 		nfs_increment_seqid(status, seqid);
 }
 
@@ -1088,14 +1090,18 @@ void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
  */
 void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid)
 {
-	nfs_increment_seqid(status, seqid);
+	if (seqid != NULL)
+		nfs_increment_seqid(status, seqid);
 }
 
 int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 {
-	struct nfs_seqid_counter *sequence = seqid->sequence;
+	struct nfs_seqid_counter *sequence;
 	int status = 0;
 
+	if (seqid == NULL)
+		goto out;
+	sequence = seqid->sequence;
 	spin_lock(&sequence->lock);
 	seqid->task = task;
 	if (list_empty(&seqid->list))
@@ -1106,6 +1112,7 @@ int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 	status = -EAGAIN;
 unlock:
 	spin_unlock(&sequence->lock);
+out:
 	return status;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7e7be5ab70bb..d05fada4929c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -946,7 +946,10 @@ static void encode_uint64(struct xdr_stream *xdr, u64 n)
 static void encode_nfs4_seqid(struct xdr_stream *xdr,
 		const struct nfs_seqid *seqid)
 {
-	encode_uint32(xdr, seqid->sequence->counter);
+	if (seqid != NULL)
+		encode_uint32(xdr, seqid->sequence->counter);
+	else
+		encode_uint32(xdr, 0);
 }
 
 static void encode_compound_hdr(struct xdr_stream *xdr,
-- 
2.1.0

