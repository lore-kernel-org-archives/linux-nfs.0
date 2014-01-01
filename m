Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f43.google.com ([209.85.128.43]:50033 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaAAM2r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jan 2014 07:28:47 -0500
Received: by mail-qe0-f43.google.com with SMTP id jy17so13242188qeb.2
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jan 2014 04:28:46 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com, bfields@fieldses.org, neilb@suse.de
Subject: [RFC PATCH 5/5] sunrpc: allow gssproxy to be explicitly disabled from userland
Date: Wed,  1 Jan 2014 07:28:34 -0500
Message-Id: <1388579314-15255-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Writing anything but '1' to the use-gss-proxy file currently results in
an error. This means that you can't explicitly disable gssproxy. Change
it so that it allows a '0' to be written there as well.

With this, we can potentially have rpc.svcgssd write a 0 to this file
to get around the initial 5s hang on RPCs if gssproxy is not in use.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 17c24bd..aa30d49 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1342,12 +1342,20 @@ static ssize_t write_gssp(struct file *file, const char __user *buf,
 	res = kstrtoul(tbuf, 0, &i);
 	if (res)
 		return res;
-	if (i != 1)
+
+	switch (i) {
+	case 1:
+		res = set_gssp_clnt(net);
+		if (res)
+			return res;
+		break;
+	case 0:
+		break;
+	default:
 		return -EINVAL;
-	res = set_gssp_clnt(net);
-	if (res)
-		return res;
-	res = set_gss_proxy(net, 1);
+	}
+
+	res = set_gss_proxy(net, i);
 	if (res)
 		return res;
 	return count;
-- 
1.8.4.2

