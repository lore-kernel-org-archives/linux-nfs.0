Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36174 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbaFZTOU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:20 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so3491608qgd.35
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 025/117] nfsd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
Date: Thu, 26 Jun 2014 15:12:05 -0400
Message-Id: <1403810017-16062-26-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  |  3 +--
 fs/nfsd/nfs4state.c | 13 ++++++++-----
 fs/nfsd/state.h     |  3 ++-
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8904c9cbcb89..eec0737abddd 100644
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
index 6b9dbdc52b47..a4636aac165e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4981,16 +4981,19 @@ nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
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
+	return nfsd4_client_record_check(cstate->clp) ?
+		nfserr_reclaim_bad : nfs_ok;
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

