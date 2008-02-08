From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] NLM: LOCKD fails to load if CONFIG_SYSCTL is not set
Date: Fri, 08 Feb 2008 12:52:44 -0500
Message-ID: <20080208175244.16261.56686.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:9658 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318AbYBHRwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, we've got another config-related nit here:

	http://bugzilla.linux-nfs.org/show_bug.cgi?id=156

You can build lockd without CONFIG_SYSCTL set, but then the module will
fail to load.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig     |    1 +
 fs/lockd/svc.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index f799964..b7aeed4 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1734,6 +1734,7 @@ config NFSD_V4
 
 config LOCKD
 	tristate
+	select SYSCTL
 
 config LOCKD_V4
 	bool
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..adb8e2c 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -516,8 +516,12 @@ module_param(nsm_use_hostnames, bool, 0644);
 
 static int __init init_nlm(void)
 {
+#if CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
 	return nlm_sysctl_table ? 0 : -ENOMEM;
+#else
+	return 0;
+#endif
 }
 
 static void __exit exit_nlm(void)

