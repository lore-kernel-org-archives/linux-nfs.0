Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755622Ab1JQV4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] nfsd4: clean up open owners on OPEN failure
Date: Mon, 17 Oct 2011 17:55:53 -0400
Message-Id: <1318888557-14719-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If process_open1() creates a new open owner, but the open later fails,
the current code will leave the open owner around.  It won't be on the
close_lru list, and the client isn't expected to send a CLOSE, so it
will hang around as long as the client does.

Similarly, if process_open1() removes an existing open owner from the
close lru, anticipating that an open owner that previously had no
associated stateid's now will, but the open subsequently fails, then
we'll again be left with the same leak.

Fix both problems.

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    1 +
 fs/nfsd/nfs4state.c |   20 ++++++++++++++++++--
 fs/nfsd/state.h     |    1 +
 fs/nfsd/xdr4.h      |    1 +
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5b192a2..10b50d7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -409,6 +409,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 */
 	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
 out:
+	nfsd4_cleanup_open_state(open, status);
 	if (open->op_openowner)
 		cstate->replay_owner = &open->op_openowner->oo_owner;
 	else
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 62aa91a..2c9a1a2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2320,7 +2320,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 		return NULL;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
-	oo->oo_flags = 0;
+	oo->oo_flags = NFS4_OO_NEW;
 	oo->oo_time = 0;
 	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
@@ -2526,7 +2526,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		open->op_openowner = NULL;
 		goto new_owner;
 	}
-	list_del_init(&oo->oo_close_lru);
 	return nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
 new_owner:
 	oo = alloc_init_open_stateowner(strhashval, clp, open);
@@ -2946,6 +2945,23 @@ out:
 	return status;
 }
 
+void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
+{
+	if (open->op_openowner) {
+		struct nfs4_openowner *oo = open->op_openowner;
+
+		if (!list_empty(&oo->oo_owner.so_stateids))
+			list_del_init(&oo->oo_close_lru);
+		if (oo->oo_flags & NFS4_OO_NEW) {
+			if (status) {
+				release_openowner(oo);
+				open->op_openowner = NULL;
+			} else
+				oo->oo_flags &= ~NFS4_OO_NEW;
+		}
+	}
+}
+
 __be32
 nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    clientid_t *clid)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 87eecfd..eab9dae 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -359,6 +359,7 @@ struct nfs4_openowner {
 	time_t			oo_time; /* time of placement on so_close_lru */
 #define NFS4_OO_CONFIRMED   1
 #define NFS4_OO_PURGE_CLOSE 2
+#define NFS4_OO_NEW         4
 	unsigned char		oo_flags;
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 4c8a7ec..32e6fd8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -554,6 +554,7 @@ extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
+extern void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);
 extern __be32 nfsd4_close(struct svc_rqst *rqstp,
-- 
1.7.5.4

