Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f52.google.com ([209.85.128.52]:35560 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbaADMSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jan 2014 07:18:15 -0500
Received: by mail-qe0-f52.google.com with SMTP id ne12so16720496qeb.11
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jan 2014 04:18:14 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: [PATCH 2/3] sunrpc: fix potential race between setting use_gss_proxy and the upcall rpc_clnt
Date: Sat,  4 Jan 2014 07:18:04 -0500
Message-Id: <1388837885-8312-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the write_gssp code will change the variable and wake up any
waiters waiting on that change. It then goes and tries to set the
gssp_clnt. This is racy -- a task waiting on the set_gss_proxy call may
end up waking up and then subsequently finding that the gss_clnt isn't
there yet and end up not using it even though it'll soon be ready.

This patch reverses the order of operations. The gssp_clnt is created
first, and the variable change is done only if that succeeds.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1b94a9c..60dc370 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1317,10 +1317,10 @@ static ssize_t write_gssp(struct file *file, const char __user *buf,
 		return res;
 	if (i != 1)
 		return -EINVAL;
-	res = set_gss_proxy(net, 1);
+	res = set_gssp_clnt(net);
 	if (res)
 		return res;
-	res = set_gssp_clnt(net);
+	res = set_gss_proxy(net, 1);
 	if (res)
 		return res;
 	return count;
-- 
1.8.4.2

