Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26303 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754515AbaI2Q3M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 12:29:12 -0400
From: <andros@netapp.com>
To: <trond.myklebust@rimarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 1/1] NFSv4.1: Fix an NFSv4.1 state renewal  regression
Date: Mon, 29 Sep 2014 12:29:05 -0400
Message-ID: <1412008145-36085-2-git-send-email-andros@netapp.com>
In-Reply-To: <1412008145-36085-1-git-send-email-andros@netapp.com>
References: <1412008145-36085-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Commit 2f60ea6b8ced ("NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation") set the NFS4_RENEW_TIMEOUT flag in nfs4_renew_state, and does
not put an nfs41_proc_async_sequence call, the NFSv4.1 lease renewal heartbeat
call, on the wire to renew the NFSv4.1 state if the flag was not set.

The NFS4_RENEW_TIMEOUT flag is set when "now" is after the last renewal
(cl_last_renewal) plus the lease time divided by 3. This is arbitrary and
sometimes does the following:

In normal operation, the only way a future state renewal call is put on the
wire is via a call to nfs4_schedule_state_renewal, which schedules a
nfs4_renew_state workqueue task. nfs4_renew_state determines if the
NFS4_RENEW_TIMEOUT should be set, and the calls nfs41_proc_async_sequence,
which only gets sent if the NFS4_RENEW_TIMEOUT flag is set.
Then the nfs41_proc_async_sequence rpc_release function schedules
another state remewal via nfs4_schedule_state_renewal.

Without this change we can get into a state where an application stops
accessing the NFSv4.1 share, state renewal calls stop due to the
NFS4_RENEW_TIMEOUT flag _not_ being set. The only way to recover
from this situation is with a clientid re-establishment, once the application
resumes and the server has timed out the lease and so returns
NFS4ERR_BAD_SESSION on the subsequent SEQUENCE operation.

An example application:
open, lock, write a file.

sleep for 6 * lease (could be less)

ulock, close.

In the above example with NFSv4.1 delegations enabled, without this change,
there are no OP_SEQUENCE state renewal calls during the sleep, and the
clientid is recovered due to lease expiration on the close.

This issue does not occur with NFSv4.1 delegations disabled, nor with
NFSv4.0, with or without delegations enabled.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c   |  2 +-
 fs/nfs/nfs4renewd.c | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 288be08..ed25f38 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7349,7 +7349,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
 	int ret = 0;
 
 	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
-		return 0;
+		return -EAGAIN;
 	task = _nfs41_proc_sequence(clp, cred, false);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 1720d32..b00e1e2 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -88,16 +88,26 @@ nfs4_renew_state(struct work_struct *work)
 			}
 			nfs_expire_all_delegations(clp);
 		} else {
+			int ret;
+
 			/* Queue an asynchronous RENEW. */
-			ops->sched_state_renewal(clp, cred, renew_flags);
+			ret = ops->sched_state_renewal(clp, cred, renew_flags);
 			put_rpccred(cred);
-			goto out_exp;
+			switch (ret) {
+			case 0:
+			default:
+				goto out_exp;
+			case -EAGAIN:
+			case -ENOMEM:
+				goto out_sched;
+			}
 		}
 	} else {
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
 				__func__);
 		spin_unlock(&clp->cl_lock);
 	}
+out_sched:
 	nfs4_schedule_state_renewal(clp);
 out_exp:
 	nfs_expire_unreferenced_delegations(clp);
-- 
1.8.3.1

