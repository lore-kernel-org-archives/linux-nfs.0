Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:46300 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbaADMSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jan 2014 07:18:16 -0500
Received: by mail-qa0-f54.google.com with SMTP id f11so1375537qae.20
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jan 2014 04:18:15 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: [PATCH 3/3] sunrpc: get rid of use_gssp_lock
Date: Sat,  4 Jan 2014 07:18:05 -0500
Message-Id: <1388837885-8312-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can achieve the same result with a cmpxchg(). This also fixes a
potential race in use_gss_proxy(). The value of sn->use_gss_proxy could
go from -1 to 1 just after we check it in use_gss_proxy() but before we
acquire the spinlock. The procfile write would end up returning success
but the value would flip to 0 soon afterward. With this method we not
only avoid locking but the first "setter" always wins.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 42 +++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 60dc370..2a93540 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1263,41 +1263,35 @@ out:
 	return ret;
 }
 
-DEFINE_SPINLOCK(use_gssp_lock);
-
-static bool use_gss_proxy(struct net *net)
+/*
+ * Try to set the sn->use_gss_proxy variable to a new value. We only allow
+ * it to be changed if it's currently undefined (-1). If it's any other value
+ * then return -EBUSY unless the type wouldn't have changed anyway.
+ */
+static int set_gss_proxy(struct net *net, int type)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	int ret;
 
-	if (sn->use_gss_proxy != -1)
-		return sn->use_gss_proxy;
-	spin_lock(&use_gssp_lock);
-	/*
-	 * If you wanted gss-proxy, you should have said so before
-	 * starting to accept requests:
-	 */
-	sn->use_gss_proxy = 0;
-	spin_unlock(&use_gssp_lock);
+	WARN_ON_ONCE(type != 0 && type != 1);
+	ret = cmpxchg(&sn->use_gss_proxy, -1, type);
+	if (ret != -1 && ret != type)
+		return -EBUSY;
 	return 0;
 }
 
-#ifdef CONFIG_PROC_FS
-
-static int set_gss_proxy(struct net *net, int type)
+static bool use_gss_proxy(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-	int ret = 0;
 
-	WARN_ON_ONCE(type != 0 && type != 1);
-	spin_lock(&use_gssp_lock);
-	if (sn->use_gss_proxy == -1 || sn->use_gss_proxy == type)
-		sn->use_gss_proxy = type;
-	else
-		ret = -EBUSY;
-	spin_unlock(&use_gssp_lock);
-	return ret;
+	/* If use_gss_proxy is still undefined, then try to disable it */
+	if (sn->use_gss_proxy == -1)
+		set_gss_proxy(net, 0);
+	return sn->use_gss_proxy;
 }
 
+#ifdef CONFIG_PROC_FS
+
 static ssize_t write_gssp(struct file *file, const char __user *buf,
 			 size_t count, loff_t *ppos)
 {
-- 
1.8.4.2

