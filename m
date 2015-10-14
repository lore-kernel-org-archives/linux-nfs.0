Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34480 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbbJNSJB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 14:09:01 -0400
Received: by oiak8 with SMTP id k8so32540067oia.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 11:09:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <561E980C.9010509@Netapp.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org> <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 Oct 2015 11:08:40 -0700
Message-ID: <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 10:59 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 10/12/2015 07:17 PM, Darrick J. Wong wrote:
>> On Sun, Oct 11, 2015 at 07:22:03AM -0700, Christoph Hellwig wrote:
>>> On Wed, Sep 30, 2015 at 01:26:52PM -0400, Anna Schumaker wrote:
>>>> This allows us to have an in-kernel copy mechanism that avoids frequent
>>>> switches between kernel and user space.  This is especially useful so
>>>> NFSD can support server-side copies.
>>>>
>>>> I make pagecache copies configurable by adding three new (exclusive)
>>>> flags:
>>>> - COPY_FR_REFLINK tells vfs_copy_file_range() to only create a reflink.
>>>> - COPY_FR_COPY does a full data copy, but may be filesystem accelerated.
>>>> - COPY_FR_DEDUP creates a reflink, but only if the contents of both
>>>>   ranges are identical.
>>>
>>> All but FR_COPY really should be a separate system call.  Clones (an
>>> dedup as a special case of clones) are really a separate beast from file
>>> copies.
>>>
>>> If I want to clone a file I either want it clone fully or fail, not copy
>>> a certain amount.  That means that a) we need to return an error not
>>> short "write", and b) locking impementations are important - we need to
>>> prevent other applications from racing with our clone even if it is
>>> large, while to get these semantics for the possible short returning
>>> file copy will require a proper userland locking protocol. Last but not
>>> least file copies need to be interruptible while clones should be not.
>>> All this is already important for local file systems and even more
>>> important for NFS exporting.
>>>
>>> So I'd suggest to drop this patch and just let your syscall handle
>>> actualy copies with all their horrors.  We can go with Peng's patches
>>> to generalize the btrfs ioctls for clones for now which is what everyone
>>> already uses anyway, and then add a separate sys_file_clone later.
>
> So what I'm hearing is that I should drop the reflink and dedup flags and change this system call only perform a full copy (with preserving of sparseness), correct?  I can make those changes, but only if everybody is in agreement that it's the best way forward.

I personally rather like the reflink option.  That thing is quite useful.

>
> The only reason I haven't done anything to make this system call interruptible is because I haven't been able to find any documentation or examples for making system calls interruptible.  How do I do this?
>

For just interruptability, avoid waiting in non-interruptable ways and
return -EINTR if one of your wait calls returns -EINTR.

For restartability, it's more complicated.  There are special values
you can return that give the signal code hints as to what to do.

--Andy
