From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NLM: Clean up flow of control in make_socks() function
Date: Wed, 31 Dec 2008 16:06:11 -0500
Message-ID: <20081231210611.4959.84900.stgit@ingres.1015granger.net>
References: <20081231210449.4959.41094.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:60184 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYLaVHD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Dec 2008 16:07:03 -0500
In-Reply-To: <20081231210449.4959.41094.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use Bruce's preferred control flow style in make_socks().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 955cfac..3fdc83c 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -224,17 +224,23 @@ static int create_lockd_listener(struct svc_serv *serv, char *name,
 static int make_socks(struct svc_serv *serv)
 {
 	static int warned;
-	int err = 0;
+	int err;
 
 	err = create_lockd_listener(serv, "udp", nlm_udpport);
-	if (err >= 0)
-		err = create_lockd_listener(serv, "tcp", nlm_tcpport);
-	if (err >= 0) {
-		warned = 0;
-		err = 0;
-	} else if (warned++ == 0)
+	if (err < 0)
+		goto out_err;
+
+	err = create_lockd_listener(serv, "tcp", nlm_tcpport);
+	if (err < 0)
+		goto out_err;
+
+	warned = 0;
+	return 0;
+
+out_err:
+	if (warned++ == 0)
 		printk(KERN_WARNING
-		       "lockd_up: makesock failed, error=%d\n", err);
+			"lockd_up: makesock failed, error=%d\n", err);
 	return err;
 }
 

