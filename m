Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:42369 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbaGOQ7m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:59:42 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so2686873qcy.16
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 09:59:42 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: silence sparse warning about accessing credentials
Date: Tue, 15 Jul 2014 12:59:36 -0400
Message-Id: <1405443576-28348-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sparse says:

    fs/nfsd/auth.c:31:38: warning: incorrect type in argument 1 (different address spaces)
    fs/nfsd/auth.c:31:38:    expected struct cred const *cred
    fs/nfsd/auth.c:31:38:    got struct cred const [noderef] <asn:4>*real_cred

Add a new accessor for the ->real_cred and use that to fetch the
pointer. Accessing current->real_cred directly is actually quite safe
since we know that they can't go away so this is mostly a cosmetic fixup
to silence sparse.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/auth.c       | 2 +-
 include/linux/cred.h | 9 +++++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 72f44823adbb..9d46a0bdd9f9 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -28,7 +28,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	validate_process_creds();
 
 	/* discard any old override before preparing the new set */
-	revert_creds(get_cred(current->real_cred));
+	revert_creds(get_cred(current_real_cred()));
 	new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
diff --git a/include/linux/cred.h b/include/linux/cred.h
index f61d6c8f5ef3..b2d0820837c4 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -259,6 +259,15 @@ static inline void put_cred(const struct cred *_cred)
 	rcu_dereference_protected(current->cred, 1)
 
 /**
+ * current_real_cred - Access the current task's objective credentials
+ *
+ * Access the objective credentials of the current task.  RCU-safe,
+ * since nobody else can modify it.
+ */
+#define current_real_cred() \
+	rcu_dereference_protected(current->real_cred, 1)
+
+/**
  * __task_cred - Access a task's objective credentials
  * @task: The task to query
  *
-- 
1.9.3

