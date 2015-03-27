Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38071 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbbC0Qwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:31 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 36/39] nfs3: Return posix acl encode errors
Date: Fri, 27 Mar 2015 17:50:34 +0100
Message-Id: <9c3090e1997518306025ddd0c55dccbc8d97c130.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an error occurs when encoding a posix acl, return the error instead of
causing a BUG().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs3xdr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 8b880f7..de6f12c 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1384,13 +1384,14 @@ static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 	error = nfsacl_encode(xdr->buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
 			    args->acl_access : NULL, 1, 0);
-	/* FIXME: this is just broken */
-	BUG_ON(error < 0);
+	if (error < 0)
+		return error;
 	error = nfsacl_encode(xdr->buf, base + error, args->inode,
 			    (args->mask & NFS_DFACL) ?
 			    args->acl_default : NULL, 1,
 			    NFS_ACL_DEFAULT);
-	BUG_ON(error < 0);
+	if (error < 0)
+		return error;
 	return 0;
 }
 
-- 
2.1.0

