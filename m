Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45044 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759117Ab3JQSNP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:15 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDENk005690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:14 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDD5Q006417
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:13 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/21] NFS: Rename "stateid_invalid" label
Date: Thu, 17 Oct 2013 14:13:13 -0400
Message-Id: <20131017181313.1073.97211.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm going to use this exit label also for migration recovery
failures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 297bdd0..c304ec1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4735,12 +4735,12 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (state == NULL)
 				break;
 			if (nfs4_schedule_stateid_recovery(server, state) < 0)
-				goto stateid_invalid;
+				goto recovery_failed;
 			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
 			if (state != NULL) {
 				if (nfs4_schedule_stateid_recovery(server, state) < 0)
-					goto stateid_invalid;
+					goto recovery_failed;
 			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
@@ -4769,7 +4769,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
-stateid_invalid:
+recovery_failed:
 	task->tk_status = -EIO;
 	return 0;
 wait_on_recovery:

