Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:37144 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbbBSTgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2015 14:36:20 -0500
Received: by pabrd3 with SMTP id rd3so2032370pab.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:36:20 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1: Don't set up a backchannel if the server didn't agree to do so
Date: Thu, 19 Feb 2015 11:36:09 -0800
Message-Id: <1424374571-4945-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1424374571-4945-1-git-send-email-trond.myklebust@primarydata.com>
References: <1424374571-4945-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server doesn't agree to out backchannel setup request, then
don't set one up.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 2 ++
 fs/nfs/nfs4proc.c      | 7 ++++++-
 fs/nfs/nfs4session.c   | 2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e36a9d78ea49..197806fb87ff 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -427,6 +427,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (clp == NULL)
 		goto out;
 
+	if (!(clp->cl_session->flags & SESSION4_BACK_CHAN))
+		goto out;
 	tbl = &clp->cl_session->bc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 006bfa3da55b..59853797825c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7195,6 +7195,8 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 	struct nfs4_channel_attrs *sent = &args->bc_attrs;
 	struct nfs4_channel_attrs *rcvd = &res->bc_attrs;
 
+	if (!(res->flags & SESSION4_BACK_CHAN))
+		goto out;
 	if (rcvd->max_rqst_sz > sent->max_rqst_sz)
 		return -EINVAL;
 	if (rcvd->max_resp_sz < sent->max_resp_sz)
@@ -7206,6 +7208,7 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 		return -EINVAL;
 	if (rcvd->max_reqs != sent->max_reqs)
 		return -EINVAL;
+out:
 	return 0;
 }
 
@@ -7226,7 +7229,9 @@ static void nfs4_update_session(struct nfs4_session *session,
 	nfs4_copy_sessionid(&session->sess_id, &res->sessionid);
 	session->flags = res->flags;
 	memcpy(&session->fc_attrs, &res->fc_attrs, sizeof(session->fc_attrs));
-	memcpy(&session->bc_attrs, &res->bc_attrs, sizeof(session->bc_attrs));
+	if (res->flags & SESSION4_BACK_CHAN)
+		memcpy(&session->bc_attrs, &res->bc_attrs,
+				sizeof(session->bc_attrs));
 }
 
 static int _nfs4_proc_create_session(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index e799dc3c3b1d..e23366effcfb 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -450,7 +450,7 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	tbl = &ses->fc_slot_table;
 	tbl->session = ses;
 	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
-	if (status) /* -ENOMEM */
+	if (status || !(ses->flags & SESSION4_BACK_CHAN)) /* -ENOMEM */
 		return status;
 	/* Back channel */
 	tbl = &ses->bc_slot_table;
-- 
2.1.0

