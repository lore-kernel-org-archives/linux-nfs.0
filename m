Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60152 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdKIThW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 14:37:22 -0500
Date: Thu, 9 Nov 2017 19:37:15 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171109193715.GB21978@ZenIV.linux.org.uk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 08, 2017 at 06:40:22PM -0800, Linus Torvalds wrote:

> > Here is the BUG we are getting:
> >> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
> >> [   58.963918] IP: vfs_statfs+0x73/0xb0
> 
> The code disassembles to

>   2a:* 48 8b b7 30 02 00 00 mov    0x230(%rdi),%rsi <-- trapping instruction

> that matters (and that traps) but I'm almost certain that it's the
> "mnt->mnt_sb->s_flags" loading that is part of calculate_f_flags()
> when it then does
> 
>      flags_by_sb(mnt->mnt_sb->s_flags);
> 
> and I think mnt->mnt_sb is NULL. We know it's not 'mnt' itself that is
> NULL, because we wouldn't have gotten this far if it was.
> 
> Now, afaik, mnt->mnt_sb should never be NULL in the first place for a
> proper path. And the vfs_statfs() code itself hasn't changed in a
> while.
> 
> Which does seem to implicate nfsd as having passed in a bad path to
> vfs_statfs(). But I'm not seeing any changes in nfsd either.

It definitely is NULL mnt->mnt_sb and that should never happen.  All
struct mount instances are allocated by alloc_vfsmnt().  Its callers
are
	* vfs_kern_mount().  Assigns ->mnt_sb to root->d_sb before
anyone else sees the address of that object.
	* clone_mnt().  Assigns ->mnt_sb to that of preexisting instance
before anyone else sees the address of that object.

No other callers exist and no other places ever modify the value of that
field.

All instances of struct dentry are created by __d_alloc()[*], which assigns
->d_sb (never to be modified afterwards) *and* dereferences the pointer
it has stored in ->d_sb before the created struct dentry becomes visible
to anyone else.  No struct dentry should ever be observed with NULL ->d_sb;
the only way to get that is memory corruption or looking at freed instance
after its memory has been reused for something else and zeroed.

In other words, we should never observe a struct mount with NULL ->mnt.mnt_sb -
not without memory corruption or looking at freed instance.

The pointer in that case should've come from exp->ex_path.mnt, exp being
the argument of nfsd4_encode_fattr().  Sure, it might have been a dangling
reference.  However, it looks a lot more like a memory corruptor *OR*
miscompiled kernel.

What kind of load do the reproducer boxen have and how fast does that
bug trigger?  Would it be possible to slap something like
	if (unlikely(!exp->exp_path.mnt->mnt_sb)) {
		struct mount *m = real_mount(exp->exp_path.mnt);
		printk(KERN_ERR "mnt: %p\n", exp->exp_path.mnt);
		printk(KERN_ERR "name: [%s]\n", m->mnt_devname);
		printk(KERN_ERR "ns: [%p]\n", m->mnt_ns);
		printk(KERN_ERR "parent: [%p]\n", m->mnt_parent);
		WARN_ON(1);
		err = -EINVAL;
		goto out_nfserr;
	}
in the beginning of nfsd4_encode_fattr() (with include of ../mount.h added
in fs/nfsd/nfs4xdr.c) and see what will it catch?

Both with and without randomized structs, if possible - I might be barking
at the wrong tree, but IMO the very first step in localizing that crap is
to find out whether it's toolchain-related or not.

[*] strictly speaking, there is one exception - lib/test_printf.c has
four static struct dentry instances.  No chance of those being returned
by any ->mount() instance, though.

