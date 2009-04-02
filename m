From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 65/67] nfs41: recover lease in _nfs4_lookup_root
Date: Thu,  2 Apr 2009 17:00:18 +0300
Message-ID: <1238680818-15436-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2263 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758330AbZDBOAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 10:00:24 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This creates the nfsv4.1 session on mount.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd773c1..e0d8698 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2036,8 +2036,13 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	int status;
+
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_recover_expired_lease(server);
+	if (!status)
+		status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	return status;
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
-- 
1.6.2.1

