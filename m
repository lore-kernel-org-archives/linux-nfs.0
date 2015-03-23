Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33869 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCWOx7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 10:53:59 -0400
Received: by ykfc206 with SMTP id c206so72977013ykf.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 07:53:58 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfsd: remove unused status arg to nfsd4_cleanup_open_state
Date: Mon, 23 Mar 2015 10:53:44 -0400
Message-Id: <1427122424-8078-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 2 +-
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/xdr4.h      | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d30bea8d0277..e54f18ae5b2e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -470,7 +470,7 @@ out:
 		fh_put(resfh);
 		kfree(resfh);
 	}
-	nfsd4_cleanup_open_state(cstate, open, status);
+	nfsd4_cleanup_open_state(cstate, open);
 	nfsd4_bump_seqid(cstate, status);
 	return status;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a66e297dc01c..3d9b0b9b1e2c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4117,7 +4117,7 @@ out:
 }
 
 void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
-			      struct nfsd4_open *open, __be32 status)
+			      struct nfsd4_open *open)
 {
 	if (open->op_openowner) {
 		struct nfs4_stateowner *so = &open->op_openowner->oo_owner;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0bda93e58e1b..83e80d6d94a6 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -683,7 +683,7 @@ extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate);
 extern void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
-		struct nfsd4_open *open, __be32 status);
+		struct nfsd4_open *open);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);
 extern __be32 nfsd4_close(struct svc_rqst *rqstp,
-- 
2.1.0

