Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753082AbdEQLbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 May 2017 07:31:39 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKcL7A=mLTeOe73jGbs7oK-5eneCNuCHNDY7OLy0_=KPUA@mail.gmail.com>
References: <CAOssrKcL7A=mLTeOe73jGbs7oK-5eneCNuCHNDY7OLy0_=KPUA@mail.gmail.com> <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk> <149486154888.23956.10260643844119198576.stgit@warthog.procyon.org.uk> <CAOssrKdf4aKRRMJWLERr8hE7kptighaqFtR0vWdoMkPraSsYpw@mail.gmail.com> <18741.1494952398@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/21] VFS: Introduce a superblock configuration context [ver #3]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 17 May 2017 12:31:35 +0100
Message-ID: <19461.1495020695@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> > (b) is internal-only at the moment, used by NFS submounts as triggered by
> > automounts.  There isn't currently any way to supply mount options to this.
> 
> And all blockdev based fs.

I see what you're getting at.  In which case there are more cases:

  (a) new mount, new sb struct with no source (eg. procfs, sysfs, tmpfs)
  (b) new mount, new sb struct, params loaded from filesystem data (eg. bdev)
  (c) new mount, new sb struct, params derived from parent (eg. NFS automount)
  (d) new mount, shared extant sb struct
  (e) remount

In the case of (d) where we're attempting to make another mount for an extant
super_block struct and we need to check the consistency of the parameters.

> > Ah - but some of these options have to be set *inside* sget() or before the
> > superblock becomes live, even the ones that can be changed in-flight.
> 
> That would be the "???" category.  Any concrete examples?

NFS is a good example.  You need parameters that indicate the server to talk
to and specify I/O parameters before you even get the superblock as you have
to talk to the server first.  I think this is particularly true of NFSv2/3
where you need to talk to mountd.

This would also be true of AFS.  There you have to access the network to look
up the volume ID before you can call sget() as the volume ID is part of the
index key to the set of super_block structs.

Further, some of these values (I/O parameters in NFS's case, for example) form
part of the super_block struct index key, so you have to set those inside
sget()'s set callback.

> >> Also I think silently ignoring options is not always the right answer.
> >
> > Example?
> 
> mount /dev/sda -oacl /mnt
> mount /dev/sda -onoacl /mnt2

So you'd like to give an error or a warning if ACLs are not supported, either
by the filesystem or the kernel as a whole?

> No really good match for what this method is doing.  We could call it
> ->get_tree_to_mount(), but calling it just ->mount() implies that it's
> doing the mounting, which it is not.

Yes, but my point is that it's part of the mount procedure.  We are, I assume,
intending to try and mount the thing at some point.  I can leave it as
->get_tree() for the moment.

> You are thinking on the wrong level.  Of course mount(2) needs to
> handle MS_NOSUID et al.  But it's doing it now, and it isn't parsing
> "nosuid", just translating MS_NOSUID to MNT_NOSUID.

Ummm...  That's done by the parser in this case, so effectively it is.

> For the fsopen() case you won't need to parse "nosuid" because that's a flag
> for fsmount().

Whilst this is true, that means that the parser has to operate differently in
the mount(2) and fsopen(2) cases - which I was trying to avoid.  I guess I can
set a flag in the sb_config struct to indicate the source and then split out
these options into an only-for-mount(2) list.

> The only thing fsmount() should take from the sc is the root_dentry.
> It should be equivalent to what currently is a bind mount, except it
> should be able to fully configure the new mount.

It needs to take the device name as well.  I wonder if it would be possible to
store the device name on the superblock and then leave a path-in-mount in the
vfsmount struct to fabricate a <source>:/<path> later.  Though this would
change the behaviour if someone did:

	mknod /dev/foo b 8 1
	mknod /dev/bar b 8 1
	mount /dev/foo /mnt/foo
	mount /dev/bar /mnt/bar

as /proc/mounts would now show /dev/foo for /mnt/bar.

Also, I guess the subtype should be wangled in the superblock-getting code
(vfs_get_tree() as of patch 21) rather than in do_new_mount_sc().  If I do
that, then it may be that do_new_mount_sc() only needs the root dentry pointer
and not the sb_config pointer (except for error string passing).

> I'm still hoping we can move subpath handling completely to fsmount()
> in which case it would just take a struct super_block.  But that would
> have to start with lots of filesystem work (not just NFS but CEPH,
> CIFS, etc..).

That would be nice, though NFSv2/3 might be tricky.

David
