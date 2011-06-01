Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36971 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab1FAS4b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 14:56:31 -0400
Received: by wwk4 with SMTP id 4so3759764wwk.1
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2011 11:56:30 -0700 (PDT)
Message-ID: <4DE68B59.3030402@panasas.com>
Date: Wed, 01 Jun 2011 21:56:25 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Weston Andros Adamson <dros@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
References: <1306898310-9229-1-git-send-email-dros@netapp.com>	<4DE5D287.603@panasas.com>	<09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>	<4DE65202.2010502@panasas.com> <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>
In-Reply-To: <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-01 19:01, Fred Isaman wrote:
> On Wed, Jun 1, 2011 at 10:51 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2011-06-01 17:44, Weston Andros Adamson wrote:
>>>
>>> On Jun 1, 2011, at 1:47 AM, Boaz Harrosh wrote:
>>>
>>>> On 06/01/2011 06:18 AM, Weston Andros Adamson wrote:
>>>>> Use nfs_generic_pg_test instead of pnfs_generic_pg_test.
>>>>>
>>>>> This fixes the BUG at fs/nfs/write.c:941 introduced by
>>>>> 89a58e32d9105c01022a757fb32ddc3b51bf0025.
>>>>>
>>>>> I was able to trigger this BUG reliably using pynfs in pnfs mode,
>>>>> by using dd(1) to write many small blocks.
>>>>>
>>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>>> ---
>>>>> Fix proposed by Trond.
>>>>>
>>>>> Benny- Does this make sense?
>>>>>
>>>>> fs/nfs/nfs4filelayout.c  |    2 +-
>>>>> fs/nfs/pagelist.c        |    5 ++++-
>>>>> include/linux/nfs_page.h |    3 ++-
>>>>> 3 files changed, 7 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>>> index 4269088..1c3bb72 100644
>>>>> --- a/fs/nfs/nfs4filelayout.c
>>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>>> @@ -661,7 +661,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>>>>     u64 p_stripe, r_stripe;
>>>>>     u32 stripe_unit;
>>>>>
>>>>> -   if (!pnfs_generic_pg_test(pgio, prev, req))
>>>>> +   if (!nfs_generic_pg_test(pgio, prev, req))
>>>>>             return 0;
>>>>>
>>>>
>>>> pnfs_generic_pg_test is the one that gets the layout.
>>>>
>>>> What you've done is revert to MDS IO
>>>>
>>>> Boaz
>>>
>>> Ah, you're right - I didn't even notice that!  I usually confirm client -> DS communication with tcpdump.  I was working for too long yesterday :)
>>>
>>> Patch: recalled.  Discussion about a real fix: started.
>>>
>>> -dros
>>
>> I think the following should work:
>>
>> Benny
>>
>> git diff --stat -p -M
>>  fs/nfs/nfs4filelayout.c |   10 ++++++++++
>>  1 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 4269088..9f1d445 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -661,6 +661,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor
>> *pgio, struct nfs_page *prev,
>>        u64 p_stripe, r_stripe;
>>        u32 stripe_unit;
>>
>> +       /*
>> +        * FIXME: ideally we should be able to coalesce all requests
>> +        * that are not block boundary aligned, but currently this
>> +        * is problematic for the case of bsize < PAGE_CACHE_SIZE,
>> +        * since nfs_flush_multi and nfs_pagein_multi assume you
>> +        * can have only one struct nfs_page.
>> +        */
>> +       if (desc->pg_bsize < PAGE_SIZE)
>> +               return 0;
>> +
>>        if (!pnfs_generic_pg_test(pgio, prev, req))
>>                return 0;
>>
> 
> Note this moves a test that was once part of the plain nfs code into
> the file layout driver.  Why don't other drivers need this test?

True.  Note I said it would work, not that it's the right fix? :-/
This just tells us what change exposed this issue...

Boaz moved this check to the nfs only path assuming that pg_bsize,
which holds the MDS's wsize/rsize is irrelevant for coalescing requests
for striping over pnfs.

I'm still convinced why nfs_flush_multi cannot use desc->pg_lseg
if it exists, but at the same time it seems like not doing the
right thing for pnfs coalescing in nfs_pageio_init_write and
nfs_pageio_do_add_request.

For pnfs, we need to ignore wsize, meaning we first need to try
to coalesce the pages and then decide if we're going the nfs_flush_multi
or the nfs_flush_one way, based on the coalesced length.

Benny

> 
> Fred
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

