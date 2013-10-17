Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45353 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762262Ab3JQSNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:55 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDrfY006245
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:54 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDr13028976
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:53 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/21] NFS: Handle NFS4ERR_LEASE_MOVED during async RENEW
Date: Thu, 17 Oct 2013 14:13:53 -0400
Message-Id: <20131017181352.1073.97155.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With NFSv4 minor version 0, the asynchronous lease RENEW
heartbeat can return NFS4ERR_LEASE_MOVED.  Error recovery logic for
async RENEW is a separate code path from the generic NFS proc paths,
so it must be updated to handle NFS4ERR_LEASE_MOVED as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e743e1d..d9c38cd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4242,7 +4242,13 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 	unsigned long timestamp = data->timestamp;
 
 	trace_nfs4_renew_async(clp, task->tk_status);
-	if (task->tk_status < 0) {
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_LEASE_MOVED:
+		nfs4_schedule_lease_moved_recovery(clp);
+		break;
+	default:
 		/* Unless we're shutting down, schedule state recovery! */
 		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) == 0)
 			return;

