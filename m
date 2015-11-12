Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754079AbbKLOTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2015 09:19:09 -0500
Date: Thu, 12 Nov 2015 09:19:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH] svcrdma: Do not send XDR roundup bytes for a write chunk
Message-ID: <20151112141907.GA6137@fieldses.org>
References: <20151016132938.8597.65237.stgit@oracle-120.nfsv4bat.org>
 <94E65795-E205-44FE-93DE-A1FF24CD5C2E@oracle.com>
 <2CF378F3-09B3-441D-9DE6-5336F0B8BF65@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <2CF378F3-09B3-441D-9DE6-5336F0B8BF65@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 11, 2015 at 03:20:33PM -0500, Chuck Lever wrote:
> 
> > On Nov 3, 2015, at 3:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > 
> >> On Oct 16, 2015, at 9:30 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >> Minor optimization: when dealing with write chunk XDR roundup, do
> >> not post a Write WR for the zero bytes in the pad. Simply update
> >> the write segment in the RPC-over-RDMA header to reflect the extra
> >> pad bytes.
> >> 
> >> The Reply chunk is also a write chunk, but the server does not use
> >> send_write_chunks() to send the Reply chunk. That's OK in this case:
> >> the server Upper Layer typically marshals the Reply chunk contents
> >> in a single contiguous buffer, without a separate tail for the XDR
> >> pad.
> >> 
> >> The comments and the variable naming refer to "chunks" but what is
> >> really meant is "segments." The existing code sends only one
> >> xdr_write_chunk per RPC reply.
> >> 
> >> The fix assumes this as well. When the XDR pad in the first write
> >> chunk is reached, the assumption is the Write list is complete and
> >> send_write_chunks() returns.
> >> 
> >> That will remain a valid assumption until the server Upper Layer can
> >> support multiple bulk payload results per RPC.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> --
> > 
> > Bruce, can you take this for 4.4 ?
> 
> Hi Bruce-
> 
> Your 4.4 pull request did not include this patch.

Whoops, sorry.

For some reason I don't have the original email, though I do see your
first followup.  Would you mind resending?

Also, it looks like that wasn't actually sent to me?  I really want
submitted patches to have my address on the To: line.  Obviously I also
try to pick up stuff sent only to the mailing list, but I'm a little
more likely to miss those.

But my fault either way, apologies.

--b.

> 
> 
> >> net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
> >> 1 files changed, 7 insertions(+), 0 deletions(-)
> >> 
> >> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> >> index 1dfae83..6c48901 100644
> >> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> >> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> >> @@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
> >> 						arg_ch->rs_handle,
> >> 						arg_ch->rs_offset,
> >> 						write_len);
> >> +
> >> +		/* Do not send XDR pad bytes */
> >> +		if (chunk_no && write_len < 4) {
> >> +			chunk_no++;
> >> +			break;
> >> +		}
> >> +
> >> 		chunk_off = 0;
> >> 		while (write_len) {
> >> 			ret = send_write(xprt, rqstp,
> >> 
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > —
> > Chuck Lever
> > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> —
> Chuck Lever
> 
> 
