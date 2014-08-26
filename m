Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32086 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbaHZHYF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 03:24:05 -0400
Message-ID: <53FC3600.9050202@oracle.com>
Date: Tue, 26 Aug 2014 15:23:44 +0800
From: Junxiao Bi <junxiao.bi@oracle.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Mel Gorman <mgorman@suse.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
References: <53F6F772.6020708@oracle.com>	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>	<20140825164852.50723141@notabene.brown>	<53FC1E93.2060800@oracle.com>	<20140826162138.5df2f8a3@notabene.brown>	<53FC2DDD.9050705@oracle.com> <20140826170410.20560764@notabene.brown>
In-Reply-To: <20140826170410.20560764@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 03:04 PM, NeilBrown wrote:
> On Tue, 26 Aug 2014 14:49:01 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
> 
>> On 08/26/2014 02:21 PM, NeilBrown wrote:
>>> On Tue, 26 Aug 2014 13:43:47 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
>>>
>>>> On 08/25/2014 02:48 PM, NeilBrown wrote:
>>>>> On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>>
>>>>>> Junxiao Bi reports seeing the following deadlock:
>>>>>>
>>>>>> @ crash> bt 1539
>>>>>> @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
>>>>>> @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
>>>>>> @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
>>>>>> @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
>>>>>> @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
>>>>>> @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
>>>>>> @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
>>>>>> @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
>>>>>> @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
>>>>>> @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
>>>>>> @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
>>>>>> @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
>>>>>> @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
>>>>>
>>>>> This stack trace (from 2.6.32) cannot happen in mainline, though it took me a
>>>>> while to remember/discover exactly why.
>>>>>
>>>>> try_to_free_pages() creates a 'struct scan_control' with ->target_mem_cgroup
>>>>> set to NULL.
>>>>> shrink_page_list() checks ->target_mem_cgroup using global_reclaim() and if
>>>>> it is NULL, wait_on_page_writeback is *not* called.
>>>>>
>>>>> So we can only hit this deadlock if mem-cgroup limits are imposed on a
>>>>> process which is using NFS - which is quite possible but probably not common.
>>>>>
>>>>> The fact that a dead-lock can happen only when memcg limits are imposed seems
>>>>> very fragile.  People aren't going to test that case much so there could well
>>>>> be other deadlock possibilities lurking.
>>>>>
>>>>> Mel: might there be some other way we could get out of this deadlock?
>>>>> Could the wait_on_page_writeback() in shrink_page_list() be made a timed-out
>>>>> wait or something?  Any other wait out of this deadlock other than setting
>>>>> PF_MEMALLOC_NOIO everywhere?
>>>>
>>>> Not only the wait_on_page_writeback() cause the deadlock but also the
>>>> next pageout()-> (mapping->a_ops->writepage), Trond's second patch fix
>>>> this. So fix the wait_on_page_writeback is not enough to fix deadlock.
>>>
>>> Shortly before the only place that pageout() is called there is this code:
>>>
>>> 			if (page_is_file_cache(page) &&
>>> 					(!current_is_kswapd() ||
>>> 					 !zone_is_reclaim_dirty(zone))) {
>>>                                 .....
>>> 				goto keep_locked;
>>>
>>>
>>> So pageout() only gets called by kswapd() .... or for swap. swap-over-NFS is
>>> already very cautious about memory allocations, and uses nfs_direct_IO, not
>>> nfs_writepage.
>>>
>>> So nfs_writepage will never get called during direct reclaim.  There is no
>>> memory-allocate deadlock risk there.
>> Yes, thanks for explaining this.
>> But is it possible rpciod blocked somewhere by memory allocation using
>> GFP_KERNEL and kswapd is trying to pageout nfs dirty pages and blocked
>> by rpciod?
> 
> I don't think so, no.
> 
> Only 40% of memory (/proc/sys/vm/dirty_ratio) can be dirty.  The direct
> reclaim procedure will eventually find some non-dirty memory it can use.
> If it cannot, and cannot write anything out to swap either, it will
> eventually trigger the OOM killer.
> 
> Direct reclaim shouldn't ever block indefinitely.  It will sometimes wait for
> a short while (e.g. congestion_wait()) but it should then push on until it
> finds something it can do: free a clean page, write something to swap, or
> kill a memory-hog with the OOM killer.
That makes sense. Thanks.

Junxiao.
> 
> NeilBrown
> 

