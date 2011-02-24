Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12537 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753434Ab1BYR5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Feb 2011 12:57:32 -0500
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] NFSv4.1 reclaim complete must wait for completion
Date: Thu, 24 Feb 2011 05:11:08 -0500
Message-Id: <1298542269-2477-3-git-send-email-andros@netapp.com>
In-Reply-To: <1298542269-2477-1-git-send-email-andros@netapp.com>
References: <1298542269-2477-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7d80e78..388817b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5385,6 +5385,9 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 		status = PTR_ERR(task);
 		goto out;
 	}
+        status = nfs4_wait_for_completion_rpc_task(task);
+        if (status == 0)
+                status = task->tk_status;
 	rpc_put_task(task);
 	return 0;
 out:
-- 
1.7.3.1

