Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756707AbdJKIyT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Oct 2017 04:54:19 -0400
Date: Wed, 11 Oct 2017 10:54:13 +0200
From: Karel Zak <kzak@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 06/14] VFS: Implement fsmount() to effect a
 pre-configured mount [ver #6]
Message-ID: <20171011085413.gexlklmojlve5imd@ws.net.home>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730499269.6182.8121149524716523148.stgit@warthog.procyon.org.uk>
 <CAOssrKcAJTJv-VjaY+Dcn_zEJBoMVSPStK5H6inWyq2uiv0f-A@mail.gmail.com>
 <20171010095107.5lzkjibyrxbwfpvp@ws.net.home>
 <CAOssrKeGsgEqW+XCf_UAkH5XamWqo5a549wFHyHSC1OUzVvJag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOssrKeGsgEqW+XCf_UAkH5XamWqo5a549wFHyHSC1OUzVvJag@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 10, 2017 at 03:38:21PM +0200, Miklos Szeredi wrote:
> On Tue, Oct 10, 2017 at 11:51 AM, Karel Zak <kzak@redhat.com> wrote:
> > On Tue, Oct 10, 2017 at 10:00:01AM +0200, Miklos Szeredi wrote:
> >> > +
> >> > +       if (flags & MS_RDONLY)
> >> > +               mnt_flags |= MNT_READONLY;
> >> > +       if (flags & MS_NOSUID)
> >> > +               mnt_flags |= MNT_NOSUID;
> >> > +       if (flags & MS_NODEV)
> >> > +               mnt_flags |= MNT_NODEV;
> >> > +       if (flags & MS_NOEXEC)
> >> > +               mnt_flags |= MNT_NOEXEC;
> >> > +       if (flags & MS_NODIRATIME)
> >> > +               mnt_flags |= MNT_NODIRATIME;
> >> > +
> >> > +       if (flags & MS_STRICTATIME) {
> >> > +               if (flags & MS_NOATIME)
> >> > +                       return -EINVAL;
> >> > +       } else if (flags & MS_NOATIME) {
> >> > +               mnt_flags |= MNT_NOATIME;
> >> > +       } else {
> >> > +               mnt_flags |= MNT_RELATIME;
> >> > +       }
> >>
> >> I'm not sure reusing the MS_FLAGS is the right choice.  Why not export
> >> MNT_* to userspace?  That would get us a clean namespace without
> >> confusion with sb flags and no need to convert back and forth.
> >
> > Well, if you think about it as about two separated things -- VFS-flags
> > and FS-flags (and for example /proc/#/mountinfo already uses two
> > columns for the flags) than the question is why the API uses one
> > variable?
> >
> > Would be better to use two variables everywhere? (mostly for the
> > syscall).
> >
> > It would be nice to keep for example propagation flags only in
> > vfs_flags, or use MS_RDONLY according to context (for FS or for VFS)
> > without extra MS_BIND, etc.
> 
> MS_BIND will be gone in the new API.   The two separate columns in
> /proc/#/mountinfo are going to be two separate things on the new
> interface (one is writes to the fsfd provided by fsopen(2), the other
> in flags for fsmount(2)).

Ah, nice. 

> The question is how to call the mount flags
> (what you call vfs flags), "MS_RDONLY" or "MNT_RDONLY" on the uAPI.
> Either is probably fine, but I feel that "MNT_FOO" is better, because
> it's a relatively clean namespace concerned with mount flags and not
> polluted with all the scum that mount(2) collected.

Hmm.. for example libmount already uses MNT_ namespace in header
files for all macros. So, I wont be happy with MNT_ in userspace ;-(

I like clone, epoll, etc flags ... there is no any abbreviation and
the prefix follows syscall or API name (CLONE_xxx, EPOLLxxx), what
about MOUNT_FOO ?

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
