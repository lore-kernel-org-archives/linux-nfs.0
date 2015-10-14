Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:47024 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbbJNR7o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 13:59:44 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
CC: "Darrick J. Wong" <darrick.wong@oracle.com>, <linux-nfs@vger.kernel.org>,
        <linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-api@vger.kernel.org>, <zab@zabbo.net>,
        <viro@zeniv.linux.org.uk>, <clm@fb.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561E980C.9010509@Netapp.com>
Date: Wed, 14 Oct 2015 13:59:40 -0400
MIME-Version: 1.0
In-Reply-To: <20151012231749.GC11398@birch.djwong.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2015 07:17 PM, Darrick J. Wong wrote:
> On Sun, Oct 11, 2015 at 07:22:03AM -0700, Christoph Hellwig wrote:
>> On Wed, Sep 30, 2015 at 01:26:52PM -0400, Anna Schumaker wrote:
>>> This allows us to have an in-kernel copy mechanism that avoids frequent
>>> switches between kernel and user space.  This is especially useful so
>>> NFSD can support server-side copies.
>>>
>>> I make pagecache copies configurable by adding three new (exclusive)
>>> flags:
>>> - COPY_FR_REFLINK tells vfs_copy_file_range() to only create a reflink.
>>> - COPY_FR_COPY does a full data copy, but may be filesystem accelerated.
>>> - COPY_FR_DEDUP creates a reflink, but only if the contents of both
>>>   ranges are identical.
>>
>> All but FR_COPY really should be a separate system call.  Clones (an
>> dedup as a special case of clones) are really a separate beast from file
>> copies.
>>
>> If I want to clone a file I either want it clone fully or fail, not copy
>> a certain amount.  That means that a) we need to return an error not
>> short "write", and b) locking impementations are important - we need to
>> prevent other applications from racing with our clone even if it is
>> large, while to get these semantics for the possible short returning
>> file copy will require a proper userland locking protocol. Last but not
>> least file copies need to be interruptible while clones should be not.
>> All this is already important for local file systems and even more
>> important for NFS exporting.
>>
>> So I'd suggest to drop this patch and just let your syscall handle
>> actualy copies with all their horrors.  We can go with Peng's patches
>> to generalize the btrfs ioctls for clones for now which is what everyone
>> already uses anyway, and then add a separate sys_file_clone later.

So what I'm hearing is that I should drop the reflink and dedup flags and change this system call only perform a full copy (with preserving of sparseness), correct?  I can make those changes, but only if everybody is in agreement that it's the best way forward.

The only reason I haven't done anything to make this system call interruptible is because I haven't been able to find any documentation or examples for making system calls interruptible.  How do I do this?

Anna

> 
> Hm.  Peng's patches only generalize the CLONE and CLONE_RANGE ioctls from
> btrfs, however they don't port over the (vastly different) EXTENT_SAME ioctl.
> 
> What does everyone think about generalizing EXTENT_SAME?  The interface enables
> one to ask the kernel to dedupe multiple file ranges in a single call.  That's
> more complex than what I was proposing with COPY_FR_DEDUP(E), but I'm assuming
> that the extra complexity buys us the ability to ... multi-dedupe at the same
> time, with locks held on the source file?
> 
> I'm happy to generalize the existing EXTENT_SAME, but please yell if you really
> hate the interface.
> 
> --D
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-api" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

