From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 45/85] nfs41: start session recovery from nfs4_setup_sequence
Date: Mon, 10 Nov 2008 22:26:07 +0200
Message-ID: <1226348767-8728-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48851 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbYKJU0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:13 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a4f5b15..12f3b9f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -491,8 +491,11 @@ int nfs4_setup_sequence(struct nfs_client *clp,
 	if (clp->cl_minorversion == 0 || res->sr_slot)
 		goto out;
 	BUG_ON(clp->cl_minorversion != 1);
-	ret = nfs41_setup_sequence(clp->cl_session, args, res,
-				   cache_reply, task);
+	if (nfs41_test_session_alloc(clp->cl_session))
+		ret = nfs41_recover_session_sync(clp->cl_session);
+	if (!ret)
+		ret = nfs41_setup_sequence(clp->cl_session, args, res,
+					   cache_reply, task);
 	if (ret) {
 		memset(res, 0, sizeof(*res));
 		if (ret != -EAGAIN) {
-- 
1.6.0.2

