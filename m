Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359AbbDKACL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 20:02:11 -0400
Date: Fri, 10 Apr 2015 17:02:08 -0700
From: Zach Brown <zab@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150411000208.GA20949@lenny.home.zabbo.net>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
 <1428703236-24735-2-git-send-email-zab@redhat.com>
 <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 06:36:41PM -0400, Trond Myklebust wrote:
> On Fri, Apr 10, 2015 at 6:00 PM, Zach Brown <zab@redhat.com> wrote:

> > +
> > +/*
> > + * copy_file_range() differs from regular file read and write in that it
> > + * specifically allows return partial success.  When it does so is up to
> > + * the copy_file_range method.
> > + */
> > +ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > +                           struct file *file_out, loff_t pos_out,
> > +                           size_t len, int flags)
> 
> I'm going to repeat a gripe with this interface. I really don't think
> we should treat copy_file_range() as taking a size_t length, since
> that is not sufficient to do a full file copy on 32-bit systems w/ LFS
> support.

*nod*.  The length type is limited by the syscall return type and the
arbitrary desire to mimic read/write.

I sympathize with wanting to copy giant files with operations that don't
scale with file size because files can be enormous but sparse.

> Could we perhaps instead of a length, define a 'pos_in_start' and a
> 'pos_in_end' offset (with the latter being -1 for a full-file copy)
> and then return an 'loff_t' value stating where the copy ended?

Well, the resulting offset will be set if the caller provided it.  So
they could already be getting the copied length from that.  But they
might not specify the offsets.  Maybe they're just using the results to
total up a completion indicator.

Maybe we could make the length a pointer like the offsets that's set to
the copied length on return.

This all seems pretty gross.  Does anyone else have a vote?

(And I'll argue strongly against creating magical offset values that
change behaviour.  If we want to ignore arguments and get the length
from the source file we'd add a flag to do so.)

> Note that both btrfs and NFSv4.2 allow for 64-bit lengths, so this
> interface would be closer to what is already in use anyway.

Yeah, btrfs doesn't allow partial progress.  It returns 0 on success.
We could also do that but people have expressed an interest in returning
partial progress.

- z
