Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vs1-f65.google.com ([209.85.217.65]:42347 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727410AbeJTCzN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 22:55:13 -0400
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181019175822.GB28891@bombadil.infradead.org>
In-Reply-To: <20181019175822.GB28891@bombadil.infradead.org>
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date: Fri, 19 Oct 2018 14:47:42 -0400
Message-ID: <CAN-5tyHvJQc+mPSvgX09F71otoZEoxRXdKLB=F=bGTzmEnt_eA@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To: willy@infradead.org
Cc: linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 1:58 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > +++ b/Documentation/filesystems/vfs.txt
> > @@ -958,7 +958,9 @@ otherwise noted.
> >
> >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> >
> > -  copy_file_range: called by the copy_file_range(2) system call.
> > +  copy_file_range: called by copy_file_range(2) system call. This method
> > +                works on two file descriptors that might reside on
> > +                different superblocks of the same type of file system.
>
> I don't think this text is explicit enough about what has changed,

Can you suggest a different wording that would be stronger? I can't
say any more clear that copy is allowed between different superblock
which wasn't the case before.

> and I
> think this is the wrong place for it.  I think there should be a paragraph
> in Documentation/filesystems/porting and it should follow the current style
> in there.

I have looked at the "porting" file and it's cryptic. I don't
understand what [mandatory] [recommended] stanzas are. There is
currently no copy_file_range. Is this just a "changelog" and you are
looking for something like
[mandatory]
copy_file_range() now allows copying between different superblocks.

I can add this wording to the "porting" file.

> > @@ -1591,7 +1587,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >        * Try cloning first, this is supported by more file systems, and
> >        * more efficient if both clone and copy are supported (e.g. NFS).
> >        */
> > -     if (file_in->f_op->clone_file_range) {
> > +     if (inode_in->i_sb == inode_out->i_sb &&
> > +                     file_in->f_op->clone_file_range) {
>
> This reads weirdly to me.  I know it's the same order the tests were done
> in before, but it would feel more natural to me to test:
>
>         if (file_in->f_op->clone_file_range &&
>                         inode_in->i_sb == inode_out->i_sb)
>
> Am I just suffering from "I would have done this differently"itis, or
> is it unnatural?

I really don't care one way or another as long as the functionality
goes in. I can change it.

> > @@ -1600,10 +1597,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >               }
> >       }
> >
> > -     if (file_out->f_op->copy_file_range) {
> > +     if (file_out->f_op->copy_file_range &&
> > +                     (file_in->f_op->copy_file_range ==
> > +                             file_out->f_op->copy_file_range)) {
>
> Can we avoid this extra test here?  I know the various stamdards groups
> including T10 and the IETF have been trying to define a universal
> identifier for the same blob of storage, no matter how it's accessed;
> potentially allowing access to the same storage across iSCSI, CIFS
> and NFS.  If we ever get to a point where we support that (and I am
> dubious), we'd want to remove this test again, and have to revalidate
> all the filesystems.

Well from previous submissions I was explicitly asked to add this check.
