Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:32863 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbcD3XXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 19:23:14 -0400
Received: by mail-qk0-f173.google.com with SMTP id n63so60267022qkf.0
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 16:23:13 -0700 (PDT)
Message-ID: <1462058589.10011.67.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 19:23:09 -0400
In-Reply-To: <20160430205705.GE25498@ZenIV.linux.org.uk>
References: <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
	 <20160429075812.GY25498@ZenIV.linux.org.uk>
	 <1462022142.10011.19.camel@poochiereds.net>
	 <1462022576.10011.22.camel@poochiereds.net>
	 <20160430142232.GA25498@ZenIV.linux.org.uk>
	 <1462027414.10011.31.camel@poochiereds.net>
	 <20160430185836.GC25498@ZenIV.linux.org.uk>
	 <20160430192931.GD25498@ZenIV.linux.org.uk>
	 <1462048765.10011.44.camel@poochiereds.net>
	 <20160430205705.GE25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-30 at 21:57 +0100, Al Viro wrote:
> On Sat, Apr 30, 2016 at 04:39:25PM -0400, Jeff Layton wrote:
> 
> > 
> > Attached. Also I ran the same test on a 4.6.0-rc1 kernel and it
> > worked
> > fine, so it does seem to be a regression introduced somewhere in
> > your
> > patch pile. Also, FWIW the machine is a KVM guest.
> OK...  Could you try #work.lookups on your setup?  That doesn't
> contain the
> last commit; the deadlock ought to be dealt with, though.  I'm trying
> to
> reproduce the corruption with KASAN enabled, will try your config
> once that's
> finished...


Here's what I got with your untested.nfs branch + KASAN:

[  192.453252] BUG: unable to handle kernel paging request at ffff814bf270ffff
[  192.454102] IP: [<ffffffff8156622b>] deactivate_slab+0xab/0x3e0
[  192.454795] PGD 0 
[  192.455040] Oops: 0000 [#1] SMP KASAN
[  192.455469] Modules linked in: nfsv3 nfs fscache xfs snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core libcrc32c snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer nfsd joydev snd acpi_cpufreq ppdev parport_pc tpm_tis virtio_net soundcore parport tpm pcspkr virtio_balloon pvpanic i2c_piix4 nfs_acl lockd auth_rpcgss grace sunrpc qxl drm_kms_helper virtio_console virtio_blk ttm drm serio_raw virtio_pci ata_generic virtio_ring pata_acpi virtio floppy
[  192.460993] CPU: 0 PID: 8628 Comm: rm Not tainted 4.6.0-rc1+ #29
[  192.461679] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  192.462359] task: ffff8801bf990000 ti: ffff8800c7e88000 task.ti: ffff8800c7e88000
[  192.463372] RIP: 0010:[<ffffffff8156622b>]  [<ffffffff8156622b>] deactivate_slab+0xab/0x3e0
[  192.464266] RSP: 0018:ffff8800c7e8f550  EFLAGS: 00010002
[  192.464839] RAX: 0000000000000000 RBX: ffff8801d6c02200 RCX: 00000001801a0019
[  192.465646] RDX: ffff8800c5949c2e RSI: ffffea0003165200 RDI: ffffea0003165200
[  192.466443] RBP: ffff8800c7e8f650 R08: ffff8800c5948750 R09: 000000000000801a
[  192.467319] R10: ffff8800c5948750 R11: ffffed0037f53c7f R12: ffff8801d6c02208
[  192.468282] R13: ffff814bf270ffff R14: ffff814bf270ffff R15: ffffea0003165200
[  192.469064] FS:  00007f8ae54d7700(0000) GS:ffff8801d7000000(0000) knlGS:0000000000000000
[  192.469919] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  192.470528] CR2: ffff814bf270ffff CR3: 00000000c5950000 CR4: 00000000000006f0
[  192.471337] Stack:
[  192.471567]  ffff8800c7e8f58c 00000000801a001a ffff8801d7007fc0 ffff8801bf990000
[  192.472453]  0000000000000000 ffff8800c7e88000 ffff8800c7e8f5c0 0000000003165200
[  192.473388]  0000000fc7e8f650 ffff8801d6c01e00 ffffffffa098b3df ffff8801bf990000
[  192.474349] Call Trace:
[  192.474641]  [<ffffffffa098b3df>] ? nfs_readdir_page_filler+0x65f/0x1430 [nfs]
[  192.475456]  [<ffffffffa098b3df>] ? nfs_readdir_page_filler+0x65f/0x1430 [nfs]
[  192.476246]  [<ffffffff810a6eeb>] ? save_stack_trace+0x2b/0x50
[  192.476872]  [<ffffffff81563614>] ? set_track+0x74/0x120
[  192.477453]  [<ffffffff81565953>] ? alloc_debug_processing+0x73/0x1b0
[  192.478143]  [<ffffffff81566ecf>] ___slab_alloc+0x4ff/0x520
[  192.478742]  [<ffffffff8156b5f6>] ? memcpy+0x36/0x40
[  192.479309]  [<ffffffffa098b3df>] ? nfs_readdir_page_filler+0x65f/0x1430 [nfs]
[  192.480084]  [<ffffffffa0a3cb73>] ? nfs3_decode_dirent+0x773/0xd90 [nfsv3]
[  192.480846]  [<ffffffffa098b3df>] ? nfs_readdir_page_filler+0x65f/0x1430 [nfs]
[  192.481642]  [<ffffffff81566f10>] __slab_alloc+0x20/0x40
[  192.482209]  [<ffffffff8156a837>] __kmalloc_track_caller+0x167/0x1d0
[  192.482884]  [<ffffffff814bf270>] kmemdup+0x20/0x50
[  192.483478]  [<ffffffffa098b3df>] nfs_readdir_page_filler+0x65f/0x1430 [nfs]
[  192.484226]  [<ffffffff81567f7a>] ? __slab_free+0x9a/0x250
[  192.484851]  [<ffffffffa098ad80>] ? nfs_do_filldir+0x730/0x730 [nfs]
[  192.485916]  [<ffffffffa0a32d47>] ? nfs3_proc_readdir+0x2a7/0x4e0 [nfsv3]
[  192.486990]  [<ffffffff81566ecf>] ? ___slab_alloc+0x4ff/0x520
[  192.487965]  [<ffffffffa0a32aa0>] ? nfs3_proc_rmdir+0x2f0/0x2f0 [nfsv3]
[  192.489009]  [<ffffffff8156b3e6>] ? kasan_unpoison_shadow+0x36/0x50
[  192.490075]  [<ffffffff81550693>] ? alloc_pages_current+0xd3/0x290
[  192.491144]  [<ffffffffa098c74d>] nfs_readdir_xdr_to_array+0x59d/0xaa0 [nfs]
[  192.492346]  [<ffffffffa098c1b0>] ? nfs_readdir_page_filler+0x1430/0x1430 [nfs]
[  192.493506]  [<ffffffff81a809c8>] ? radix_tree_lookup_slot+0x58/0x90
[  192.494564]  [<ffffffff81550604>] ? alloc_pages_current+0x44/0x290
[  192.495558]  [<ffffffff81467d60>] ? add_to_page_cache_locked+0x20/0x20
[  192.496593]  [<ffffffffa098ccba>] nfs_readdir_filler+0x6a/0x1c0 [nfs]
[  192.497595]  [<ffffffff8146879e>] do_read_cache_page+0x22e/0x6a0
[  192.498568]  [<ffffffffa098cc50>] ? nfs_readdir_xdr_to_array+0xaa0/0xaa0 [nfs]
[  192.499646]  [<ffffffff81468c50>] read_cache_page+0x40/0x70
[  192.500547]  [<ffffffffa098d266>] nfs_readdir+0x456/0x1680 [nfs]
[  192.501501]  [<ffffffff81495dfb>] ? lru_cache_add_active_or_unevictable+0xcb/0x260
[  192.502616]  [<ffffffffa098ce10>] ? nfs_readdir_filler+0x1c0/0x1c0 [nfs]
[  192.503634]  [<ffffffffa0a3c400>] ? nfs3_xdr_dec_getattr3res+0xb0/0xb0 [nfsv3]
[  192.504714]  [<ffffffff815dfb53>] iterate_dir+0x3f3/0x5b0
[  192.505591]  [<ffffffff815e0708>] SyS_getdents+0xf8/0x1a0
[  192.506473]  [<ffffffff81006460>] ? enter_from_user_mode+0x50/0x50
[  192.507454]  [<ffffffff815e0610>] ? SyS_old_readdir+0x100/0x100
[  192.508412]  [<ffffffff815dfd10>] ? iterate_dir+0x5b0/0x5b0
[  192.509332]  [<ffffffff81006a61>] ? syscall_trace_enter_phase2+0xf1/0x510
[  192.510377]  [<ffffffff815e0610>] ? SyS_old_readdir+0x100/0x100
[  192.511351]  [<ffffffff810072fa>] do_syscall_64+0x19a/0x410
[  192.512258]  [<ffffffff81460bfd>] ? context_tracking_enter+0x1d/0x20
[  192.513275]  [<ffffffff8271e321>] entry_SYSCALL64_slow_path+0x25/0x25
[  192.514271] Code: 8b 57 10 49 8b 4f 18 49 89 54 05 00 48 89 4c 24 68 66 83 6c 24 68 01 80 7c 24 6b 00 78 c6 0f 0b 48 63 43 20 49 8b 57 10 4d 89 f5 <49> 8b 0c 06 48 85 c9 74 05 49 89 ce eb ca 48 8b 7c 24 48 45 31 
[  192.518193] RIP  [<ffffffff8156622b>] deactivate_slab+0xab/0x3e0
[  192.519099]  RSP <ffff8800c7e8f550>
[  192.519738] CR2: ffff814bf270ffff
[  192.520410] ---[ end trace a406a29677c40c04 ]---

Same spot, apparently:

(gdb) list *(deactivate_slab+0xab)
0xffffffff8156622b is in deactivate_slab (mm/slub.c:245).
240	 * 			Core slab cache functions
241	 *******************************************************************/
242	
243	static inline void *get_freepointer(struct kmem_cache *s, void *object)
244	{
245		return *(void **)(object + s->offset);
246	}
247	
248	static void prefetch_freepointer(const struct kmem_cache *s, void *object)
249	{

IIRC, when I looked at this code last time, my take was that it wasn't
so much that the slab objects were getting corrupted, but rather the
cache metadata.

-- 
Jeff Layton <jlayton@poochiereds.net>

