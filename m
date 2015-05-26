Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34131 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbbEZPx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 11:53:56 -0400
Subject: [PATCH v3 17/17] NFS: Fix size of NFSACL SETACL operations
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 11:53:52 -0400
Message-ID: <20150526155352.4542.1803.stgit@manet.1015granger.net>
In-Reply-To: <20150526153926.4542.96409.stgit@manet.1015granger.net>
References: <20150526153926.4542.96409.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When encoding the NFSACL SETACL operation, reserve just the estimated
size of the ACL rather than a fixed maximum. This eliminates needless
zero padding on the wire that the server ignores.

Fixes: ee5dc7732bd5 ('NFS: Fix "kernel BUG at fs/nfs/nfs3xdr.c:1338!"')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs3xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 53852a4..9b04c2e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1342,7 +1342,7 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 	if (args->npages != 0)
 		xdr_write_pages(xdr, args->pages, 0, args->len);
 	else
-		xdr_reserve_space(xdr, NFS_ACL_INLINE_BUFSIZE);
+		xdr_reserve_space(xdr, args->len);
 
 	error = nfsacl_encode(xdr->buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?

