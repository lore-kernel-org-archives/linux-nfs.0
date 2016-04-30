Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34365 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbcD3NPr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 09:15:47 -0400
Received: by mail-qg0-f41.google.com with SMTP id 90so37512752qgz.1
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 06:15:46 -0700 (PDT)
Message-ID: <1462022142.10011.19.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 09:15:42 -0400
In-Reply-To: <20160429075812.GY25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
	 <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
	 <20160429075812.GY25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-04-29 at 08:58 +0100, Al Viro wrote:
> On Sun, Apr 24, 2016 at 08:18:35PM +0100, Al Viro wrote:
> 
> > 
> > What we get out of that is fully parallel
> > lookup/readdir/sillyunlink - all
> > exclusion is on per-name basis (nfs_prime_dcache() vs. nfs_lookup()
> > vs.
> > nfs_do_call_unlink()).  It will require a bit of care in
> > atomic_open(),
> > though...
> > 
> > I'll play with that a bit and see what can be done...
> OK, a bunch of atomic_open cleanups (moderately tested) +
> almost untested sillyunlink patch are in vfs.git#untested.nfs.
> 
> It ought to make lookups (and readdir, and !O_CREAT case of
> atomic_open)
> on NFS really execute in parallel.  Folks, please hit that sucker
> with
> NFS torture tests.  In particular, the stuff mentioned in commit
> 565277f6 would be interesting to try.


I pulled down the branch and built it, and then ran the cthon special
tests 100 times in a loop, and ran "ls -l" on the test directory in a
loop at the same time. On pass 42, I hit this:

[ 1168.630763] general protection fault: 0000 [#1] SMP 
[ 1168.631617] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache xfs snd_hda_codec_generic snd_hda_intel snd_hda_codec libcrc32c snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd nfsd joydev ppdev soundcore acpi_cpufreq virtio_net pcspkr i2c_piix4 tpm_tis tpm parport_pc parport virtio_balloon floppy pvpanic nfs_acl lockd auth_rpcgss grace sunrpc qxl drm_kms_helper ttm drm virtio_console virtio_blk virtio_pci virtio_ring virtio serio_raw ata_generic pata_acpi
[ 1168.638448] CPU: 3 PID: 1850 Comm: op_ren Not tainted 4.6.0-rc1+ #25
[ 1168.639413] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 1168.640146] task: ffff880035cf5400 ti: ffff8800d064c000 task.ti: ffff8800d064c000
[ 1168.641107] RIP: 0010:[<ffffffff811f6488>]  [<ffffffff811f6488>] kmem_cache_alloc+0x78/0x160
[ 1168.642292] RSP: 0018:ffff8800d064fa90  EFLAGS: 00010246
[ 1168.642978] RAX: 73747365746e7572 RBX: 0000000000000894 RCX: 0000000000000020
[ 1168.643920] RDX: 0000000000318271 RSI: 00000000024080c0 RDI: 000000000001a440
[ 1168.644862] RBP: ffff8800d064fac0 R08: ffff88021fd9a440 R09: ffff880035b82400
[ 1168.645794] R10: 0000000000000000 R11: ffff8800d064fb70 R12: 00000000024080c0
[ 1168.646762] R13: ffffffff81317667 R14: ffff880217001d00 R15: 73747365746e7572
[ 1168.647650] FS:  00007f0cb8295700(0000) GS:ffff88021fd80000(0000) knlGS:0000000000000000
[ 1168.648639] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1168.649330] CR2: 0000000000401090 CR3: 0000000035f9a000 CR4: 00000000000006e0
[ 1168.650239] Stack:
[ 1168.650498]  00ff8800026084c0 0000000000000894 ffff880035b82400 ffff8800d064fd14
[ 1168.651509]  ffff8800d0650000 ffff880201ca5e38 ffff8800d064fae0 ffffffff81317667
[ 1168.652506]  ffffffff81c9b140 ffff880035b82400 ffff8800d064fb00 ffffffff8130ef03
[ 1168.653494] Call Trace:
[ 1168.653889]  [<ffffffff81317667>] selinux_file_alloc_security+0x37/0x60
[ 1168.654728]  [<ffffffff8130ef03>] security_file_alloc+0x33/0x50
[ 1168.655447]  [<ffffffff812117da>] get_empty_filp+0x9a/0x1c0
[ 1168.656231]  [<ffffffff81399d96>] ? copy_to_iter+0x1b6/0x260
[ 1168.656999]  [<ffffffff8121d75e>] path_openat+0x2e/0x1660
[ 1168.657645]  [<ffffffff81103133>] ? current_fs_time+0x23/0x30
[ 1168.658311]  [<ffffffff81399d96>] ? copy_to_iter+0x1b6/0x260
[ 1168.658999]  [<ffffffff81103133>] ? current_fs_time+0x23/0x30
[ 1168.659742]  [<ffffffff8122bea3>] ? touch_atime+0x23/0xa0
[ 1168.660435]  [<ffffffff8121fe3e>] do_filp_open+0x7e/0xe0
[ 1168.661072]  [<ffffffff8120e8d7>] ? __vfs_read+0xa7/0xd0
[ 1168.661792]  [<ffffffff8120e8d7>] ? __vfs_read+0xa7/0xd0
[ 1168.662410]  [<ffffffff811f6444>] ? kmem_cache_alloc+0x34/0x160
[ 1168.663130]  [<ffffffff81214d94>] do_open_execat+0x64/0x150
[ 1168.664100]  [<ffffffff8121524b>] open_exec+0x2b/0x50
[ 1168.664949]  [<ffffffff8126302a>] load_elf_binary+0x29a/0x1670
[ 1168.665880]  [<ffffffff811c43d4>] ? get_user_pages_remote+0x54/0x60
[ 1168.666843]  [<ffffffff81215fac>] ? copy_strings.isra.30+0x25c/0x370
[ 1168.667812]  [<ffffffff8121595e>] search_binary_handler+0x9e/0x1d0
[ 1168.668753]  [<ffffffff8121714c>] do_execveat_common.isra.41+0x4fc/0x6d0
[ 1168.669753]  [<ffffffff812175ba>] SyS_execve+0x3a/0x50
[ 1168.670560]  [<ffffffff81003cb2>] do_syscall_64+0x62/0x110
[ 1168.671384]  [<ffffffff8174ae21>] entry_SYSCALL64_slow_path+0x25/0x25
[ 1168.672305] Code: 49 83 78 10 00 4d 8b 38 0f 84 bd 00 00 00 4d 85 ff 0f 84 b4 00 00 00 49 63 46 20 49 8b 3e 4c 01 f8 40 f6 c7 0f 0f 85 cf 00 00 00 <48> 8b 18 48 8d 4a 01 4c 89 f8 65 48 0f c7 0f 0f 94 c0 84 c0 74 
[ 1168.676071] RIP  [<ffffffff811f6488>] kmem_cache_alloc+0x78/0x160
[ 1168.677008]  RSP <ffff8800d064fa90>
[ 1168.679699] general protection fault: 0000 [#2]


kmem_cache corruption maybe?

(gdb) list *(kmem_cache_alloc+0x78)
0xffffffff811f6488 is in kmem_cache_alloc (mm/slub.c:245).
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
