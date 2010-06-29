From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] SQUASHME: into [SQUASHME: pnfsd: Support for cb_layout returning
 NFS4ERR_DELAY]
Date: Tue, 29 Jun 2010 14:36:56 +0300
Message-ID: <4C29DAD8.1060809@panasas.com>
References: <4C1A4DED.50702@panasas.com> <4C28D829.5070706@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27303 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755947Ab0F2Lg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 07:36:58 -0400
In-Reply-To: <4C28D829.5070706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is the correct code.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3bbeae8..60c719c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1046,7 +1046,7 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 		/* Pole the client until it's done with the layout */
 		rpc_delay(task, HZ/100); /* 10 mili-seconds */
 		task->tk_status = 0;
-		rpc_restart_call(task);
+		rpc_restart_call_prepare(task);
 		break;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
 		task->tk_status = 0;
-- 
1.6.6.1


