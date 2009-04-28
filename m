From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] NFS: Fix xdr decoding error of NFSv4 SETATTR response
Date: Tue, 28 Apr 2009 15:19:34 +0300
Message-ID: <1240921174-25443-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:32768 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbZD1Mbp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 08:31:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

A non-OK response to setattr has a bitmap associated with it
that was not being parsed.  Note it is still being ignored.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

Trond, this patch fixes an existing bug in the nfsv4 code base.
Since nobody complained about it so far it is not urgent for
for 2.6.30, but it would be nice to get it upstream if you
send more fixes for 2.6.30 anyway.

Thanks,

Benny

 fs/nfs/nfs4xdr.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80af0ae..6c2e098 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4110,12 +4110,11 @@ static int decode_setattr(struct xdr_stream *xdr)
 	int status;
 
 	status = decode_op_hdr(xdr, OP_SETATTR);
-	if (status)
-		return status;
+	/* Attribute array is sent even in error case */
 	READ_BUF(4);
 	READ32(bmlen);
 	READ_BUF(bmlen << 2);
-	return 0;
+	return status;
 }
 
 static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
-- 
1.6.2.1

