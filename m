Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37808 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab3EXWMe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 May 2013 18:12:34 -0400
Date: Fri, 24 May 2013 18:12:28 -0400
To: linux-nfs@vger.kernel.org
Cc: Jan Stancek <jstancek@redhat.com>, simo@redhat.com
Subject: [PATCH] svcrpc: implement O_NONBLOCK behavior for use-gss-proxy
Message-ID: <20130524221228.GB28309@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Somebody noticed LTP was complaining about O_NONBLOCK opens of
/proc/net/rpc/use-gss-proxy succeeding and then a following read
hanging.

I'm not convinced LTP really has any business opening random proc files
and expecting them to behave a certain way.  And I don't really know if
this is really a bug.

But in any case perhaps the O_NONBLOCK behavior could be useful for
someone that wants to test whether gss-proxy is up without waiting.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Considering for 3.10.

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 9f0f017..618ccf5 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1313,10 +1313,12 @@ static inline bool gssp_ready(struct sunrpc_net *sn)
 	return false;
 }
 
-static int wait_for_gss_proxy(struct net *net)
+static int wait_for_gss_proxy(struct net *net, struct file *file)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
+	if (file->f_flags & O_NONBLOCK && !gssp_ready(sn))
+		return -EAGAIN;
 	return wait_event_interruptible(sn->gssp_wq, gssp_ready(sn));
 }
 
@@ -1358,7 +1360,7 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
 	size_t len;
 	int ret;
 
-	ret = wait_for_gss_proxy(net);
+	ret = wait_for_gss_proxy(net, file);
 	if (ret)
 		return ret;
 
-- 
1.7.9.5

