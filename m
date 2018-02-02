Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:40343 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752634AbeBBT3B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 14:29:01 -0500
Subject: [PATCH v2] svcrdma: Fix Read chunk round-up
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 02 Feb 2018 14:28:59 -0500
Message-ID: <20180202192631.12289.86122.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A single NFSv4 WRITE compound can often have three operations:
PUTFH, WRITE, then GETATTR.

When the WRITE payload is sent in a Read chunk, the client places
the GETATTR in the inline part of the RPC/RDMA message, just after
the WRITE operation (sans payload). The position value in the Read
chunk enables the receiver to insert the Read chunk at the correct
place in the received XDR stream; that is between the WRITE and
GETATTR.

According to RFC 8166, an NFS/RDMA client does not have to add XDR
round-up to the Read chunk that carries the WRITE payload. The
receiver adds XDR round-up padding if it is absent and the
receiver's XDR decoder requires it to be present.

Commit 193bcb7b3719 ("svcrdma: Populate tail iovec when receiving")
attempted to add support for receiving such a compound so that just
the WRITE payload appears in rq_arg's page list, and the trailing
GETATTR is placed in rq_arg's tail iovec. (TCP just strings the
whole compound into the head iovec and page list, without regard
to the alignment of the WRITE payload).

The server transport logic also had to accommodate the optional XDR
round-up of the Read chunk, which it did simply by lengthening the
tail iovec when round-up was needed. This approach is adequate for
the NFSv2 and NFSv3 WRITE decoders.

Unfortunately it is not sufficient for nfsd4_decode_write. When the
Read chunk length is a couple of bytes less than PAGE_SIZE, the
computation at the end of nfsd4_decode_write allows argp->pagelen to
go negative, which breaks the logic in read_buf that looks for the
tail iovec.

The result is that a WRITE operation whose payload length is just
less than a multiple of a page succeeds, but the subsequent GETATTR
in the same compound fails with NFS4ERR_OP_ILLEGAL because the XDR
decoder can't find it. Clients ignore the error, but they must
update their attribute cache via a separate round trip.

As nfsd4_decode_write appears to expect the payload itself to always
have appropriate XDR round-up, have svc_rdma_build_normal_read_chunk
add the Read chunk XDR round-up to the page_len rather than
lengthening the tail iovec.

Reported-by: Olga Kornievskaia <kolga@netapp.com>
Fixes: 193bcb7b3719 ("svcrdma: Populate tail iovec when receiving")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Olga Kornievskaia <kolga@netapp.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Hi Bruce-

This is ready for you to take for v4.16 or later. Thanks!

Changes since v1:
- Minor edits of the patch description
- Added Olga's Tested-by:

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 9bd0454..12b9a7e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -727,12 +727,16 @@ static int svc_rdma_build_normal_read_chunk(struct svc_rqst *rqstp,
 		head->arg.head[0].iov_len - info->ri_position;
 	head->arg.head[0].iov_len = info->ri_position;
 
-	/* Read chunk may need XDR roundup (see RFC 5666, s. 3.7).
+	/* Read chunk may need XDR roundup (see RFC 8166, s. 3.4.5.2).
 	 *
-	 * NFSv2/3 write decoders need the length of the tail to
-	 * contain the size of the roundup padding.
+	 * If the client already rounded up the chunk length, the
+	 * length does not change. Otherwise, the length of the page
+	 * list is increased to include XDR round-up.
+	 *
+	 * Currently these chunks always start at page offset 0,
+	 * thus the rounded-up length never crosses a page boundary.
 	 */
-	head->arg.tail[0].iov_len += 4 - (info->ri_chunklen & 3);
+	info->ri_chunklen = XDR_QUADLEN(info->ri_chunklen) << 2;
 
 	head->arg.page_len = info->ri_chunklen;
 	head->arg.len += info->ri_chunklen;

