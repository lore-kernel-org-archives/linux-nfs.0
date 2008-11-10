From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 51/85] nfs41: state reclaimer renew lease error handling
Date: Mon, 10 Nov 2008 22:27:11 +0200
Message-ID: <1226348831-8927-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59971 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbYKJU1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:27:16 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The state reclaimer has been called due to a NFS4_STALE_CLIENTID or NFS4_EXPIRE
error. First it tries to renew the old lease (network partion case) which for
v4.1 means an nfs4_proc_sequence call. Any error from the sequence operation
means that the lease cannot be renewed.

Switch on the minorversion to handle the error return from the renew lease call.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4state.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d3c5e92..0d6b902 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -975,18 +975,24 @@ restart_loop:
 		/* Yes there are: try to renew the old lease */
 		status = ops->renew_lease(clp, cred);
 		put_rpccred(cred);
-		switch (status) {
-		case 0:
-		case -NFS4ERR_CB_PATH_DOWN:
+		if (!status)
 			goto out;
-		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
-			ops = nfs4_reboot_recovery_ops[clp->cl_minorversion];
-		}
+		if (clp->cl_minorversion == 0)
+			switch (status) {
+			case -NFS4ERR_CB_PATH_DOWN:
+				goto out;
+			case -NFS4ERR_STALE_CLIENTID:
+			case -NFS4ERR_LEASE_MOVED:
+				break;
+			default:
+				goto establish_clid;
+			}
+		ops = nfs4_reboot_recovery_ops[clp->cl_minorversion];
 	} else {
 		/* "reboot" to ensure we clear all state on the server */
 		clp->cl_boot_time = CURRENT_TIME;
 	}
+establish_clid:
 	/* We're going to have to re-establish a clientid */
 	nfs4_state_mark_reclaim(clp);
 	status = -ENOENT;
-- 
1.6.0.2

