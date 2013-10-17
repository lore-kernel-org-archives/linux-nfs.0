Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45281 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759050Ab3JQSNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:43 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDgmZ006140
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:42 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDfFH028666
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:41 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/21] NFS: Implement support for NFS4ERR_LEASE_MOVED
Date: Thu, 17 Oct 2013 14:13:41 -0400
Message-Id: <20131017181341.1073.24544.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trigger lease-moved recovery when a request returns
NFS4ERR_LEASE_MOVED.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 360e14e..3a03cd6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -389,6 +389,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			if (ret < 0)
 				break;
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -1585,6 +1588,9 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 		case -NFS4ERR_MOVED:
 			nfs4_schedule_migration_recovery(server);
 			return -EAGAIN;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(server->nfs_client);
+			return -EAGAIN;
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
@@ -4765,6 +4771,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (nfs4_schedule_migration_recovery(server) < 0)
 				goto recovery_failed;
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:

