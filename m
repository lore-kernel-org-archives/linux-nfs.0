Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:60084 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752097AbcIZU40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Sep 2016 16:56:26 -0400
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_sunrpc:_queue_work_on_sys?=
 =?UTF-8?Q?tem=5fpower=5fefficient=5fwq?=
To: =?UTF-8?B?S2UgV2FuZyAo546L56eRKQ==?= <Ke.Wang@spreadtrum.com>,
        Chunyan Zhang <zhang.lyra@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "davem@davemloft.net" <davem@davemloft.net>
References: <1472715026-11397-1-git-send-email-zhang.lyra@gmail.com>
 <544e309c-9893-a0ed-ab8a-ccbf5d342dc6@Netapp.com>
 <d72ce63e4a054c8797c9ba92cdad3b5d@SHMBX03.spreadtrum.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <0828f346-2e30-afb4-6e90-cdefaf5df36f@Netapp.com>
Date: Mon, 26 Sep 2016 16:56:08 -0400
MIME-Version: 1.0
In-Reply-To: <d72ce63e4a054c8797c9ba92cdad3b5d@SHMBX03.spreadtrum.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I took a second look at the patch and it still looks okay to me.  It's in my git tree for 4.9.

Thanks,
Anna

On 09/19/2016 10:33 PM, Ke Wang (王科) wrote:
> May I have any comments for this patch?
> or
> This patch can be merged directly into next release?
> 
> Thanks,
> Ke
> ________________________________________
> 发件人: Anna Schumaker <Anna.Schumaker@netapp.com>
> 发送时间: 2016年9月2日 2:46
> 收件人: Chunyan Zhang; trond.myklebust@primarydata.com; anna.schumaker@netapp.com; davem@davemloft.net
> 抄送: linux-nfs@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Ke Wang (王科)
> 主题: Re: [PATCH] sunrpc: queue work on system_power_efficient_wq
> 
> On 09/01/2016 03:30 AM, Chunyan Zhang wrote:
>> From: Ke Wang <ke.wang@spreadtrum.com>
>>
>> sunrpc uses workqueue to clean cache regulary. There is no real dependency
>> of executing work on the cpu which queueing it.
>>
>> On a idle system, especially for a heterogeneous systems like big.LITTLE,
>> it is observed that the big idle cpu was woke up many times just to service
>> this work, which against the principle of power saving. It would be better
>> if we can schedule it on a cpu which the scheduler believes to be the most
>> appropriate one.
>>
>> After apply this patch, system_wq will be replaced by
>> system_power_efficient_wq for sunrpc. This functionality is enabled when
>> CONFIG_WQ_POWER_EFFICIENT is selected.
> 
> Makes sense to me, but I'm a little surprised that there isn't a "schedule_delayed_power_efficient_work()" function to match how the normal workqueue is used.
> 
> Thanks,
> Anna
> 
>>
>> Signed-off-by: Ke Wang <ke.wang@spreadtrum.com>
>> ---
>>  net/sunrpc/cache.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 4d8e11f..8aabe12 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -353,7 +353,7 @@ void sunrpc_init_cache_detail(struct cache_detail *cd)
>>       spin_unlock(&cache_list_lock);
>>
>>       /* start the cleaning process */
>> -     schedule_delayed_work(&cache_cleaner, 0);
>> +     queue_delayed_work(system_power_efficient_wq, &cache_cleaner, 0);
>>  }
>>  EXPORT_SYMBOL_GPL(sunrpc_init_cache_detail);
>>
>> @@ -476,7 +476,8 @@ static void do_cache_clean(struct work_struct *work)
>>               delay = 0;
>>
>>       if (delay)
>> -             schedule_delayed_work(&cache_cleaner, delay);
>> +             queue_delayed_work(system_power_efficient_wq,
>> +                                &cache_cleaner, delay);
>>  }
>>
>>
>>
> 

