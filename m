Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:56869 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab2EGN7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 09:59:47 -0400
Message-ID: <4FA7D54E.9080309@pocock.com.au>
Date: Mon, 07 May 2012 13:59:42 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
References: <4FA5E950.5080304@pocock.com.au>   <1336328594.2593.14.camel@lade.trondhjem.org>   <4FA6EBD4.7040308@pocock.com.au>  <1336340993.2600.11.camel@lade.trondhjem.org>  <4FA6F75E.6090300@pocock.com.au> <1336344160.2600.30.camel@lade.trondhjem.org> <4FA793AB.70107@pocock.com.au>
In-Reply-To: <4FA793AB.70107@pocock.com.au>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/05/12 09:19, Daniel Pocock wrote:
> 
>>> Ok, so the combination of:
>>>
>>> - enable writeback with hdparm
>>> - use ext4 (and not ext3)
>>> - barrier=1 and data=writeback?  or data=?
>>>
>>> - is there a particular kernel version (on either client or server side)
>>> that will offer more stability using this combination of features?
>>
>> Not that I'm aware of. As long as you have a kernel > 2.6.29, then LVM
>> should work correctly. The main problem is that some SATA hardware tends
>> to be buggy, defeating the methods used by the barrier code to ensure
>> data is truly on disk. I believe that XFS will therefore actually test
>> the hardware when you mount with write caching and barriers, and should
>> report if the test fails in the syslogs.
>> See http://xfs.org/index.php/XFS_FAQ#Write_barrier_support.
>>
>>> I think there are some other variations of my workflow that I can
>>> attempt too, e.g. I've contemplated compiling C++ code onto a RAM disk
>>> because I don't need to keep the hundreds of object files.
>>
>> You might also consider using something like ccache and set the
>> CCACHE_DIR to a local disk if you have one.
>>
> 
> 
> Thanks for the feedback about these options, I am going to look at these
> strategies more closely
> 


I decided to try and take md and LVM out of the picture, I tried two
variations:

a) the boot partitions are not mirrored, so I reformatted one of them as
ext4,
- enabled write-cache for the whole of sdb,
- mounted ext4, barrier=1,data=ordered
- and exported this volume over NFS

unpacking a large source tarball on this volume, iostat reports write
speeds that are even slower, barely 300kBytes/sec

b) I took an external USB HDD,
- created two 20GB partitions sdc1 and sdc2
- formatted sdc1 as btrfs
- formatted sdc2 as ext4
- mounted sdc2 the same as sdb1 in test (a),
      ext4, barrier=1,data=ordered
- exported both volumes over NFS

unpacking a large source tarball on these two volumes, iostat reports
write speeds that are around 5MB/sec - much faster than the original
problem I was having

Bottom line, this leaves me with the impression that either
- the server's SATA controller or disks need a firmware upgrade,
- or there is some issue with the kernel barriers and/or cache flushing
on this specific SATA hardware.

I think it is fair to say that the NFS client is not at fault, however,
I can imagine many people would be tempted to just use `async' when
faced with a problem like this, given that async makes everything just
run fast.

