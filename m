Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38368 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755383AbdKJBrg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 20:47:36 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
From: Patrick McLean <chutzpah@gentoo.org>
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
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
Message-ID: <7b6c04d9-5358-9394-ddb4-cc3a3d8b2080@gentoo.org>
Date: Thu, 9 Nov 2017 17:47:33 -0800
MIME-Version: 1.0
In-Reply-To: <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2017-11-09 11:51 AM, Patrick McLean wrote:
> On 2017-11-09 11:37 AM, Al Viro wrote:
>> On Wed, Nov 08, 2017 at 06:40:22PM -0800, Linus Torvalds wrote:
>>
>>>> Here is the BUG we are getting:
>>>>> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
>>>>> [   58.963918] IP: vfs_statfs+0x73/0xb0
>>>
>>> The code disassembles to
>>
>>>   2a:* 48 8b b7 30 02 00 00 mov    0x230(%rdi),%rsi <-- trapping instruction
>>
>>> that matters (and that traps) but I'm almost certain that it's the
>>> "mnt->mnt_sb->s_flags" loading that is part of calculate_f_flags()
>>> when it then does
>>>
>>>      flags_by_sb(mnt->mnt_sb->s_flags);
>>>
>>> and I think mnt->mnt_sb is NULL. We know it's not 'mnt' itself that is
>>> NULL, because we wouldn't have gotten this far if it was.
>>>
>>
>> All instances of struct dentry are created by __d_alloc()[*], which assigns
>> ->d_sb (never to be modified afterwards) *and* dereferences the pointer
>> it has stored in ->d_sb before the created struct dentry becomes visible
>> to anyone else.  No struct dentry should ever be observed with NULL ->d_sb;
>> the only way to get that is memory corruption or looking at freed instance
>> after its memory has been reused for something else and zeroed.
>>
>> In other words, we should never observe a struct mount with NULL ->mnt.mnt_sb -
>> not without memory corruption or looking at freed instance.
>>
>> The pointer in that case should've come from exp->ex_path.mnt, exp being
>> the argument of nfsd4_encode_fattr().  Sure, it might have been a dangling
>> reference.  However, it looks a lot more like a memory corruptor *OR*
>> miscompiled kernel.
>>
>> What kind of load do the reproducer boxen have and how fast does that
>> bug trigger?  Would it be possible to slap something like
>> 	if (unlikely(!exp->exp_path.mnt->mnt_sb)) {
>> 		struct mount *m = real_mount(exp->exp_path.mnt);
>> 		printk(KERN_ERR "mnt: %p\n", exp->exp_path.mnt);
>> 		printk(KERN_ERR "name: [%s]\n", m->mnt_devname);
>> 		printk(KERN_ERR "ns: [%p]\n", m->mnt_ns);
>> 		printk(KERN_ERR "parent: [%p]\n", m->mnt_parent);
>> 		WARN_ON(1);
>> 		err = -EINVAL;
>> 		goto out_nfserr;
>> 	}
>> in the beginning of nfsd4_encode_fattr() (with include of ../mount.h added
>> in fs/nfsd/nfs4xdr.c) and see what will it catch?
>>
>> Both with and without randomized structs, if possible - I might be barking
>> at the wrong tree, but IMO the very first step in localizing that crap is
>> to find out whether it's toolchain-related or not.
> 

That condition did not seem to trigger, and I am getting a slightly
different crash message (GPF rather than null pointer dereference). Here
is the dump from the latest crash (with CONFIG_GCC_PLUGIN_STRUCTLEAK,
CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL and CONFIG_GCC_PLUGIN_RANDSTRUCT
all enabled).

> [   36.834232] general protection fault: 0000 [#1] SMP
> [   36.835168] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_multiport xt_addrtype iptable_mangle iptable_raw iptable_nat nf_nat_ipv4 nf_nat gkuart(O) usbserial x86_pkg_temp_thermal ie31200_edac tpm_tis ipmi_ssif tpm_tis_core ext4 mbcache jbd2 e1000e crc32c_intel
> [   36.839120] CPU: 1 PID: 3969 Comm: nfsd Tainted: G           O    4.14.0-rc8-git-kratos-1-00053-gd93d4ce103fd-dirty #1
> [   36.840883] Hardware name: TYAN S5510/S5510, BIOS V2.02 03/12/2013
> [   36.841892] task: ffff88040a0b1c80 task.stack: ffffc900027bc000
> [   36.842887] RIP: 0010:vfs_statfs+0x73/0xb0
> [   36.843728] RSP: 0018:ffffc900027bfb30 EFLAGS: 00010202
> [   36.844687] RAX: 0000000000000000 RBX: ffffc900027bfbf8 RCX: 000000000000180d
> [   36.845891] RDX: 000000000000080d RSI: 0000000000000020 RDI: e2006d6574737973
> [   36.847075] RBP: ffffc900027bfbc8 R08: 0000000000000000 R09: 00000000000000ff
> [   36.848175] R10: 000000000038be3a R11: ffff88040b687578 R12: 0000000000000000
> [   36.849260] R13: ffff88040d7dc400 R14: ffff88040d38b000 R15: ffffc900027bfbf8
> [   36.850347] FS:  0000000000000000(0000) GS:ffff88041fc40000(0000) knlGS:0000000000000000
> [   36.851891] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   36.852873] CR2: 00007f049228edc0 CR3: 0000000001e0a004 CR4: 00000000001606e0
> [   36.853942] Call Trace:
> [   36.854667]  nfsd4_encode_fattr+0x34e/0x23b0
> [   36.855578]  ? ext4_get_acl+0x1b2/0x260 [ext4]
> [   36.856485]  ? get_acl+0x7a/0xf0
> [   36.857266]  ? generic_permission+0x125/0x1a0
> [   36.858150]  nfsd4_encode_getattr+0x25/0x30
> [   36.859002]  nfsd4_encode_operation+0x98/0x1a0
> [   36.859889]  nfsd4_proc_compound+0x3eb/0x5c0
> [   36.860736]  nfsd_dispatch+0xa8/0x230
> [   36.861538]  svc_process_common+0x347/0x640
> [   36.862383]  svc_process+0x100/0x1b0
> [   36.863204]  nfsd+0xe0/0x150
> [   36.863984]  kthread+0xfc/0x130
> [   36.864781]  ? nfsd_destroy+0x50/0x50
> [   36.865624]  ? kthread_create_on_node+0x40/0x40
> [   36.866529]  ? do_group_exit+0x3a/0xb0
> [   36.867362]  ret_from_fork+0x25/0x30
> [   36.868188] Code: d1 83 c9 08 40 f6 c6 04 0f 45 d1 89 d1 80 cd 04 40 f6 c6 08 0f 45 d1 89 d1 80 cd 08 40 f6 c6 10 0f 45 d1 89 d1 80 cd 10 83 e6 20 <48> 8b b7 b0 05 00 00 0f 45 d1 83 ca 20 89 f1 83 e1 10 89 cf 83
> [   36.871101] RIP: vfs_statfs+0x73/0xb0 RSP: ffffc900027bfb30
> [   36.872059] ---[ end trace 603ac898c4e2d616 ]---

I haven't been able to reproduce it with CONFIG_GCC_PLUGIN_RANDSTRUCT
disabled, so it seems like it must be a bug there. It's odd that it just
surfaced recently though, we have been using that since it was added.

> The reproducer boxen are not under particularly heavy load, they are
> serving NFS to 1 or 2 clients (which are essentially embedded devices).
> When the bug triggers, it usually triggers pretty fast and reliably, but
> it seems to only trigger on some subset of bootups. Once it fails to
> trigger, we seem to have to reboot to get it to trigger.
> 
> I should be able to have some results with that added in a few hours.
> It's weirdly unreliable to reproduce this.
> 
> We do have CONFIG_GCC_PLUGIN_STRUCTLEAK and
> CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL enabled on these boxes as well as
> CONFIG_GCC_PLUGIN_RANDSTRUCT as you pointed out before.
> 
