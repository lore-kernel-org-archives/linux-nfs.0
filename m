Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36600 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbcDVAwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2016 20:52:12 -0400
Received: by mail-qk0-f178.google.com with SMTP id x7so33030600qkd.3
        for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2016 17:52:12 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/7] sunrpc: add a get_rpccred_rcu inline
Date: Thu, 21 Apr 2016 20:51:56 -0400
Message-Id: <1461286320-24601-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
References: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sometimes we might have a RCU managed credential pointer and don't want
to use locking to handle it. Add a function that will take a reference
to the cred iff the refcount is not already zero. Callers can dereference
the pointer under the rcu_read_lock and use that function to take a
reference only if the cred is not on its way to destruction.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/auth.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 16bd8f8fef8c..6f36b2bf3e05 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -206,5 +206,23 @@ struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 	return cred;
 }
 
+/**
+ * get_rpccred_rcu - get a reference to a cred using rcu-protected pointer
+ * @cred: cred of which to take a reference
+ *
+ * In some cases, we may have a pointer to a credential to which we
+ * want to take a reference, but don't already have one. Because these
+ * objects are freed using RCU, we can access the cr_count while its
+ * on its way to destruction and only take a reference if it's not already
+ * zero.
+ */
+static inline struct rpc_cred *
+get_rpccred_rcu(struct rpc_cred *cred)
+{
+	if (atomic_inc_not_zero(&cred->cr_count))
+		return cred;
+	return NULL;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_AUTH_H */
-- 
2.5.5

