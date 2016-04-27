Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22149 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbcD0QAA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 12:00:00 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Removing NFS/RDMA client support for PHYSICAL memory registration
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1B0B3E47-05C0-4134-B486-0869628B453C@oracle.com>
Date: Wed, 27 Apr 2016 11:59:29 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C0D8DC78-C6AB-4926-AF27-5D51E16FD447@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192259.3566.58807.stgit@manet.1015granger.net> <571FCF03.4060406@grimberg.me> <1B0B3E47-05C0-4134-B486-0869628B453C@oracle.com>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 4:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Apr 26, 2016, at 4:26 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
>> 
>> 
>> 
>> On 25/04/16 22:22, Chuck Lever wrote:
>>> There needs to be a safe method of releasing registered memory
>>> resources when an RPC terminates. Safe can mean a number of things:
>>> 
>>> + Doesn't have to sleep
>>> 
>>> + Doesn't rely on having a QP in RTS
>>> 
>>> ro_unmap_safe will be that safe method. It can be used in cases
>>> where synchronous memory invalidation can deadlock, or needs to have
>>> an active QP.
>>> 
>>> The important case is fencing an RPC's memory regions after it is
>>> signaled (^C) and before it exits. If this is not done, there is a
>>> window where the server can write an RPC reply into memory that the
>>> client has released and re-used for some other purpose.
>>> 
>>> Note that this is a full solution for FRWR, but FMR and physical
>>> still have some gaps where a particularly bad server can wreak
>>> some havoc on the client. These gaps are not made worse by this
>>> patch and are expected to be exceptionally rare and timing-based.
>>> They are noted in documenting comments.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

[ snip ]

>>> diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
>>> index 2dc6ec2..95ef3a7 100644
>>> --- a/net/sunrpc/xprtrdma/physical_ops.c
>>> +++ b/net/sunrpc/xprtrdma/physical_ops.c
>>> @@ -97,6 +97,25 @@ physical_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>>> 		rpcrdma_unmap_one(device, &req->rl_segments[i++]);
>>> }
>>> 
>>> +/* Use a slow, safe mechanism to invalidate all memory regions
>>> + * that were registered for "req".
>>> + *
>>> + * For physical memory registration, there is no good way to
>>> + * fence a single MR that has been advertised to the server. The
>>> + * client has already handed the server an R_key that cannot be
>>> + * invalidated and is shared by all MRs on this connection.
>>> + * Tearing down the PD might be the only safe choice, but it's
>>> + * not clear that a freshly acquired DMA R_key would be different
>>> + * than the one used by the PD that was just destroyed.
>>> + * FIXME.
>>> + */
>>> +static void
>>> +physical_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
>>> +		       bool sync)
>>> +{
>>> +	physical_op_unmap_sync(r_xprt, req);
>>> +}
>>> +
>> 
>> So physical has no async mode?
> 
> Nope. There's no way to fence memory once a client has
> exposed its whole-memory R_key.
> 
> The client could drop its connection and delete the PD.
> 
> 
>> Is there a device that makes you resort to physical memreg?
> 
> I'm not aware of one.
> 
> 
>> It's an awful lot of maintenance on what looks to be a esoteric (at
>> best) code path.
> 
> It's never chosen by falling back to that mode.
> 
> physical has long been on the chopping block. Last time
> I suggested removing it I got a complaint. But there's no
> in-kernel device that requires this mode, so seems like
> it should go sooner rather than later.

I'm planning to add support for NFS/RDMA with Kerberos
in v4.8. That seems like a very appropriate time to
remove PHYSICAL, which is not secure.

Is there any objection to removing PHYSICAL in v4.8?


--
Chuck Lever



