From: andros@netapp.com
Subject: [PATCH 08/11] nfs41: don't clear tk_action on success
Date: Fri,  4 Dec 2009 15:25:43 -0500
Message-ID: <1259958347-9031-9-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
 <1259958347-9031-6-git-send-email-andros@netapp.com>
 <1259958347-9031-7-git-send-email-andros@netapp.com>
 <1259958347-9031-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757287AbZLDUZ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:57 -0500
In-Reply-To: <1259958347-9031-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b8bd31..b1d8dcd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -527,7 +527,7 @@ int nfs4_setup_sequence(struct nfs_client *clp,
 		goto out;
 	ret = nfs41_setup_sequence(clp->cl_session, args, res, cache_reply,
 				   task);
-	if (ret != -EAGAIN) {
+	if (ret && ret != -EAGAIN) {
 		/* terminate rpc task */
 		task->tk_status = ret;
 		task->tk_action = NULL;
-- 
1.6.0.6

