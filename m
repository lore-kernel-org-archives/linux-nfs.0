Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35086 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcITFDr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 01:03:47 -0400
MIME-Version: 1.0
In-Reply-To: <d72ce63e4a054c8797c9ba92cdad3b5d@SHMBX03.spreadtrum.com>
References: <1472715026-11397-1-git-send-email-zhang.lyra@gmail.com>
 <544e309c-9893-a0ed-ab8a-ccbf5d342dc6@Netapp.com> <d72ce63e4a054c8797c9ba92cdad3b5d@SHMBX03.spreadtrum.com>
From: Chunyan Zhang <zhang.lyra@gmail.com>
Date: Tue, 20 Sep 2016 13:03:45 +0800
Message-ID: <CAAfSe-s6U8A2rccb5Q+ZyhyrGp2ibDxrSY4X+dRQ4iGB8eXDBw@mail.gmail.com>
Subject: =?UTF-8?B?UmU6IOetlOWkjTogW1BBVENIXSBzdW5ycGM6IHF1ZXVlIHdvcmsgb24gc3lzdGVtX3Bvdw==?=
        =?UTF-8?B?ZXJfZWZmaWNpZW50X3dx?=
To: =?UTF-8?B?S2UgV2FuZyAo546L56eRKQ==?= <Ke.Wang@spreadtrum.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resend behalf on Ke Wang.

Thanks,
Chunyan

On 20 September 2016 at 10:33, Ke Wang (=E7=8E=8B=E7=A7=91) <Ke.Wang@spread=
trum.com> wrote:
> May I have any comments for this patch?
> or
> This patch can be merged directly into next release?
>
> Thanks,
> Ke
> ________________________________________
> =E5=8F=91=E4=BB=B6=E4=BA=BA: Anna Schumaker <Anna.Schumaker@netapp.com>
> =E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4: 2016=E5=B9=B49=E6=9C=882=E6=97=A5 2=
:46
> =E6=94=B6=E4=BB=B6=E4=BA=BA: Chunyan Zhang; trond.myklebust@primarydata.c=
om; anna.schumaker@netapp.com; davem@davemloft.net
> =E6=8A=84=E9=80=81: linux-nfs@vger.kernel.org; netdev@vger.kernel.org; li=
nux-kernel@vger.kernel.org; Ke Wang (=E7=8E=8B=E7=A7=91)
> =E4=B8=BB=E9=A2=98: Re: [PATCH] sunrpc: queue work on system_power_effici=
ent_wq
>
> On 09/01/2016 03:30 AM, Chunyan Zhang wrote:
>> From: Ke Wang <ke.wang@spreadtrum.com>
>>
>> sunrpc uses workqueue to clean cache regulary. There is no real dependen=
cy
>> of executing work on the cpu which queueing it.
>>
>> On a idle system, especially for a heterogeneous systems like big.LITTLE=
,
>> it is observed that the big idle cpu was woke up many times just to serv=
ice
>> this work, which against the principle of power saving. It would be bett=
er
>> if we can schedule it on a cpu which the scheduler believes to be the mo=
st
>> appropriate one.
>>
>> After apply this patch, system_wq will be replaced by
>> system_power_efficient_wq for sunrpc. This functionality is enabled when
>> CONFIG_WQ_POWER_EFFICIENT is selected.
>
> Makes sense to me, but I'm a little surprised that there isn't a "schedul=
e_delayed_power_efficient_work()" function to match how the normal workqueu=
e is used.
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
>> @@ -353,7 +353,7 @@ void sunrpc_init_cache_detail(struct cache_detail *c=
d)
>>       spin_unlock(&cache_list_lock);
>>
>>       /* start the cleaning process */
>> -     schedule_delayed_work(&cache_cleaner, 0);
>> +     queue_delayed_work(system_power_efficient_wq, &cache_cleaner, 0);
>>  }
>>  EXPORT_SYMBOL_GPL(sunrpc_init_cache_detail);
>>
>> @@ -476,7 +476,8 @@ static void do_cache_clean(struct work_struct *work)
>>               delay =3D 0;
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
