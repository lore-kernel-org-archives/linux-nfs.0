From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 07/67] nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
Date: Thu,  2 Apr 2009 16:51:21 +0300
Message-ID: <1238680281-13619-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31984 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755168AbZDBNv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:28 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be returned to the mount command when trying to mount a v4 server
using minorversion 1.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0298e90..bc683ed 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1107,6 +1107,8 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 			nfs4_clear_machine_cred(clp);
 			status = -EAGAIN;
 		}
+		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
+			status = -EPROTONOSUPPORT;
 	}
 	return status;
 }
-- 
1.6.2.1

