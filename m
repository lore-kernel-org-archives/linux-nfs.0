Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EB55C10F05
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 63F9621473
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730605AbfCZWGb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44956 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731483AbfCZWGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F06733086230;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AD34960C96;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 1B79A21343; Tue, 26 Mar 2019 18:06:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC v3 4/5] nfsd: re-order client tracking method selection
Date:   Tue, 26 Mar 2019 18:06:29 -0400
Message-Id: <20190326220630.2911-5-smayhew@redhat.com>
In-Reply-To: <20190326220630.2911-1-smayhew@redhat.com>
References: <20190326220630.2911-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The new order is first nfsdcld, then the UMH upcall, and finally the
legacy tracking method.  Added some printk's to the tracking
initialization functions so it's clear which tracking method was
ultimately selected.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c | 80 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 65 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 09e3c9352778..d60001da1dbf 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -628,6 +628,7 @@ nfsd4_legacy_tracking_init(struct net *net)
 	status = nfsd4_load_reboot_recovery_data(net);
 	if (status)
 		goto err;
+	printk("NFSD: Using legacy client tracking operations.\n");
 	return 0;
 
 err:
@@ -937,7 +938,7 @@ nfsd4_cld_unregister_net(struct net *net, struct rpc_pipe *pipe)
 
 /* Initialize rpc_pipefs pipe for communication with client tracking daemon */
 static int
-nfsd4_init_cld_pipe(struct net *net)
+__nfsd4_init_cld_pipe(struct net *net)
 {
 	int ret;
 	struct dentry *dentry;
@@ -980,6 +981,17 @@ nfsd4_init_cld_pipe(struct net *net)
 	return ret;
 }
 
+static int
+nfsd4_init_cld_pipe(struct net *net)
+{
+	int status;
+
+	status = __nfsd4_init_cld_pipe(net);
+	if (!status)
+		printk("NFSD: Using old nfsdcld client tracking operations.\n");
+	return status;
+}
+
 static void
 nfsd4_remove_cld_pipe(struct net *net)
 {
@@ -1285,27 +1297,55 @@ nfs4_cld_state_shutdown(struct net *net)
 	kfree(nn->reclaim_str_hashtbl);
 }
 
+static bool
+cld_running(struct nfsd_net *nn)
+{
+	struct cld_net *cn = nn->cld_net;
+	struct rpc_pipe *pipe = cn->cn_pipe;
+
+	return pipe->nreaders || pipe->nwriters;
+}
+
 static int
 nfsd4_cld_tracking_init(struct net *net)
 {
 	int status;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	bool running;
+	int retries = 10;
 
 	status = nfs4_cld_state_init(net);
 	if (status)
 		return status;
 
-	status = nfsd4_init_cld_pipe(net);
+	status = __nfsd4_init_cld_pipe(net);
 	if (status)
 		goto err_shutdown;
 
+	/*
+	 * rpc pipe upcalls take 30 seconds to time out, so we don't want to
+	 * queue an upcall unless we know that nfsdcld is running (because we
+	 * want this to fail fast so that nfsd4_client_tracking_init() can try
+	 * the next client tracking method).  nfsdcld should already be running
+	 * before nfsd is started, so the wait here is for nfsdcld to open the
+	 * pipefs file we just created.
+	 */
+	while (!(running = cld_running(nn)) && retries--)
+		msleep(100);
+
+	if (!running) {
+		status = -ETIMEDOUT;
+		goto err_remove;
+	}
+
 	status = nfsd4_cld_grace_start(nn);
 	if (status) {
 		if (status == -EOPNOTSUPP)
 			printk(KERN_WARNING "NFSD: Please upgrade nfsdcld.\n");
 		nfs4_release_reclaim(nn);
 		goto err_remove;
-	}
+	} else
+		printk("NFSD: Using nfsdcld client tracking operations.\n");
 	return 0;
 
 err_remove:
@@ -1552,6 +1592,8 @@ nfsd4_umh_cltrack_init(struct net *net)
 
 	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
 	kfree(grace_start);
+	if (!ret)
+		printk("NFSD: Using UMH upcall client tracking operations.\n");
 	return ret;
 }
 
@@ -1701,9 +1743,20 @@ nfsd4_client_tracking_init(struct net *net)
 	if (nn->client_tracking_ops)
 		goto do_init;
 
+	/* First, try to use nfsdcld */
+	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
+	status = nn->client_tracking_ops->init(net);
+	if (!status)
+		return status;
+	if (status != -ETIMEDOUT) {
+		nn->client_tracking_ops = &nfsd4_cld_tracking_ops_v0;
+		status = nn->client_tracking_ops->init(net);
+		if (!status)
+			return status;
+	}
+
 	/*
-	 * First, try a UMH upcall. It should succeed or fail quickly, so
-	 * there's little harm in trying that first.
+	 * Next, try the UMH upcall.
 	 */
 	nn->client_tracking_ops = &nfsd4_umh_tracking_ops;
 	status = nn->client_tracking_ops->init(net);
@@ -1711,26 +1764,23 @@ nfsd4_client_tracking_init(struct net *net)
 		return status;
 
 	/*
-	 * See if the recoverydir exists and is a directory. If it is,
-	 * then use the legacy ops.
+	 * Finally, See if the recoverydir exists and is a directory.
+	 * If it is, then use the legacy ops.
 	 */
 	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
 	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
 	if (!status) {
 		status = d_is_dir(path.dentry);
 		path_put(&path);
-		if (status)
-			goto do_init;
+		if (!status) {
+			status = -EINVAL;
+			goto out;
+		}
 	}
 
-	/* Finally, try to use nfsdcld */
-	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
-	status = nn->client_tracking_ops->init(net);
-	if (!status)
-		return status;
-	nn->client_tracking_ops = &nfsd4_cld_tracking_ops_v0;
 do_init:
 	status = nn->client_tracking_ops->init(net);
+out:
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
 				    "recovery tracking! (%d)\n", status);
-- 
2.17.2

