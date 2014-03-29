Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:63091 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbaC2Snn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Mar 2014 14:43:43 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so6045148iec.24
        for <linux-nfs@vger.kernel.org>; Sat, 29 Mar 2014 11:43:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: Idan Kedar <idank@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd: Don't return NFS4ERR_RESTOREFH for NFSv4.1+
Date: Sat, 29 Mar 2014 14:43:39 -0400
Message-Id: <1396118619-12771-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
References: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 obsoletes NFS4ERR_RESTOREFH in favour of NFS4ERR_NOFILEHANDLE.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 82189b208af3..eeee4418d44a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -536,8 +536,11 @@ static __be32
 nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		void *arg)
 {
-	if (!cstate->save_fh.fh_dentry)
+	if (!cstate->save_fh.fh_dentry) {
+		if (nfsd4_has_session(cstate))
+			return nfserr_nofilehandle;
 		return nfserr_restorefh;
+	}
 
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
 	if (HAS_STATE_ID(cstate, SAVED_STATE_ID_FLAG)) {
-- 
1.9.0

