Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751061AbdE3PgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 11:36:17 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170530145043.GG6365@ZenIV.linux.org.uk>
References: <20170530145043.GG6365@ZenIV.linux.org.uk> <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: dhowells@redhat.com, mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 00/23] VFS: Introduce superblock configuration context [ver #4]
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Tue, 30 May 2017 16:36:14 +0100
Message-ID: <15403.1496158574@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> wrote:

> Random notes:
> 	* "sb_config" looks rather odd in the current variant; mount_context,
> perhaps?  Or fs_context, for that matter...  Anyway, that's trivial.

You can argue that one with Miklós.  He argued against mount_context as I had
it originally.  His point is that the same struct may be used when
reconfiguring an sb - which isn't exactly a mount operation (even though we do
it that day today with remount).

> 	* if NFS folks want to play with EXPORT_SYMBOL_GPL, fine, but any
> EXPORT_SYMBOL_GPL in vfs proper is a mistake.  If it's an interface that
> makes sense, just export it; if it's a vewwwy, vewwwy pwiwate interface
> for some specific module - let's figure out how to deal with that layering
> violation rather than exporting it at all.

I agree, but apparently not everyone does.  There are _GPL symbols in the core
VFS that I need to replace.

> 	* what the hell is ms_flags thing doing in __vfs_new_sb_config()?
> It's a really vile mix of unrelated flags and operations we had in existing
> mount(2) ABI.  With MS_KERNMOUNT thrown into that loo^Wmix.  Sure, we need
> to parse the garbage fed to mount(2).  And we need to pass that garbage to
> "legacy" types as well, but let's not inflict it upon the new mechanisms.

I know, but we might get it from mount(2).  I can tamp down the flag mask and
translate it from MS_*, but the MS_* flags are also stored in the superblock
(->s_flags).

I've removed the MNT_* flags from there already.

> 	* what's wrong with simple_pin_fs() as it is?  You keep
> vfs_kern_mount() anyway, so...

I would like to replace vfs_kern_mount() and vfs_submount(), with the _sc
versions but the users would need converting first.  It might make sense to
retain an __init variant of the former though.

> 	* vfs_new_sb_config(): please, move dealing with name into the caller.
> Then you would be able to use it more than once.

Technically, it's used twice, but okay.  I guess I should just rename
__vfs_new_sb_config() to vfs_new_sb_config() and add the extra parameters to
the caller.

> 	* submount side of that thing: do we ever want a type different from
> that of src_sb,

Hmmm...  Good question.  For the moment I've assumed not.  I've killed off the
NFS special types since I can now carry the information in the sb_config
struct that they previously conveyed.

> and how the fuck would methods know what to do with it?

Until I have an example, it's hard to say.
 
> 	* remounts: where (if anywhere) do you call ->validate() for those,

It got moved out of the path that revalidate was invoking.  I need to put it
back.

However, it may be worth leaving this to the filesystem to invoke during
->get_tree() and ->remount_fs() as it then has access to the on-disk fs
metadata if a blockdev is being used, against which it may need to do
validation.

The biggest advantage of having a separate call is that the argument
combination can be validated before taking any locks, opening a blockdev or
sending packets on the network.

> and if you do not, WTF is this
> +       if (cfg->sc.purpose == SB_CONFIG_FOR_REMOUNT)
> +               return 0;
> for?  You know, the only place that ever looks at ->purpose...

That being the only place is true at the moment, but may not remain so as more
filesystems are converted.

> 	* docs need to be brought in sync with code - 'purpose' is called 'mount_type'
> in those, which is especially unpleasant since you do introduce a field called just
> that - NFS-only and in NFS-private part.

Yep.

> 	* you don't need to register filesystem to use kern_mount()

Hmmm...  I'm not sure whether that's actually a problem.

> 	* locking inode in fsmount(2).  What for?

Yeah, I can get rid of that.  The superblock-getting bit used to be done after
this point, so the lock was necessary to prevent a race.

> 	* ->sb_mountpoint().  YALinuxSadoMasochismHook.  Not called on normal
> mount(2) pathway.  Yuck...

That replaces security_sb_kern_mount().  That should move into
do_new_mount_sc().

> 	* could you split whitespace parts off?  Minor, but...

You mean patch 2?  You could just take that one patch and apply it/pass it to
Linus, then I could rebase.

> 	* I'd like to see ipc/mqueue.c dealt with as well; feels like procfs
> counterpart might have too much open-coded.  This would show what might be
> folded into saner helpers...

Okay.  Any other file system types you'd like to see done immediately?
cpuset, maybe?

I still have to finish the ext4 conversion too.

David
