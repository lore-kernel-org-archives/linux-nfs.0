Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54713 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab1K3Du6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 22:50:58 -0500
Message-ID: <4ED5A808.8050705@panasas.com>
Date: Tue, 29 Nov 2011 19:50:32 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <tao.peng@emc.com>
CC: <bergwolf@gmail.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <bhalevy@tonian.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> <4ED54FE4.9050008@panasas.com> <F19688880B763E40B28B2B462677FBF805E3A4B073@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E3A4B073@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 07:16 PM, tao.peng@emc.com wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Boaz
>> Harrosh
>> Sent: Wednesday, November 30, 2011 5:34 AM
>> To: Peng Tao
>> Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; bhalevy@tonian.com
>> Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
>>
>> On 12/02/2011 08:52 PM, Peng Tao wrote:
>>> Issuing layoutget at .pg_init will drop the IO size information and ask for 4KB
>>> layout every time. However, the IO size information is very valuable for MDS to
>>> determine how much layout it should return to client.
>>>
>>> The patchset try to allow LD not to send layoutget at .pg_init but instead at
>>> pnfs_do_multiple_writes. So that real IO size is preserved and sent to MDS.
>>>
>>> Tests against a server that does not aggressively pre-allocate layout, shows
>>> that the IO size informantion is really useful to block layout MDS.
>>>
>>> The generic pnfs layer changes are trival to file layout and object as long as
>>> they still send layoutget at .pg_init.
>>>
>>
>> I have a better solution for your problem. Which is a much smaller a change and
>> I think gives you much better heuristics.
>>
>> Keep the layout_get exactly where it is, but instead of sending PAGE_SIZE send
>> the amount of dirty pages you have.
>>
>> If it is a linear write you will be exact on the money with a single lo_get. If
>> it is an heavy random write then you might need more lo_gets and you might be getting
>> some unused segments. But heavy random write is rare and slow anyway. As a first
>> approximation its fine. (We can later fix that as well)
>
> I would say no to the above... For objects/files MDS, it may not hurt
> much to allocate wasting layout. But for blocklayout server, each
> layout allocation consumes much more resource than just giving out
> stripping information like objects/files. 

That's fine, for the linear IO like iozone below my way is just the same
as yours. For the random IO I'm not sure how much better will your solution
be. Not by much.

I want a solution for objects as well. But I cannot use yours because I need
a layout before the final request consolidation. Solve my problem too.

> So helping MDS to do the
> correct decision is the right thing for client to do.

I agree. All I'm saying is that there is available information at the time
of .pg_init to send that number just fine. Have you looked? it's all there
NFS core can tell you how many pages have passed ->write_pages.

> 
>>
>> The .pg_init is done after .write_pages call from VFS and all the to-be-written
>> pages are already staged to be written. So there should be a way to easily extract
>> that information.
>>
>>> iozone cmd:
>>> ./iozone -r 1m -s 4G -w -W -c -t 10 -i 0 -F /mnt/iozone.data.1 /mnt/iozone.data.2 /mnt/iozone.data.3
>> /mnt/iozone.data.4 /mnt/iozone.data.5 /mnt/iozone.data.6 /mnt/iozone.data.7 /mnt/iozone.data.8
>> /mnt/iozone.data.9 /mnt/iozone.data.10
>>>
>>> Befor patch: around 12MB/s throughput
>>> After patch: around 72MB/s throughput
>>>
>>
>> Yes Yes that stupid Brain dead Server is no indication for anything. The server
>> should know best about optimal sizes and layouts. Please don't give me that stuff
>> again.
>>
> Actually the server is already doing layout pre-allocation. It is
> just that it doesn't know what client really wants so cannot do it
> too aggressively. That's why I wanted to make client to send the REAL
> IO size information to server. From performance perspective, dropping
> IO size information is always a BAD THING(TM) to do.

I totally agree. I want it too. There is a way to do it in pg_init time
all the information is there it only needs to be passed to layout_get.

> 
>> BTW don't limit the lo_segment size by the max_io_size. This is why you
>> have .bg_test to signal when IO is maxed out.
>>
> Actually lo_segment size is never limited by max_io_size. Server is
> always entitled to send larger layout than client asks from.

You miss my point. In your last patch you have

+/* While RFC doesn't limit maximum size of layout, we better limit it ourself. */
+#define PNFSBLK_MAXRSIZE (0x1<<22)
+#define PNFSBLK_MAXWSIZE (0x1<<21)

I don't know what these number mean but they kind of look like IO limits
and not segment limits. If I'm wrong then sorry. What are these numbers?

If a client has 1G of dirty pages to write why not get the full layout
at once. Where does the 4M limit comes from?

> 
>> - The read segments should be as big as possible (i_size long)
>> - The Write segments should ideally be as big as the Application
>>   wants to write to. (Amount of dirty pages at time of nfs-write-out
>>   is a very good first approximation).
>>
>> So I guess it is: I hate these patches, to much mess, too little goodness.
> I'm afraid I can't agree with you...
> 

Sure you do. You did the hard work and now I'm telling you you need to do
more work. I'm sorry for that. But I want a solution for me and I think
there is a simple solution that will satisfy both of our needs.

Sorry for that. If I had time I would do it. Only I have harder real BUGS
to fix on my plate.

If you could look into it It will be very nice. And thank you for working
on this so far. Only that current solution is not optimal and I will need
to continue on it later, if left as is.

> Thanks,
> Tao
> 

Thanks
