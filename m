Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:36460 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751225AbdKITvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 14:51:24 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk>
From: Patrick McLean <chutzpah@gentoo.org>
Message-ID: <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
Date: Thu, 9 Nov 2017 11:51:22 -0800
MIME-Version: 1.0
In-Reply-To: <20171109193715.GB21978@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-09 11:37 AM, Al Viro wrote:
> On Wed, Nov 08, 2017 at 06:40:22PM -0800, Linus Torvalds wrote:
> 
>>> Here is the BUG we are getting:
>>>> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
>>>> [   58.963918] IP: vfs_statfs+0x73/0xb0
>>
>> The code disassembles to
> 
>>   2a:* 48 8b b7 30 02 00 00 mov    0x230(%rdi),%rsi <-- trapping instruction
> 
>> that matters (and that traps) but I'm almost certain that it's the
>> "mnt->mnt_sb->s_flags" loading that is part of calculate_f_flags()
>> when it then does
>>
>>      flags_by_sb(mnt->mnt_sb->s_flags);
>>
>> and I think mnt->mnt_sb is NULL. We know it's not 'mnt' itself that is
>> NULL, because we wouldn't have gotten this far if it was.
>>
> 
> All instances of struct dentry are created by __d_alloc()[*], which assigns
> ->d_sb (never to be modified afterwards) *and* dereferences the pointer
> it has stored in ->d_sb before the created struct dentry becomes visible
> to anyone else.  No struct dentry should ever be observed with NULL ->d_sb;
> the only way to get that is memory corruption or looking at freed instance
> after its memory has been reused for something else and zeroed.
> 
> In other words, we should never observe a struct mount with NULL ->mnt.mnt_sb -
> not without memory corruption or looking at freed instance.
> 
> The pointer in that case should've come from exp->ex_path.mnt, exp being
> the argument of nfsd4_encode_fattr().  Sure, it might have been a dangling
> reference.  However, it looks a lot more like a memory corruptor *OR*
> miscompiled kernel.
> 
> What kind of load do the reproducer boxen have and how fast does that
> bug trigger?  Would it be possible to slap something like
> 	if (unlikely(!exp->exp_path.mnt->mnt_sb)) {
> 		struct mount *m = real_mount(exp->exp_path.mnt);
> 		printk(KERN_ERR "mnt: %p\n", exp->exp_path.mnt);
> 		printk(KERN_ERR "name: [%s]\n", m->mnt_devname);
> 		printk(KERN_ERR "ns: [%p]\n", m->mnt_ns);
> 		printk(KERN_ERR "parent: [%p]\n", m->mnt_parent);
> 		WARN_ON(1);
> 		err = -EINVAL;
> 		goto out_nfserr;
> 	}
> in the beginning of nfsd4_encode_fattr() (with include of ../mount.h added
> in fs/nfsd/nfs4xdr.c) and see what will it catch?
> 
> Both with and without randomized structs, if possible - I might be barking
> at the wrong tree, but IMO the very first step in localizing that crap is
> to find out whether it's toolchain-related or not.

The reproducer boxen are not under particularly heavy load, they are
serving NFS to 1 or 2 clients (which are essentially embedded devices).
When the bug triggers, it usually triggers pretty fast and reliably, but
it seems to only trigger on some subset of bootups. Once it fails to
trigger, we seem to have to reboot to get it to trigger.

I should be able to have some results with that added in a few hours.
It's weirdly unreliable to reproduce this.

We do have CONFIG_GCC_PLUGIN_STRUCTLEAK and
CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL enabled on these boxes as well as
CONFIG_GCC_PLUGIN_RANDSTRUCT as you pointed out before.
