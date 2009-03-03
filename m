From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/46] nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
Date: Wed,  4 Mar 2009 01:52:53 +0200
Message-ID: <1236124373-3168-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17398
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752222AbZCCXxH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:53:07 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be returned to the mount command when trying to mount a v4 server
using minorversion 1.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2022fe4..42e60b6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1101,6 +1101,8 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 			nfs4_clear_machine_cred(clp);
 			status = -EAGAIN;
 		}
+		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
+			status = -EPROTONOSUPPORT;
 	}
 	return status;
 }
-- 
1.6.1.3

