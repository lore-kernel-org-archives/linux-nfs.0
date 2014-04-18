Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:38495 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437AbaDRSqJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:09 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so1907047ieb.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 41/70] NFSd: nfsd4_process_open2() must reference the delegation stateid
Date: Fri, 18 Apr 2014 14:44:35 -0400
Message-Id: <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that nfsd4_process_open2() keeps a reference to the delegation
stateid until it is done working with it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d1e4f0e07f09..634cd4de9d32 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3068,6 +3068,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -3083,14 +3085,18 @@ nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
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
@@ -3528,6 +3534,8 @@ out:
 	if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED) &&
 	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
+	if (dp)
+		nfs4_put_delegation(dp);
 
 	return status;
 }
-- 
1.9.0

