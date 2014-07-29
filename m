Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:56376 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaG2Uet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:49 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so303109qgd.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 13/38] nfsd: nfsd4_process_open2() must reference the delegation stateid
Date: Tue, 29 Jul 2014 16:33:56 -0400
Message-Id: <1406666061-14175-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_process_open2() keeps a reference to the delegation
stateid until it is done working with it. Necessary step toward
client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ddb6706e2046..2020303fd100 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3325,6 +3325,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -3340,14 +3342,18 @@ nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
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
+		nfs4_put_stid(&deleg->dl_stid);
+		goto out;
+	}
+	*dp = deleg;
 out:
 	if (!nfsd4_is_deleg_cur(open))
 		return nfs_ok;
@@ -3828,6 +3834,8 @@ out:
 	if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED) &&
 	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
+	if (dp)
+		nfs4_put_stid(&dp->dl_stid);
 
 	return status;
 }
-- 
1.9.3

