From: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>
Subject: Re: processes in D state too long too often
Date: Sat, 07 Feb 2009 20:49:27 +0000
Message-ID: <W396157575167661234039767@webmail27>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from omr5.networksolutionsemail.com ([205.178.146.55]:43894 "EHLO
	omr5.networksolutionsemail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753327AbZBGUt3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Feb 2009 15:49:29 -0500
Received: from mail.networksolutionsemail.com (ns-omr5.mgt.netsol.com [10.49.6.68])
	by omr5.networksolutionsemail.com (8.13.6/8.13.6) with SMTP id n17KnRPN030162
	for <linux-nfs@vger.kernel.org>; Sat, 7 Feb 2009 15:49:27 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Then send us those traces. Please try to avoid wordwrapping them in
the email.

Ok, so I run my simulations, and then run the following script. 

--- This was run on the master node
echo w > /proc/sysrq-trigger
dmesg -c -s 1000000 > foo

I've captured these stuck tasks on both the master and the slave node, on separate runs.

Here is the master capture.
---
SysRq : Show Blocked State
  task                        PC stack   pid father
SysRq : Show Blocked State
  task                        PC stack   pid father
nfsd          D 00000001079318f8     0  5832      2
 ffff880837a23c70 0000000000000046 0000000000000000 0000000000000002
 ffff88083aef5950 ffff88083cda5790 ffff88083aef5b80 0000000437a23c80
 00000000ffffffff 00000001079318fb 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5840      2
 ffff88083725fc70 0000000000000046 0000000000000000 0000000000000002
 ffff880838cca8e0 ffffffff8070a340 ffff880838ccab10 000000003725fc80
 00000000ffffffff 00000001079318fb 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5847      2
 ffff8808369a3c70 0000000000000046 0000000000000000 0000000000000002
 ffff880836f88bb0 ffffffff8070a340 ffff880836f88de0 00000000369a3c80
 00000000ffffffff 00000001079318f9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5867      2
 ffff88083561fc70 0000000000000046 0000000000000000 0000000000000002
 ffff880835422cb0 ffffffff8070a340 ffff880835422ee0 000000003561fc80
 00000000ffffffff 00000001079318f8 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5868      2
 ffff880835739c70 0000000000000046 0000000000000000 0000000000000002
 ffff880835422720 ffffffff8070a340 ffff880835422950 0000000035739c80
 00000000ffffffff 00000001079318f9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5887      2
 ffff8808342bbc70 0000000000000046 0000000000000000 0000000000000002
 ffff8808340a2db0 ffffffff8070a340 ffff8808340a2fe0 00000000342bbc80
 00000000ffffffff 00000001079318f9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5888      2
 ffff8808343b9c70 0000000000000046 0000000000000000 0000000000000002
 ffff8808340a2820 ffffffff8070a340 ffff8808340a2a50 00000000343b9c80
 00000000ffffffff 00000001079318fb 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5893      2
 ffff8808338e7c70 0000000000000046 0000000000000000 0000000000000002
 ffff880833dd0860 ffffffff8070a340 ffff880833dd0a90 00000000338e7c80
 00000000ffffffff 00000001079318f9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

nfsd          D 00000001079318e9     0  5905      2
 ffff880832d41c70 0000000000000046 0000000000000000 0000000000000002
 ffff880832d3f9d0 ffffffff8070a340 ffff880832d3fc00 0000000032d41c80
 00000000ffffffff 00000001079318fb 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
 [<ffffffff80237e8b>] process_timeout+0x0/0x5
 [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
 [<ffffffff80238178>] msleep+0x14/0x1e
 [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
 [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
 [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
 [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
 [<ffffffff80307ac1>] decode_fh+0x1c/0x45
 [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
 [<ffffffff805456f5>] svc_process+0x408/0x6e7
 [<ffffffff8056f920>] __down_read+0x12/0x93
 [<ffffffff802fef26>] nfsd+0x1b7/0x285
 [<ffffffff802fed6f>] nfsd+0x0/0x285
 [<ffffffff80240d34>] kthread+0x47/0x73
 [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
 [<ffffffff8020c109>] child_rip+0xa/0x11
 [<ffffffff80240ced>] kthread+0x0/0x73
 [<ffffffff8020c0ff>] child_rip+0x0/0x11

And here's what was caught on the slave node during a separate run.
---
SysRq : Show Blocked State
  task                        PC stack   pid father
hello_c       D 00000001027c68c2     0  9840   9839
 ffff88043b101bf8 0000000000000086 0000000000000000 0000000000000246
 ffff88043e58f2c0 ffff88043e4d6bf0 ffff88043e58f4f0 0000000200000246
 00000000ffffffff ffffffff805317a9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff805317a9>] xprt_prepare_transmit+0x81/0x8c
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff802f58e9>] nfs_wait_bit_killable+0x2a/0x30
 [<ffffffff80560e03>] __wait_on_bit+0x40/0x6e
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff80560e9d>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff80240e87>] wake_bit_function+0x0/0x23
 [<ffffffff802f94b0>] nfs_sync_mapping_wait+0xed/0x21a
 [<ffffffff802f9672>] nfs_wb_page+0x95/0xc7
 [<ffffffff802f9da0>] nfs_flush_incompatible+0x40/0x51
 [<ffffffff802eea77>] nfs_vm_page_mkwrite+0xbd/0xf2
 [<ffffffff80267f9e>] do_wp_page+0xe3/0x511
 [<ffffffff80269a34>] handle_mm_fault+0x665/0x6c1
 [<ffffffff8026d46b>] vma_merge+0x147/0x1f4
 [<ffffffff80563f91>] do_page_fault+0x43a/0x7f5
 [<ffffffff80562049>] error_exit+0x0/0x51

hello_c       D 00000001027c68e6     0  9841   9839
 ffff88043a0a3bf8 0000000000000086 0000000000000000 ffff88043c491800
 ffff88043c9d8660 ffff88043e4a0620 ffff88043c9d8890 000000013c491800
 00000000ffffffff ffffffff805307a5 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff805307a5>] xprt_end_transmit+0x2c/0x39
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff802f58e9>] nfs_wait_bit_killable+0x2a/0x30
 [<ffffffff80560e03>] __wait_on_bit+0x40/0x6e
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff80560e9d>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff80240e87>] wake_bit_function+0x0/0x23
 [<ffffffff802f94b0>] nfs_sync_mapping_wait+0xed/0x21a
 [<ffffffff802f9672>] nfs_wb_page+0x95/0xc7
 [<ffffffff802f9da0>] nfs_flush_incompatible+0x40/0x51
 [<ffffffff802eea77>] nfs_vm_page_mkwrite+0xbd/0xf2
 [<ffffffff80267f9e>] do_wp_page+0xe3/0x511
 [<ffffffff80269a34>] handle_mm_fault+0x665/0x6c1
 [<ffffffff80281f21>] put_unused_fd+0x31/0x3c
 [<ffffffff80563f91>] do_page_fault+0x43a/0x7f5
 [<ffffffff80562049>] error_exit+0x0/0x51

hello_c       D ffffffff802f58bf     0  9842   9839
 ffff88043b1bdbf8 0000000000000082 ffff88043a0ee688 ffff88043c491800
 ffff88043bbc8d30 ffff88043c9a99d0 ffff88043bbc8f60 000000033c491800
 ffff88043a0ee688 ffffffff805307a5 ffff88043a0ee688 0000000000000246
Call Trace:
 [<ffffffff805307a5>] xprt_end_transmit+0x2c/0x39
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff802f58e9>] nfs_wait_bit_killable+0x2a/0x30
 [<ffffffff80560e03>] __wait_on_bit+0x40/0x6e
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff80560e9d>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff80240e87>] wake_bit_function+0x0/0x23
 [<ffffffff802f94b0>] nfs_sync_mapping_wait+0xed/0x21a
 [<ffffffff802f9672>] nfs_wb_page+0x95/0xc7
 [<ffffffff802f9da0>] nfs_flush_incompatible+0x40/0x51
 [<ffffffff802eea77>] nfs_vm_page_mkwrite+0xbd/0xf2
 [<ffffffff80267f9e>] do_wp_page+0xe3/0x511
 [<ffffffff80269a34>] handle_mm_fault+0x665/0x6c1
 [<ffffffff80563f91>] do_page_fault+0x43a/0x7f5
 [<ffffffff80562049>] error_exit+0x0/0x51

hello_c       D 00000001027c68db     0  9843   9839
 ffff88043ac59bf8 0000000000000082 0000000000000000 0000000000000246
 ffff88043bbc8210 ffffffff806f9340 ffff88043bbc8440 0000000000000246
 00000000ffffffff ffffffff805317a9 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff805317a9>] xprt_prepare_transmit+0x81/0x8c
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff802f58e9>] nfs_wait_bit_killable+0x2a/0x30
 [<ffffffff80560e03>] __wait_on_bit+0x40/0x6e
 [<ffffffff802f58bf>] nfs_wait_bit_killable+0x0/0x30
 [<ffffffff80560e9d>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff80240e87>] wake_bit_function+0x0/0x23
 [<ffffffff802f94b0>] nfs_sync_mapping_wait+0xed/0x21a
 [<ffffffff802f9672>] nfs_wb_page+0x95/0xc7
 [<ffffffff802f9da0>] nfs_flush_incompatible+0x40/0x51
 [<ffffffff802eea77>] nfs_vm_page_mkwrite+0xbd/0xf2
 [<ffffffff80267f9e>] do_wp_page+0xe3/0x511
 [<ffffffff80269a34>] handle_mm_fault+0x665/0x6c1
 [<ffffffff80563f91>] do_page_fault+0x43a/0x7f5
 [<ffffffff80562049>] error_exit+0x0/0x51




