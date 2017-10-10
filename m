Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751420AbdJJJvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Oct 2017 05:51:12 -0400
Date: Tue, 10 Oct 2017 11:51:07 +0200
From: Karel Zak <kzak@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 06/14] VFS: Implement fsmount() to effect a
 pre-configured mount [ver #6]
Message-ID: <20171010095107.5lzkjibyrxbwfpvp@ws.net.home>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730499269.6182.8121149524716523148.stgit@warthog.procyon.org.uk>
 <CAOssrKcAJTJv-VjaY+Dcn_zEJBoMVSPStK5H6inWyq2uiv0f-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOssrKcAJTJv-VjaY+Dcn_zEJBoMVSPStK5H6inWyq2uiv0f-A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 10, 2017 at 10:00:01AM +0200, Miklos Szeredi wrote:
> > +
> > +       if (flags & MS_RDONLY)
> > +               mnt_flags |= MNT_READONLY;
> > +       if (flags & MS_NOSUID)
> > +               mnt_flags |= MNT_NOSUID;
> > +       if (flags & MS_NODEV)
> > +               mnt_flags |= MNT_NODEV;
> > +       if (flags & MS_NOEXEC)
> > +               mnt_flags |= MNT_NOEXEC;
> > +       if (flags & MS_NODIRATIME)
> > +               mnt_flags |= MNT_NODIRATIME;
> > +
> > +       if (flags & MS_STRICTATIME) {
> > +               if (flags & MS_NOATIME)
> > +                       return -EINVAL;
> > +       } else if (flags & MS_NOATIME) {
> > +               mnt_flags |= MNT_NOATIME;
> > +       } else {
> > +               mnt_flags |= MNT_RELATIME;
> > +       }
> 
> I'm not sure reusing the MS_FLAGS is the right choice.  Why not export
> MNT_* to userspace?  That would get us a clean namespace without
> confusion with sb flags and no need to convert back and forth.

Well, if you think about it as about two separated things -- VFS-flags
and FS-flags (and for example /proc/#/mountinfo already uses two
columns for the flags) than the question is why the API uses one
variable?

Would be better to use two variables everywhere? (mostly for the
syscall). 

It would be nice to keep for example propagation flags only in
vfs_flags, or use MS_RDONLY according to context (for FS or for VFS)
without extra MS_BIND, etc.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
