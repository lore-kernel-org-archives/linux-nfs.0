Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:49531 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbbATNiR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2015 08:38:17 -0500
Message-ID: <54BE5A41.40707@pocock.pro>
Date: Tue, 20 Jan 2015 14:38:09 +0100
From: Daniel Pocock <daniel@pocock.pro>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: storage controllers for use with NFS+BtrFs
References: <54BD75DF.9010702@pocock.pro> <alpine.OSX.2.19.9992.1501200805110.498@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1501200805110.498@planck.local>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20/01/15 14:25, Benjamin Coddington wrote:
> Hi Daniel,
>
> On Mon, 19 Jan 2015, Daniel Pocock wrote:
>> I've been looking into the issue of which storage controllers are
>> suitable for use with NFS + BtrFs (or NFS + ZFS) and put some comments
>> about it on my blog[1] today.
>>
>> I understand that for NFS it is generally desirable to have non-volatile
>> write cache if you want good write performance.
>>
>> On the other hand, self-healing file systems (BtrFs and ZFS) like having
>> direct access to disks and those RAID cards with caches don't always
>> give the same level of access to the volume.
>>
>> Can anybody give any practical suggestions about how to reconcile these
>> requirements and experience good NFS write performance onto these
>> filesystems given the type of HBA and RAID cards available?
> I don't think that reconciling these requirements is going to necessarily
> equal good NFS write performance.  You've got to define what good means.
> It sounds like you want fast commits, but how fast, how many, what size?
More specific example of the use-case will probably answer that:
- consider a home network or small office, less than 10 users
- aim to improve the performance of tasks such as:
  - unzipping source tarballs with many files in them
  - switching between branches in Git when many files change
  - compiling large projects with many object files or Java class files
to be written
       and/or building packages

For compiling, I can obviously generate my object files on tmpfs or some
other workaround to get performance.

> If you're building on ZFS, best thing would be to find a very fast ZIL
> device, but if you're already building pools on SSD to get any gain you'd
> need something really fast like DDR.  A ramdrive ZIL might be a nice way to
> test that on your setup before spending anything.
>
> Many BBU-d RAID controllers allow JBOD modes that still slice up their
> cache for writes to disk, for example check out megacli's
> "-CfgEachDskRaid0".

Thanks for that feedback

I had been using BtrFs and md at present (1TB for each) and I'm thinking
about going up to 4TB or 6TB and deciding whether to use BtrFs or ZFS on
most of it.

Regards,

Daniel



