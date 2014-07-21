Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:39724 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932187AbaGUNhh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:37:37 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so5316653qgd.40
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:37:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: print status when nfsd4_open fails to open file it just created
Date: Mon, 21 Jul 2014 09:37:30 -0400
Message-Id: <1405949850-27841-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for nfsd to fail opening a file that it has just created.
When that happens, we throw a WARN but it doesn't include any info about
the error code. Print the status code to give us a bit more info.

Our QA group hit some of these warnings under some very heavy stress
testing. My suspicion is that they hit the file-max limit, but it's hard
to know for sure. Go ahead and add a -ENFILE mapping to
nfserr_serverfault to make the error more distinct (and correct).

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 4 +++-
 fs/nfsd/nfsproc.c  | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 29a617ebe38c..8611585f739d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -460,7 +460,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
 	 */
 	status = nfsd4_process_open2(rqstp, resfh, open);
-	WARN_ON(status && open->op_created);
+	WARN(status && open->op_created,
+	     "nfsd4_process_open2 failed to open newly-created file! status=%u\n",
+	     be32_to_cpu(status));
 out:
 	if (resfh && resfh != &cstate->current_fh) {
 		fh_dup2(&cstate->current_fh, resfh);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index b19c7e8bf64c..b8680738f588 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -745,6 +745,7 @@ nfserrno (int errno)
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
+		{ nfserr_serverfault, -ENFILE },
 	};
 	int	i;
 
-- 
1.9.3

