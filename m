Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:42946 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751729AbcITWHF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Sep 2016 18:07:05 -0400
Subject: Re: [PATCH v6 00/29] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 20 Sep 2016 18:06:46 -0400
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <C5E6E9A2-24B0-4D4B-A82A-706A89E23D24@linuxhacker.ru>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 20, 2016, at 12:55 PM, Trond Myklebust wrote:

> According to RFC5661, if any of the SEQUENCE status bits
> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
> TEST_STATEID to figure out which stateids have been revoked, so we
> can acknowledge the loss of state using FREE_STATEID.
> 
> While we already do this for open and lock state, we have not been doing
> so for all the delegations.
> 
> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
> v3: Now with added lock revoke fixes and close/delegreturn/locku fixes
> v4: Close a bunch of corner cases
> v5: Report revoked delegations as invalid in nfs_have_delegation()
>    Fix an infinite loop in nfs_reap_expired_delegations.
>        Fixes for other looping behaviour
> v6: Fix nfs4_do_handle_exception to handle all stateids, not just delegations
>    Stable fix for nfs4_copy_delegation_stateid
>    Marked fix "NFSv4: Don't report revoked delegations as valid in
>        nfs_have_delegation" for stable.
>    Stable fix for the inode mode/fileid corruption
> 
> Trond Myklebust (29):
>  NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
>  NFS: Fix inode corruption in nfs_prime_dcache()
>  NFSv4: Don't report revoked delegations as valid in
>    nfs_have_delegation()
>  NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is
>    invalid
>  NFSv4.1: Don't check delegations that are already marked as revoked
>  NFSv4.1: Allow test_stateid to handle session errors without waiting
>  NFSv4.1: Add a helper function to deal with expired stateids
>  NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a
>    stateid
>  NFSv4.1: Test delegation stateids when server declares "some state
>    revoked"
>  NFSv4.1: Deal with server reboots during delegation expiration
>    recovery
>  NFSv4.1: Don't recheck delegations that have already been checked
>  NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
>  NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
>  NFSv4.1: FREE_STATEID can be asynchronous
>  NFSv4.1: Ensure we call FREE_STATEID if needed on
>    close/delegreturn/locku
>  NFSv4: Ensure we don't re-test revoked and freed stateids
>  NFSv4: nfs_inode_find_delegation_state_and_recover() should check all
>    stateids
>  NFSv4: nfs4_handle_delegation_recall_error() handle expiration as
>    revoke case
>  NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
>  NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
>  NFSv4: Pass the stateid to the exception handler in
>    nfs4_read/write_done_cb
>  NFSv4: Fix a race in nfs_inode_reclaim_delegation()
>  NFSv4: Fix a race when updating an open_stateid
>  NFS: Always call nfs_inode_find_state_and_recover() when revoking a
>    delegation
>  NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single
>    stateid
>  NFSv4: Don't test open_stateid unless it is set
>  NFSv4: Mark the lock and open stateids as invalid after freeing them
>  NFSv4: Open state recovery must account for file permission changes
>  NFSv4: Fix retry issues with nfs41_test/free_stateid

This one seems to fail in multiple ways.
This is applied on top of Linus' tree commit d2ffb0103aaefa9b169da042cf39ce27bfb6cdbb
One is similar to what we saw before:

[12374.572987] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
[12374.572988] --> nfs41_setup_sequence
[12374.572989] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[12374.572990] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[12374.572991] <-- nfs41_setup_sequence slotid=0 seqid=3873200
[12374.572998] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873200 slotid=0 max_slotid=0 cache_this=1
[12374.573228] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[12374.573229] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[12374.573230] nfs4_free_slot: slotid 1 highest_used_slotid 0
[12374.573231] nfs41_sequence_process: Error 0 free the slot 
[12374.573232] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[12374.573252] --> nfs_put_client({2})
[12374.573257] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
[12374.573258] --> nfs41_setup_sequence
[12374.573259] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[12374.573260] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[12374.573261] <-- nfs41_setup_sequence slotid=0 seqid=3873201
[12374.573268] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873201 slotid=0 max_slotid=0 cache_this=1
[12374.573525] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[12374.573526] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[12374.573527] nfs4_free_slot: slotid 1 highest_used_slotid 0
[12374.573527] nfs41_sequence_process: Error 0 free the slot 
[12374.573529] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[12374.573548] --> nfs_put_client({2})
[12374.573554] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
[12374.573555] --> nfs41_setup_sequence
[12374.573556] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[12374.573557] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[12374.573558] <-- nfs41_setup_sequence slotid=0 seqid=3873202
[12374.573565] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873202 slotid=0 max_slotid=0 cache_this=1
[12374.573794] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[12374.573795] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[12374.573796] nfs4_free_slot: slotid 1 highest_used_slotid 0
[12374.573797] nfs41_sequence_process: Error 0 free the slot 
[12374.573798] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[12374.573818] --> nfs_put_client({2})
[12374.573823] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
[12374.573824] --> nfs41_setup_sequence
[12374.573825] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[12374.573826] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[12374.573827] <-- nfs41_setup_sequence slotid=0 seqid=3873203
[12374.573835] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873203 slotid=0 max_slotid=0 cache_this=1
[12374.574103] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[12374.574104] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[12374.574105] nfs4_free_slot: slotid 1 highest_used_slotid 0
[12374.574106] nfs41_sequence_process: Error 0 free the slot 
[12374.574108] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[12374.574128] --> nfs_put_client({2})

Then there are crashes/warnings, I have 4 starting with same warning, here's a sample:
[ 7338.195888] ------------[ cut here ]------------
[ 7338.210606] WARNING: CPU: 5 PID: 2310872 at /home/green/bk/linux-test/fs/dcache.c:768 dput+0x31f/0x410
[ 7338.211548] Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq tpm_tis tpm_tis_core joydev tpm i2c_piix4 pcspkr virtio_console nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm serio_raw floppy
[ 7338.213209] CPU: 5 PID: 2310872 Comm: ls Not tainted 4.8.0-rc7-vm-nfst+ #38
[ 7338.213707] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[ 7338.214614]  0000000000000286 0000000073f54649 ffff8800ab0039b0 ffffffff814ad883
[ 7338.215510]  0000000000000000 0000000000000000 ffff8800ab0039f0 ffffffff8108a0ab
[ 7338.217487]  000003005b1bdb20 ffff880060b2d090 ffffffff81c6e4f8 ffffffff81291fa7
[ 7338.218415] Call Trace:
[ 7338.219158]  [<ffffffff814ad883>] dump_stack+0x86/0xc3
[ 7338.219608]  [<ffffffff8108a0ab>] __warn+0xcb/0xf0
[ 7338.220109]  [<ffffffff81291fa7>] ? dput+0x37/0x410
[ 7338.220558]  [<ffffffff8108a1dd>] warn_slowpath_null+0x1d/0x20
[ 7338.230497]  [<ffffffff8129228f>] dput+0x31f/0x410
[ 7338.230961]  [<ffffffff81291fa7>] ? dput+0x37/0x410
[ 7338.231450]  [<ffffffff81294bbb>] ? d_lookup+0x9b/0xe0
[ 7338.231913]  [<ffffffff8138875b>] nfs_prime_dcache+0x16b/0x330
[ 7338.232416]  [<ffffffff81388d22>] nfs_readdir_page_filler+0x222/0x430
[ 7338.232903]  [<ffffffff813891f2>] nfs_readdir_xdr_to_array+0x2c2/0x450
[ 7338.233423]  [<ffffffff81108c08>] ? rcu_read_lock_sched_held+0x8/0x80
[ 7338.233914]  [<ffffffff813893a0>] nfs_readdir_filler+0x20/0x90
[ 7338.234424]  [<ffffffff811d088c>] do_read_cache_page+0x15c/0x2d0
[ 7338.234908]  [<ffffffff810db0c5>] ? wake_up_bit+0x25/0x30
[ 7338.235754]  [<ffffffff81389380>] ? nfs_readdir_xdr_to_array+0x450/0x450
[ 7338.236238]  [<ffffffff811d0a1c>] read_cache_page+0x1c/0x20
[ 7338.236746]  [<ffffffff81389f52>] nfs_readdir+0x182/0x7e0
[ 7338.237205]  [<ffffffff8104c1a5>] ? kvm_sched_clock_read+0x25/0x40
[ 7338.237736]  [<ffffffff8101fb79>] ? sched_clock+0x9/0x10
[ 7338.238205]  [<ffffffff813c77d0>] ? nfs4_xdr_dec_lookup_root+0xb0/0xb0
[ 7338.238728]  [<ffffffff8128c9e1>] iterate_dir+0x181/0x1b0
[ 7338.239191]  [<ffffffff8128cefc>] SyS_getdents+0x9c/0x130
[ 7338.240175]  [<ffffffff8128cc60>] ? fillonedir+0x100/0x100
[ 7338.240694]  [<ffffffff8189f03c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[ 7338.241216] ---[ end trace 650001f792293ddc ]---
[ 7338.241712] ------------[ cut here ]------------
[ 7338.377788] WARNING: CPU: 6 PID: 2310872 at /home/green/bk/linux-test/fs/dcache.c:304 dentry_free+0x7d/0x80
[ 7338.377801] Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq tpm_tis tpm_tis_core joydev tpm i2c_piix4 pcspkr virtio_console nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm serio_raw floppy
[ 7338.377803] CPU: 6 PID: 2310872 Comm: ls Tainted: G        W       4.8.0-rc7-vm-nfst+ #38
[ 7338.377804] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[ 7338.377807]  0000000000000286 0000000073f54649 ffff8800ab003970 ffffffff814ad883
[ 7338.377809]  0000000000000000 0000000000000000 ffff8800ab0039b0 ffffffff8108a0ab
[ 7338.377811]  0000013000000246 ffff880060b2d000 ffff88000d822000 ffff880060b2d090
[ 7338.377811] Call Trace:
[ 7338.377815]  [<ffffffff814ad883>] dump_stack+0x86/0xc3
[ 7338.377817]  [<ffffffff8108a0ab>] __warn+0xcb/0xf0
[ 7338.377819]  [<ffffffff8108a1dd>] warn_slowpath_null+0x1d/0x20
[ 7338.377821]  [<ffffffff8128fbad>] dentry_free+0x7d/0x80
[ 7338.377822]  [<ffffffff812902cd>] __dentry_kill+0x10d/0x160
[ 7338.377824]  [<ffffffff81291fa7>] ? dput+0x37/0x410
[ 7338.377825]  [<ffffffff81292259>] dput+0x2e9/0x410
[ 7338.377826]  [<ffffffff81291fa7>] ? dput+0x37/0x410
[ 7338.377830]  [<ffffffff8138875b>] nfs_prime_dcache+0x16b/0x330
[ 7338.377833]  [<ffffffff81388d22>] nfs_readdir_page_filler+0x222/0x430
[ 7338.377835]  [<ffffffff813891f2>] nfs_readdir_xdr_to_array+0x2c2/0x450
[ 7338.377839]  [<ffffffff81108c08>] ? rcu_read_lock_sched_held+0x8/0x80
[ 7338.377841]  [<ffffffff813893a0>] nfs_readdir_filler+0x20/0x90
[ 7338.377843]  [<ffffffff811d088c>] do_read_cache_page+0x15c/0x2d0
[ 7338.377845]  [<ffffffff810db0c5>] ? wake_up_bit+0x25/0x30
[ 7338.377847]  [<ffffffff81389380>] ? nfs_readdir_xdr_to_array+0x450/0x450
[ 7338.377849]  [<ffffffff811d0a1c>] read_cache_page+0x1c/0x20
[ 7338.377851]  [<ffffffff81389f52>] nfs_readdir+0x182/0x7e0
[ 7338.377853]  [<ffffffff8104c1a5>] ? kvm_sched_clock_read+0x25/0x40
[ 7338.377855]  [<ffffffff8101fb79>] ? sched_clock+0x9/0x10
[ 7338.377857]  [<ffffffff813c77d0>] ? nfs4_xdr_dec_lookup_root+0xb0/0xb0
[ 7338.377859]  [<ffffffff8128c9e1>] iterate_dir+0x181/0x1b0
[ 7338.377860]  [<ffffffff8128cefc>] SyS_getdents+0x9c/0x130
[ 7338.377862]  [<ffffffff8128cc60>] ? fillonedir+0x100/0x100
[ 7338.377865]  [<ffffffff8189f03c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[ 7338.377867] ---[ end trace 650001f792293ddd ]---
[ 7338.439443] BUG: spinlock bad magic on CPU#1, ls/2310745
[ 7338.439452] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 7338.439461] Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq tpm_tis tpm_tis_core joydev tpm i2c_piix4 pcspkr virtio_console nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm serio_raw floppy
[ 7338.439463] CPU: 1 PID: 2310745 Comm: ls Tainted: G        W       4.8.0-rc7-vm-nfst+ #38
[ 7338.439464] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[ 7338.439465] task: ffff8800abc28880 task.stack: ffff88005d39c000
[ 7338.439470] RIP: 0010:[<ffffffff810eede1>]  [<ffffffff810eede1>] spin_dump+0x51/0xd0
[ 7338.439471] RSP: 0018:ffff88005d39f930  EFLAGS: 00010202
[ 7338.439472] RAX: 000000000000002c RBX: 6b6b6b6b6b6b6b6b RCX: ffff8800abc28880
[ 7338.439472] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000296
[ 7338.439473] RBP: ffff88005d39f940 R08: 0000000000000001 R09: 000000006b6b6b6b
[ 7338.439474] R10: 0000000000000001 R11: 00000000000338e4 R12: ffff880060b2d090
[ 7338.439475] R13: 00000000e430028f R14: ffff880060b2d130 R15: ffff880060b2d090
[ 7338.439476] FS:  00007fbeab953800(0000) GS:ffff8800b8400000(0000) knlGS:0000000000000000
[ 7338.439477] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7338.439478] CR2: 00007f7e27b90008 CR3: 000000005df9a000 CR4: 00000000000006e0
[ 7338.439481] Stack:
[ 7338.439483]  ffff880060b2d090 0000000000000000 ffff88005d39f958 ffffffff810ef093
[ 7338.439485]  ffff880060b2d090 ffff88005d39f970 ffffffff8189e6d7 ffff880060b2d090
[ 7338.439487]  ffff88005d39f990 ffffffff814bd1cd ffff88000d822000 ffffffff833a1478
[ 7338.439487] Call Trace:
[ 7338.439491]  [<ffffffff810ef093>] do_raw_spin_unlock+0x63/0xc0
[ 7338.439494]  [<ffffffff8189e6d7>] _raw_spin_unlock+0x27/0x40
[ 7338.439496]  [<ffffffff814bd1cd>] lockref_get_not_dead+0x3d/0x50
[ 7338.439499]  [<ffffffff812941de>] d_alloc_parallel+0x27e/0x950
[ 7338.439502]  [<ffffffff813887e6>] ? nfs_prime_dcache+0x1f6/0x330
[ 7338.439504]  [<ffffffff81294bbb>] ? d_lookup+0x9b/0xe0
[ 7338.439506]  [<ffffffff813887e6>] nfs_prime_dcache+0x1f6/0x330
[ 7338.439508]  [<ffffffff81388d22>] nfs_readdir_page_filler+0x222/0x430
[ 7338.439511]  [<ffffffff813891f2>] nfs_readdir_xdr_to_array+0x2c2/0x450
[ 7338.439514]  [<ffffffff81108c08>] ? rcu_read_lock_sched_held+0x8/0x80
[ 7338.439516]  [<ffffffff813893a0>] nfs_readdir_filler+0x20/0x90
[ 7338.439518]  [<ffffffff811d088c>] do_read_cache_page+0x15c/0x2d0
[ 7338.439520]  [<ffffffff810db0c5>] ? wake_up_bit+0x25/0x30
[ 7338.439522]  [<ffffffff81389380>] ? nfs_readdir_xdr_to_array+0x450/0x450
[ 7338.439523]  [<ffffffff811d0a1c>] read_cache_page+0x1c/0x20
[ 7338.439525]  [<ffffffff81389f52>] nfs_readdir+0x182/0x7e0
[ 7338.439528]  [<ffffffff8104c1a5>] ? kvm_sched_clock_read+0x25/0x40
[ 7338.439530]  [<ffffffff8101fb79>] ? sched_clock+0x9/0x10
[ 7338.439533]  [<ffffffff813c77d0>] ? nfs4_xdr_dec_lookup_root+0xb0/0xb0
[ 7338.439534]  [<ffffffff8128c9e1>] iterate_dir+0x181/0x1b0
[ 7338.439536]  [<ffffffff8128cefc>] SyS_getdents+0x9c/0x130
[ 7338.439537]  [<ffffffff8128cc60>] ? fillonedir+0x100/0x100
[ 7338.439539]  [<ffffffff8189f03c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[ 7338.439560] Code: 44 8b 80 80 08 00 00 48 8d 88 b8 0a 00 00 48 c7 c7 a8 a5 c4 81 65 8b 15 56 b3 f1 7e e8 75 e4 0d 00 48 85 db 45 8b 4c 24 08 74 6a <44> 8b 83 80 08 00 00 48 8d 8b b8 0a 00 00 41 8b 54 24 04 4c 89 
[ 7338.439562] RIP  [<ffffffff810eede1>] spin_dump+0x51/0xd0
[ 7338.439563]  RSP <ffff88005d39f930>


dcache.c:768 is:
        WARN_ON(d_in_lookup(dentry));

And two softlockups that start with the same warning, so I guess they are the same.



> 
> fs/nfs/delegation.c                    | 212 ++++++++++++++++--
> fs/nfs/delegation.h                    |   8 +-
> fs/nfs/dir.c                           |  14 +-
> fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
> fs/nfs/nfs4_fs.h                       |   5 +-
> fs/nfs/nfs4proc.c                      | 378 +++++++++++++++++++++++----------
> fs/nfs/nfs4session.h                   |   1 +
> fs/nfs/nfs4state.c                     |  76 +++++--
> include/linux/nfs4.h                   |   1 +
> 9 files changed, 538 insertions(+), 159 deletions(-)
> 
> -- 
> 2.7.4

