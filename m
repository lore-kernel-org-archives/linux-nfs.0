From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] NFS: clean up short packet handling for NFSv2 readdir
Date: Fri, 22 Feb 2008 14:49:59 -0500
Message-ID: <1203709801-20055-2-git-send-email-jlayton@redhat.com>
References: <1203709801-20055-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758565AbYBVTuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2008 14:50:24 -0500
In-Reply-To: <1203709801-20055-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the NFS readdir decoders have a workaround for buggy servers
that send an empty readdir response with the EOF bit unset. If the
server sends a malformed response in some cases, this workaround kicks
in and just returns an empty response rather than returning a proper
error to the caller.

This patch does 3 things:

1) have malformed responses with no entries return error (-EIO)

2) preserve existing workaround for servers that send empty
   responses with the EOF marker unset.

3) Add some comments to clarify the logic in nfs_xdr_readdirres().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs2xdr.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f7ea67..86a80b3 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -428,7 +428,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	size_t hdrlen;
 	unsigned int pglen, recvd;
 	u32 len;
-	int status, nr;
+	int status, nr = 0;
 	__be32 *end, *entry, *kaddr;
 
 	if ((status = ntohl(*p++)))
@@ -452,7 +452,12 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	kaddr = p = kmap_atomic(*page, KM_USER0);
 	end = (__be32 *)((char *)p + pglen);
 	entry = p;
-	for (nr = 0; *p++; nr++) {
+
+	/* Make sure the packet actually has a value_follows and EOF entry */
+	if ((entry + 1) > end)
+		goto short_pkt;
+
+	for (; *p++; nr++) {
 		if (p + 2 > end)
 			goto short_pkt;
 		p++; /* fileid */
@@ -467,18 +472,32 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 			goto short_pkt;
 		entry = p;
 	}
-	if (!nr && (entry[0] != 0 || entry[1] == 0))
-		goto short_pkt;
+
+	/*
+	 * Apparently some server sends responses that are a valid size, but
+	 * contain no entries, and have value_follows==0 and EOF==0. For
+	 * those, just set the EOF marker.
+	 */
+	if (!nr && entry[1] == 0) {
+		dprintk("NFS: readdir reply truncated!\n");
+		entry[1] = 1;
+	}
  out:
 	kunmap_atomic(kaddr, KM_USER0);
 	return nr;
  short_pkt:
+	/*
+	 * When we get a short packet there are 2 possibilities. We can
+	 * return an error, or fix up the response to look like a valid
+	 * response and return what we have so far. If there are no
+	 * entries and the packet was short, then return -EIO. If there
+	 * are valid entries in the response, return them and pretend that
+	 * the call was successful, but incomplete. The caller can retry the
+	 * readdir starting at the last cookie.
+	 */
 	entry[0] = entry[1] = 0;
-	/* truncate listing ? */
-	if (!nr) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
+	if (!nr)
+		nr = -errno_NFSERR_IO;
 	goto out;
 err_unmap:
 	nr = -errno_NFSERR_IO;
-- 
1.5.4.1

