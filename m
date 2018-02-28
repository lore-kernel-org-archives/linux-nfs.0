Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:35522 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935590AbeB1XER (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 18:04:17 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 7/8] xprtrdma: Chain Send to FastReg WRs
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180228225946.GF19007@ziepe.ca>
Date: Wed, 28 Feb 2018 18:04:13 -0500
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <59D65B93-6B35-46CC-B550-A5854A89757E@oracle.com>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
 <20180228203059.25968.28807.stgit@manet.1015granger.net>
 <37357f5c-25c5-b862-4e4f-7f84a38a29b2@Netapp.com>
 <20180228225946.GF19007@ziepe.ca>
To: Jason Gunthorpe <jgg@ziepe.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 28, 2018, at 5:59 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>=20
> On Wed, Feb 28, 2018 at 04:51:11PM -0500, Anna Schumaker wrote:
>>=20
>>=20
>> On 02/28/2018 03:30 PM, Chuck Lever wrote:
>>> With FRWR, the client transport can perform memory registration and
>>> post a Send with just a single ib_post_send.
>>>=20
>>> This reduces contention between the send_request path and the Send
>>> Completion handlers, and reduces the overhead of registering a chunk
>>> that has multiple segments.
>>>=20
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> net/sunrpc/xprtrdma/fmr_ops.c   |   11 ++++++++
>>> net/sunrpc/xprtrdma/frwr_ops.c  |   51 =
+++++++++++++++++++++++++++------------
>>> net/sunrpc/xprtrdma/verbs.c     |    3 +-
>>> net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
>>> 4 files changed, 49 insertions(+), 18 deletions(-)
>>>=20
>>> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c =
b/net/sunrpc/xprtrdma/fmr_ops.c
>>> index 629e539..5cc68a8 100644
>>> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
>>> @@ -251,6 +251,16 @@ enum {
>>> 	return ERR_PTR(-EIO);
>>> }
>>>=20
>>> +/* Post Send WR containing the RPC Call message.
>>> + */
>>> +static int
>>> +fmr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
>>> +{
>>> +	struct ib_send_wr *bad_wr;
>>> +
>>> +	return ib_post_send(ia->ri_id->qp, &req->rl_sendctx->sc_wr, =
&bad_wr);
>>=20
>> I wish there was a bad_wr null-check in ib_post_send() (or in the
>> infiniband drivers) so you don't have to declare a variable that's
>> never used again.  Coordinating that might be more work than it's
>> worth, though.
>=20
> It is a good point, I actually don't think we have any user in kernel
> of bad_wr ..

Yes, frwr_op_unmap_sync() uses the 3rd argument, and I'm about to add
a call site for ib_post_recv which uses that argument as well.


> Would prefer to just drop the parameter and add a new function call if
> really, really needed.

You could do something like

  ib_post_send_one(qp, wr);

for the common case; and likewise for ib_post_recv.

--
Chuck Lever



