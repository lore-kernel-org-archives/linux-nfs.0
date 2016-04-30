Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36825 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcD3NXA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 09:23:00 -0400
Received: by mail-qk0-f182.google.com with SMTP id x7so56794860qkd.3
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 06:22:59 -0700 (PDT)
Message-ID: <1462022576.10011.22.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 09:22:56 -0400
In-Reply-To: <1462022142.10011.19.camel@poochiereds.net>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
	 <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
	 <20160429075812.GY25498@ZenIV.linux.org.uk>
	 <1462022142.10011.19.camel@poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-30 at 09:15 -0400, Jeff Layton wrote:
> On Fri, 2016-04-29 at 08:58 +0100, Al Viro wrote:
> > 
> > On Sun, Apr 24, 2016 at 08:18:35PM +0100, Al Viro wrote:
> > 
> > > 
> > > 
> > > What we get out of that is fully parallel
> > > lookup/readdir/sillyunlink - all
> > > exclusion is on per-name basis (nfs_prime_dcache() vs.
> > > nfs_lookup()
> > > vs.
> > > nfs_do_call_unlink()).  It will require a bit of care in
> > > atomic_open(),
> > > though...
> > > 
> > > I'll play with that a bit and see what can be done...
> > OK, a bunch of atomic_open cleanups (moderately tested) +
> > almost untested sillyunlink patch are in vfs.git#untested.nfs.
> > 
> > It ought to make lookups (and readdir, and !O_CREAT case of
> > atomic_open)
> > on NFS really execute in parallel.  Folks, please hit that sucker
> > with
> > NFS torture tests.  In particular, the stuff mentioned in commit
> > 565277f6 would be interesting to try.
> 
> I pulled down the branch and built it, and then ran the cthon special
> tests 100 times in a loop, and ran "ls -l" on the test directory in a
> loop at the same time. On pass 42, I hit this:
> 
> [ 1168.630763] general protection fault: 0000 [#1] SMP 
> [ 1168.631617] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache xfs snd_hda_codec_generic snd_hda_intel snd_hda_codec libcrc32c snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd nfsd joydev ppdev soundcore acpi_cpufreq virtio_net pcspkr i2c_piix4 tpm_tis tpm parport_pc parport virtio_balloon floppy pvpanic nfs_acl lockd auth_rpcgss grace sunrpc qxl drm_kms_helper ttm drm virtio_console virtio_blk virtio_pci virtio_ring virtio serio_raw ata_generic pata_acpi
> [ 1168.638448] CPU: 3 PID: 1850 Comm: op_ren Not tainted 4.6.0-rc1+ #25
> [ 1168.639413] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [ 1168.640146] task: ffff880035cf5400 ti: ffff8800d064c000 task.ti: ffff8800d064c000
> [ 1168.641107] RIP: 0010:[]  [] kmem_cache_alloc+0x78/0x160
> [ 1168.642292] RSP: 0018:ffff8800d064fa90  EFLAGS: 00010246
> [ 1168.642978] RAX: 73747365746e7572 RBX: 0000000000000894 RCX: 0000000000000020
> [ 1168.643920] RDX: 0000000000318271 RSI: 00000000024080c0 RDI: 000000000001a440
> [ 1168.644862] RBP: ffff8800d064fac0 R08: ffff88021fd9a440 R09: ffff880035b82400
> [ 1168.645794] R10: 0000000000000000 R11: ffff8800d064fb70 R12: 00000000024080c0
> [ 1168.646762] R13: ffffffff81317667 R14: ffff880217001d00 R15: 73747365746e7572
> [ 1168.647650] FS:  00007f0cb8295700(0000) GS:ffff88021fd80000(0000) knlGS:0000000000000000
> [ 1168.648639] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1168.649330] CR2: 0000000000401090 CR3: 0000000035f9a000 CR4: 00000000000006e0
> [ 1168.650239] Stack:
> [ 1168.650498]  00ff8800026084c0 0000000000000894 ffff880035b82400 ffff8800d064fd14
> [ 1168.651509]  ffff8800d0650000 ffff880201ca5e38 ffff8800d064fae0 ffffffff81317667
> [ 1168.652506]  ffffffff81c9b140 ffff880035b82400 ffff8800d064fb00 ffffffff8130ef03
> [ 1168.653494] Call Trace:
> [ 1168.653889]  [] selinux_file_alloc_security+0x37/0x60
> [ 1168.654728]  [] security_file_alloc+0x33/0x50
> [ 1168.655447]  [] get_empty_filp+0x9a/0x1c0
> [ 1168.656231]  [] ? copy_to_iter+0x1b6/0x260
> [ 1168.656999]  [] path_openat+0x2e/0x1660
> [ 1168.657645]  [] ? current_fs_time+0x23/0x30
> [ 1168.658311]  [] ? copy_to_iter+0x1b6/0x260
> [ 1168.658999]  [] ? current_fs_time+0x23/0x30
> [ 1168.659742]  [] ? touch_atime+0x23/0xa0
> [ 1168.660435]  [] do_filp_open+0x7e/0xe0
> [ 1168.661072]  [] ? __vfs_read+0xa7/0xd0
> [ 1168.661792]  [] ? __vfs_read+0xa7/0xd0
> [ 1168.662410]  [] ? kmem_cache_alloc+0x34/0x160
> [ 1168.663130]  [] do_open_execat+0x64/0x150
> [ 1168.664100]  [] open_exec+0x2b/0x50
> [ 1168.664949]  [] load_elf_binary+0x29a/0x1670
> [ 1168.665880]  [] ? get_user_pages_remote+0x54/0x60
> [ 1168.666843]  [] ? copy_strings.isra.30+0x25c/0x370
> [ 1168.667812]  [] search_binary_handler+0x9e/0x1d0
> [ 1168.668753]  [] do_execveat_common.isra.41+0x4fc/0x6d0
> [ 1168.669753]  [] SyS_execve+0x3a/0x50
> [ 1168.670560]  [] do_syscall_64+0x62/0x110
> [ 1168.671384]  [] entry_SYSCALL64_slow_path+0x25/0x25
> [ 1168.672305] Code: 49 83 78 10 00 4d 8b 38 0f 84 bd 00 00 00 4d 85 ff 0f 84 b4 00 00 00 49 63 46 20 49 8b 3e 4c 01 f8 40 f6 c7 0f 0f 85 cf 00 00 00 <48> 8b 18 48 8d 4a 01 4c 89 f8 65 48 0f c7 0f 0f 94 c0 84 c0 74 
> [ 1168.676071] RIP  [] kmem_cache_alloc+0x78/0x160
> [ 1168.677008]  RSP 
> [ 1168.679699] general protection fault: 0000 [#2]
> 
> 
> kmem_cache corruption maybe?
> 
> (gdb) list *(kmem_cache_alloc+0x78)
> 0xffffffff811f6488 is in kmem_cache_alloc (mm/slub.c:245).
> 240      *                      Core slab cache functions
> 241      *******************************************************************/
> 242
> 243     static inline void *get_freepointer(struct kmem_cache *s, void *object)
> 244     {
> 245             return *(void **)(object + s->offset);
> 246     }
> 247
> 248     static void prefetch_freepointer(const struct kmem_cache *s, void *object)
> 249     {
> 
> 
> From /sys/kernel/slab (after rebooting and rerunning the cthon tests once):
> 
> lrwxrwxrwx. 1 root root 0 Apr 30 09:10 selinux_file_security -> :t-0000016
> 
> [root@rawhide slab]# ls -l | grep :t-0000016
> lrwxrwxrwx. 1 root root 0 Apr 30 09:10 kmalloc-16 -> :t-0000016
> lrwxrwxrwx. 1 root root 0 Apr 30 09:10 selinux_file_security -> :t-0000016
> drwxr-xr-x. 2 root root 0 Apr 30 09:11 :t-0000016
> 
> 
> Hard to tell if this is related to your changes but it certainly did
> happen in the open codepath. I'll see if I can reproduce it again.
> 

Second oops on second attempt. Different codepath this time:

[  548.093261] general protection fault: 0000 [#1] SMP 
[  548.094023] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache xfs snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device libcrc32c snd_pcm snd_timer snd acpi_cpufreq ppdev tpm_tis soundcore tpm nfsd parport_pc parport virtio_net floppy virtio_balloon joydev pvpanic i2c_piix4 pcspkr nfs_acl lockd auth_rpcgss grace sunrpc qxl drm_kms_helper ttm virtio_console virtio_blk drm serio_raw virtio_pci virtio_ring ata_generic virtio pata_acpi
[  548.100968] CPU: 2 PID: 18173 Comm: ls Not tainted 4.6.0-rc1+ #25
[  548.101799] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  548.102586] task: ffff8800d0275400 ti: ffff880202934000 task.ti: ffff880202934000
[  548.103610] RIP: 0010:[<ffffffff811f9a06>]  [<ffffffff811f9a06>] __kmalloc_track_caller+0x96/0x1b0
[  548.104793] RSP: 0018:ffff880202937ad0  EFLAGS: 00010246
[  548.105488] RAX: ff656c6966676962 RBX: 0000000000000006 RCX: 0000000000000000
[  548.106412] RDX: 0000000000009f9f RSI: 0000000000000000 RDI: 000000000001a420
[  548.107335] RBP: ffff880202937b00 R08: ffff88021fd1a420 R09: ff656c6966676962
[  548.108236] R10: 0000000000000001 R11: ffff880212756240 R12: 00000000024000c0
[  548.109375] R13: 0000000000000006 R14: ffffffffa03d9697 R15: ffff880217001e00
[  548.110308] FS:  00007fd7839e2800(0000) GS:ffff88021fd00000(0000) knlGS:0000000000000000
[  548.111378] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  548.112136] CR2: 00007ffe35047f3c CR3: 0000000202816000 CR4: 00000000000006e0
[  548.113064] Stack:
[  548.113333]  ffff880201065548 0000000000000006 ffff88020222e314 0000000000000000
[  548.114338]  ffff880202f563e8 ffff880202937cb0 ffff880202937b20 ffffffff811b5e50
[  548.115335]  ffff880202f56000 ffff880202937df0 ffff880202937c38 ffffffffa03d9697
[  548.116342] Call Trace:
[  548.116665]  [<ffffffff811b5e50>] kmemdup+0x20/0x50
[  548.117295]  [<ffffffffa03d9697>] nfs_readdir_page_filler+0x277/0x5f0 [nfs]
[  548.118173]  [<ffffffffa03d9c0f>] nfs_readdir_xdr_to_array+0x1ff/0x330 [nfs]
[  548.119058]  [<ffffffffa03d9d64>] nfs_readdir_filler+0x24/0xb0 [nfs]
[  548.119856]  [<ffffffff8119772e>] ? add_to_page_cache_lru+0x6e/0xc0
[  548.120625]  [<ffffffff81197b4f>] do_read_cache_page+0x13f/0x2c0
[  548.121397]  [<ffffffffa03d9d40>] ? nfs_readdir_xdr_to_array+0x330/0x330 [nfs]
[  548.122296]  [<ffffffff81197ce9>] read_cache_page+0x19/0x20
[  548.122995]  [<ffffffffa03d9f63>] nfs_readdir+0x173/0x5f0 [nfs]
[  548.123711]  [<ffffffff81457a5a>] ? tty_write+0x1ca/0x2f0
[  548.124568]  [<ffffffffa0427cb0>] ? nfs4_xdr_dec_fsinfo+0x70/0x70 [nfsv4]
[  548.125372]  [<ffffffff812232bb>] iterate_dir+0x16b/0x1a0
[  548.126039]  [<ffffffff812236e8>] SyS_getdents+0x88/0x100
[  548.126686]  [<ffffffff812232f0>] ? iterate_dir+0x1a0/0x1a0
[  548.127651]  [<ffffffff81003cb2>] do_syscall_64+0x62/0x110
[  548.128614]  [<ffffffff8174ae21>] entry_SYSCALL64_slow_path+0x25/0x25
[  548.129667] Code: 49 83 78 10 00 4d 8b 08 0f 84 bf 00 00 00 4d 85 c9 0f 84 b6 00 00 00 49 63 47 20 49 8b 3f 4c 01 c8 40 f6 c7 0f 0f 85 fa 00 00 00 <48> 8b 18 48 8d 4a 01 4c 89 c8 65 48 0f c7 0f 0f 94 c0 84 c0 74 
[  548.133600] RIP  [<ffffffff811f9a06>] __kmalloc_track_caller+0x96/0x1b0
[  548.134659]  RSP <ffff880202937ad0>
[  548.135353] ---[ end trace 77ac2ecac8d76afe ]---

...but looks like same problem:

(gdb) list *(__kmalloc_track_caller+0x96)
0xffffffff811f9a06 is in __kmalloc_track_caller (mm/slub.c:245).
240      *                      Core slab cache functions
241      *******************************************************************/
242
243     static inline void *get_freepointer(struct kmem_cache *s, void *object)
244     {
245             return *(void **)(object + s->offset);
246     }
247
248     static void prefetch_freepointer(const struct kmem_cache *s, void *object)
249     {

-- 
Jeff Layton <jlayton@poochiereds.net>

