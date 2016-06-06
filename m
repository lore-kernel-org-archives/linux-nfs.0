Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:54164 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbcFFXgi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2016 19:36:38 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160603055655.GQ14480@ZenIV.linux.org.uk>
Date: Mon, 6 Jun 2016 19:36:26 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <18266C54-EE2D-4E79-9216-77D1B17A1B85@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk> <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru> <20160603042648.GN14480@ZenIV.linux.org.uk> <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru> <20160603055655.GQ14480@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well, I have some bad news.

This patch does not fix the issue 100% of the time apparently, I just hit it again.

Only this time it's much harder to trigger, but stack is the same
(looks a bit different due to a compiler change). Must be some much narrower race now.

I still don't have a crashdump, though (apparently makedumpfile that is used by
kexec-tools is behind times and does not work with 4.7.0-rc1 kernels) so I cannot
tell you more about the dentry still.

[12470.365211] kernel BUG at /home/green/bk/linux/fs/dcache.c:2989!
[12470.366336] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[12470.366927] Modules linked in: loop rpcsec_gss_krb5 joydev pcspkr acpi_cpufreq i2c_piix4 tpm_tis virtio_console tpm nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm serio_raw virtio_blk floppy
[12470.368917] CPU: 7 PID: 15952 Comm: cat Not tainted 4.7.0-rc1-vm-nfs+ #115
[12470.369554] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[12470.370137] task: ffff8800447447c0 ti: ffff880049a48000 task.ti: ffff880049a48000
[12470.371214] RIP: 0010:[<ffffffff81288061>]  [<ffffffff81288061>] d_splice_alias+0x1e1/0x470
[12470.372340] RSP: 0018:ffff880049a4bab8  EFLAGS: 00010286
[12470.372906] RAX: ffff8800393372a8 RBX: ffff88003c781000 RCX: 0000000000000001
[12470.373525] RDX: 0000000000001895 RSI: ffff88003c781000 RDI: ffff8800393372a8
[12470.374145] RBP: ffff880049a4baf0 R08: 00001353641935c2 R09: 0000000000000000
[12470.374777] R10: 0000000000000001 R11: 0000000000000000 R12: ffff88003a7b9300
[12470.375407] R13: 0000000000000000 R14: ffff88003bf0d2a8 R15: 0000000000000000
[12470.376016] FS:  00007fbb07feb700(0000) GS:ffff88006b800000(0000) knlGS:0000000000000000
[12470.377106] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[12470.377693] CR2: 000055a498c7bdc8 CR3: 00000000479b3000 CR4: 00000000000006e0
[12470.378311] Stack:
[12470.378823]  ffff880040008f00 0000000029e67876 ffff88003c781000 ffff88003a7b9300
[12470.379946]  0000000000000000 ffff88003bf0d2a8 0000000000000000 ffff880049a4bb48
[12470.381075]  ffffffff8137d63c ffffffffffffffeb ffff880000000000 0000000000000000
[12470.382228] Call Trace:
[12470.382766]  [<ffffffff8137d63c>] nfs_lookup+0x15c/0x420
[12470.383363]  [<ffffffff8137f681>] nfs_atomic_open+0xb1/0x700
[12470.383961]  [<ffffffff812792ea>] lookup_open+0x2ea/0x770
[12470.384570]  [<ffffffff8127c76f>] path_openat+0x7ff/0x1030
[12470.385169]  [<ffffffff8127d15f>] ? getname_flags+0x4f/0x1f0
[12470.385770]  [<ffffffff8104a485>] ? kvm_sched_clock_read+0x25/0x40
[12470.386361]  [<ffffffff8127e1d1>] do_filp_open+0x91/0x100
[12470.386945]  [<ffffffff8188aa97>] ? _raw_spin_unlock+0x27/0x40
[12470.387559]  [<ffffffff8128f810>] ? __alloc_fd+0x100/0x200
[12470.388158]  [<ffffffff8126a230>] do_sys_open+0x130/0x220
[12470.388758]  [<ffffffff8126a33e>] SyS_open+0x1e/0x20
[12470.389327]  [<ffffffff8188b3fc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[12470.389929] Code: 83 c4 10 4c 89 f8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 89 df e8 f1 d6 ff ff 4c 89 f7 e8 19 2a 60 00 45 31 ff eb d9 49 89 ff eb d4 <0f> 0b 48 8b 43 50 4c 8b 78 68 49 8d 97 c8 03 00 00 eb 02 f3 90 
[12470.392299] RIP  [<ffffffff81288061>] d_splice_alias+0x1e1/0x470


On Jun 3, 2016, at 1:56 AM, Al Viro wrote:

> On Fri, Jun 03, 2016 at 12:58:10AM -0400, Oleg Drokin wrote:
> 
>> This one cures the insta-crash I was having, and I see no other ill-effects so far.
> 
> OK...  I can take it through vfs.git, but I think it'd be better off in
> NFS tree.  Is everyone OK with something like the following?
> 
> make nfs_atomic_open() call d_drop() on all ->open_context() errors.
> 
> In "NFSv4: Move dentry instantiation into the NFSv4-specific atomic open code"
> unconditional d_drop() after the ->open_context() had been removed.  It had
> been correct for success cases (there ->open_context() itself had been doing
> dcache manipulations), but not for error ones.  Only one of those (ENOENT)
> got a compensatory d_drop() added in that commit, but in fact it should've
> been done for all errors.  As it is, the case of O_CREAT non-exclusive open
> on a hashed negative dentry racing with e.g. symlink creation from another
> client ended up with ->open_context() getting an error and proceeding to
> call nfs_lookup().  On a hashed dentry, which would've instantly triggered
> BUG_ON() in d_materialise_unique() (or, these days, its equivalent in
> d_splice_alias()).
> 
> Cc: stable@vger.kernel.org # v3.10+
> Tested-by: Oleg Drokin <green@linuxhacker.ru>
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index aaf7bd0..6e3a6f4 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1536,9 +1536,9 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
> 		err = PTR_ERR(inode);
> 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
> 		put_nfs_open_context(ctx);
> +		d_drop(dentry);
> 		switch (err) {
> 		case -ENOENT:
> -			d_drop(dentry);
> 			d_add(dentry, NULL);
> 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
> 			break;

