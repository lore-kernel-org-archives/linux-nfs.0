Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12732 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756945Ab0JVOQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:16:33 -0400
Message-ID: <4CC19CC0.6030508@netapp.com>
Date: Fri, 22 Oct 2010 10:16:32 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: check xdr_decode for errors
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Check if the decoded entry has the eof bit set when returning from xdr_decode
with an error.  If it does, we should set the eof bits in the array before
returning.  This should keep us from looping when we expect more data but the
server doesn't give us anything new.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 628eca7..da3c103 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -442,6 +442,8 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 	struct xdr_stream stream;
 	struct xdr_buf buf;
 	__be32 *ptr = xdr_page;
+	int status;
+	struct nfs_cache_array *array;
 
 	buf.head->iov_base = xdr_page;
 	buf.head->iov_len = buflen;
@@ -453,11 +455,23 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 
 	xdr_init_decode(&stream, &buf, ptr);
 
-	while (xdr_decode(desc, entry, &stream) == 0) {
+
+	do {
+		status = xdr_decode(desc, entry, &stream);
+		if (status != 0)
+			break;
+
 		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
 		if (desc->plus == 1)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
+	} while (!entry->eof);
+
+	if (status == -EBADCOOKIE && entry->eof) {
+		array = nfs_readdir_get_array(page);
+		array->eof_index = array->size - 1;
+		status = 0;
+		nfs_readdir_release_array(page);
 	}
 }
 
