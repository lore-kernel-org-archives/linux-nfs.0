Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23158 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759356Ab3JQSNU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:20 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDJqd013561
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:20 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDJ4J012078
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:19 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/21] NFS: Add migration recovery callouts in nfs4proc.c
Date: Thu, 17 Oct 2013 14:13:19 -0400
Message-Id: <20131017181319.1073.20263.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a server returns NFS4ERR_MOVED, trigger the new migration
recovery logic in the state manager.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c304ec1..25d42a8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -384,6 +384,11 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
 			goto wait_on_recovery;
+		case -NFS4ERR_MOVED:
+			ret = nfs4_schedule_migration_recovery(server);
+			if (ret < 0)
+				break;
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -431,6 +436,8 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 	return nfs4_map_errors(ret);
 wait_on_recovery:
 	ret = nfs4_wait_clnt_recover(clp);
+	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+		return -EIO;
 	if (ret == 0)
 		exception->retry = 1;
 	return ret;
@@ -2981,11 +2988,16 @@ static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
 	status = nfs4_proc_fs_locations(client, dir, name, locations, page);
 	if (status != 0)
 		goto out;
-	/* Make sure server returned a different fsid for the referral */
+
+	/*
+	 * If the fsid didn't change, this is a migration event, not a
+	 * referral.  Cause us to drop into the exception handler, which
+	 * will kick off migration recovery.
+	 */
 	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
 		dprintk("%s: server did not return a different fsid for"
 			" a referral at %s\n", __func__, name->name);
-		status = -EIO;
+		status = -NFS4ERR_MOVED;
 		goto out;
 	}
 	/* Fixup attributes for the nfs_lookup() call to nfs_fhget() */
@@ -4746,6 +4758,10 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
 			goto wait_on_recovery;
+		case -NFS4ERR_MOVED:
+			if (nfs4_schedule_migration_recovery(server) < 0)
+				goto recovery_failed;
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -4776,6 +4792,8 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+		goto recovery_failed;
 restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;

