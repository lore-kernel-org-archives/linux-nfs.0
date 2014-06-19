Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:44910 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbaFSOvv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:51 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2166098qga.23
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 037/104] NFSd: nfsd4_process_open2() must reference the delegation stateid
Date: Thu, 19 Jun 2014 10:49:43 -0400
Message-Id: <1403189450-18729-38-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_process_open2() keeps a reference to the delegation
stateid until it is done working with it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cf3b19bb5839..4878faec4c68 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3180,6 +3180,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -3195,14 +3197,18 @@ nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
 {
 	int flags;
 	__be32 status = nfserr_bad_stateid;
+	struct nfs4_delegation *deleg;
 
-	*dp = find_deleg_stateid(cl, &open->op_delegate_stateid);
-	if (*dp == NULL)
+	deleg = find_deleg_stateid(cl, &open->op_delegate_stateid);
+	if (deleg == NULL)
 		goto out;
 	flags = share_access_to_flags(open->op_share_access);
-	status = nfs4_check_delegmode(*dp, flags);
-	if (status)
-		*dp = NULL;
+	status = nfs4_check_delegmode(deleg, flags);
+	if (status) {
+		nfs4_put_delegation(deleg);
+		goto out;
+	}
+	*dp = deleg;
 out:
 	if (!nfsd4_is_deleg_cur(open))
 		return nfs_ok;
@@ -3644,6 +3650,8 @@ out:
 	if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED) &&
 	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
+	if (dp)
+		nfs4_put_delegation(dp);
 
 	return status;
 }
-- 
1.9.3

