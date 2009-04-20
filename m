From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Fix the XDR iovec calculation in nfs3_xdr_setaclargs
Date: Mon, 20 Apr 2009 14:58:35 -0400
Message-ID: <1240267498.16708.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Leonardo Chiquitto <leonardo.lists@gmail.com>,
	Suresh Jayaraman <sjayaraman@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16231 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756258AbZDTWpq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2009 18:45:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit ae46141ff08f1965b17c531b571953c39ce8b9e2 (NFSv3: Fix posix ACL code)
introduces a bug in the calculation of the XDR header iovec. In the case
where we are inlining the acls, we need to adjust the length of the iovec
req->rq_svec, in addition to adjusting the total buffer length.

Tested-by: Leonardo Chiquitto <leonardo.lists@gmail.com>
Tested-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Please apply to 2.6.30-rc2 & 2.6.29-stable...

 fs/nfs/nfs3xdr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index e6a1932..35869a4 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -713,7 +713,8 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
 	if (args->npages != 0)
 		xdr_encode_pages(buf, args->pages, 0, args->len);
 	else
-		req->rq_slen += args->len;
+		req->rq_slen = xdr_adjust_iovec(req->rq_svec,
+				p + XDR_QUADLEN(args->len));
 
 	err = nfsacl_encode(buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
-- 
1.6.0.4
