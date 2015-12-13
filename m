Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25641 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbbLMU1T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Dec 2015 15:27:19 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 5/6] svcrdma: Add infrastructure to receive backwards direction RPC/RDMA replies
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <566CE4E7.9050307@talpey.com>
Date: Sun, 13 Dec 2015 15:27:15 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9C958C9B-6C55-4570-B633-A620164A54ED@oracle.com>
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net> <20151207204305.12988.2749.stgit@klimt.1015granger.net> <566CE4E7.9050307@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom-


> On Dec 12, 2015, at 10:24 PM, Tom Talpey <tom@talpey.com> wrote:
> 
> Three comments.
> 
> On 12/7/2015 12:43 PM, Chuck Lever wrote:
>> To support the NFSv4.1 backchannel on RDMA connections, add a
>> capability for receiving an RPC/RDMA reply on a connection
>> established by a client.
>> (snip)
> 
>> +/* By convention, backchannel calls arrive via rdma_msg type
> 
> "By convention" is ok, but it's important to note that this is
> actually not "by protocol". Therefore, the following check may
> reject valid messages. Even though it is unlikely an implementation
> will insert chunks, it's not illegal, and ignoring them will
> be less harmful. So I'm going to remake my earlier observation
> that three checks below should be removed:

The convention is established in

 https://datatracker.ietf.org/doc/draft-ietf-nfsv4-rpcrdma-bidirection/

Specifically, it states that backward direction messages in
RPC-over-RDMA Version One cannot have chunks and cannot be
larger than the connection's inline threshold. Thus these
checks are all valid and will not reject valid forward or
backward messages.

The reason for that stipulation is it makes the RPC-over-RDMA
header in backward direction messages a fixed size.

a. The call direction field in incoming RPC headers is then
   always at a predictable offset in backward direction calls.
   This means chunk lists don't have to be parsed to find the
   call direction field. All that is needed is to ensure that
   the chunk lists in the header are empty before going after
   the call direction field. If any chunk list is present, it
   must be a forward direction message.

b. The maximum size of backward direction messages is
   predictable: it is always the inline threshold minus the
   size of the RPC-over-RDMA header (always 28 bytes when
   there are no chunks).

The client side has a very similar looking set of checks in
its reply handler to distinguish incoming backward direction
RPC calls from forward direction RPC replies.


>> + * messages, and never populate the chunk lists. This makes
>> + * the RPC/RDMA header small and fixed in size, so it is
>> + * straightforward to check the RPC header's direction field.
>> + */
>> +static bool
>> +svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp)
>> +{
>> +	__be32 *p = (__be32 *)rmsgp;
>> +
>> +	if (!xprt->xpt_bc_xprt)
>> +		return false;
>> +
>> +	if (rmsgp->rm_type != rdma_msg)
>> +		return false;
> 
> These three:
> 
>> +	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero)
>> +		return false;
>> +	if (rmsgp->rm_body.rm_chunks[1] != xdr_zero)
>> +		return false;
>> +	if (rmsgp->rm_body.rm_chunks[2] != xdr_zero)
>> +		return false;
>> +
> 
> (snip)
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index a1fd74a..3895574 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -309,6 +309,8 @@ struct rpcrdma_buffer {
>>  	u32			rb_bc_srv_max_requests;
>>  	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
>>  	struct list_head	rb_allreqs;
>> +
>> +	u32			rb_bc_max_requests;
> 
> Why does this need to be u32? Shouldn't it be an int, and also the
> rb_bc_srv_max_requests just above? The forward channel max_requests
> are int, btw.

The XDR definition of RPC-over-RDMA in Section 4.3 of
RFC 5666 defines the on-the-wire credits field as a 
uint32.

I prefer that the host representation of this
field match the sign and be able to contain the full
range values that can be conveyed in the on-the-wire
field. That makes marshaling and unmarshaling of the
wire value straightforward; and reasoning about the
C code in our implementation also applies directly to
wire values as well.

The forward channel max_requests field on the client,
rb_max_requests, is also a u32 since commit 9b1dcbc8cf46
from February 2015.

I've changed the equivalent server side field,
sc_max_requests, to a u32 in the next version of this
series.

ib_device_attr::max_qp_wr and svcxprt_rdma::sc_sq_depth
are both signed, but I can't imagine what a negative
value in these fields could mean.

sc_sq_depth is plugged into ib_qp_cap::max_send_wr and
ib_cq_init_attr::cqe, which are both unsigned, so
sc_sq_depth really should be unsigned too, IMHO.

--
Chuck Lever




