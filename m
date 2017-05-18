Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37302 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754755AbdERIKC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2017 04:10:02 -0400
Received: by mail-wm0-f41.google.com with SMTP id d127so42889464wmf.0
        for <linux-nfs@vger.kernel.org>; Thu, 18 May 2017 01:10:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <19461.1495020695@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
 <149486154888.23956.10260643844119198576.stgit@warthog.procyon.org.uk>
 <CAOssrKdf4aKRRMJWLERr8hE7kptighaqFtR0vWdoMkPraSsYpw@mail.gmail.com>
 <18741.1494952398@warthog.procyon.org.uk> <CAOssrKcL7A=mLTeOe73jGbs7oK-5eneCNuCHNDY7OLy0_=KPUA@mail.gmail.com>
 <19461.1495020695@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Thu, 18 May 2017 10:09:59 +0200
Message-ID: <CAOssrKehzdSABr-K6Usb7AjxyJ-POtUbdRap0e8Jq78=o-cMLg@mail.gmail.com>
Subject: Re: [PATCH 06/21] VFS: Introduce a superblock configuration context
 [ver #3]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 17, 2017 at 1:31 PM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> > (b) is internal-only at the moment, used by NFS submounts as triggered by
>> > automounts.  There isn't currently any way to supply mount options to this.
>>
>> And all blockdev based fs.
>
> I see what you're getting at.  In which case there are more cases:
>
>   (a) new mount, new sb struct with no source (eg. procfs, sysfs, tmpfs)
>   (b) new mount, new sb struct, params loaded from filesystem data (eg. bdev)
>   (c) new mount, new sb struct, params derived from parent (eg. NFS automount)
>   (d) new mount, shared extant sb struct
>   (e) remount
>
> In the case of (d) where we're attempting to make another mount for an extant
> super_block struct and we need to check the consistency of the parameters.

Yes.  Current behavior seems to just ignore given options (except
MS_RDONLY) in that case, so we need to keep that possibility.

Also I think it would be good to allow selecting when superblock is created:

  - non-exclusive create: if exists return it, if not create it
  - exclusive create: only create if non-existent
  - non-create: only return if exists

>
>> > Ah - but some of these options have to be set *inside* sget() or before the
>> > superblock becomes live, even the ones that can be changed in-flight.
>>
>> That would be the "???" category.  Any concrete examples?
>
> NFS is a good example.  You need parameters that indicate the server to talk
> to and specify I/O parameters before you even get the superblock as you have
> to talk to the server first.  I think this is particularly true of NFSv2/3
> where you need to talk to mountd.
>
> This would also be true of AFS.  There you have to access the network to look
> up the volume ID before you can call sget() as the volume ID is part of the
> index key to the set of super_block structs.
>
> Further, some of these values (I/O parameters in NFS's case, for example) form
> part of the super_block struct index key, so you have to set those inside
> sget()'s set callback.

So what I propose is:

 1) call ->parse_option()

      would get indication what we are trying to do (find and/or
create and/or reconfig)

      this step is optional, the the filesystem type could possibly be
enough for the following steps

 2) call ->get_tree()

      pass sc containing parsed options and flags controlling the
creation of the superblock (create/exclusive)

      this step is optional, not called if we are given an sb to work
with (i.e. only reconfig)

 3) call ->reconfig()

      pass sc containing parsed options

      this step is optional, we might be instructed just to find or
create the sb

>
>> >> Also I think silently ignoring options is not always the right answer.
>> >
>> > Example?
>>
>> mount /dev/sda -oacl /mnt
>> mount /dev/sda -onoacl /mnt2
>
> So you'd like to give an error or a warning if ACLs are not supported, either
> by the filesystem or the kernel as a whole?

What I was getting at is that the second mount will ignore the "noacl"
option.  It's not something we apparently care much about (but will
definitely want to keep as back-compat thing for the mount(2)
interface).  But for the new interface I think we need something less
crazy.  One solution would be the exclusive create, which doesn't have
this problem. Maybe that's enough; not sure if we need anything more
sophisticated.

>> You are thinking on the wrong level.  Of course mount(2) needs to
>> handle MS_NOSUID et al.  But it's doing it now, and it isn't parsing
>> "nosuid", just translating MS_NOSUID to MNT_NOSUID.
>
> Ummm...  That's done by the parser in this case, so effectively it is.

Where exactly?  You are not touching do_mount(), which is where the
MS_*** -> MNT_*** translation is done.


>> For the fsopen() case you won't need to parse "nosuid" because that's a flag
>> for fsmount().
>
> Whilst this is true, that means that the parser has to operate differently in
> the mount(2) and fsopen(2) cases - which I was trying to avoid.

I don't get it.  We never passed MNT_* options as strings to the
kernel.  That was parsed by mount(8) and translated to MS_* flags.
So how would mount(2) and fsopen(2) need to operate differently
regarding parsing MNT_* options, when we want neither to do it?

>> The only thing fsmount() should take from the sc is the root_dentry.
>> It should be equivalent to what currently is a bind mount, except it
>> should be able to fully configure the new mount.
>
> It needs to take the device name as well.  I wonder if it would be possible to
> store the device name on the superblock and then leave a path-in-mount in the

Ah, mnt_devname.  The device name as just a special type of option and
as such should be stored in the superblock.

> vfsmount struct to fabricate a <source>:/<path> later.  Though this would
> change the behaviour if someone did:
>
>         mknod /dev/foo b 8 1
>         mknod /dev/bar b 8 1
>         mount /dev/foo /mnt/foo
>         mount /dev/bar /mnt/bar
>
> as /proc/mounts would now show /dev/foo for /mnt/bar.

I'd very much hope this doesn't introduce regressions, but if it did,
then we'd have to go back to using mnt_devname...

> Also, I guess the subtype should be wangled in the superblock-getting code
> (vfs_get_tree() as of patch 21) rather than in do_new_mount_sc().  If I do
> that, then it may be that do_new_mount_sc() only needs the root dentry pointer
> and not the sb_config pointer (except for error string passing).

Would be nice.

And hopefully error string passing can be made generic and be moved
out of this set.

Thanks,
Miklos
