Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54963 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab2E1RZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 13:25:00 -0400
Message-ID: <4FC3B4D7.9080000@panasas.com>
Date: Mon, 28 May 2012 20:24:39 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <tao.peng@emc.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS41: add pnfs_dio_begin/dio_end
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com> <1338096780-2763-2-git-send-email-bergwolf@gmail.com> <1338136170.3044.7.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805F0BADF35@MX09A.corp.emc.com> <1338176574.2265.7.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805F0BADF5C@MX09A.corp.emc.com> <4FC356FA.2070008@panasas.com> <4FC358CA.2090301@panasas.com> <CA+a=Yy5c2wCMvOnOSh2y+tHShmR6bnOtMWhoQPPRmkv_q-4D9w@mail.gmail.com>
In-Reply-To: <CA+a=Yy5c2wCMvOnOSh2y+tHShmR6bnOtMWhoQPPRmkv_q-4D9w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 08:14 PM, Peng Tao wrote:

> On Mon, May 28, 2012 at 6:51 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 05/28/2012 01:44 PM, Boaz Harrosh wrote:
>>
>>> On 05/28/2012 07:13 AM, tao.peng@emc.com wrote:
>>>
>>>>> -----Original Message-----
>>>>> From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
>>>>> Sent: Monday, May 28, 2012 11:43 AM
>>>>> To: Peng, Tao
>>>>> Cc: bergwolf@gmail.com; linux-nfs@vger.kernel.org
>>>>> Subject: RE: [PATCH 1/3] NFS41: add pnfs_dio_begin/dio_end
>>>>>
>>>>> On Sun, 2012-05-27 at 22:30 -0400, tao.peng@emc.com wrote:
>>>>>> I'm afraid there is. There is no way to pass struct blk_plug around pg_init/pg_doio, unless we put
>>>>> it in struct nfs_pageio_descriptor, which I think is more intrusive and less efficient as it is only
>>>>> useful for block layout driver in DIO case.
>>>>>
>>>>> Then add a 'void *pg_layout_private' field to nfs_pageio_descriptor and
>>>>> allocate the struct blk_plug dynamically.
>>>>>
>>>
>>>> OK. I thought data structure change is more intrusive because it
>>>> affects all layout drivers and generic NFS as well. But since you
>>>> think it is OK, I will change it as you suggested.
>>>>
>>>
>>>
>>> I want a pg_layout_private in nfs_pageio_descriptor as well. I even wrote
>>> the ML about it. And everyone agreed. (Just never had time to finish)
>>>
>>> So yes please do add it. it will have more users.
>>>
>>
>>
>> I forgot to say. You might want/need to pass this pg_layout_private
>> back to LD->paglist_write/read. (If you need to, I will)
>>
>> (In fact one optimization I wanted for a long time is to pass
>> nfs_pageio_descriptor to paglist_write/read directly instead of
>> duplicating all it's members (back and forth). In a new invented
>> structures where the worse is that the common code of read and write
>> can't be common because it is not the same types.
>> But that's for another patch)
>>
> I also plan to add void *layout_private and unsigned char moreio 


you mean bool moreio. What is it?

> to
> nfs_pageio_header structure, in order to pass necessary information to
> pagelist_read/write. Are there any objections against doing so?
> 


Yes please add it to the passed structure

> The alternative would be to extent pnfs_try_to_read/write_data() and
> read/write_pagelist() APIs to pass in the same information.
> 


Don't add new parameters to the functions. Add new fields to the passed
structures.

> Which one do you prefer? Please share your thoughts. Thank you very much!
> 
> Thanks,
> Tao
> 
>> Ciao
>> Boaz
>>
>>>
>>>> Thanks,
>>>> Tao
>>>>
>>>
>>>
>>> Thanks
>>> Boaz
>>
>>


