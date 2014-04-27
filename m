Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:30904 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaD0MhV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 08:37:21 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <535CD819.3050508@dev.mellanox.co.il>
Date: Sun, 27 Apr 2014 08:37:09 -0400
Cc: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <4ACED3B0-CC8B-4F1F-8DB6-6C272AB17C99@oracle.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com> <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com> <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com> <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com> <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDED915@CMEXMB1.ad.emulex.com> <C689AB91-46F6-4E96-A673-0DE76FE54CC4@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com> <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com> <5358B975.4020207@dev.mellanox.co.il> <B39C0B38-357F-4BDA-BDA7-048BD38853F7@oracle.com> <535CD819.3050508@dev!
 .mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 27, 2014, at 6:12 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 4/24/2014 6:01 PM, Chuck Lever wrote:
>> On Apr 24, 2014, at 3:12 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>> 
>>> On 4/24/2014 2:30 AM, Devesh Sharma wrote:
>>>> Hi Chuck
>>>> 
>>>> Following is the complete call trace of a typical NFS-RDMA transaction while mounting a share.
>>>> It is unavoidable to stop calling post-send in case it is not created. Therefore, applying checks to the connection state is a must
>>>> While registering/deregistering frmrs on-the-fly. The unconnected state of QP implies don't call  post_send/post_recv from any context.
>>>> 
>>> Long thread... didn't follow it all.
>> I think you got the gist of it.
>> 
>>> If I understand correctly this race comes only for *cleanup* (LINV) of FRMR registration while teardown flow destroyed the QP.
>>> I think this might be disappear if for each registration you post LINV+FRMR.
>>> This is assuming that a situation where trying to post Fastreg on a "bad" QP can
>>> never happen (usually since teardown flow typically suspends outgoing commands).
>> That’s typically true for “hard” NFS mounts. But “soft” NFS mounts
>> wake RPCs after a timeout while the transport is disconnected, in
>> order to kill them.  At that point, deregistration still needs to
>> succeed somehow.
> 
> Not sure I understand, Can you please explain why deregistration will not succeed?
> AFAIK You are allowed to register FRMR and then deregister it without having to invalidate it.
> 
> Can you please explain why you logically connected LINV with deregistration?

Confusion. Sorry.

> 
>> 
>> IMO there are three related problems.
>> 
>> 1.  rpcrdma_ep_connect() is allowing RPC tasks to be awoken while
>>     there is no QP at all (->qp is NULL). The woken RPC tasks are
>>     trying to deregister buffers that may include page cache pages,
>>     and it’s oopsing because ->qp is NULL.
>> 
>>     That’s a logic bug in rpcrdma_ep_connect(), and I have an idea
>>     how to address it.
> 
> Why not first create a new id+qp and assign them - and then destroy the old id+qp?
> see SRP related section: ib_srp.x:srp_create_target_ib()
> 
> Anyway it is indeed important to guarantee that no xmit flows happens concurrently to that,
> and cleanups are processed synchronously and in-order.

I posted a patch on Friday that should provide that serialization.

> 
>> 
>> 2.  If a QP is present but disconnected, posting LOCAL_INV won’t work.
>>     That leaves buffers (and page cache pages, potentially) registered.
>>     That could be addressed with LINV+FRMR. But...
>> 
>> 3.  The client should not leave page cache pages registered indefinitely.
>>     Both LINV+FRMR and our current approach depends on having a working
>>     QP _at_ _some_ _point_ … but the client simply can’t depend on that.
>>     What happens if an NFS server is, say, destroyed by fire while there
>>     are active client mount points? What if the HCA’s firmware is
>>     permanently not allowing QP creation?
> 
> Again, I don't understand why you can't dereg_mr().
> 
> How about allocating the FRMR pool *after* the QP was successfully created/connected (makes sense as the FRMRs are
> not usable until then), and destroy/cleanup the pool before the QP is disconnected/destroyed. it also makes sense as they
> must match PDs.

It’s not about deregistration, but rather about invalidation, I was
confused.

xprt_rdma_free() invalidates and then frees the chunks on RPC chunk
lists. We just need to see that those invalidations can be successful
while the transport is disconnected.

I understand that even in the error state, a QP should allow consumers
to post send WRs to invalidate FRMRs…?

The other case is whether the consumer can _replace_ a QP with a fresh
one, and still have invalidations succeed, even if the transport remains
disconnected, once waiting RPCs are awoken.

An alternative would be to invalidate all waiting RPC chunk lists on a
transport as soon as the QP goes to error state but before it is
destroyed, and fastreg the chunks again when waiting RPCs are
remarshalled.

I think the goals are:

  1.  Avoid fastreg on an FRMR that is already valid

  2.  Avoid leaving FRMRs valid indefinitely (preferably just long enough
      to execute the RPC request, and no longer)


> 
>> 
>> Here's a relevant comment in rpcrdma_ep_connect():
>> 
>>  815                 /* TEMP TEMP TEMP - fail if new device:
>>  816                  * Deregister/remarshal *all* requests!
>>  817                  * Close and recreate adapter, pd, etc!
>>  818                  * Re-determine all attributes still sane!
>>  819                  * More stuff I haven't thought of!
>>  820                  * Rrrgh!
>>  821                  */
>> 
>> xprtrdma does not do this today.
>> 
>> When a new device is created, all existing RPC requests could be
>> deregistered and re-marshalled.  As far as I can tell,
>> rpcrdma_ep_connect() is executing in a synchronous context (the connect
>> worker) and we can simply use dereg_mr, as long as later, when the RPCs
>> are re-driven, they know they need to re-marshal.
> 
> Agree.
> 
> Sagi.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



