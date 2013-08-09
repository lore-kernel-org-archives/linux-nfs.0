Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f43.google.com ([209.85.213.43]:44078 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968214Ab3HIQvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:47 -0400
Received: by mail-yh0-f43.google.com with SMTP id z12so1521125yhz.16
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:46 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id i4sm20660855yhg.16.2013.08.09.09.51.45
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:46 -0700 (PDT)
Subject: [PATCH v2 27/33] NFS: Add migration recovery callouts in nfs4proc.c
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:43 -0400
Message-ID: <20130809165143.5362.64989.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a server returns NFS4ERR_MOVED, trigger the new migration
recovery logic in the state manager.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 93eeac3..ae19cd5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -381,6 +381,11 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
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
@@ -428,6 +433,8 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 	return nfs4_map_errors(ret);
 wait_on_recovery:
 	ret = nfs4_wait_clnt_recover(clp);
+	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+		return -EIO;
 	if (ret == 0)
 		exception->retry = 1;
 	return ret;
@@ -2928,11 +2935,16 @@ static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
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
@@ -4664,6 +4676,16 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
 			goto wait_on_recovery;
+		case -NFS4ERR_MOVED:
+			if (state == NULL) {
+				pr_err("%s: no inode for migration recovery\n",
+					__func__);
+				WARN_ON(1);
+				goto recovery_failed;
+			}
+			if (nfs4_schedule_migration_recovery(server) < 0)
+				goto recovery_failed;
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -4694,6 +4716,8 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+		goto recovery_failed;
 restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;

