Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35217 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbbJAQhl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 12:37:41 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com>
Date: Thu, 1 Oct 2015 12:37:36 -0400
Cc: Devesh Sharma <devesh.sharma@avagotech.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204435.19671.56195.stgit@manet.1015granger.net> <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com> <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com> <55FE8C0F.1050706@dev.mellanox.co.il> <CANjDDBjcRXsPFt2Bd+9oL2wTBTxpDsAvN5PZN669dhTC7xSyqw@mail.gmail.com> <0804C887-9E32-4257-96D2-6C1FBC9CB271@oracle.com> <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com>
To: linux-rdma <linux-rdma@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 22, 2015, at 1:32 PM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:
> 
> On Mon, Sep 21, 2015 at 9:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> On Sep 21, 2015, at 1:51 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:
>>> 
>>> On Sun, Sep 20, 2015 at 4:05 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>>>>>> It is possible that in a given poll_cq
>>>>>> call you end up getting on 1 completion, the other completion is
>>>>>> delayed due to some reason.
>>>>> 
>>>>> 
>>>>> If a CQE is allowed to be delayed, how does polling
>>>>> again guarantee that the consumer can retrieve it?
>>>>> 
>>>>> What happens if a signal occurs, there is only one CQE,
>>>>> but it is delayed? ib_poll_cq would return 0 in that
>>>>> case, and the consumer would never call again, thinking
>>>>> the CQ is empty. There's no way the consumer can know
>>>>> for sure when a CQ is drained.
>>>>> 
>>>>> If the delayed CQE happens only when there is more
>>>>> than one CQE, how can polling multiple WCs ever work
>>>>> reliably?
>>>>> 
>>>>> Maybe I don't understand what is meant by delayed.
>>>>> 
>>>> 
>>>> If I'm not mistaken, Devesh meant that if between ib_poll_cq (where you
>>>> polled the last 2 wcs) until the while statement another CQE was
>>>> generated then you lost a bit of efficiency. Correct?
>>> 
>>> Yes, That's the point.
>> 
>> I’m optimizing for the common case where 1 CQE is ready
>> to be polled. How much of an efficiency loss are you
>> talking about, how often would this loss occur, and is
>> this a problem for all providers / devices?
> 
> The scenario would happen or not is difficult to predict, but its
> quite possible with any vendor based on load on PCI bus I guess.
> This may affect the latency figures though.
> 
>> 
>> Is this an issue for the current arrangement where 8 WCs
>> are polled at a time?
> 
> Yes, its there even today.

This review comment does not feel closed yet. Maybe it’s
because I don’t understand exactly what the issue is.

Is this the problem that REPORT_MISSED_EVENTS is supposed to
resolve? 

A missed WC will result in an RPC/RDMA transport deadlock. In
fact that is the reason for this particular patch (although
it addresses only one source of missed WCs). So I would like
to see that there are no windows here.

I’ve been told the only sure way to address this for every
provider is to use the classic but inefficient mechanism of
poll one WC at a time until no WC is returned; re-arm; poll
again until no WC is returned.

In the common case this means two extra poll_cq calls that
return nothing. So I claim the current status quo isn’t
good enough :-)

Doug and others have suggested the best place to address
problems with missed WC signals is in the drivers. All of
them should live up to the ib_poll_cq() API contract the
same way. In addition I’d really like to see

 - polling and arming work without having to perform extra
    unneeded locking of the CQ, and
 - polling arrays work without introducing races

Can we have that discussion now, since there is already
some discussion of IB core API fix-ups?


—
Chuck Lever



