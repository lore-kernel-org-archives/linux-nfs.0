From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 49/85] nfs41: recover lease in _nfs4_lookup_root
Date: Mon, 10 Nov 2008 22:26:49 +0200
Message-ID: <1226348809-8861-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59963 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbYKJU0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:55 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This creates the nfsv4.1 session on mount.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 749027d..179ea6c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1956,7 +1956,11 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	dprintk("--> %s\n", __func__);
 	nfs_fattr_init(info->fattr);
+	status = nfs4_recover_expired_lease(server);
+	if (status != 0)
+		goto out;
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+out:
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
-- 
1.6.0.2

