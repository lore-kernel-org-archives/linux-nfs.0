Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44401 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934944Ab2JXOad (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 10:30:33 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so593358vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 07:30:32 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/4] nfsd: warn about impending removal of nfsdcld upcall
Date: Wed, 24 Oct 2012 10:30:18 -0400
Message-Id: <1351089018-24551-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
References: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let's shoot for removing the nfsdcld upcall in 3.10. Most likely,
no one is actually using it so I don't expect this warning to
fire often (except maybe on misconfigured systems).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 782168d..0a9ac9d 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1165,6 +1165,9 @@ nfsd4_client_tracking_init(struct net *net)
 
 	/* Finally, try to use nfsdcld */
 	client_tracking_ops = &nfsd4_cld_tracking_ops;
+	printk(KERN_WARNING "NFSD: the nfsdcld client tracking upcall will be "
+			"removed in 3.10. Please transition to using "
+			"nfsdcltrack.\n");
 do_init:
 	status = client_tracking_ops->init(net);
 	if (status) {
-- 
1.7.11.7

