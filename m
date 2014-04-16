Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39660 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161180AbaDPOMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 10:12:34 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so1440387wib.17
        for <linux-nfs@vger.kernel.org>; Wed, 16 Apr 2014 07:12:32 -0700 (PDT)
Message-ID: <534E8FCE.909@dev.mellanox.co.il>
Date: Wed, 16 Apr 2014 17:12:30 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com>
In-Reply-To: <534E8608.8030801@opengridcomputing.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/16/2014 4:30 PM, Steve Wise wrote:
> On 4/16/2014 7:48 AM, Sagi Grimberg wrote:
>> On 4/15/2014 1:23 AM, Chuck Lever wrote:
>>> The current CQ handler uses the ib_wc.opcode field to distinguish
>>> between event types. However, the contents of that field are not
>>> reliable if the completion status is not IB_WC_SUCCESS.
>>>
>>> When an error completion occurs on a send event, the CQ handler
>>> schedules a tasklet with something that is not a struct rpcrdma_rep.
>>> This is never correct behavior, and sometimes it results in a panic.
>>>
>>> To resolve this issue, split the completion queue into a send CQ and
>>> a receive CQ. The send CQ handler now handles only struct rpcrdma_mw
>>> wr_id's, and the receive CQ handler now handles only struct
>>> rpcrdma_rep wr_id's.
>>
>> Hey Chuck,
>>
>> So 2 suggestions related (although not directly) to this one.
>>
>> 1. I recommend suppressing Fastreg completions - no one cares that 
>> they succeeded.
>>
>
> Not true.  The nfsrdma client uses frmrs across re-connects for the 
> same mount and needs to know at any point in time if a frmr is 
> registered or invalid.  So completions of both fastreg and invalidate 
> need to be signaled.  See:
>
> commit 5c635e09cec0feeeb310968e51dad01040244851
> Author: Tom Tucker <tom@ogc.us>
> Date:   Wed Feb 9 19:45:34 2011 +0000
>
>     RPCRDMA: Fix FRMR registration/invalidate handling.
>

Hmm, But if either FASTREG or LINV failed the QP will go to error state 
and you *will* get the error wc (with a rain of FLUSH errors).
AFAICT it is safe to assume that it succeeded as long as you don't get 
error completions.
Moreover, FASTREG on top of FASTREG are not allowed indeed, but AFAIK 
LINV on top of LINV are allowed.
It is OK to just always do LINV+FASTREG post-list each registration and 
this way no need to account for successful completions.

Cheers,
Sagi.
