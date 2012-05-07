Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:53706 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab2EGJTr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 05:19:47 -0400
Message-ID: <4FA793AB.70107@pocock.com.au>
Date: Mon, 07 May 2012 09:19:39 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
References: <4FA5E950.5080304@pocock.com.au>   <1336328594.2593.14.camel@lade.trondhjem.org>   <4FA6EBD4.7040308@pocock.com.au>  <1336340993.2600.11.camel@lade.trondhjem.org>  <4FA6F75E.6090300@pocock.com.au> <1336344160.2600.30.camel@lade.trondhjem.org>
In-Reply-To: <1336344160.2600.30.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> Ok, so the combination of:
>>
>> - enable writeback with hdparm
>> - use ext4 (and not ext3)
>> - barrier=1 and data=writeback?  or data=?
>>
>> - is there a particular kernel version (on either client or server side)
>> that will offer more stability using this combination of features?
> 
> Not that I'm aware of. As long as you have a kernel > 2.6.29, then LVM
> should work correctly. The main problem is that some SATA hardware tends
> to be buggy, defeating the methods used by the barrier code to ensure
> data is truly on disk. I believe that XFS will therefore actually test
> the hardware when you mount with write caching and barriers, and should
> report if the test fails in the syslogs.
> See http://xfs.org/index.php/XFS_FAQ#Write_barrier_support.
> 
>> I think there are some other variations of my workflow that I can
>> attempt too, e.g. I've contemplated compiling C++ code onto a RAM disk
>> because I don't need to keep the hundreds of object files.
> 
> You might also consider using something like ccache and set the
> CCACHE_DIR to a local disk if you have one.
> 


Thanks for the feedback about these options, I am going to look at these
strategies more closely


>>>>> setups really _suck_ at dealing with fsync(). The latter is used every
>>>>
>>>> I'm using md RAID1, my setup is like this:
>>>>
>>>> 2x 1TB SATA disks ST31000528AS (7200rpm with 32MB cache and NCQ)
>>>>
>>>> SATA controller: ATI Technologies Inc SB700/SB800 SATA Controller [AHCI
>>>> mode] (rev 40)
>>>> - not using any of the BIOS softraid stuff
>>>>
>>>> Both devices have identical partitioning:
>>>> 1. 128MB boot
>>>> 2. md volume (1TB - 128MB)
>>>>
>>>> The entire md volume (/dev/md2) is then used as a PV for LVM
>>>>
>>>> I do my write tests on a fresh LV with no fragmentation
>>>>
>>>>> time the NFS client sends a COMMIT or trunc() instruction, and for
>>>>> pretty much all file and directory creation operations (you can use
>>>>> 'nfsstat' to monitor how many such operations the NFS client is sending
>>>>> as part of your test).
>>>>
>>>> I know that my two tests are very different in that way:
>>>>
>>>> - dd is just writing one big file, no fsync
>>>>
>>>> - unpacking a tarball (or compiling a large C++ project) does a lot of
>>>> small writes with many fsyncs
>>>>
>>>> In both cases, it is slow
>>>>
>>>>> Local disk can get away with doing a lot less fsync(), because the cache
>>>>> consistency guarantees are different:
>>>>>       * in NFS, the server is allowed to crash or reboot without
>>>>>         affecting the client's view of the filesystem.
>>>>>       * in the local file system, the expectation is that on reboot any
>>>>>         data lost is won't need to be recovered (the application will
>>>>>         have used fsync() for any data that does need to be persistent).
>>>>>         Only the disk filesystem structures need to be recovered, and
>>>>>         that is done using the journal (or fsck).
>>>>
>>>>
>>>> Is this an intractable problem though?
>>>>
>>>> Or do people just work around this, for example, enable async and
>>>> write-back cache, and then try to manage the risk by adding a UPS and/or
>>>> battery backed cache to their RAID setup (to reduce the probability of
>>>> unclean shutdown)?
>>>
>>> It all boils down to what kind of consistency guarantees you are
>>> comfortable living with. The default NFS server setup offers much
>>> stronger data consistency guarantees than local disk, and is therefore
>>> likely to be slower when using cheap hardware.
>>>
>>
>> I'm keen for consistency, because I don't like the idea of corrupting
>> some source code or a whole git repository for example.
>>
>> How did you know I'm using cheap hardware?  It is a HP MicroServer, I
>> even got the £100 cash-back cheque:
>>
>> http://www8.hp.com/uk/en/campaign/focus-for-smb/solution.html#/tab2/
>>
>> Seriously though, I've worked with some very large arrays in my business
>> environment, but I use this hardware at home because of the low noise
>> and low heat dissipation rather than for saving money, so I would like
>> to try and get the most out of it if possible and I'm very grateful for
>> these suggestions.
> 
> Right. All I'm saying is that when comparing local disk and NFS
> performance, then make sure that you are doing an apples-to-apples
> comparison.
> The main reason for wanting to use NFS in a home setup would usually be
> in order to simultaneously access the same data through several clients.
> If that is not a concern, then perhaps transforming your NFS server into
> an iSCSI target might fit your performance requirements better?

There are various types of content, some things, like VM images, are
only accessed by one client at a time, those could be iSCSI.

However, some of the code I'm compiling needs to be built on different
platforms (e.g. I have a Debian squeeze desktop, and Debian wheezy in a
VM), consequently, it is convenient for me to have access to the git
workspaces from all these hosts using NFS.



