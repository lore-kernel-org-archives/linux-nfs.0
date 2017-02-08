Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:25477 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750966AbdBHS2t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 13:28:49 -0500
Subject: Re: [PATCH v2 0/5] Fix "support large inline thresholds"
To: Chuck Lever <chuck.lever@oracle.com>
References: <20170123205159.21699.47373.stgit@manet.1015granger.net>
 <353a72a5-549d-535b-28b7-411ba81483a1@Netapp.com>
 <82302622-9524-4020-869E-81F57629EC86@oracle.com>
 <68619BE7-CBFD-41DE-8227-ABCD797E81F7@oracle.com>
 <D12FEB95-6948-4E51-84EA-6D138C7F8B12@oracle.com>
CC: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <3357fff7-f41d-3a07-ff60-4650b63a292a@Netapp.com>
Date: Wed, 8 Feb 2017 13:28:41 -0500
MIME-Version: 1.0
In-Reply-To: <D12FEB95-6948-4E51-84EA-6D138C7F8B12@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/08/2017 11:47 AM, Chuck Lever wrote:
> 
>> On Feb 1, 2017, at 1:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>>
>>> On Jan 24, 2017, at 4:46 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>>
>>>> On Jan 24, 2017, at 4:35 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>>>
>>>> Hi Chuck,
>>>>
>>>> On 01/23/2017 03:52 PM, Chuck Lever wrote:
>>>>> Hi Anna-
>>>>>
>>>>> I've received a number of reports that v4.9 commit 655fec6987be
>>>>> ("xprtrdma: Use gathered Send for large inline messages") causes
>>>>> NFS/RDMA mounts to fail for devices that have a small max_sge.
>>>>>
>>>>> This series addresses that problem. Would you consider this series
>>>>> of bug fixes for v4.10-rc?
>>>>
>>>> I noticed that patches one and four are the only ones with a "Fixes:" tag.  Do you need all five patches to fix the problem, or can the rest be deferred to 4.11?
>>>
>>> 5/5 can be deferred if you want. The others are all required to
>>> fix the problem. However, these were tested as a series. I'm
>>> reticent to split them at this point.
>>>
>>> Should 1 - 4 have a "Fixes: 655fec6987be ("xprtrdma: Use
>>> gathered Send for large ...")" ?
>>
>> Hi Anna, is there anything more you need from me? As above,
>> I was hoping these could be included in v4.10-rc, which is
>> likely to be closed in just a week or two.
> 
> Hi Anna-
> 
> Since I haven't heard from you regarding this series, and v4.10
> final is imminent, I will assume these fixes should be folded
> into nfs-rdma-for-4.11. v3 of nfs-rdma-for-4.11 will include
> these patches.

Sorry that I dropped the ball on these :(  I was considering sending them for v4.11 but with a "Cc stable" so that they get backported to v4.9 and v4.10 kernels.  Rolling them into v3 sounds good to me.

Thanks,
Anna

> 
> 
>>>> Thanks,
>>>> Anna
>>>>
>>>>>
>>>>>
>>>>> Available in the "nfs-rdma-for-4.10-rc" topic branch of this git repo:
>>>>>
>>>>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>>>>>
>>>>> And for online review:
>>>>>
>>>>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.10-rc
>>>>>
>>>>>
>>>>> Changes since v1:
>>>>> - Rebased on v4.10-rc5
>>>>> - Renamed some variables for clarity
>>>>> - Clarified patch descriptions
>>>>> - Added Tested-by and Reviewed-by tags
>>>>>
>>>>> ---
>>>>>
>>>>> Chuck Lever (5):
>>>>>    xprtrdma: Fix Read chunk padding
>>>>>    xprtrdma: Per-connection pad optimization
>>>>>    xprtrdma: Disable pad optimization by default
>>>>>    xprtrdma: Reduce required number of send SGEs
>>>>>    xprtrdma: Shrink send SGEs array
>>>>>
>>>>>
>>>>> net/sunrpc/xprtrdma/rpc_rdma.c  |   62 +++++++++++++++++++++++++--------------
>>>>> net/sunrpc/xprtrdma/transport.c |    2 +
>>>>> net/sunrpc/xprtrdma/verbs.c     |   15 ++++++---
>>>>> net/sunrpc/xprtrdma/xprt_rdma.h |   14 ++++++---
>>>>> 4 files changed, 60 insertions(+), 33 deletions(-)
>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>>
>>>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Chuck Lever
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
