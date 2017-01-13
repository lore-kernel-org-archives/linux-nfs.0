Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33443 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdAMTbJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 14:31:09 -0500
Received: by mail-io0-f196.google.com with SMTP id 101so6570789iom.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jan 2017 11:30:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix client recovery when server reboots multiple times
Date: Fri, 13 Jan 2017 14:30:33 -0500
Message-Id: <20170113193033.11006-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server reboots multiple times, the client should rely on the
server to tell it that it cannot reclaim state as per section 9.6.3.4
in RFC7530 and section 8.4.2.1 in RFC5661.
Currently, the client is being to conservative, and is assuming that
if the server reboots while state recovery is in progress, then it must
ignore state that was not recovered before the reboot.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1d152f4470cd..90e6193ce6be 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1729,7 +1729,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
 			break;
 		case -NFS4ERR_EXPIRED:
-- 
2.9.3

