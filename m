Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34416 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750985AbdE3QC1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 12:02:27 -0400
Date: Tue, 30 May 2017 15:50:43 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 00/23] VFS: Introduce superblock configuration
 context [ver #4]
Message-ID: <20170530145043.GG6365@ZenIV.linux.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 22, 2017 at 04:50:56PM +0100, David Howells wrote:
> 
> Here are a set of patches to create a superblock configuration context
> prior to setting up a new mount, populating it with the parsed
> options/binary data, creating the superblock and then effecting the mount.
> 
> This allows namespaces and other information to be conveyed through the
> mount procedure.  It also allows extra error information to be returned
> (so many things can go wrong during a mount that a small integer isn't
> really sufficient to convey the issue).
> 
> This also allows Miklós Szeredi's idea of doing:
> 
> 	fd = fsopen("nfs");
> 	write(fd, "option=val", ...);
> 	fsmount(fd, "/mnt");
> 
> that he presented at LSF-2017 to be implemented (see the relevant patches
> in the series), to which I can add:
> 
> 	read(fd, error_buffer, ...);
> 
> to read back any error message.  I didn't use netlink as that would make it
> depend on CONFIG_NET and would introduce network namespacing issues.

Random notes:
	* "sb_config" looks rather odd in the current variant; mount_context,
perhaps?  Or fs_context, for that matter...  Anyway, that's trivial.
	* if NFS folks want to play with EXPORT_SYMBOL_GPL, fine, but any
EXPORT_SYMBOL_GPL in vfs proper is a mistake.  If it's an interface that
makes sense, just export it; if it's a vewwwy, vewwwy pwiwate interface
for some specific module - let's figure out how to deal with that layering
violation rather than exporting it at all.
	* what the hell is ms_flags thing doing in __vfs_new_sb_config()?
It's a really vile mix of unrelated flags and operations we had in existing
mount(2) ABI.  With MS_KERNMOUNT thrown into that loo^Wmix.  Sure, we need
to parse the garbage fed to mount(2).  And we need to pass that garbage to
"legacy" types as well, but let's not inflict it upon the new mechanisms.
	* what's wrong with simple_pin_fs() as it is?  You keep
vfs_kern_mount() anyway, so...
	* vfs_new_sb_config(): please, move dealing with name into the caller.
Then you would be able to use it more than once.
	* submount side of that thing: do we ever want a type different from
that of src_sb, and how the fuck would methods know what to do with it?
	* remounts: where (if anywhere) do you call ->validate() for those,
and if you do not, WTF is this
+       if (cfg->sc.purpose == SB_CONFIG_FOR_REMOUNT)
+               return 0;
for?  You know, the only place that ever looks at ->purpose...
	* docs need to be brought in sync with code - 'purpose' is called 'mount_type'
in those, which is especially unpleasant since you do introduce a field called just
that - NFS-only and in NFS-private part.
	* you don't need to register filesystem to use kern_mount()
	* locking inode in fsmount(2).  What for?
	* ->sb_mountpoint().  YALinuxSadoMasochismHook.  Not called on normal
mount(2) pathway.  Yuck...
	* could you split whitespace parts off?  Minor, but...
	* I'd like to see ipc/mqueue.c dealt with as well; feels like procfs
counterpart might have too much open-coded.  This would show what might be
folded into saner helpers...
