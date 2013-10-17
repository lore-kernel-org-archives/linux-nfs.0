Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23404 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759050Ab3JQSNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:48 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDlsr013910
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:48 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDlwM007813
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:47 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/21] NFS: Migration support for RELEASE_LOCKOWNER
Date: Thu, 17 Oct 2013 14:13:47 -0400
Message-Id: <20131017181347.1073.95179.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the Linux NFS client ignores the operation status code for
the RELEASE_LOCKOWNER operation.  Like NFSv3's UMNT operation,
RELEASE_LOCKOWNER is a courtesy to help servers manage their
resources, and the outcome is not consequential for the client.

During a migration, a server may report NFS4ERR_LEASE_MOVED, in
which case the client really should retry, since typically
LEASE_MOVED has nothing to do with the current operation, but does
prevent it from going forward.

Also, it's important for a client to respond as soon as possible to
a moved lease condition, since the client's lease could expire on
the destination without further action by the client.

NFS4ERR_DELAY is not included in the list of valid status codes for
RELEASE_LOCKOWNER in RFC 3530bis.  However, rfc3530-migration-update
does permit migration-capable servers to return DELAY to clients,
but only in the context of an ongoing migration.  In this case the
server has frozen lock state in preparation for migration, and a
client retry would help the destination server purge unneeded state
once migration recovery is complete.

Interestly, NFS4ERR_MOVED is not valid for RELEASE_LOCKOWNER, even
though lock owners can be migrated with Transparent State Migration.

Note that RFC 3530bis section 9.5 includes RELEASE_LOCKOWNER in the
list of operations that renew a client's lease on the server if they
succeed.  Now that our client pays attention to the operation's
status code, we can note that renewal appropriately.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3a03cd6..e743e1d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5806,6 +5806,7 @@ struct nfs_release_lockowner_data {
 	struct nfs_release_lockowner_args args;
 	struct nfs4_sequence_args seq_args;
 	struct nfs4_sequence_res seq_res;
+	unsigned long timestamp;
 };
 
 static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
@@ -5813,12 +5814,27 @@ static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata
 	struct nfs_release_lockowner_data *data = calldata;
 	nfs40_setup_sequence(data->server,
 				&data->seq_args, &data->seq_res, task);
+	data->timestamp = jiffies;
 }
 
 static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs_release_lockowner_data *data = calldata;
+	struct nfs_server *server = data->server;
+
 	nfs40_sequence_done(task, &data->seq_res);
+
+	switch (task->tk_status) {
+	case 0:
+		renew_lease(server, data->timestamp);
+		break;
+	case -NFS4ERR_STALE_CLIENTID:
+	case -NFS4ERR_EXPIRED:
+	case -NFS4ERR_LEASE_MOVED:
+	case -NFS4ERR_DELAY:
+		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+			rpc_restart_call_prepare(task);
+	}
 }
 
 static void nfs4_release_lockowner_release(void *calldata)

