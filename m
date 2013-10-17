Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45127 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759425Ab3JQSN0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:26 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDPRp005819
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:25 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDO5D020936
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:24 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/21] NFS: Handle NFS4ERR_MOVED during delegation recall
Date: Thu, 17 Oct 2013 14:13:24 -0400
Message-Id: <20131017181324.1073.88332.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a server returns NFS4ERR_MOVED during a delegation recall,
trigger the new migration recovery logic in the state manager.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 25d42a8..af8feba 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1582,6 +1582,9 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 			/* Don't recall a delegation if it was lost */
 			nfs4_schedule_lease_recovery(server->nfs_client);
 			return -EAGAIN;
+		case -NFS4ERR_MOVED:
+			nfs4_schedule_migration_recovery(server);
+			return -EAGAIN;
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:

