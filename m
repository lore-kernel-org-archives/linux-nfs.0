From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] NFS: Fix send buffer length calculation in nfs3_xdr_setaclargs()
Date: Wed, 15 Apr 2009 19:40:46 +0530
Message-ID: <49E5EAE6.7000507@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:39670 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbZDOOLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 10:11:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The recent posixacl fix(commit ae46141ff08f1965b17c531b571953c39ce8b9e2)
seems to have introduced a bug that will lead to -EINVAL errors during
normal setfacl operations on file or dir. This patch attempts to fix
this.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index e6a1932..7cd0069 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -702,18 +702,19 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
                    struct nfs3_setaclargs *args)
 {
 	struct xdr_buf *buf = &req->rq_snd_buf;
-	unsigned int base;
+	unsigned int base, len;
+	unsigned int len_in_head = 2 * (2 + 3 * NFS_ACL_MAX_ENTRIES_INLINE);
 	int err;
 
 	p = xdr_encode_fhandle(p, NFS_FH(args->inode));
 	*p++ = htonl(args->mask);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	base = req->rq_slen;
+	len = xdr_adjust_iovec(req->rq_svec, p);
+	base = len;
+	len -= len_in_head; 
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len >> 2));
 
 	if (args->npages != 0)
-		xdr_encode_pages(buf, args->pages, 0, args->len);
-	else
-		req->rq_slen += args->len;
+		xdr_encode_pages(buf, args->pages, 0, len);
 
 	err = nfsacl_encode(buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?


