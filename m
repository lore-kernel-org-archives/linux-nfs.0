Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45505 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab3JQSOM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:14:12 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIEAXP006700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:14:11 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIEAdA009043
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:14:10 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/21] NFS: Fix possible endless state recovery wait
Date: Thu, 17 Oct 2013 14:14:10 -0400
Message-Id: <20131017181410.1073.25348.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs4_wait_clnt_recover(), hold a reference to the clp being
waited on.  The state manager can reduce clp->cl_count to 1, in
which case the nfs_put_client() in nfs4_run_state_manager() can
free *clp before wait_on_bit() returns and allows
nfs4_wait_clnt_recover() to run again.

The behavior at that point is non-deterministic.  If the waited-on
bit still happens to be zero, wait_on_bit() will wake the waiter as
expected.  If the bit is set again (say, if the memory was poisoned
when freed) wait_on_bit() can leave the waiter asleep.

This is a narrow fix which ensures the safety of accessing *clp in
nfs4_wait_clnt_recover(), but does not address the continued use
of a possibly freed *clp after nfs4_wait_clnt_recover() returns
(see nfs_end_delegation_return(), for example).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6daa064..1a3cb26 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1255,14 +1255,16 @@ int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	might_sleep();
 
+	atomic_inc(&clp->cl_count);
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (res)
-		return res;
-
+		goto out;
 	if (clp->cl_cons_state < 0)
-		return clp->cl_cons_state;
-	return 0;
+		res = clp->cl_cons_state;
+out:
+	nfs_put_client(clp);
+	return res;
 }
 
 int nfs4_client_recover_expired_lease(struct nfs_client *clp)

