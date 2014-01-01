Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:50116 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbaAAM2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jan 2014 07:28:44 -0500
Received: by mail-qc0-f182.google.com with SMTP id e16so12805830qcx.27
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jan 2014 04:28:44 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com, bfields@fieldses.org, neilb@suse.de
Subject: [RFC PATCH 2/5] sunrpc: don't hang indefinitely in wait_for_gss_proxy
Date: Wed,  1 Jan 2014 07:28:31 -0500
Message-Id: <1388579314-15255-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A later patch will make upcalls delay for a bit if gssproxy isn't
up yet. Make wait_for_gss_proxy just delay for a little while before
giving up and disabling it. The 5s here is definitely negotiable.

Also, since there are no callers now, we can get rid of the file
pointer here and eliminate the O_NONBLOCK goop.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 5e9323e..64c025e 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1313,13 +1313,23 @@ static inline bool gssp_ready(struct sunrpc_net *sn)
 	return false;
 }
 
-static int wait_for_gss_proxy(struct net *net, struct file *file)
+/*
+ * The initial upcall to gssproxy will wait 5s for the use_gss_proxy
+ * var to change to something besides -1.
+ */
+#define GSSP_INITIAL_UPCALL_TIMEOUT	(5 * HZ)
+
+static int wait_for_gss_proxy(struct net *net)
 {
+	int ret;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
-	if (file->f_flags & O_NONBLOCK && !gssp_ready(sn))
-		return -EAGAIN;
-	return wait_event_interruptible(sn->gssp_wq, gssp_ready(sn));
+	ret = wait_event_interruptible_timeout(sn->gssp_wq, gssp_ready(sn),
+					       GSSP_INITIAL_UPCALL_TIMEOUT);
+	/* If we timed out, disable gssp */
+	if (ret == 0)
+		set_gss_proxy(net, 0);
+	return ret < 0 ? ret : 0;
 }
 
 
-- 
1.8.4.2

