Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40218 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751118AbdEJMlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 08:41:36 -0400
Date: Wed, 10 May 2017 14:41:28 +0200
From: Karel Zak <kzak@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
Message-ID: <20170510124128.jpjhbn5oxqtczquh@ws.net.home>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk>
 <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 10:03:43AM +0200, Miklos Szeredi wrote:
> On Tue, May 9, 2017 at 12:57 AM, David Howells <dhowells@redhat.com> wrote:
> > Miklos Szeredi <mszeredi@redhat.com> wrote:
> >
> >> > + (3) Validate and pre-process the mount context.
> >>
> >> (3.5) Create super block
> >>
> >> I think this need to be triggered by something like a "commit" command
> >> from userspace.  Basically this is where the options are atomically
> >> set on the new (create) or existing (reconfigure) superblock.
> >
> > Why do you need to expose this step to userspace?  Assuming in the "new" case
> > you do, say:
> >
> >         fd = fsopen("nfs");
> >         write(fd, "s foo.bar:/bar", ...);
> >         write(fd, "o intr", ...);
> >         write(fd, "o fsc", ...);
> >         ...
> >         write(fd, "c", ...); /* commit operation to get a superblock */
> >         fsmount(fd, AT_FDCWD, "/mnt");  /* mount the superblock we just got */
> >
> > Then the "commit" op is dissimilar to "mount -o remount" since remount may
> > alter the superblock parameters *and* the mountpoint parameters, but commit
> > can only affect the superblock.
> 
> Forget remount, it's a historical remnant.  We need fsreconfig(sb) and
> setmntattr(mnt).  They are changing properties of different objects.

I agree and I'd like to highlight another issue we have with the
current mount(2). The problem is non-atomic work with more
propagation flags if you want to mount a filesystem. For example:

  mount /dev/sda1 /A -o private,unbindable,ro

this is supported by mount(8), but it's implemented by three
independent mount(2) calls

    - 1st mounts /dev/sda1 with MS_RDONLY
    - 2nd sets MS_PRIVATE flag
    - 3rd sets MS_UNBINDABLE flag.

it would be nice set all the VFS flags and then as atomic operation attach
the context to the tree.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
