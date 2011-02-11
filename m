Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53156 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757234Ab1BKPmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:42:47 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3/4] NFS: remove pointless if statement in nfs_direct_write_result
Date: Fri, 11 Feb 2011 10:42:37 -0500
Message-Id: <1297438958-24861-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
References: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The code was doing nothing more in either branch of the if.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9943a75..f493bdd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -649,8 +649,7 @@ static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 
-	if (nfs_writeback_done(task, data) != 0)
-		return;
+	nfs_writeback_done(task, data);
 }
 
 /*
-- 
1.7.2.1

