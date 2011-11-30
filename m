Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62008 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab1K3Mmz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 07:42:55 -0500
Received: by bkas6 with SMTP id s6so819469bka.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 04:42:53 -0800 (PST)
Message-ID: <4ED624C8.8080504@tonian.com>
Date: Wed, 30 Nov 2011 14:42:48 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tao.peng@emc.com
CC: bharrosh@panasas.com, bergwolf@gmail.com, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> <4ED54FE4.9050008@panasas.com> <F19688880B763E40B28B2B462677FBF805E3A4B073@MX09A.corp.emc.com> <4ED5A808.8050705@panasas.com> <F19688880B763E40B28B2B462677FBF805E3A4B0A1@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E3A4B0A1@MX09A.corp.emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-30 07:05, tao.peng@emc.com wrote:
>> -----Original Message-----
>> From: Boaz Harrosh [mailto:bharrosh@panasas.com]
>> Sent: Wednesday, November 30, 2011 11:51 AM
>> To: Peng, Tao
>> Cc: bergwolf@gmail.com; Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; bhalevy@tonian.com
>> Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
>>
>> On 11/29/2011 07:16 PM, tao.peng@emc.com wrote:
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Boaz
>>>> Harrosh
>>>> Sent: Wednesday, November 30, 2011 5:34 AM
>>>> To: Peng Tao
>>>> Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; bhalevy@tonian.com
>>>> Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
>>>>
>>>> On 12/02/2011 08:52 PM, Peng Tao wrote:
>>>>> Issuing layoutget at .pg_init will drop the IO size information and ask for 4KB
>>>>> layout every time. However, the IO size information is very valuable for MDS to
>>>>> determine how much layout it should return to client.
>>>>>
>>>>> The patchset try to allow LD not to send layoutget at .pg_init but instead at
>>>>> pnfs_do_multiple_writes. So that real IO size is preserved and sent to MDS.
>>>>>
>>>>> Tests against a server that does not aggressively pre-allocate layout, shows
>>>>> that the IO size informantion is really useful to block layout MDS.
>>>>>
>>>>> The generic pnfs layer changes are trival to file layout and object as long as
>>>>> they still send layoutget at .pg_init.
>>>>>
>>>>
>>>> I have a better solution for your problem. Which is a much smaller a change and
>>>> I think gives you much better heuristics.
>>>>
>>>> Keep the layout_get exactly where it is, but instead of sending PAGE_SIZE send
>>>> the amount of dirty pages you have.
>>>>
>>>> If it is a linear write you will be exact on the money with a single lo_get. If
>>>> it is an heavy random write then you might need more lo_gets and you might be getting
>>>> some unused segments. But heavy random write is rare and slow anyway. As a first
>>>> approximation its fine. (We can later fix that as well)
>>>
>>> I would say no to the above... For objects/files MDS, it may not hurt
>>> much to allocate wasting layout. But for blocklayout server, each
>>> layout allocation consumes much more resource than just giving out
>>> stripping information like objects/files.
>>
>> That's fine, for the linear IO like iozone below my way is just the same
>> as yours. For the random IO I'm not sure how much better will your solution
>> be. Not by much.
> As I said, for random IO, there will be much disk space wasting on blocklayout server in your solution. That's why I don't agree with it. Besides, in some cases, server may be put in a hard position to determine if the IO is really linear or in fact random in your solution.
> 
>>
>> I want a solution for objects as well. But I cannot use yours because I need
>> a layout before the final request consolidation. Solve my problem too.
>>
> I used to look at objects at some time, and as I remember, it need max io size in each lseg to finish .pg_test. Is this the reason you need a layout before the final request consolidation? Does the value vary in different lseg?
> 
>>> So helping MDS to do the
>>> correct decision is the right thing for client to do.
>>
>> I agree. All I'm saying is that there is available information at the time
>> of .pg_init to send that number just fine. Have you looked? it's all there
>> NFS core can tell you how many pages have passed ->write_pages.
>>
> It only tells a fake IO size for the number of dirty pages. No one can promise these pages are all continuous. Instead, if we can give a real IO size, why refuse to do it?
> 

I agree. The client need not blindly extend loga_length.
Simply ask for what you need and let the server optimize the result.

Benny

>>>
>>>>
>>>> The .pg_init is done after .write_pages call from VFS and all the to-be-written
>>>> pages are already staged to be written. So there should be a way to easily extract
>>>> that information.
>>>>
>>>>> iozone cmd:
>>>>> ./iozone -r 1m -s 4G -w -W -c -t 10 -i 0 -F /mnt/iozone.data.1 /mnt/iozone.data.2
>> /mnt/iozone.data.3
>>>> /mnt/iozone.data.4 /mnt/iozone.data.5 /mnt/iozone.data.6 /mnt/iozone.data.7 /mnt/iozone.data.8
>>>> /mnt/iozone.data.9 /mnt/iozone.data.10
>>>>>
>>>>> Befor patch: around 12MB/s throughput
>>>>> After patch: around 72MB/s throughput
>>>>>
>>>>
>>>> Yes Yes that stupid Brain dead Server is no indication for anything. The server
>>>> should know best about optimal sizes and layouts. Please don't give me that stuff
>>>> again.
>>>>
>>> Actually the server is already doing layout pre-allocation. It is
>>> just that it doesn't know what client really wants so cannot do it
>>> too aggressively. That's why I wanted to make client to send the REAL
>>> IO size information to server. From performance perspective, dropping
>>> IO size information is always a BAD THING(TM) to do.
>>
>> I totally agree. I want it too. There is a way to do it in pg_init time
>> all the information is there it only needs to be passed to layout_get.
>>
> This "all the information is there" is likely to be false, unless you only deal with sequential IO...
> 
>>>
>>>> BTW don't limit the lo_segment size by the max_io_size. This is why you
>>>> have .bg_test to signal when IO is maxed out.
>>>>
>>> Actually lo_segment size is never limited by max_io_size. Server is
>>> always entitled to send larger layout than client asks from.
>>
>> You miss my point. In your last patch you have
>>
>> +/* While RFC doesn't limit maximum size of layout, we better limit it ourself. */
>> +#define PNFSBLK_MAXRSIZE (0x1<<22)
>> +#define PNFSBLK_MAXWSIZE (0x1<<21)
>>
>> I don't know what these number mean but they kind of look like IO limits
>> and not segment limits. If I'm wrong then sorry. What are these numbers?
>>
> Yes, these are io size limit. I should just remove the comments that are totally misleading.
> 
>> If a client has 1G of dirty pages to write why not get the full layout
>> at once. Where does the 4M limit comes from?
>>
> Please note that block layout server cannot just give full file stripping information. When we ask for 1GB layout, most times we get much less anyway. And the value of 2MB comes from our experience with MPFS, to allow the balance between server pressure and client performance.
> 
> Also, currently we retry MDS on a per nfs_read/write_data basis. It is much easier to handle 2MB rather than 1GB dirty pages. I notice that it may not be an issue for objects as you have max IO size limit on every lseg.
> 
>>>
>>>> - The read segments should be as big as possible (i_size long)
>>>> - The Write segments should ideally be as big as the Application
>>>>   wants to write to. (Amount of dirty pages at time of nfs-write-out
>>>>   is a very good first approximation).
>>>>
>>>> So I guess it is: I hate these patches, to much mess, too little goodness.
>>> I'm afraid I can't agree with you...
>>>
>>
>> Sure you do. You did the hard work and now I'm telling you you need to do
>> more work. I'm sorry for that. But I want a solution for me and I think
>> there is a simple solution that will satisfy both of our needs.
>>
> Sorry but I don't think your solution is good enough to address blocklayout's concerns. It would be great if we can utilize the same solution. But when we do need, I think it perfectly reasonable to let blocklayout and object layout have different strategy on layoutget, based on the fact that our servers have different behavior on layout allocation. And allowing this kind of difference is exactly what strcut nfs_pageio_ops serves for.
> 
> What do you think?
> 
> Thanks,
> Tao
>> Sorry for that. If I had time I would do it. Only I have harder real BUGS
>> to fix on my plate.
>>
>> If you could look into it It will be very nice. And thank you for working
>> on this so far. Only that current solution is not optimal and I will need
>> to continue on it later, if left as is.
>>
>>> Thanks,
>>> Tao
>>>
>>
>> Thanks
> 
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r��z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�mml==
