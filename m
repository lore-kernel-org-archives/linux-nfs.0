Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:47530 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727616AbeJTDNx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 23:13:53 -0400
Date: Fri, 19 Oct 2018 12:06:30 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181019190630.GC28891@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
 <20181019175822.GB28891@bombadil.infradead.org>
 <CAN-5tyHvJQc+mPSvgX09F71otoZEoxRXdKLB=F=bGTzmEnt_eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHvJQc+mPSvgX09F71otoZEoxRXdKLB=F=bGTzmEnt_eA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 02:47:42PM -0400, Olga Kornievskaia wrote:
> On Fri, Oct 19, 2018 at 1:58 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > > +++ b/Documentation/filesystems/vfs.txt
> > > @@ -958,7 +958,9 @@ otherwise noted.
> > >
> > >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> > >
> > > -  copy_file_range: called by the copy_file_range(2) system call.
> > > +  copy_file_range: called by copy_file_range(2) system call. This method
> > > +                works on two file descriptors that might reside on
> > > +                different superblocks of the same type of file system.
> >
> > I don't think this text is explicit enough about what has changed,
> 
> Can you suggest a different wording that would be stronger? I can't
> say any more clear that copy is allowed between different superblock
> which wasn't the case before.

I would leave this file alone.

> > and I
> > think this is the wrong place for it.  I think there should be a paragraph
> > in Documentation/filesystems/porting and it should follow the current style
> > in there.
> 
> I have looked at the "porting" file and it's cryptic. I don't
> understand what [mandatory] [recommended] stanzas are. There is
> currently no copy_file_range. Is this just a "changelog" and you are
> looking for something like
> [mandatory]
> copy_file_range() now allows copying between different superblocks.
> 
> I can add this wording to the "porting" file.

The porting file is written from the point of view of someone who's trying
to port an old filesystem to current Linux.

Maybe something like

[mandatory]
	->copy_file_range() may now be passed files which belong to two
	different filesystems.  The destination's copy_file_range() is the
	function which is called.  If it cannot copy ranges from the source,
	it should return -EXDEV.

> > > -     if (file_out->f_op->copy_file_range) {
> > > +     if (file_out->f_op->copy_file_range &&
> > > +                     (file_in->f_op->copy_file_range ==
> > > +                             file_out->f_op->copy_file_range)) {
> >
> > Can we avoid this extra test here?  I know the various stamdards groups
> > including T10 and the IETF have been trying to define a universal
> > identifier for the same blob of storage, no matter how it's accessed;
> > potentially allowing access to the same storage across iSCSI, CIFS
> > and NFS.  If we ever get to a point where we support that (and I am
> > dubious), we'd want to remove this test again, and have to revalidate
> > all the filesystems.
> 
> Well from previous submissions I was explicitly asked to add this check.

I'm not sure that's exactly what Jeff was asking for.  Or maybe it was
and my argument above will change his mind.  Jeff, what do you think?

If we do do this, cifs will need a modification as part of this patch to
reject non-CIFS files as it currently assumes that src_file->private_data
is a pointer to a struct cifsFileInfo.
