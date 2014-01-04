Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f52.google.com ([209.85.128.52]:54720 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaADMSO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jan 2014 07:18:14 -0500
Received: by mail-qe0-f52.google.com with SMTP id ne12so16194455qeb.25
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jan 2014 04:18:13 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: [PATCH 1/3] sunrpc: don't wait for write before allowing reads from use-gss-proxy file
Date: Sat,  4 Jan 2014 07:18:03 -0500
Message-Id: <1388837885-8312-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It doesn't make much sense to make reads from this procfile hang. As
far as I can tell, only gssproxy itself will open this file and it
never reads from it. Change it to just give the present setting of
sn->use_gss_proxy without waiting for anything.

Note that we do not want to call use_gss_proxy() in this codepath
since an inopportune read of this file could cause it to be disabled
prematurely.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  2 --
 net/sunrpc/auth_gss/svcauth_gss.c    | 33 ++-------------------------------
 net/sunrpc/netns.h                   |  1 -
 3 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 458f85e..abbb7dc 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -137,7 +137,6 @@ void init_gssp_clnt(struct sunrpc_net *sn)
 {
 	mutex_init(&sn->gssp_lock);
 	sn->gssp_clnt = NULL;
-	init_waitqueue_head(&sn->gssp_wq);
 }
 
 int set_gssp_clnt(struct net *net)
@@ -154,7 +153,6 @@ int set_gssp_clnt(struct net *net)
 		sn->gssp_clnt = clnt;
 	}
 	mutex_unlock(&sn->gssp_lock);
-	wake_up(&sn->gssp_wq);
 	return ret;
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 008cdad..1b94a9c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1295,34 +1295,9 @@ static int set_gss_proxy(struct net *net, int type)
 	else
 		ret = -EBUSY;
 	spin_unlock(&use_gssp_lock);
-	wake_up(&sn->gssp_wq);
 	return ret;
 }
 
-static inline bool gssp_ready(struct sunrpc_net *sn)
-{
-	switch (sn->use_gss_proxy) {
-		case -1:
-			return false;
-		case 0:
-			return true;
-		case 1:
-			return sn->gssp_clnt;
-	}
-	WARN_ON_ONCE(1);
-	return false;
-}
-
-static int wait_for_gss_proxy(struct net *net, struct file *file)
-{
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-	if (file->f_flags & O_NONBLOCK && !gssp_ready(sn))
-		return -EAGAIN;
-	return wait_event_interruptible(sn->gssp_wq, gssp_ready(sn));
-}
-
-
 static ssize_t write_gssp(struct file *file, const char __user *buf,
 			 size_t count, loff_t *ppos)
 {
@@ -1355,16 +1330,12 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
 			 size_t count, loff_t *ppos)
 {
 	struct net *net = PDE_DATA(file_inode(file));
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	unsigned long p = *ppos;
 	char tbuf[10];
 	size_t len;
-	int ret;
-
-	ret = wait_for_gss_proxy(net, file);
-	if (ret)
-		return ret;
 
-	snprintf(tbuf, sizeof(tbuf), "%d\n", use_gss_proxy(net));
+	snprintf(tbuf, sizeof(tbuf), "%d\n", sn->use_gss_proxy);
 	len = strlen(tbuf);
 	if (p >= len)
 		return 0;
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 779742c..3a260e4 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -26,7 +26,6 @@ struct sunrpc_net {
 	unsigned int rpcb_is_af_local : 1;
 
 	struct mutex gssp_lock;
-	wait_queue_head_t gssp_wq;
 	struct rpc_clnt *gssp_clnt;
 	int use_gss_proxy;
 	int pipe_version;
-- 
1.8.4.2

