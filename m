Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx61.netapp.com ([216.240.31.181]:5252 "EHLO mx61.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752710AbdG1Ubi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:31:38 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 01/12] SELINUX export security_current_sid_to_context
Date: Fri, 28 Jul 2017 16:21:47 -0400
Message-ID: <1501273318-14200-2-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RPCSEC_GSS Version 3 label assertions require the client thread
sid in string context form, and so needs this interface
or one like it.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/selinux.h  |  7 +++++++
 security/selinux/hooks.c | 10 ++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/selinux.h b/include/linux/selinux.h
index 44f4596..e82a4ba 100644
--- a/include/linux/selinux.h
+++ b/include/linux/selinux.h
@@ -24,12 +24,19 @@
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
index 819fd68..ba6974b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6516,3 +6516,13 @@ int selinux_disable(void)
 	return 0;
 }
 #endif
+
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
1.8.3.1

