Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:35395 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756595AbaFZKtY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 06:49:24 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so2647392qac.27
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 03:49:23 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix file access refcount leak when nfsd4_truncate fails
Date: Thu, 26 Jun 2014 06:49:16 -0400
Message-Id: <1403779756-5070-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently will get access to the file, and then call nfsd4_truncate
to (possibly) truncate it. If that operation fails though, then the
access references will never be released as the nfs4_ol_stateid is
never initialized.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2204e1fe5725..3b19008c2978 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3351,8 +3351,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (status)
 			goto out;
 		status = nfsd4_truncate(rqstp, current_fh, open);
-		if (status)
+		if (status) {
+			nfs4_file_put_access(fp,
+				nfs4_access_to_omode(open->op_share_access));
 			goto out;
+		}
 		stp = open->op_stp;
 		open->op_stp = NULL;
 		init_open_stateid(stp, fp, open);
-- 
1.9.3

