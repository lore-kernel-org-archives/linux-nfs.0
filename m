Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab0KUTVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:45 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/8] NFS: Assume eof if the server returns no readdir records
Date: Sun, 21 Nov 2010 14:21:16 -0500
Message-Id: <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Some servers are known to be buggy w.r.t. this. Deal with them...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 662df2a..2789cb3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -466,8 +466,9 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 	struct xdr_stream stream;
 	struct xdr_buf buf;
 	__be32 *ptr = xdr_page;
-	int status;
 	struct nfs_cache_array *array;
+	unsigned int count = 0;
+	int status;
 
 	buf.head->iov_base = xdr_page;
 	buf.head->iov_len = buflen;
@@ -488,6 +489,8 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 			break;
 		}
 
+		count++;
+
 		if (desc->plus == 1)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 
@@ -496,13 +499,14 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 			break;
 	} while (!entry->eof);
 
-	if (status == -EBADCOOKIE && entry->eof) {
+	if (count == 0 || (status == -EBADCOOKIE && entry->eof == 1)) {
 		array = nfs_readdir_get_array(page);
 		if (!IS_ERR(array)) {
 			array->eof_index = array->size;
 			status = 0;
 			nfs_readdir_release_array(page);
-		}
+		} else
+			status = PTR_ERR(array);
 	}
 	return status;
 }
-- 
1.7.3.2

