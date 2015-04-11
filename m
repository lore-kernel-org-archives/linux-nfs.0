Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33893 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbbDKNEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Apr 2015 09:04:09 -0400
Received: by qkgx75 with SMTP id x75so78515147qkg.1
        for <linux-nfs@vger.kernel.org>; Sat, 11 Apr 2015 06:04:08 -0700 (PDT)
Date: Sat, 11 Apr 2015 09:04:02 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Zach Brown <zab@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150411090402.67d22d02@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
	<1428703236-24735-2-git-send-email-zab@redhat.com>
	<CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
	<20150411000208.GA20949@lenny.home.zabbo.net>
	<CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 10 Apr 2015 20:24:06 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Apr 10, 2015 at 8:02 PM, Zach Brown <zab@redhat.com> wrote:
> > On Fri, Apr 10, 2015 at 06:36:41PM -0400, Trond Myklebust wrote:
> >> On Fri, Apr 10, 2015 at 6:00 PM, Zach Brown <zab@redhat.com> wrote:
> >
> >> > +
> >> > +/*
> >> > + * copy_file_range() differs from regular file read and write in that it
> >> > + * specifically allows return partial success.  When it does so is up to
> >> > + * the copy_file_range method.
> >> > + */
> >> > +ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >> > +                           struct file *file_out, loff_t pos_out,
> >> > +                           size_t len, int flags)
> >>
> >> I'm going to repeat a gripe with this interface. I really don't think
> >> we should treat copy_file_range() as taking a size_t length, since
> >> that is not sufficient to do a full file copy on 32-bit systems w/ LFS
> >> support.
> >
> > *nod*.  The length type is limited by the syscall return type and the
> > arbitrary desire to mimic read/write.
> >
> > I sympathize with wanting to copy giant files with operations that don't
> > scale with file size because files can be enormous but sparse.
> 
> The other argument against using a size_t is that there is no memory
> buffer involved here. size_t is, after all, a type describing
> in-memory objects, not files.
> 
> >> Could we perhaps instead of a length, define a 'pos_in_start' and a
> >> 'pos_in_end' offset (with the latter being -1 for a full-file copy)
> >> and then return an 'loff_t' value stating where the copy ended?
> >
> > Well, the resulting offset will be set if the caller provided it.  So
> > they could already be getting the copied length from that.  But they
> > might not specify the offsets.  Maybe they're just using the results to
> > total up a completion indicator.
> >
> > Maybe we could make the length a pointer like the offsets that's set to
> > the copied length on return.
> 
> That works, but why do we care so much about the difference between a
> length and an offset as a return value?
> 

I think it just comes down to potential confusion for users. What's
more useful, the number of bytes actually copied, or the offset into the
file where the copy ended?

I tend to the think an offset is more useful for someone trying to
copy a file in chunks, particularly if the file is sparse. That gives
them a clear place to continue the copy.

So, I think I agree with Trond that phrasing this interface in terms of
file offsets seems like it might be more useful. That also neatly
sidesteps the size_t limitations on 32-bit platforms.

> To be fair, the NFS copy offload also allows the copy to proceed out
> of order, in which case the range of copied data could be
> non-contiguous in the case of a failure. However neither the length
> nor the offset case will give you the full story in that case. Any
> return value can at best be considered to define an offset range whose
> contents need to be checked for success/failure.
> 

Yuck! How the heck do you clean up the mess if that happens? I guess
you're just stuck redoing the copy with normal READ/WRITE?

Maybe we need to have the interface return a hard error in that
case and not try to give back any sort of offset?

> > This all seems pretty gross.  Does anyone else have a vote?
> >
> > (And I'll argue strongly against creating magical offset values that
> > change behaviour.  If we want to ignore arguments and get the length
> > from the source file we'd add a flag to do so.)
> 
> The '-1' was not intended to be a special/magical value: as far as I'm
> concerned any end offset that covers the full range of supported file
> lengths would be OK.
> 

Agreed. A "whole file" flag might also be useful too, but I'd leave
that for after the initial implementation is merged, just in the
interest of having _something_ that works in the near term.

> >> Note that both btrfs and NFSv4.2 allow for 64-bit lengths, so this
> >> interface would be closer to what is already in use anyway.
> >
> > Yeah, btrfs doesn't allow partial progress.  It returns 0 on success.
> > We could also do that but people have expressed an interest in returning
> > partial progress.
> 
> Returning an end offset would satisfy the partial progress requirement
> (with the caveat mentioned above).
> 

-- 
Jeff Layton <jlayton@poochiereds.net>
