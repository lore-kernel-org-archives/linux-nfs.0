Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:51951 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567AbaF3Pu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:58 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so7159981qcv.33
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 018/114] nfsd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
Date: Mon, 30 Jun 2014 11:48:47 -0400
Message-Id: <1404143423-24381-19-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

lookup_clientid is preferable to find_confirmed_client since it's able
to use the cached client in the compound state.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c  |  3 +--
 fs/nfsd/nfs4state.c | 15 ++++++++++-----
 fs/nfsd/state.h     |  3 ++-
 3 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7aa83bf34fa9..3c72eef479a3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -431,8 +431,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
 			status = nfs4_check_open_reclaim(&open->op_clientid,
-							 cstate->minorversion,
-							 nn);
+							 cstate, nn);
 			if (status)
 				goto out;
 			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a482fb97964f..c3b537570bce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4980,16 +4980,21 @@ nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
 * Called from OPEN. Look for clientid in reclaim list.
 */
 __be32
-nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
+nfs4_check_open_reclaim(clientid_t *clid,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd_net *nn)
 {
-	struct nfs4_client *clp;
+	__be32 status;
 
 	/* find clientid in conf_id_hashtbl */
-	clp = find_confirmed_client(clid, sessions, nn);
-	if (clp == NULL)
+	status = lookup_clientid(clid, cstate, nn);
+	if (status)
 		return nfserr_reclaim_bad;
 
-	return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
+	if (nfsd4_client_record_check(cstate->clp))
+		return nfserr_reclaim_bad;
+
+	return nfs_ok;
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 305414a083c5..b2c9afce33bf 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -458,7 +458,8 @@ void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *)
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
-extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
+extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
+		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
 extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
-- 
1.9.3

