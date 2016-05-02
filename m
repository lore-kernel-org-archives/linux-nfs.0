Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34949 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859AbcEBVIv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 17:08:51 -0400
Received: by mail-io0-f193.google.com with SMTP id u185so376660iod.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2016 14:08:51 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: blocked on the spin lock
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <1264524839.11600209.1462219635088.JavaMail.zimbra@desy.de>
Date: Mon, 2 May 2016 17:08:48 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        William Andros Adamson <william.adamson@netapp.com>
Message-Id: <AC7B8856-9451-43F0-A960-BDFD2D27B3A0@monkey.org>
References: <148899538.11512158.1462174191227.JavaMail.zimbra@desy.de> <65246751-DEBE-4B05-BBAD-4E3CE6589442@monkey.org> <1264524839.11600209.1462219635088.JavaMail.zimbra@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 2, 2016, at 4:07 PM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy.de> wrote:
> 
> Hi Dros,
> 
> as you can see from the stack trace, this is NFSv3.

Oh, I didn't notice that! 

> For now, it happened only once. May be there is some change with
> our workflow. I will let you know, if we see it again.

OK. If you do, try applying that patch set and see if it’s still reproducible.

-dros

> 
> 
> Thanks,
>   Tigran.
> 
> ----- Original Message -----
>> From: "Weston Andros Adamson" <dros@monkey.org>
>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>> Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>, "Steve Dickson" <steved@redhat.com>, "Andy Adamson"
>> <william.adamson@netapp.com>
>> Sent: Monday, May 2, 2016 3:30:29 PM
>> Subject: Re: blocked on the spin lock
> 
>>> On May 2, 2016, at 3:29 AM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy.de> wrote:
>>> 
>>> 
>>> 
>>> Hi Dros et. al.
>>> 
>>> We have seen the following stack trace on one of out systems:
>>> 
>>> 
>>> Apr 28 22:09:51 bird510 kernel: BUG: soft lockup - CPU#7 stuck for 67s!
>>> [tee:13755]
>>> Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu
>>> nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat
>>> usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc
>>> cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
>>> dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support
>>> bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2
>>> mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib
>>> ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
>>> tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded:
>>> ipmi_devintf]
>>> Apr 28 22:09:51 bird510 kernel: CPU 7
>>> Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu
>>> nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat
>>> usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc
>>> cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
>>> dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support
>>> bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2
>>> mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib
>>> ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
>>> tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded:
>>> ipmi_devintf]
>>> Apr 28 22:09:51 bird510 kernel:
>>> Apr 28 22:09:51 bird510 kernel: Pid: 13755, comm: tee Tainted: P           --
>>> ------------    2.6.32-573.12.1.el6.x86_64 #1 Dell Inc. PowerEdge M610/0N582M
>>> Apr 28 22:09:51 bird510 kernel: RIP: 0010:[<ffffffff8153bde1>]
>>> [<ffffffff8153bde1>] _spin_lock+0x21/0x30
>>> Apr 28 22:09:51 bird510 kernel: RSP: 0018:ffff8803528179c8  EFLAGS: 00000297
>>> Apr 28 22:09:51 bird510 kernel: RAX: 00000000000003b1 RBX: ffff8803528179c8 RCX:
>>> 0000000000000000
>>> Apr 28 22:09:51 bird510 kernel: RDX: 00000000000003b0 RSI: ffff880159aeb820 RDI:
>>> ffff880159aeb8d0
>>> Apr 28 22:09:51 bird510 kernel: RBP: ffffffff8100bc0e R08: ffff880352817af0 R09:
>>> 0000000000000002
>>> Apr 28 22:09:51 bird510 kernel: R10: ffffea0008efc428 R11: 0000000000000003 R12:
>>> 0000000000000001
>>> Apr 28 22:09:51 bird510 kernel: R13: 001310facb5806bd R14: 0000000000000000 R15:
>>> 0000000000000000
>>> Apr 28 22:09:51 bird510 kernel: FS:  00007f3e78118700(0000)
>>> GS:ffff880028260000(0000) knlGS:0000000000000000
>>> Apr 28 22:09:51 bird510 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
>>> 000000008005003b
>>> Apr 28 22:09:51 bird510 kernel: CR2: 00007fefa21ff000 CR3: 0000000352959000 CR4:
>>> 00000000000007e0
>>> Apr 28 22:09:51 bird510 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>> 0000000000000000
>>> Apr 28 22:09:51 bird510 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>> 0000000000000400
>>> Apr 28 22:09:51 bird510 kernel: Process tee (pid: 13755, threadinfo
>>> ffff880352814000, task ffff880636064ab0)
>>> Apr 28 22:09:51 bird510 kernel: Stack:
>>> Apr 28 22:09:51 bird510 kernel: ffff880352817a18 ffffffffa0490dc1
>>> ffff880159aeb8d0 ffff880159aeb770
>>> Apr 28 22:09:51 bird510 kernel: <d> 0000000000000000 0000000000000000
>>> ffffffffa04bd040 ffffffffa048f39a
>>> Apr 28 22:09:51 bird510 kernel: <d> ffff8803378761c0 ffffea000a13dcc0
>>> ffff880352817a48 ffffffffa0490ec8
>>> Apr 28 22:09:51 bird510 kernel: Call Trace:
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ?
>>> nfs_clear_request_commit+0xa1/0xf0 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ?
>>> nfs_page_find_request_locked+0x2a/0x40 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ?
>>> nfs_wb_page_cancel+0xb8/0xf0 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ?
>>> nfs_invalidate_page+0x47/0x80 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ?
>>> do_invalidatepage+0x25/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ?
>>> truncate_inode_page+0xa2/0xc0
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ?
>>> truncate_inode_pages_range+0x16f/0x500
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ?
>>> mempool_free_slab+0x17/0x20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ?
>>> truncate_inode_pages+0x15/0x20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ?
>>> truncate_pagecache+0x4f/0x70
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ?
>>> nfs_setattr_update_inode+0xb9/0x150 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ?
>>> nfs3_proc_setattr+0xdb/0x120 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50
>>> [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170
>>> [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ?
>>> security_inode_permission+0x1f/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ?
>>> strncpy_from_user+0x4a/0x90
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ?
>>> system_call_fastpath+0x16/0x1b
>>> Apr 28 22:09:51 bird510 kernel: Code: 01 74 05 e8 52 1c d6 ff c9 c3 55 48 89 e5
>>> 0f 1f 44 00 00 b8 00 00 01 00 f0 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 0e f3 90
>>> 0f b7 17 <eb> f5 83 3f 00 75 f4 eb df c9 c3 0f 1f 40 00 55 48 89 e5 0f 1f
>>> Apr 28 22:09:51 bird510 kernel: Call Trace:
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ?
>>> nfs_clear_request_commit+0xa1/0xf0 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ?
>>> nfs_page_find_request_locked+0x2a/0x40 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ?
>>> nfs_wb_page_cancel+0xb8/0xf0 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ?
>>> nfs_invalidate_page+0x47/0x80 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ?
>>> do_invalidatepage+0x25/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ?
>>> truncate_inode_page+0xa2/0xc0
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ?
>>> truncate_inode_pages_range+0x16f/0x500
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ?
>>> mempool_free_slab+0x17/0x20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ?
>>> truncate_inode_pages+0x15/0x20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ?
>>> truncate_pagecache+0x4f/0x70
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ?
>>> nfs_setattr_update_inode+0xb9/0x150 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ?
>>> nfs3_proc_setattr+0xdb/0x120 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50
>>> [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170
>>> [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ?
>>> security_inode_permission+0x1f/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ?
>>> strncpy_from_user+0x4a/0x90
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
>>> Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ?
>>> system_call_fastpath+0x16/0x1b
>>> 
>>> 
>>> 
>>> 
>>> The questionable spin lock was remove by commit 411a99adf. Is there was a
>>> problem?
>>> Do we need a packport in RHEL kernel?
>>> 
>>> Thanks a lot,
>>>  Tigran.
>>> 
>> 
>> Hey Tigran,
>> 
>> It’s been a while since I looked at this, so I don’t know off the top of my
>> head, but IIRC the patch series that 411a99adf is part of are some important
>> bug fixes to the effort to split sub-page regions:
>> 
>> 411a99adffb4 nfs: clear_request_commit while holding i_lock
>> e6cf82d1830f pnfs: add pnfs_put_lseg_async
>> 02d1426c7053 pnfs: find swapped pages on pnfs commit lists too
>> b412ddf0661e nfs: fix comment and add warn_on for PG_INODE_REF
>> e7029206ff43 nfs: check wait_on_bit_lock err in page_group_lock
>> 
>> Also, if you are using the pnfs_nfs commit path, there are several recent fixes
>> that are pretty important. Until recently, the only server to do NFS backed
>> pnfs did only STABLE writes, so that stuff was pretty much untested…
>> 
>> In fact, I have a patch to post today that fixes a problem in the commit path,
>> although it probably isn’t an issue in RHEL as it was a regression introduced
>> by a recent patch.
>> 
>> -dros

