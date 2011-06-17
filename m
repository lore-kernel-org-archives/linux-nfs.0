Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757186Ab1FQQsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2011 12:48:06 -0400
Date: Fri, 17 Jun 2011 12:48:04 -0400
To: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
Cc: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: Re: Exports stops working with permission denied.
Message-ID: <20110617164804.GA23399@fieldses.org>
References: <2BF070A7A2375D46BA1B6087F8D5DCB67E82926EBD@seldmbx01.corpusers.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2BF070A7A2375D46BA1B6087F8D5DCB67E82926EBD@seldmbx01.corpusers.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 17, 2011 at 02:23:35PM +0200, Assarsson, Emil wrote:
> Hi,
> 
> I got a problem where clients suddenly wasn't allowed to use mounted nfs filesystems. When I try to use them it responds with permission denied. It doesn't help to restart the nfsserver daemon, I need to restart the server :-/

Do you have a network trace showing what happens on the network when you
try to access the filesystem?

> uname -a
> Linux seldlnx101 2.6.32.12-0.7-default #1 SMP 2010-05-20 11:14:20 +0200 x86_64 x86_64 x86_64 GNU/Linux

This is the server?  What are the clients?

> ---
> lsb_release -a
> LSB Version:    core-2.0-noarch:core-3.2-noarch:core-4.0-noarch:core-2.0-x86_64:core-3.2-x86_64:core-4.0-x86_64:desktop-4.0-amd64:desktop-4.0-noarch:graphics-2.0-amd64:graphics-2.0-noarch:graphics-3.2-amd64:graphics-3.2-noarch:graphics-4.0-amd64:graphics-4.0-noarch
> Distributor ID: SUSE LINUX
> Description:    SUSE Linux Enterprise Server 11 (x86_64)

Have you opened a bug with SUSE?

> Release:        11
> Codename:       n/a
> ---
> 
> We use infiniband but no offload is used on the interface.
> ---
> ethtool -k ib0
> Offload parameters for ib0:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
> large receive offload: off
> ---
> 
> ---
> [16810.468968] RPC: fragment too large: 0x00800103
> [16810.473942] RPC: multiple fragments per record not supported

Hm.  Either you have an unusual client, or you're getting garbage off
the network.

> [19518.260511] RPC: fragment too large: 0x00800103
> [19521.259759] RPC: multiple fragments per record not supported
> [42412.835219] Disabling lock debugging due to kernel taint
> [42412.835226] Machine check events logged
> [103769.238439] RPC: fragment too large: 0x00800103
> [103769.248987] RPC: multiple fragments per record not supported
> [106163.584409] RPC: fragment too large: 0x00800103
> [106166.879358] RPC: multiple fragments per record not supported
> [190419.847170] RPC: fragment too large: 0x00800103
> [190419.854418] RPC: multiple fragments per record not supported
> [192898.293568] RPC: fragment too large: 0x00800103
> [192898.297469] RPC: multiple fragments per record not supported
> [251805.619942] ib0: Completion received during destruction of connection. Waiting.
> [277362.959669] RPC: fragment too large: 0x00800103
> [277366.145589] RPC: multiple fragments per record not supported
> [279462.162306] RPC: fragment too large: 0x00800103
> [279465.438442] RPC: multiple fragments per record not supported
> [348681.698560] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)

??

> [348681.698570] BUG: unable to handle kernel paging request at ffff880bfbf20008

Nothing looks familiar here....

--b.

> [348681.698575] IP: [<ffff880bfbf20008>] 0xffff880bfbf20008
> [348681.698584] PGD 1805063 PUD 8000000bc00001e3
> [348681.698589] Oops: 0011 [#1] SMP
> [348681.698594] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:03.0/enable
> [348681.698600] CPU 23
> [348681.698603] Modules linked in: iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 mptctl mptbase af_packet nfsd exportfs iptable_filter ip_tables x_tables nfs lockd fscache nfs_acl auth_rpcgss sunrpc bonding kcopy(N) rdma_ucm rds_tcp(N) rds_rdma(N) rds(N) ib_sdp(N) rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_usa(N) ib_sa ib_uverbs ib_umad iw_nes crc32c libcrc32c iw_cxgb3 cxgb3 cpufreq_conservative cpufreq_userspace cpufreq_powersave pcc_cpufreq ib_qib(N) mlx4_ib mlx4_core ib_mthca microcode binfmt_misc ipv6 fuse loop dm_mod dca ib_mad sg ib_core rtc_cmos iTCO_wdt tpm_tis hpilo iTCO_vendor_support sr_mod tpm bnx2 rtc_core hpwdt serio_raw joydev pcspkr tpm_bios cdrom rtc_lib power_meter button container usbhid hid uhci_hcd ehci_hcd usbcore edd ext3 mbcache jbd fan ide_pci_generic ide_core ata_generic ata_piix libata thermal processor thermal_sys hwmon cciss scsi_mod
> [348681.698680] Supported: No, Unsupported modules are loaded
> [348681.698686] Pid: 5853, comm: rpc.mountd Tainted: G   M      N  2.6.32.12-0.7-default #1 ProLiant DL380 G7
> [348681.698690] RIP: 0010:[<ffff880bfbf20008>]  [<ffff880bfbf20008>] 0xffff880bfbf20008
> [348681.698698] RSP: 0018:ffff880bfbd59c50  EFLAGS: 00010246
> [348681.698702] RAX: ffff880bfb437cd0 RBX: 0000000000000063 RCX: ffff880bfbd59c58
> [348681.698706] RDX: ffff880bfbd59c58 RSI: 0000000000000000 RDI: ffff880bfb437cd0
> [348681.698710] RBP: ffff880b02fde8c0 R08: ffff880bfbcd2288 R09: 0000000000000000
> [348681.698714] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880bfbd59c58
> [348681.698718] R13: ffff880b02fde8c0 R14: ffff880bfbd59df4 R15: ffff880bfbd59d08
> [348681.698723] FS:  00007fa2461a7740(0000) GS:ffff880635560000(0000) knlGS:0000000000000000
> [348681.698727] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [348681.698731] CR2: ffff880bfbf20008 CR3: 0000000c027ff000 CR4: 00000000000006e0
> [348681.698736] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [348681.698740] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [348681.698745] Process rpc.mountd (pid: 5853, threadinfo ffff880bfbd58000, task ffff880bfbcba400)
> [348681.698749] Stack:
> [348681.698751]  ffffffffa05a6883 ffff880bfbd59c58 ffff880bfbd59c58 ffff880b02fde8c0
> [348681.698756] <0> ffffffffa05b9740 00000000000559d8 ffffffffa05a725d 0000000000000004
> [348681.698762] <0> 00000000000000cf ffffffffa05b9740 ffffffffa05a87ab ffffffffa05b9758
> [348681.698769] Call Trace:
> [348681.698787] BUG: unable to handle kernel NULL pointer dereference at 0000000000000005
> [348681.698793] IP: [<ffffffff8107e540>] processCFI+0xa0/0x630
> [348681.698801] PGD 0
> [348681.698804] Oops: 0000 [#2] SMP
> [348681.698807] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:03.0/enable
> [348681.698812] CPU 23
> [348681.698814] Modules linked in: iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 mptctl mptbase af_packet nfsd exportfs iptable_filter ip_tables x_tables nfs lockd fscache nfs_acl auth_rpcgss sunrpc bonding kcopy(N) rdma_ucm rds_tcp(N) rds_rdma(N) rds(N) ib_sdp(N) rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_usa(N) ib_sa ib_uverbs ib_umad iw_nes crc32c libcrc32c iw_cxgb3 cxgb3 cpufreq_conservative cpufreq_userspace cpufreq_powersave pcc_cpufreq ib_qib(N) mlx4_ib mlx4_core ib_mthca microcode binfmt_misc ipv6 fuse loop dm_mod dca ib_mad sg ib_core rtc_cmos iTCO_wdt tpm_tis hpilo iTCO_vendor_support sr_mod tpm bnx2 rtc_core hpwdt serio_raw joydev pcspkr tpm_bios cdrom rtc_lib power_meter button container usbhid hid uhci_hcd ehci_hcd usbcore edd ext3 mbcache jbd fan ide_pci_generic ide_core ata_generic ata_piix libata thermal processor thermal_sys hwmon cciss scsi_mod
> [348681.698890] Supported: No, Unsupported modules are loaded
> [348681.698895] Pid: 5853, comm: rpc.mountd Tainted: G   M      N  2.6.32.12-0.7-default #1 ProLiant DL380 G7
> [348681.698899] RIP: 0010:[<ffffffff8107e540>]  [<ffffffff8107e540>] processCFI+0xa0/0x630
> [348681.698906] RSP: 0018:ffff880bfbd594a8  EFLAGS: 00010097
> [348681.698910] RAX: 0000000b00000001 RBX: ffff880bfbd59668 RCX: 00000000ffffffff
> [348681.698914] RDX: 0000000b00000003 RSI: 0000000affffffff RDI: 0000000000000005
> [348681.698918] RBP: 0000000affffffff R08: ffff880bfbd59668 R09: ffffffff81529d17
> [348681.698922] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880bfbd594e8
> [348681.698926] R13: ffff880bfbd59668 R14: 0000000000000001 R15: 0000000000000000
> [348681.698930] FS:  00007fa2461a7740(0000) GS:ffff880635560000(0000) knlGS:0000000000000000
> [348681.698935] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [348681.698938] CR2: 0000000000000005 CR3: 0000000c027ff000 CR4: 00000000000006e0
> [348681.698943] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [348681.698947] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [348681.698951] Process rpc.mountd (pid: 5853, threadinfo ffff880bfbd58000, task ffff880bfbcba400)
> [348681.698955] Stack:
> [348681.698957]  6662663230303038 0000000b00000001 0000000b00000003 ffffffffeb8f0490
> [348681.698962] <0> 0000000000000005 ffff880bfbd59698 ffff880bfbd596a8 ffffffff811c5c23
> [348681.698967] <0> 0000000000000005 ffff880602aef1d0 ffff880bfbd59520 ffff880bfbd59668
> [348681.698974] Call Trace:
> [348681.698985]  [<ffffffff8107e4e1>] processCFI+0x41/0x630
> [348681.698992]  [<ffffffff8107ed0e>] unwind+0xee/0x1130
> [348681.699001]  [<ffffffff810072e4>] dump_trace_unwind+0xa4/0xe0
> [348681.699008]  [<ffffffff810073c7>] try_stack_unwind+0xa7/0x1c0
> [348681.699014]  [<ffffffff810061dc>] dump_trace+0x6c/0x2d0
> [348681.699021]  [<ffffffff81005e7f>] show_stack_log_lvl+0xef/0x160
> [348681.699027]  [<ffffffff81005fe4>] show_registers+0xf4/0x280
> [348681.699036]  [<ffffffff81397f74>] __die+0xb4/0x100
> [348681.699045]  [<ffffffff8102d72a>] no_context+0xca/0x1a0
> [348681.699052]  [<ffffffff8102d955>] __bad_area_nosemaphore+0x155/0x230
> [348681.699058]  [<ffffffff813972ef>] page_fault+0x1f/0x30
> [348681.699066]  [<ffff880bfbf20008>] 0xffff880bfbf20008
> [348681.699073] DWARF2 unwinder stuck at 0xffff880bfbf20008
> [348681.699077]
> [348681.699079] Leftover inexact backtrace:
> [348681.699080]
> [348681.699100]  [<ffffffffa05a6883>] ? cache_revisit_request+0xf3/0x110 [sunrpc]
> [348681.699116]  [<ffffffffa05a725d>] ? cache_fresh_unlocked+0x3d/0x60 [sunrpc]
> [348681.699131]  [<ffffffffa05a87ab>] ? sunrpc_cache_update+0xab/0x240 [sunrpc]
> [348681.699146]  [<ffffffffa05a27b9>] ? ip_map_update+0x149/0x1b0 [sunrpc]
> [348681.699161]  [<ffffffffa05a2cf1>] ? ip_map_parse+0x221/0x2a0 [sunrpc]
> [348681.699169]  [<ffffffff811a581d>] ? apparmor_dentry_open+0x6d/0x130
> [348681.699175]  [<ffffffff810b422b>] ? find_get_page+0x1b/0xb0
> [348681.699189]  [<ffffffffa05a628d>] ? cache_do_downcall+0x3d/0x60 [sunrpc]
> [348681.699204]  [<ffffffffa05a6f9b>] ? cache_downcall+0xbb/0x110 [sunrpc]
> [348681.699219]  [<ffffffffa05a7058>] ? cache_write+0x68/0xa0 [sunrpc]
> [348681.699226]  [<ffffffff81150927>] ? proc_reg_write+0x77/0xc0
> [348681.699232]  [<ffffffff810fc74e>] ? vfs_write+0xce/0x140
> [348681.699237]  [<ffffffff810fc8c3>] ? sys_write+0x53/0xa0
> [348681.699243]  [<ffffffff81002f7b>] ? system_call_fastpath+0x16/0x1b
> [348681.699246] Code: 7c 24 20 4c 8d 64 24 40 48 89 54 24 28 48 89 44 24 30 48 8d 55 04 48 8d 45 02 48 89 54 24 10 48 89 44 24 08 0f 1f 80 00 00 00 00 <0f> b6 07 89 c1 c0 e9 06 80 f9 01 0f 84 3f 01 00 00 0f 83 a9 00
> [348681.699280] RIP  [<ffffffff8107e540>] processCFI+0xa0/0x630
> [348681.699286]  RSP <ffff880bfbd594a8>
> [348681.699288] CR2: 0000000000000005
> [348681.699293] ---[ end trace 9cf7876bf6b9d794 ]---
> [355628.412154] nfsd: last server has exited, flushing export cache
> ---
> 
> Best regards
> 
> Emil Assarsson
> Sony Ericsson Mobile Communications AB
> 
> "The information in this email, and attachment(s) thereto, is strictly confidential and may be legally privileged. It is intended solely for the named recipient(s), and access to this e-mail, or any attachment(s) thereto, by anyone else is unauthorized. Violations hereof may result in legal actions. Any attachment(s) to this e-mail has been checked for viruses, but please rely on your own virus-checker and procedures. If you contact us by e-mail, we will store your name and address to facilitate communications in the matter concerned. If you do not consent to us storing your name and address for above stated purpose, please notify the sender promptly. Also, if you are not the intended recipient please inform the sender by replying to this transmission, and delete the e-mail, its attachment(s), and any copies of it without, disclosing it."
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
