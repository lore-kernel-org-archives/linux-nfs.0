Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:36538 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932802AbbJNS0x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 14:26:53 -0400
Received: by obbrx8 with SMTP id rx8so46364443obb.3
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 11:26:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014181142.GE11398@birch.djwong.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org> <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com> <20151014181142.GE11398@birch.djwong.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 Oct 2015 11:26:32 -0700
Message-ID: <CALCETrWMQsuWtPHD8S=xore_COSDpe47k0PVhJKPcOkYfyfpTw@mail.gmail.com>
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:11 AM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Wed, Oct 14, 2015 at 01:59:40PM -0400, Anna Schumaker wrote:
>> On 10/12/2015 07:17 PM, Darrick J. Wong wrote:
>> > On Sun, Oct 11, 2015 at 07:22:03AM -0700, Christoph Hellwig wrote:
>> >> On Wed, Sep 30, 2015 at 01:26:52PM -0400, Anna Schumaker wrote:
>> >>> This allows us to have an in-kernel copy mechanism that avoids frequent
>> >>> switches between kernel and user space.  This is especially useful so
>> >>> NFSD can support server-side copies.
>> >>>
>> >>> I make pagecache copies configurable by adding three new (exclusive)
>> >>> flags:
>> >>> - COPY_FR_REFLINK tells vfs_copy_file_range() to only create a reflink.
>> >>> - COPY_FR_COPY does a full data copy, but may be filesystem accelerated.
>> >>> - COPY_FR_DEDUP creates a reflink, but only if the contents of both
>> >>>   ranges are identical.
>> >>
>> >> All but FR_COPY really should be a separate system call.  Clones (an
>> >> dedup as a special case of clones) are really a separate beast from file
>> >> copies.
>> >>
>> >> If I want to clone a file I either want it clone fully or fail, not copy
>> >> a certain amount.  That means that a) we need to return an error not
>> >> short "write", and b) locking impementations are important - we need to
>> >> prevent other applications from racing with our clone even if it is
>> >> large, while to get these semantics for the possible short returning
>> >> file copy will require a proper userland locking protocol. Last but not
>> >> least file copies need to be interruptible while clones should be not.
>> >> All this is already important for local file systems and even more
>> >> important for NFS exporting.
>> >>
>> >> So I'd suggest to drop this patch and just let your syscall handle
>> >> actualy copies with all their horrors.  We can go with Peng's patches
>> >> to generalize the btrfs ioctls for clones for now which is what everyone
>> >> already uses anyway, and then add a separate sys_file_clone later.
>>
>> So what I'm hearing is that I should drop the reflink and dedup flags and
>> change this system call only perform a full copy (with preserving of
>> sparseness), correct?  I can make those changes, but only if everybody is in
>> agreement that it's the best way forward.
>
> Sounds fine to me; I'll work on promoting EXTENT_SAME to the VFS.
>
>> The only reason I haven't done anything to make this system call
>> interruptible is because I haven't been able to find any documentation or
>> examples for making system calls interruptible.  How do I do this?
>
> I thought it was mostly a matter of sprinkling in "if (signal_pending(...))
> return -ERESTARTSYS" type things whenever it's convenient to check.  The splice
> code already seems to have this, though I'm no expert on what the splice code
> actually does. :)
>

Oh, right.  That's for making loops that don't otherwise block
interruptible.  If you're doing wait_xyz, then you want to use the
interruptable variable of that.

Anyway, I just checked on x86.  The relevant error codes are (I think):

-EINTR: returns -EINTR to userspace with no special handling.

-ERESTARTNOINTR: end the syscall, call a signal handler if
appropriate, then retry the syscall with the same arguments (i.e. the
syscall needs to make sure that trying again is an acceptable thing to
do by, e.g., updating offsets that are used).

-ERESTARTSYS: same as -ERESTARTNOINTR *unless* there's an unblocked
signal handler that has SA_RESTART clear, which which case the caller
gets -EINTR.

-ERESTARTNOHAND: end the syscall and retry with the same arguments if
no signal handler would be called; otherwise call the signal handler
and return -EINTR to the caller.

-ERESTART_RESTARTBLOCK: return -EINTR if a signal is delivered and
otherwise use the restart_block mechanism.  (Don't use that -- it's
evil.)

So -ERESTARTSYS is probably the most sensible thing to use under
normal circumstances.

--Andy
