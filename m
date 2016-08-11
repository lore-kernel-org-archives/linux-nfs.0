Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35962 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbcHKOhd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 10:37:33 -0400
Received: by mail-io0-f194.google.com with SMTP id y34so539687ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 07:37:32 -0700 (PDT)
Subject: [PATCH v4 1/2] nfsd: Fix race between FREE_STATEID and LOCK
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Aug 2016 10:37:30 -0400
Message-ID: <20160811143730.20488.70535.stgit@klimt.1015granger.net>
In-Reply-To: <20160811143205.20488.82396.stgit@klimt.1015granger.net>
References: <20160811143205.20488.82396.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When running LTP's nfslock01 test, the Linux client can send a LOCK
and a FREE_STATEID request at the same time. The outcome is:

Frame 324    R OPEN stateid [2,O]

Frame 115004 C LOCK lockowner_is_new stateid [2,O] offset 672000 len 64
Frame 115008 R LOCK stateid [1,L]
Frame 115012 C WRITE stateid [0,L] offset 672000 len 64
Frame 115016 R WRITE NFS4_OK
Frame 115019 C LOCKU stateid [1,L] offset 672000 len 64
Frame 115022 R LOCKU NFS4_OK
Frame 115025 C FREE_STATEID stateid [2,L]
Frame 115026 C LOCK lockowner_is_new stateid [2,O] offset 672128 len 64
Frame 115029 R FREE_STATEID NFS4_OK
Frame 115030 R LOCK stateid [3,L]
Frame 115034 C WRITE stateid [0,L] offset 672128 len 64
Frame 115038 R WRITE NFS4ERR_BAD_STATEID

In other words, the server returns stateid L in a successful LOCK
reply, but it has already released it. Subsequent uses of stateid L
fail.

To address this, protect the generation check in nfsd4_free_stateid
with the st_mutex. This should guarantee that only one of two
outcomes occurs: either LOCK returns a fresh valid stateid, or
FREE_STATEID returns NFS4ERR_LOCKS_HELD.

Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 fs/nfsd/nfs4state.c |   40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b921123..de868fe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4885,6 +4885,32 @@ nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return nfs_ok;
 }
 
+static __be32
+nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
+{
+	struct nfs4_ol_stateid *stp = openlockstateid(s);
+	__be32 ret;
+
+	mutex_lock(&stp->st_mutex);
+
+	ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
+	if (ret)
+		goto out;
+
+	ret = nfserr_locks_held;
+	if (check_for_locks(stp->st_stid.sc_file,
+			    lockowner(stp->st_stateowner)))
+		goto out;
+
+	release_lock_stateid(stp);
+	ret = nfs_ok;
+
+out:
+	mutex_unlock(&stp->st_mutex);
+	nfs4_put_stid(s);
+	return ret;
+}
+
 __be32
 nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_free_stateid *free_stateid)
@@ -4892,7 +4918,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
 	struct nfs4_delegation *dp;
-	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
@@ -4911,18 +4936,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_locks_held;
 		break;
 	case NFS4_LOCK_STID:
-		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
-		if (ret)
-			break;
-		stp = openlockstateid(s);
-		ret = nfserr_locks_held;
-		if (check_for_locks(stp->st_stid.sc_file,
-				    lockowner(stp->st_stateowner)))
-			break;
-		WARN_ON(!unhash_lock_stateid(stp));
+		atomic_inc(&s->sc_count);
 		spin_unlock(&cl->cl_lock);
-		nfs4_put_stid(s);
-		ret = nfs_ok;
+		ret = nfsd4_free_lock_stateid(stateid, s);
 		goto out;
 	case NFS4_REVOKED_DELEG_STID:
 		dp = delegstateid(s);

