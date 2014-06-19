Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:45955 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213AbaFSOwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:33 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2284513qcz.14
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:33 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 066/104] NFSd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
Date: Thu, 19 Jun 2014 10:50:12 -0400
Message-Id: <1403189450-18729-67-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
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
index 72e673781e6b..833c753e4775 100644
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
index 7bb7dd19e275..dd436ebf1123 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5446,16 +5446,19 @@ nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
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
index 747ab44b806a..880b5acd05f3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -440,7 +440,8 @@ void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *)
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
-extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
+extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
+		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
 extern int set_callback_cred(void);
 extern void nfsd4_init_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
-- 
1.9.3

