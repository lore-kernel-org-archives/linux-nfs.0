Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:33748 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932166AbcFBXDj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 19:03:39 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=us-ascii
Subject: NFS/d_splice_alias breakage
Date: Thu, 2 Jun 2016 18:46:08 -0400
Message-Id: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   I just came across a bug (trying to run some Lustre test scripts against NFS, while hunting for another nfsd bug)
   that seems to be present since at least 2014 that lets users crash nfs client locally.

   Here's some interesting comment quote first from d_obtain_alias:

>  * Cluster filesystems may call this function with a negative, hashed dentry.
>  * In that case, we know that the inode will be a regular file, and also this
>  * will only occur during atomic_open. So we need to check for the dentry
>  * being already hashed only in the final case.
>  */
> struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
> {
>         if (IS_ERR(inode))
>                 return ERR_CAST(inode);
> 
>         BUG_ON(!d_unhashed(dentry));
        ^^^^^^^^^^^^^^ - This does not align well with the quote above.

It got imported here by commit b5ae6b15bd73e35b129408755a0804287a87e041

Removing the BUG_ON headon is not going to work since the d_rehash of old
is now folded into __d_add and we might not want to move that condition there.

doing an
if (d_unhashed(dentry))
   __d_add(dentry, inode);
else
   d_instantiate(dentry, inode);

also does not look super pretty and who knows how all of the previous code
like _d_find_any_alias would react.

Al, I think you might want to chime in here on how to better handle this?

The problem was there at least since 3.10 it appears where the fs/nfs/dir.c code
was calling d_materialise_unique() that did require the dentry to be unhashed.

Not sure how this was not hit earlier. The crash looks like this (I added
a printk to ensure this is what is going on indeed and not some other weird race):

[   64.489326] Calling into d_splice_alias with hashed dentry, dentry->d_inode (null) inode ffff88010f500c70
[   64.489549] ------------[ cut here ]------------
[   64.489642] kernel BUG at /home/green/bk/linux/fs/dcache.c:2989!
[   64.489750] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   64.489853] Modules linked in: loop rpcsec_gss_krb5 joydev pcspkr acpi_cpufreq i2c_piix4 tpm_tis tpm nfsd drm_kms_helper ttm drm serio_raw virtio_blk
[   64.491111] CPU: 6 PID: 7125 Comm: file_concat.sh Not tainted 4.7.0-rc1-vm-nfs+ #99
[   64.492069] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   64.492489] task: ffff880110a801c0 ti: ffff8800c283c000 task.ti: ffff8800c283c000
[   64.493159] RIP: 0010:[<ffffffff8124292f>]  [<ffffffff8124292f>] d_splice_alias+0x31f/0x480
[   64.493866] RSP: 0018:ffff8800c283fb20  EFLAGS: 00010282
[   64.494238] RAX: 0000000000000067 RBX: ffff88010f500c70 RCX: 0000000000000000
[   64.494625] RDX: 0000000000000067 RSI: ffff8800d08d2ed0 RDI: ffff88010f500c70
[   64.495021] RBP: ffff8800c283fb78 R08: 0000000000000001 R09: 0000000000000000
[   64.495407] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8800d08d2ed0
[   64.495804] R13: 0000000000000000 R14: ffff8800d4a56f00 R15: ffff8800d0bb8c70
[   64.496199] FS:  00007f94ae25c700(0000) GS:ffff88011f580000(0000) knlGS:0000000000000000
[   64.496859] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   64.497235] CR2: 000055e5d3fb46a4 CR3: 00000000ce364000 CR4: 00000000000006e0
[   64.497626] Stack:
[   64.497961]  ffffffff8132154e ffff8800c283fb68 ffffffff81325916 0000000000000000
[   64.498765]  0000000000000000 ffff8801109459c0 0000000000000000 ffff8800d0bb8c70
[   64.499578]  ffff8800c283fba0 ffff8800d08d2ed0 ffff8800cb927080 ffff8800c283fc18
[   64.500385] Call Trace:
[   64.500727]  [<ffffffff8132154e>] ? nfs_lookup+0x17e/0x320
[   64.501103]  [<ffffffff81325916>] ? __put_nfs_open_context+0xc6/0xf0
[   64.501477]  [<ffffffff8132252b>] nfs_atomic_open+0x8b/0x430
[   64.501850]  [<ffffffff81236def>] lookup_open+0x29f/0x7a0
[   64.502222]  [<ffffffff812377ce>] path_openat+0x4de/0xfc0
[   64.502591]  [<ffffffff8123935e>] do_filp_open+0x7e/0xe0
[   64.502964]  [<ffffffff8124877c>] ? __alloc_fd+0xbc/0x170
[   64.503347]  [<ffffffff817f4977>] ? _raw_spin_unlock+0x27/0x40
[   64.503719]  [<ffffffff8124877c>] ? __alloc_fd+0xbc/0x170
[   64.504097]  [<ffffffff81226896>] do_sys_open+0x116/0x1f0
[   64.504465]  [<ffffffff8122698e>] SyS_open+0x1e/0x20
[   64.504831]  [<ffffffff817f5176>] entry_SYSCALL_64_fastpath+0x1e/0xad
[   64.505218] Code: 01 e8 46 20 5b 00 85 db 74 0b 4c 89 ff 4c 63 fb e8 87 d8 ff ff 4c 89 e7 e8 2f 3c 00 00 4c 89 f8 e9 5e fe ff ff 0f 0b 48 89 f8 c3 <0f> 0b 48 8b 43 40 4c 8b 78 58 49 8d 8f 58 03 00 00 eb 02 f3 90 
[   64.508754] RIP  [<ffffffff8124292f>] d_splice_alias+0x31f/0x480
[   64.509176]  RSP <ffff8800c283fb20>

Bye,
    Oleg