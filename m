Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13629 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261Ab1CISOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 13:14:03 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH Cthon2011 fixes 3/3] NFSv4.1 reclaim complete must wait for completion
Date: Wed,  9 Mar 2011 13:13:46 -0500
Message-Id: <1299694426-5620-3-git-send-email-andros@netapp.com>
In-Reply-To: <1299694426-5620-2-git-send-email-andros@netapp.com>
References: <1299694426-5620-1-git-send-email-andros@netapp.com>
 <1299694426-5620-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8edb1fc..0bce091 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5435,6 +5435,9 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
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
1.6.6

