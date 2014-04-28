Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46432 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbaD1I6d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 04:58:33 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so5283271wib.17
        for <linux-nfs@vger.kernel.org>; Mon, 28 Apr 2014 01:58:32 -0700 (PDT)
Message-ID: <535E1834.8080601@dev.mellanox.co.il>
Date: Mon, 28 Apr 2014 11:58:28 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com> <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com> <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com> <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com> <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDED915@CMEXMB1.ad.emulex.com> <C689AB91-46F6-4E96-A673-0DE76FE54CC4@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com> <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com> <5358B975.4020207@dev.mellanox.co.il> <B39C0B38-357F-4BDA-BDA7-048BD38853F7@oracle.com> <535CD819.3050508@dev! .mellanox.co.il> <4ACED3B0-CC8B-4F1F-8DB6-6C272AB17C99@oracle.com>
In-Reply-To: <4ACED3B0-CC8B-4F1F-8DB6-6C272AB17C99@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/27/2014 3:37 PM, Chuck Lever wrote:

<SNIP>

>> Why not first create a new id+qp and assign them - and then destroy the old id+qp?
>> see SRP related section: ib_srp.x:srp_create_target_ib()
>>
>> Anyway it is indeed important to guarantee that no xmit flows happens concurrently to that,
>> and cleanups are processed synchronously and in-order.
> I posted a patch on Friday that should provide that serialization.
>
>>> 2.  If a QP is present but disconnected, posting LOCAL_INV won’t work.
>>>      That leaves buffers (and page cache pages, potentially) registered.
>>>      That could be addressed with LINV+FRMR. But...
>>>
>>> 3.  The client should not leave page cache pages registered indefinitely.
>>>      Both LINV+FRMR and our current approach depends on having a working
>>>      QP _at_ _some_ _point_ … but the client simply can’t depend on that.
>>>      What happens if an NFS server is, say, destroyed by fire while there
>>>      are active client mount points? What if the HCA’s firmware is
>>>      permanently not allowing QP creation?
>> Again, I don't understand why you can't dereg_mr().
>>
>> How about allocating the FRMR pool *after* the QP was successfully created/connected (makes sense as the FRMRs are
>> not usable until then), and destroy/cleanup the pool before the QP is disconnected/destroyed. it also makes sense as they
>> must match PDs.
> It’s not about deregistration, but rather about invalidation, I was
> confused.

OK got it.

> xprt_rdma_free() invalidates and then frees the chunks on RPC chunk
> lists. We just need to see that those invalidations can be successful
> while the transport is disconnected.

They can't be completed though. Can't you just skip invalidation? will 
be done when FRMR is reused.
Sorry to be difficult, but I still don't understand why invalidation 
must occur in this case.

> I understand that even in the error state, a QP should allow consumers
> to post send WRs to invalidate FRMRs…?

Its allowed, they won't execute though (I'll be surprised if they will).
AFAIK posting on a QP in error state has only one use-case - post a 
colored WQE to know that FLUSH errors has ended.

>
> The other case is whether the consumer can _replace_ a QP with a fresh
> one, and still have invalidations succeed, even if the transport remains
> disconnected, once waiting RPCs are awoken.

Which invalidations succeeded and which didn't are known - so I don't 
see the problem here.
The only thing is the corner case that Steve indicated wrt flush errors, 
but if I recall correctly
posting LINV on an invalidated MR is allowed.

>
> An alternative would be to invalidate all waiting RPC chunk lists on a
> transport as soon as the QP goes to error state but before it is
> destroyed, and fastreg the chunks again when waiting RPCs are
> remarshalled.
>
> I think the goals are:
>
>    1.  Avoid fastreg on an FRMR that is already valid
>
>    2.  Avoid leaving FRMRs valid indefinitely (preferably just long enough
>        to execute the RPC request, and no longer)

(1) is a non-issue for INV+FASTREG.
Can you please explain your concern on (2)? is it security (server can 
keep doing RDMA)?
because you have remote invalidate for that (server can implement 
SEND+INVALIDATE).

Having said that, I probably don't see the full picture here like you 
guys so I might be missing some things.

Sagi.
