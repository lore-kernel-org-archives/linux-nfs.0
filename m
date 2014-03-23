Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47920 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbaCWBMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 41/50] nfsd4: enforce rd_dircount
Date: Sat, 22 Mar 2014 21:12:12 -0400
Message-Id: <1395537141-10389-42-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As long as we're here, let's enforce the protocol's limit on the number
of directory entries to return in a readdir.

I don't think anyone's ever noticed our lack of enforcement, but maybe
there's more of a chance they will now that we allow larger readdirs.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fa3ae50..b35b7b1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1033,7 +1033,7 @@ nfsd4_decode_readdir(struct nfsd4_compoundargs *argp, struct nfsd4_readdir *read
 	READ_BUF(24);
 	READ64(readdir->rd_cookie);
 	COPYMEM(readdir->rd_verf.data, sizeof(readdir->rd_verf.data));
-	READ32(readdir->rd_dircount);    /* just in case you needed a useless field... */
+	READ32(readdir->rd_dircount);
 	READ32(readdir->rd_maxcount);
 	if ((status = nfsd4_decode_bitmap(argp, readdir->rd_bmval)))
 		goto out;
@@ -2719,6 +2719,9 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	if (entry_bytes > cd->rd_maxcount)
 		goto fail;
 	cd->rd_maxcount -= entry_bytes;
+	if (!cd->rd_dircount)
+		goto fail;
+	cd->rd_dircount--;
 	cd->cookie_offset = cookie_offset;
 skip_entry:
 	cd->common.err = nfs_ok;
-- 
1.8.5.3

