From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NLM: LOCKD fails to load if CONFIG_SYSCTL is not set
Date: Fri, 14 Mar 2008 14:18:30 -0400
Message-ID: <20080314181830.29948.92805.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:30345 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbYCNSSt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:18:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce Fields says:
"By the way, we've got another config-related nit here:

	http://bugzilla.linux-nfs.org/show_bug.cgi?id=156

You can build lockd without CONFIG_SYSCTL set, but then the module will
fail to load."

For now, disable the sysctl registration calls in lockd if CONFIG_SYSCTL
is not enabled.  This allows the kernel to build properly if PROC_FS or
SYSCTL is not enabled, but an NFS client is desired.

In the long run, we would like to be able to build the kernel with an
NFS client but without lockd.  This makes sense, for example, if you want
an NFSv4-only NFS client, as NFSv4 doesn't use NLM at all.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1ed8bd4..38c2f0b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -74,7 +74,9 @@ static const unsigned long	nlm_timeout_min = 3;
 static const unsigned long	nlm_timeout_max = 20;
 static const int		nlm_port_min = 0, nlm_port_max = 65535;
 
+#ifdef CONFIG_SYSCTL
 static struct ctl_table_header * nlm_sysctl_table;
+#endif
 
 static unsigned long get_lockd_grace_period(void)
 {
@@ -359,6 +361,8 @@ out:
 }
 EXPORT_SYMBOL(lockd_down);
 
+#ifdef CONFIG_SYSCTL
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
@@ -443,6 +447,8 @@ static ctl_table nlm_sysctl_root[] = {
 	{ .ctl_name = 0 }
 };
 
+#endif	/* CONFIG_SYSCTL */
+
 /*
  * Module (and sysfs) parameters.
  */
@@ -516,15 +522,21 @@ module_param(nsm_use_hostnames, bool, 0644);
 
 static int __init init_nlm(void)
 {
+#ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
 	return nlm_sysctl_table ? 0 : -ENOMEM;
+#else
+	return 0;
+#endif
 }
 
 static void __exit exit_nlm(void)
 {
 	/* FIXME: delete all NLM clients */
 	nlm_shutdown_hosts();
+#ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
+#endif
 }
 
 module_init(init_nlm);

