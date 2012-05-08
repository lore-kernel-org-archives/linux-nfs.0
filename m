Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:43317 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab2EHMH2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 08:07:28 -0400
Message-ID: <4FA90C63.7000505@pocock.com.au>
Date: Tue, 08 May 2012 12:06:59 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
References: <4FA5E950.5080304@pocock.com.au> <1336328594.2593.14.camel@lade.trondhjem.org> <4FA6EBD4.7040308@pocock.com.au> <1336340993.2600.11.camel@lade.trondhjem.org> <4FA6F75E.6090300@pocock.com.au> <1336344160.2600.30.camel@lade.trondhjem.org> <4FA793AB.70107@pocock.com.au> <4FA7D54E.9080309@pocock.com.au> <20120507171759.GA10137@fieldses.org>
In-Reply-To: <20120507171759.GA10137@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/05/12 17:18, J. Bruce Fields wrote:
> On Mon, May 07, 2012 at 01:59:42PM +0000, Daniel Pocock wrote:
>>
>>
>> On 07/05/12 09:19, Daniel Pocock wrote:
>>>
>>>>> Ok, so the combination of:
>>>>>
>>>>> - enable writeback with hdparm
>>>>> - use ext4 (and not ext3)
>>>>> - barrier=1 and data=writeback?  or data=?
>>>>>
>>>>> - is there a particular kernel version (on either client or server side)
>>>>> that will offer more stability using this combination of features?
>>>>
>>>> Not that I'm aware of. As long as you have a kernel > 2.6.29, then LVM
>>>> should work correctly. The main problem is that some SATA hardware tends
>>>> to be buggy, defeating the methods used by the barrier code to ensure
>>>> data is truly on disk. I believe that XFS will therefore actually test
>>>> the hardware when you mount with write caching and barriers, and should
>>>> report if the test fails in the syslogs.
>>>> See http://xfs.org/index.php/XFS_FAQ#Write_barrier_support.
>>>>
>>>>> I think there are some other variations of my workflow that I can
>>>>> attempt too, e.g. I've contemplated compiling C++ code onto a RAM disk
>>>>> because I don't need to keep the hundreds of object files.
>>>>
>>>> You might also consider using something like ccache and set the
>>>> CCACHE_DIR to a local disk if you have one.
>>>>
>>>
>>>
>>> Thanks for the feedback about these options, I am going to look at these
>>> strategies more closely
>>>
>>
>>
>> I decided to try and take md and LVM out of the picture, I tried two
>> variations:
>>
>> a) the boot partitions are not mirrored, so I reformatted one of them as
>> ext4,
>> - enabled write-cache for the whole of sdb,
>> - mounted ext4, barrier=1,data=ordered
>> - and exported this volume over NFS
>>
>> unpacking a large source tarball on this volume, iostat reports write
>> speeds that are even slower, barely 300kBytes/sec
> 
> How many file creates per second?
> 

I ran:
nfsstat -s -o all -l -Z5
and during the test (unpacking the tarball), I see numbers like these
every 5 seconds for about 2 minutes:

nfs v3 server        total:      319
------------- ------------- --------
nfs v3 server      getattr:        1
nfs v3 server      setattr:      126
nfs v3 server       access:        6
nfs v3 server        write:       61
nfs v3 server       create:       61
nfs v3 server        mkdir:        3
nfs v3 server       commit:       61


I decided to expand the scope of my testing too, I want to rule out the
possibility that my HP Microserver with onboard SATA is the culprit.  I
set up two other NFS servers (all Debian 6, kernel 2.6.38):

HP Z800 Xeon workstation
Intel Corporation 82801 SATA RAID Controller (operating as AHCI)
VB0250EAVER (250GB 7200rpm)

Lenovo Thinkpad X220
Intel Corporation Cougar Point 6 port SATA AHCI Controller (rev 04)
SSDSA2BW160G3L  (160GB SSD)

Both the Z800 and X220 run as NFSv3 servers
Each one has a fresh 10GB logical volume formatted ext4,
mount options: barrier=1,data=ordered
write cache (hdparm -W 1): enabled

Results:
NFS client: X220
NFS server: Z800 (regular disk)
iostat reports about 1,000kbytes/sec when unpacking the tarball
This is just as slow as the original NFS server

NFS client: Z800
NFS server: X220 (SSD disk)
iostat reports about 22,000kbytes/sec when unpacking the tarball

It seems that buying a pair of SSDs for my HP MicroServer will let me
use NFS `sync' and enjoy healthy performance - 20x faster.

However, is there really no other way to get more speed out of NFS when
using the `sync' option?


