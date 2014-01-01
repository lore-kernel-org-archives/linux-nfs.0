Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:63602 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaAAM2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jan 2014 07:28:43 -0500
Received: by mail-qc0-f177.google.com with SMTP id m20so12589069qcx.36
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jan 2014 04:28:43 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com, bfields@fieldses.org, neilb@suse.de
Subject: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing reads from use-gss-proxy file
Date: Wed,  1 Jan 2014 07:28:30 -0500
Message-Id: <1388579314-15255-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It doesn't make much sense to make reads from this procfile hang. As
far as I can tell, only gssproxy itself will open this file and it
never reads from it. Change it to just give the present setting of
sn->use_gss_proxy without waiting for anything.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 008cdad..5e9323e 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1355,16 +1355,12 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
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
-- 
1.8.4.2

