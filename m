From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] NFS: clean up short packet handling for NFSv4 readdir
Date: Fri, 22 Feb 2008 14:50:01 -0500
Message-ID: <1203709801-20055-4-git-send-email-jlayton@redhat.com>
References: <1203709801-20055-1-git-send-email-jlayton@redhat.com>
	<1203709801-20055-2-git-send-email-jlayton@redhat.com>
	<1203709801-20055-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1203709801-20055-3-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
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

3) Add some comments to clarify the logic in decode_readdir().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4xdr.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db1ed9c..6a203ba 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3481,7 +3481,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	size_t		hdrlen;
 	u32		recvd, pglen = rcvbuf->page_len;
 	__be32		*end, *entry, *p, *kaddr;
-	unsigned int	nr;
+	unsigned int	nr = 0;
 	int		status;
 
 	status = decode_op_hdr(xdr, OP_READDIR);
@@ -3505,7 +3505,12 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	kaddr = p = kmap_atomic(page, KM_USER0);
 	end = p + ((pglen + readdir->pgbase) >> 2);
 	entry = p;
-	for (nr = 0; *p++; nr++) {
+
+	/* Make sure the packet actually has a value_follows and EOF entry */
+	if ((entry + 1) > end)
+		goto short_pkt;
+
+	for (; *p++; nr++) {
 		u32 len, attrlen, xlen;
 		if (end - p < 3)
 			goto short_pkt;
@@ -3532,20 +3537,32 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		p += attrlen;		/* attributes */
 		entry = p;
 	}
-	if (!nr && (entry[0] != 0 || entry[1] == 0))
-		goto short_pkt;
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
 	return 0;
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
 	dprintk("%s: short packet at entry %d\n", __FUNCTION__, nr);
 	entry[0] = entry[1] = 0;
-	/* truncate listing ? */
-	if (!nr) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
-	goto out;
+	if (nr)
+		goto out;
 err_unmap:
 	kunmap_atomic(kaddr, KM_USER0);
 	return -errno_NFSERR_IO;
-- 
1.5.4.1
