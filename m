Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:39258 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932141AbeE3TrD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 15:47:03 -0400
Received: by mail-vk0-f68.google.com with SMTP id y137-v6so11867214vkd.6
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 12:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFZ9JWPOoLd01+rEw2+TO9O6ZrfLWsmTQbeZh=wdBhx6w@mail.gmail.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <CAN-5tyExDWpWuZ5_EwTHbxPbr+FC9jg4zB_Y2pdAHKmX2mDPsQ@mail.gmail.com>
 <8cf44605f0635b591e097594167289160e0e0d8b.camel@hammerspace.com>
 <CAN-5tyF8J9tBwLTRLEc=f1LJ4PGoY9cxJsKX4dD330z8Vs8PJg@mail.gmail.com>
 <CAN-5tyFR0R4XtcB_RAxqRQjwdXU=vBY7oDr5ATMOSS6F2MoJpw@mail.gmail.com> <CAN-5tyFZ9JWPOoLd01+rEw2+TO9O6ZrfLWsmTQbeZh=wdBhx6w@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 30 May 2018 15:47:01 -0400
Message-ID: <CAN-5tyH8zDtVWo_vBbGA87vssNZfp+mVJLaVB=FzGoz2uy3LYw@mail.gmail.com>
Subject: Re: [PATCH 00/19] Layoutget on OPEN
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get a kernel oops

[  101.881058] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000088
[  101.884302] PGD 800000002e0dc067 P4D 800000002e0dc067 PUD 2e0dd067 PMD 0
[  101.886773] Oops: 0000 [#1] SMP PTI
[  101.888026] Modules linked in: nfs_layout_nfsv41_files
rpcsec_gss_krb5 nfsv4 dns_resolver nfs ib_iser libiscsi
scsi_transport_iscsi ib_srp scsi_transport_srp ib_ipoib rdma_ucm
ib_ucm ib_uverbs ib_umad rpcrdma rdma_cm iw_cm ib_cm ib_core rfcomm
fuse ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT
nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_security iptable_raw ebtable_filter ebtables
ip6table_filter ip6_tables iptable_filter bnep snd_seq_midi
snd_seq_midi_event coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel pcbc btusb btrtl uvcvideo btbcm snd_ens1371
btintel
[  101.913196]  snd_ac97_codec bluetooth ac97_bus aesni_intel snd_seq
videobuf2_vmalloc crypto_simd videobuf2_memops videobuf2_v4l2 cryptd
glue_helper videodev vmw_balloon snd_pcm pcspkr ext4 snd_timer mbcache
jbd2 snd_rawmidi videobuf2_common snd_seq_device snd rfkill
ecdh_generic vmw_vmci shpchp soundcore i2c_piix4 nfsd nfs_acl lockd
auth_rpcgss grace sunrpc ip_tables xfs libcrc32c sr_mod cdrom
ata_generic vmwgfx pata_acpi drm_kms_helper syscopyarea sysfillrect
sysimgblt fb_sys_fops ttm sd_mod drm crc32c_intel ahci ata_piix
libahci serio_raw libata mptspi scsi_transport_spi e1000 i2c_core
mptscsih mptbase dm_mirror dm_region_hash dm_log dm_mod
[  101.934175] CPU: 0 PID: 2485 Comm: bash Tainted: G        W
4.17.0-rc7+ #111
[  101.938064] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  101.943395] RIP: 0010:fl_pnfs_update_layout.constprop.22+0x51/0x150
[nfs_layout_nfsv41_files]
[  101.947586] RSP: 0018:ffffb00443027ac0 EFLAGS: 00010246
[  101.949513] RAX: 0000000000000000 RBX: ffff9739bada46c0 RCX: 00000001802a0028
[  101.952094] RDX: 00000001802a0029 RSI: 0000000000000000 RDI: 0000000040000000
[  101.954862] RBP: ffff97396cd70608 R08: ffff9739b3b2d200 R09: 00000001802a0028
[  101.957999] R10: 00000000b3b2d101 R11: ffff9739b3b2d200 R12: 0000000001400040
[  101.960552] R13: 0000000000000000 R14: ffffb00443027d90 R15: ffff9739b9126000
[  101.963083] FS:  00007f31d31b0740(0000) GS:ffff9739bb600000(0000)
knlGS:0000000000000000
[  101.966021] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  101.968468] CR2: 0000000000000088 CR3: 000000002e0f0006 CR4: 00000000001606f0
[  101.971240] Call Trace:
[  101.972178]  filelayout_pg_init_write+0x223/0x270 [nfs_layout_nfsv41_files]
[  101.974741]  __nfs_pageio_add_request+0x117/0x3c0 [nfs]
[  101.976637]  ? radix_tree_tag_clear+0x9c/0xd0
[  101.978230]  nfs_pageio_add_request+0x17f/0x310 [nfs]
[  101.980123]  nfs_do_writepage+0x18e/0x390 [nfs]
[  101.981774]  nfs_writepages_callback+0xf/0x20 [nfs]
[  101.983526]  write_cache_pages+0x21f/0x460
[  101.985077]  ? nfs_do_writepage+0x390/0x390 [nfs]
[  101.986853]  ? wb_wakeup_delayed+0x52/0x60
[  101.988315]  ? __set_page_dirty_nobuffers+0x119/0x180
[  101.990125]  ? _cond_resched+0x15/0x30
[  101.991481]  ? kmem_cache_alloc_trace+0xae/0x1c0
[  101.993151]  nfs_writepages+0xb2/0x120 [nfs]
[  101.994705]  do_writepages+0x17/0x70
[  101.996012]  __filemap_fdatawrite_range+0xc5/0x100
[  101.997727]  filemap_write_and_wait_range+0x30/0x80
[  101.999453]  nfs_file_fsync+0x39/0x1f0 [nfs]
[  102.000991]  filp_close+0x2a/0x70
[  102.002176]  do_dup2+0x79/0xd0
[  102.003293]  __x64_sys_dup2+0x1a/0x60
[  102.004639]  do_syscall_64+0x55/0x180
[  102.005951]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  102.007771] RIP: 0033:0x7f31d289ff17
[  102.009093] RSP: 002b:00007fff269668b8 EFLAGS: 00000246 ORIG_RAX:
0000000000000021
[  102.011772] RAX: ffffffffffffffda RBX: 0000000002644790 RCX: 00007f31d289ff17
[  102.014323] RDX: 0000000000000001 RSI: 0000000000000001 RDI: 000000000000000a
[  102.016852] RBP: 00007fff26966940 R08: 000000000000000a R09: 000000000263a250
[  102.019380] R10: 0000000000000003 R11: 0000000000000246 R12: 0000000000000007
[  102.021928] R13: 0000000000000009 R14: 0000000000000001 R15: 0000000000000000
[  102.024454] Code: b6 fc f8 ff 48 85 c0 48 89 c3 74 13 48 3d 00 f0
ff ff 77 0b 48 83 7b 78 00 48 8b 45 e8 74 0c 48 83 c4 08 48 89 d8 5b
5d 41 5c c3 <48> 8b 90 88 00 00 00 48 8b 80 90 00 00 00 48 8d 73 68 44
89 e1
[  102.031048] RIP: fl_pnfs_update_layout.constprop.22+0x51/0x150
[nfs_layout_nfsv41_files] RSP: ffffb00443027ac0
[  102.034692] CR2: 0000000000000088
[  102.036225] ---[ end trace ae6b78ef3992a438 ]---
[  102.037969] Kernel panic - not syncing: Fatal exception
[  102.039901] Kernel Offset: 0x36600000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  102.043717] ---[ end Kernel panic - not syncing: Fatal exception ]---

On Wed, May 30, 2018 at 3:29 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> I added EXPORT_SYMBOL_GPL for those function to get passed it.
>
> On Wed, May 30, 2018 at 3:27 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> It doesn't compile. Am I missing something?
>>
>> ERROR: "nfs4_inode_make_writeable" [fs/nfs/nfs.ko] undefined!
>> ERROR: "nfs4_inode_return_delegation" [fs/nfs/nfs.ko] undefined!
>>
>> On Wed, May 30, 2018 at 2:37 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> Awesome thanks.
>>>
>>> On Wed, May 30, 2018 at 2:36 PM, Trond Myklebust
>>> <trondmy@hammerspace.com> wrote:
>>>> On Wed, 2018-05-30 at 14:25 -0400, Olga Kornievskaia wrote:
>>>>> Hi Trond,
>>>>>
>>>>> Do you by any chance have this patch set somewhere in your git
>>>>> branches? I'd like to test this against NetApp.
>>>>>
>>>>> Thank you.
>>>>>
>>>>
>>>> I've just pushed it out to my testing branch on git.linux-nfs.org.
>>>>
>>>>> On Wed, May 30, 2018 at 2:05 PM, Trond Myklebust <trondmy@gmail.com>
>>>>> wrote:
>>>>> > This patchset is something we've been sitting on for a couple of
>>>>> > years
>>>>> > in order to allow it to mature. It was mainly developed by Fred
>>>>> > Isaman
>>>>> > while he was working for Primary Data, but we've had a few bugfixes
>>>>> > come in since then.
>>>>> > The main reason for delaying the upstream merge was to ensure that
>>>>> > adding layoutget to the OPEN compound was safe (does not cause
>>>>> > existing
>>>>> > layouts to be automatically revoked) and that it gives us a real
>>>>> > performance benefit.
>>>>> >
>>>>> > Fred Isaman (14):
>>>>> >   pnfs: Remove redundant assignment from nfs4_proc_layoutget().
>>>>> >   pnfs: Store return value of decode_layoutget for later processing
>>>>> >   NFS4: move ctx into nfs4_run_open_task
>>>>> >   pnfs: Add layout driver flag PNFS_LAYOUTGET_ON_OPEN
>>>>> >   pnfs: refactor send_layoutget
>>>>> >   pnfs: move allocations out of nfs4_proc_layoutget
>>>>> >   pnfs: Add conditional encode/decode of LAYOUTGET within OPEN
>>>>> > compound
>>>>> >   pnfs: Move nfs4_opendata into nfs4_fs.h
>>>>> >   pnfs: Change pnfs_alloc_init_layoutget_args call signature
>>>>> >   pnfs: Add LAYOUTGET to OPEN of a new file
>>>>> >   pnfs: Add LAYOUTGET to OPEN of an existing file
>>>>> >   pnfs: Stop attempting LAYOUTGET on OPEN on failure
>>>>> >   pnfs: Add barrier to prevent lgopen using LAYOUTGET during recall
>>>>> >   pnfs: Fix manipulation of NFS_LAYOUT_FIRST_LAYOUTGET
>>>>> >
>>>>> > Trond Myklebust (5):
>>>>> >   NFSv4/pnfs: Ensure pnfs_parse_lgopen() won't try to parse
>>>>> >     uninitialised data
>>>>> >   NFSv4/pnfs: Don't switch off layoutget-on-open for transient
>>>>> > errors
>>>>> >   pNFS: Don't send LAYOUTGET on OPEN for read, if we already have
>>>>> > cached
>>>>> >     data
>>>>> >   pnfs: Don't call commit on failed layoutget-on-open
>>>>> >   pnfs: Don't release the sequence slot until we've processed
>>>>> > layoutget
>>>>> >     on open
>>>>> >
>>>>> >  fs/nfs/callback_proc.c                 |   2 +
>>>>> >  fs/nfs/flexfilelayout/flexfilelayout.c |   1 +
>>>>> >  fs/nfs/nfs4_fs.h                       |  25 +++
>>>>> >  fs/nfs/nfs4proc.c                      |  97 +++++----
>>>>> >  fs/nfs/nfs4state.c                     |   8 +
>>>>> >  fs/nfs/nfs4xdr.c                       |  65 +++++-
>>>>> >  fs/nfs/pnfs.c                          | 266
>>>>> > +++++++++++++++++++++----
>>>>> >  fs/nfs/pnfs.h                          |  28 ++-
>>>>> >  include/linux/nfs_fs_sb.h              |   2 +
>>>>> >  include/linux/nfs_xdr.h                |   4 +
>>>>> >  10 files changed, 398 insertions(+), 100 deletions(-)
>>>>> >
>>>>> > --
>>>>> > 2.17.0
>>>>> >
>>>>> > --
>>>>> > To unsubscribe from this list: send the line "unsubscribe linux-
>>>>> > nfs" in
>>>>> > the body of a message to majordomo@vger.kernel.org
>>>>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>>> in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> --
>>>> Trond Myklebust
>>>> Linux NFS client maintainer, Hammerspace
>>>> trond.myklebust@hammerspace.com
>>>>
