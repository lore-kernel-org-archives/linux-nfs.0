Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751481AbdESOF4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 May 2017 10:05:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKehzdSABr-K6Usb7AjxyJ-POtUbdRap0e8Jq78=o-cMLg@mail.gmail.com>
References: <CAOssrKehzdSABr-K6Usb7AjxyJ-POtUbdRap0e8Jq78=o-cMLg@mail.gmail.com> <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk> <149486154888.23956.10260643844119198576.stgit@warthog.procyon.org.uk> <CAOssrKdf4aKRRMJWLERr8hE7kptighaqFtR0vWdoMkPraSsYpw@mail.gmail.com> <18741.1494952398@warthog.procyon.org.uk> <CAOssrKcL7A=mLTeOe73jGbs7oK-5eneCNuCHNDY7OLy0_=KPUA@mail.gmail.com> <19461.1495020695@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/21] VFS: Introduce a superblock configuration context [ver #3]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 19 May 2017 15:05:52 +0100
Message-ID: <23332.1495202752@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> Yes.  Current behavior seems to just ignore given options (except
> MS_RDONLY) in that case, so we need to keep that possibility.

Yeah.  I wonder if we really should be consistency checking some parameters in
some filesystems - or, at least, offering the opportunity.

> Also I think it would be good to allow selecting when superblock is created:
> 
>   - non-exclusive create: if exists return it, if not create it
>   - exclusive create: only create if non-existent
>   - non-create: only return if exists

I quite like that idea.  Use O_CREAT and O_EXCL?  Probably better to define a
new flag space for fsopen() rather than trying to share with open().  I'm not
sure how likely it would be to be used, though.

> So what I propose is:
> 
>  1) call ->parse_option()
> 
>       would get indication what we are trying to do (find and/or
> create and/or reconfig)
> 
>       this step is optional, the the filesystem type could possibly be
> enough for the following steps
> 
>  2) call ->get_tree()
> 
>       pass sc containing parsed options and flags controlling the
> creation of the superblock (create/exclusive)
> 
>       this step is optional, not called if we are given an sb to work
> with (i.e. only reconfig)

No.  We have to call this to get the root dentry.  Whether or not it creates a
superblock - or even if it creates a superblock in someone else's filesystem
(the cpuset fs, for example) - is immaterial.

Further, we aren't given information as to whether the superblock was created
for us or not - though that can be changed.

Even further, I think by the time this returns, the superblock should be
live.  It will be live if we're reusing it, though we can get s_umount to
prevent a race.

>  3) call ->reconfig()
> 
>       pass sc containing parsed options
> 
>       this step is optional, we might be instructed just to find or
> create the sb

Actually, it's arguable that we *shouldn't* be calling this if the superblock
already exists - otherwise we may end up changing the parameters someone else
has set.

For mount(2), for most filesystems, we have to leave the active parameters
unaltered for compatibility.  For fsopen() I'm willing to add a consistency
check - but there probably has to be a flag to waive that as otherwise you
can't mount without determining what the other party's parameters were.

> I don't get it.  We never passed MNT_* options as strings to the
> kernel.

You're right.  I've moved all those flags over to the forbidden list.

> Ah, mnt_devname.  The device name as just a special type of option and
> as such should be stored in the superblock.

I'll leave that for now and deal with it later.  We have to be careful not to
break userspace by changing what's seen in /proc/mounts.

David
