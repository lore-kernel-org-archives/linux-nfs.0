Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbdBXWUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:05 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 03/17] SELINUX export security_current_sid_to_context
Date: Fri, 24 Feb 2017 17:19:39 -0500
Message-ID: <20170224221953.5502-4-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RPCSEC_GSS Version 3 label assertions require the client thread
sid in string context form

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/selinux.h  |  7 +++++++
 security/selinux/hooks.c | 14 ++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/selinux.h b/include/linux/selinux.h
index 44f4596..e82a4ba 100644
--- a/include/linux/selinux.h
+++ b/include/linux/selinux.h
@@ -24,12 +24,19 @@ struct kern_ipc_perm;
  * selinux_is_enabled - is SELinux enabled?
  */
 bool selinux_is_enabled(void);
+int security_current_sid_to_context(char **scontext, u32 *scontext_len);
 #else
 
 static inline bool selinux_is_enabled(void)
 {
 	return false;
 }
+
+static inline int
+security_current_sid_to_context(char **scontext, u32 *scontext_len)
+{
+	return -EINVAL;
+}
 #endif	/* CONFIG_SECURITY_SELINUX */
 
 #endif /* _LINUX_SELINUX_H */
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c7c6619..a65f6dc 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6492,3 +6492,17 @@ int selinux_disable(void)
 	return 0;
 }
 #endif
+
+/**
+ * RPCSEC_GSS Version 3 Full Mode labeling needs this interface
+ * or one like it.
+ */
+int security_current_sid_to_context(char **scontext, u32 *scontext_len)
+{
+	const struct task_security_struct *ts = current_security();
+
+	if (!selinux_enabled)
+		return -EINVAL;
+	return security_sid_to_context(ts->sid, scontext, scontext_len);
+}
+EXPORT_SYMBOL_GPL(security_current_sid_to_context);
-- 
2.9.3

