Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:61934 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933272AbaLMOLt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Dec 2014 09:11:49 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so6612471qge.4
        for <linux-nfs@vger.kernel.org>; Sat, 13 Dec 2014 06:11:48 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: fix fi_delegees leak when fi_had_conflict returns true
Date: Sat, 13 Dec 2014 09:11:39 -0500
Message-Id: <1418479900-4757-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
References: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nfs4_set_delegation takes a reference to an existing
delegation and then checks to see if there is a conflict. If there is
one, then it doesn't release that reference.

Change the code to take the reference after the check and only if there
is no conflict.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f62e8051e2b..86bc2882bffc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3898,11 +3898,11 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		status = nfs4_setlease(dp);
 		goto out;
 	}
-	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
 		status = -EAGAIN;
 		goto out_unlock;
 	}
+	atomic_inc(&fp->fi_delegees);
 	hash_delegation_locked(dp, fp);
 	status = 0;
 out_unlock:
-- 
2.1.0

