Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8606 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755837AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 03/16] SELINUX export security_current_sid_to_context
Date: Fri, 23 Dec 2016 11:04:15 -0500
Message-ID: <1482509068-24516-4-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RPCSEC_GSS Version 3 label assertions require the client thread
sid in string context form

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/selinux.h  |  1 +
 security/selinux/hooks.c | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/selinux.h b/include/linux/selinux.h
index 44f4596..3dfaf41 100644
--- a/include/linux/selinux.h
+++ b/include/linux/selinux.h
@@ -24,6 +24,7 @@
  * selinux_is_enabled - is SELinux enabled?
  */
 bool selinux_is_enabled(void);
+int security_current_sid_to_context(char **scontext, u32 *scontext_len);
 #else
 
 static inline bool selinux_is_enabled(void)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 09fd610..f355c49 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6463,3 +6463,15 @@ int selinux_disable(void)
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
+	return security_sid_to_context(ts->sid, scontext, scontext_len);
+}
+EXPORT_SYMBOL_GPL(security_current_sid_to_context);
-- 
1.8.3.1

