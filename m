Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:53353 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754233AbaDRSq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:26 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so944166igq.7
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 52/70] NFSd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
Date: Fri, 18 Apr 2014 14:44:46 -0400
Message-Id: <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 2 +-
 fs/nfsd/nfs4state.c | 7 ++++---
 fs/nfsd/state.h     | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a23da87b384e..1101bf6b63c8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -432,7 +432,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		case NFS4_OPEN_CLAIM_PREVIOUS:
 			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 			status = nfs4_check_open_reclaim(&open->op_clientid,
-							 cstate->minorversion,
+							 cstate->session,
 							 nn);
 			if (status)
 				goto out;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d316fe10b9aa..1708f6b7e9e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5068,13 +5068,14 @@ nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
 * Called from OPEN. Look for clientid in reclaim list.
 */
 __be32
-nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
+nfs4_check_open_reclaim(clientid_t *clid, struct nfsd4_session *session, struct nfsd_net *nn)
 {
 	struct nfs4_client *clp;
+	__be32 status;
 
 	/* find clientid in conf_id_hashtbl */
-	clp = find_confirmed_client(clid, sessions, nn);
-	if (clp == NULL)
+	status = lookup_clientid(clid, session, nn, &clp);
+	if (status)
 		return nfserr_reclaim_bad;
 
 	return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index a4ac75a0de21..b6187676d991 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -435,7 +435,7 @@ void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *)
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
-extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
+extern __be32 nfs4_check_open_reclaim(clientid_t *clid, struct nfsd4_session *session, struct nfsd_net *nn);
 extern int set_callback_cred(void);
 extern void nfsd4_init_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
-- 
1.9.0

