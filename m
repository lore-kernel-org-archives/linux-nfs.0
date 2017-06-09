Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57062 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751535AbdFIHsx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 03:48:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170530145043.GG6365@ZenIV.linux.org.uk>
References: <20170530145043.GG6365@ZenIV.linux.org.uk> <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: dhowells@redhat.com, mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Some filesystems set MNT_* flags in superblock->s_flags
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 09 Jun 2017 08:48:50 +0100
Message-ID: <19326.1496994530@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> wrote:

> 	* what the hell is ms_flags thing doing in __vfs_new_sb_config()?
> It's a really vile mix of unrelated flags and operations we had in existing
> mount(2) ABI.  With MS_KERNMOUNT thrown into that loo^Wmix.  Sure, we need
> to parse the garbage fed to mount(2).  And we need to pass that garbage to
> "legacy" types as well, but let's not inflict it upon the new mechanisms.

Hmmm...  Some ->remount_fs() operations attempt to alter the MS_* flags that
correspond to MNT_* flags.  Coda, for example:

	static int coda_remount(struct super_block *sb, int *flags, char *data)
	{
		sync_filesystem(sb);
		*flags |= MS_NOATIME;
		return 0;
	}

But this is quashed in do_remount_sb:

	sb->s_flags = (sb->s_flags & ~MS_RMT_MASK) | (flags & MS_RMT_MASK);

And others set them directly in s_flags, v9fs_fill_super() for example sets
MS_NOATIME:

	sb->s_flags |= MS_ACTIVE | MS_DIRSYNC | MS_NOATIME;

I'm guessing things like this should be got rid of, but does there need to be
a way to inform mount() that these should be set on the vfsmount?

David
