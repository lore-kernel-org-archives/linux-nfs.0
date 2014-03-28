Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26250 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaC1Waq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2014 18:30:46 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Kernel oops/panic with NFS over RDMA mount after disrupted Infiniband connection
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5335440A.9030207@ims.co.at>
Date: Fri, 28 Mar 2014 15:30:33 -0700
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3FF5D87A-8199-4CE1-BF97-82DC61E4F480@oracle.com>
References: <5332D425.3030803@ims.co.at> <4E6350BB-5E9C-40D9-8624-6CAA78E5B902@oracle.com> <lh0le0$u5$1@ger.gmane.org> <B7D4A29C-5E1F-4B6C-A8FC-C46D8DF6A87D@oracle.com> <5335440A.9030207@ims.co.at>
To: Senn Klemens <klemens.senn@ims.co.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 28, 2014, at 2:42 AM, Senn Klemens <klemens.senn@ims.co.at> wrote:

> Hi Chuck,
> 
> On 03/27/2014 04:59 PM, Chuck Lever wrote:
>> Hi-
>> 
>> 
>> On Mar 27, 2014, at 12:53 AM, Reiter Rafael <rafael.reiter@ims.co.at> wrote:
>> 
>>> On 03/26/2014 07:15 PM, Chuck Lever wrote:
>>>> 
>>>> Hi Rafael-
>>>> 
>>>> I’ll take a look. Can you report your HCA and how you reproduce this issue?
>>> 
>>> The HCA is Mellanox Technologies MT26428.
>>> 
>>> Reproduction:
>>> 1) Mount a directory via NFS/RDMA
>>> mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
> 
> An additional "ls /mnt" is needed here (between step 1 and 2)
> 
>>> 2) Pull the Infiniband cable or use ibportstate to disrupt the Infiniband connection
>>> 3) ls /mnt
>>> 4) wait 5-30 seconds
>> 
>> Thanks for the information.
>> 
>> I have that HCA, but I won’t have access to my test systems for a week (traveling). So can you try this:
>> 
>> # rpcdebug -m rpc -s trans
>> 
>> then reproduce (starting with step 1 above). Some debugging output will appear at the tail of /var/log/messages. Copy it to this thread.
>> 
> 
> The output of /var/log/messages is:
> 
> [  143.233701] RPC:  1688 xprt_rdma_allocate: size 1112 too large for
> buffer[1024]: prog 100003 vers 4 proc 1
> [  143.233708] RPC:  1688 xprt_rdma_allocate: size 1112, request
> 0xffff88105894c000
> [  143.233715] RPC:  1688 rpcrdma_inline_pullup: pad 0 destp
> 0xffff88105894d7dc len 124 hdrlen 124
> [  143.233718] RPC:       rpcrdma_register_frmr_external: Using frmr
> ffff88084e589260 to map 1 segments
> [  143.233722] RPC:  1688 rpcrdma_create_chunks: reply chunk elem
> 652@0x105894d92c:0xced01 (last)
> [  143.233725] RPC:  1688 rpcrdma_marshal_req: reply chunk: hdrlen 48
> rpclen 124 padlen 0 headerp 0xffff88105894d100 base 0xffff88105894d760
> lkey 0x8000
> [  143.233785] RPC:       rpcrdma_event_process: event rep
> ffff88084e589260 status 0 opcode 8 length 0
> [  177.272397] RPC:       rpcrdma_event_process: event rep
> (null) status C opcode FFFF8808 length 4294967295
> [  177.272649] RPC:       rpcrdma_event_process: event rep
> ffff880848ed0000 status 5 opcode FFFF8808 length 4294936584

The mlx4 provider is returning a WC completion status of
IB_WC_WR_FLUSH_ERR.

> [  177.272651] RPC:       rpcrdma_event_process: WC opcode -30712 status
> 5, connection lost

-30712 is a bogus WC opcode. So the mlx4 provider is not filling in the
WC opcode. rpcrdma_event_process() thus can’t depend on the contents of
the ib_wc.opcode field when the WC completion status != IB_WC_SUCCESS.

A copy of the opcode reachable from the incoming rpcrdma_rep could be
added, initialized in the forward paths. rpcrdma_event_process() could
use the copy in the error case.


> [  177.984996] RPC:  1689 xprt_rdma_allocate: size 436, request
> 0xffff880848f00000
> [  182.290655] RPC:       xprt_rdma_connect_worker: reconnect
> [  182.290992] RPC:       rpcrdma_ep_disconnect: after wait, disconnected
> [  187.300726] RPC:       xprt_rdma_connect_worker: exit
> [  197.320527] RPC:       xprt_rdma_connect_worker: reconnect
> [  197.320795] RPC:       rpcrdma_ep_disconnect: after wait, disconnected
> [  202.330477] RPC:       xprt_rdma_connect_worker: exit
> [  222.354286] RPC:       xprt_rdma_connect_worker: reconnect
> [  222.354624] RPC:       rpcrdma_ep_disconnect: after wait, disconnected
> 
> 
> The output on the serial terminal is:
> 
> [  227.364376] kernel tried to execute NX-protected page - exploit
> attempt? (uid: 0)
> [  227.364517] RPC:  1689 rpcrdma_inline_pullup: pad 0 destp
> 0xffff880848f017c4 len 100 hdrlen 100
> [  227.364519] RPC:       rpcrdma_register_frmr_external: Using frmr
> ffff88084e588810 to map 1 segments
> [  227.364522] RPC:  1689 rpcrdma_create_chunks: reply chunk elem
> 152@0x848f0187c:0xcab01 (last)
> [  227.364523] RPC:  1689 rpcrdma_marshal_req: reply chunk: hdrlen 48
> rpclen 100 padlen 0 headerp 0xffff880848f01100 base 0xffff880848f01760
> lkey 0x8000
> [  227.411547] BUG: unable to handle kernel paging request at
> ffff880848ed1758
> [  227.418535] IP: [<ffff880848ed1758>] 0xffff880848ed1757
> [  227.423781] PGD 1d7c067 PUD 85d52f063 PMD 848f12063 PTE 8000000848ed1163
> [  227.430544] Oops: 0011 [#1] SMP
> [  227.433802] Modules linked in: auth_rpcgss oid_registry nfsv4
> xprtrdma cpuid af_packet 8021q garp stp llc rdma_ucm ib_ucm rdma_cm
> iw_cm ib_addr ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib ib_sa
> ib_mad ib_core joydev usbhid mlx4_core iTCO_wdt iTCO_vendor_support
> acpi_cpufreq coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel
> aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64
> microcode pcspkr sb_edac edac_core i2c_i801 isci sg libsas ehci_pci
> ehci_hcd scsi_transport_sas usbcore lpc_ich ioatdma mfd_core usb_common
> shpchp pci_hotplug wmi mperf processor thermal_sys button edd autofs4
> xfs libcrc32c nfsv3 nfs fscache lockd nfs_acl sunrpc igb dca
> i2c_algo_bit ptp pps_core
> [  227.496536] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 3.10.17-allpatches+ #1
> [  227.503583] Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0
> 09/04/2013
> [  227.510451] task: ffffffff81a11440 ti: ffffffff81a00000 task.ti:
> ffffffff81a00000
> [  227.517924] RIP: 0010:[<ffff880848ed1758>]  [<ffff880848ed1758>]
> 0xffff880848ed1757
> [  227.525597] RSP: 0018:ffff88087fc03e88  EFLAGS: 00010282
> [  227.530903] RAX: 0000000000000286 RBX: ffff880848ed1758 RCX:
> ffffffffa0354360
> [  227.538032] RDX: ffff88084e589280 RSI: 0000000000000286 RDI:
> ffff88084e589260
> [  227.545157] RBP: ffff88087fc03ea0 R08: ffffffffa0354360 R09:
> 00000000000005f0
> [  227.552286] R10: 0000000000000003 R11: dead000000100100 R12:
> ffff88084e589260
> [  227.559412] R13: 0000000000000006 R14: 0000000000000006 R15:
> ffffffff81a5db90
> [  227.566540] FS:  0000000000000000(0000) GS:ffff88087fc00000(0000)
> knlGS:0000000000000000
> [  227.574620] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  227.580360] CR2: ffff880848ed1758 CR3: 0000000001a0c000 CR4:
> 00000000000407f0
> [  227.587487] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  227.594614] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  227.601742] Stack:
> [  227.603754]  ffffffffa034edde ffffffffa0354388 0000000000000000
> ffff88087fc03ec0
> [  227.611210]  ffffffff81049c82 0000000000000001 ffffffff81a050b0
> ffff88087fc03f30
> [  227.618666]  ffffffff81049870 ffffffff81a01fd8 00000000ffffb895
> 0000000000202000
> [  227.626123] Call Trace:
> [  227.628569]  <IRQ>
> [  227.630493]  [<ffffffffa034edde>] ? rpcrdma_run_tasklet+0x7e/0xc0
> [xprtrdma]
> [  227.637764]  [<ffffffff81049c82>] tasklet_action+0x52/0xc0
> [  227.643249]  [<ffffffff81049870>] __do_softirq+0xe0/0x220
> [  227.648643]  [<ffffffff8155cbac>] call_softirq+0x1c/0x30
> [  227.653957]  [<ffffffff8100452d>] do_softirq+0x4d/0x80
> [  227.659097]  [<ffffffff81049b05>] irq_exit+0x95/0xa0
> [  227.664056]  [<ffffffff8100411e>] do_IRQ+0x5e/0xd0
> [  227.668847]  [<ffffffff81553eaa>] common_interrupt+0x6a/0x6a
> [  227.674503]  <EOI>
> [  227.676429]  [<ffffffff8141de86>] ? cpuidle_enter_state+0x56/0xd0
> [  227.682733]  [<ffffffff8141de82>] ? cpuidle_enter_state+0x52/0xd0
> [  227.688819]  [<ffffffff8141dfb6>] cpuidle_idle_call+0xb6/0x200
> [  227.694649]  [<ffffffff8100aa39>] arch_cpu_idle+0x9/0x20
> [  227.699963]  [<ffffffff81087cc0>] cpu_startup_entry+0x80/0x200
> [  227.705799]  [<ffffffff815358a2>] rest_init+0x72/0x80
> [  227.710854]  [<ffffffff81ac4e28>] start_kernel+0x3b2/0x3bf
> [  227.716341]  [<ffffffff81ac4875>] ? repair_env_string+0x5e/0x5e
> [  227.722261]  [<ffffffff81ac45a5>] x86_64_start_reservations+0x2a/0x2c
> [  227.728696]  [<ffffffff81ac4675>] x86_64_start_kernel+0xce/0xd2
> [  227.734607] Code: 88 ff ff 07 a4 34 a0 ff ff ff ff 00 10 91 7b 10 88
> ff ff 26 00 26 00 10 00 00 00 00 01 00 00 00 00 00 00 20 00 00 00 00 00
> 00 00 <00> 88 58 4e 08 88 ff ff 78 92 58 4e 08 88 ff ff 01 00 00 00 00
> [  227.754568] RIP  [<ffff880848ed1758>] 0xffff880848ed1757
> [  227.759898]  RSP <ffff88087fc03e88>
> [  227.763386] CR2: ffff880848ed1758
> [  227.766699] ---[ end trace 264f2f21a7499134 ]---
> [  227.772473] Kernel panic - not syncing: Fatal exception in interrupt
> [  227.779954] ------------[ cut here ]------------
> [  227.784570] WARNING: at arch/x86/kernel/smp.c:123
> native_smp_send_reschedule+0x56/0x60()
> [  227.792657] Modules linked in: auth_rpcgss oid_registry nfsv4
> xprtrdma cpuid af_packet 8021q garp stp llc rdma_ucm ib_ucm rdma_cm
> iw_cm ib_addr ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib ib_sa
> ib_mad ib_core joydev usbhid mlx4_core iTCO_wdt iTCO_vendor_support
> acpi_cpufreq coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel
> aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64
> microcode pcspkr sb_edac edac_core i2c_i801 isci sg libsas ehci_pci
> ehci_hcd scsi_transport_sas usbcore lpc_ich ioatdma mfd_core usb_common
> shpchp pci_hotplug wmi mperf processor thermal_sys button edd autofs4
> xfs libcrc32c nfsv3 nfs fscache lockd nfs_acl sunrpc igb dca
> i2c_algo_bit ptp pps_core
> [  227.855155] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D
> 3.10.17-allpatches+ #1
> [  227.863147] Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0
> 09/04/2013
> [  227.870014]  0000000000000009 ffff88087fc03850 ffffffff8154de8a
> ffff88087fc03890
> [  227.877471]  ffffffff81041d3b ffff88105d9bff30 0000000000000001
> 0000000000000001
> [  227.884927]  00000000ffffb8fb ffff88087fc33380 0000000000000000
> ffff88087fc038a0
> [  227.892385] Call Trace:
> [  227.894830]  <IRQ>  [<ffffffff8154de8a>] dump_stack+0x19/0x1b
> [  227.900597]  [<ffffffff81041d3b>] warn_slowpath_common+0x6b/0xa0
> [  227.906596]  [<ffffffff81041d85>] warn_slowpath_null+0x15/0x20
> [  227.912422]  [<ffffffff81024046>] native_smp_send_reschedule+0x56/0x60
> [  227.918944]  [<ffffffff8107f084>] trigger_load_balance+0x174/0x210
> [  227.925127]  [<ffffffff81073715>] scheduler_tick+0x105/0x140
> [  227.930789]  [<ffffffff81051e62>] update_process_times+0x62/0x80
> [  227.936796]  [<ffffffff81091219>] tick_sched_handle.isra.10+0x29/0x70
> [  227.943238]  [<ffffffff810913a7>] tick_sched_timer+0x47/0x70
> [  227.948891]  [<ffffffff81068bea>] __run_hrtimer+0x6a/0x1b0
> [  227.954371]  [<ffffffff81091360>] ? tick_sched_do_timer+0x30/0x30
> [  227.960467]  [<ffffffff810694df>] hrtimer_interrupt+0xff/0x230
> [  227.966303]  [<ffffffff810250a4>] smp_apic_timer_interrupt+0x64/0xa0
> [  227.972658]  [<ffffffff8155c53a>] apic_timer_interrupt+0x6a/0x70
> [  227.978665]  [<ffffffff8154980f>] ? panic+0x181/0x1bf
> [  227.983712]  [<ffffffff81549779>] ? panic+0xeb/0x1bf
> [  227.988681]  [<ffffffff81554bca>] oops_end+0xda/0xe0
> [  227.993647]  [<ffffffff815490f9>] no_context+0x24e/0x279
> [  227.998955]  [<ffffffff815492d9>] __bad_area_nosemaphore+0x1b5/0x1d4
> [  228.005310]  [<ffffffff8104394f>] ? wake_up_klogd+0x2f/0x40
> [  228.010876]  [<ffffffff81549306>] bad_area_nosemaphore+0xe/0x10
> [  228.016791]  [<ffffffff81557406>] __do_page_fault+0x396/0x4e0
> [  228.022548]  [<ffffffffa02939d1>] ? mlx4_ib_poll_cq+0x91/0xe0 [mlx4_ib]
> [  228.029164]  [<ffffffff81557559>] do_page_fault+0x9/0x10
> [  228.034477]  [<ffffffff815540b2>] page_fault+0x22/0x30
> [  228.039611]  [<ffffffffa034edde>] ? rpcrdma_run_tasklet+0x7e/0xc0
> [xprtrdma]
> [  228.046659]  [<ffffffff81049c82>] tasklet_action+0x52/0xc0
> [  228.052140]  [<ffffffff81049870>] __do_softirq+0xe0/0x220
> [  228.057542]  [<ffffffff8155cbac>] call_softirq+0x1c/0x30
> [  228.062856]  [<ffffffff8100452d>] do_softirq+0x4d/0x80
> [  228.067989]  [<ffffffff81049b05>] irq_exit+0x95/0xa0
> [  228.072958]  [<ffffffff8100411e>] do_IRQ+0x5e/0xd0
> [  228.077752]  [<ffffffff81553eaa>] common_interrupt+0x6a/0x6a
> [  228.083411]  <EOI>  [<ffffffff8141de86>] ? cpuidle_enter_state+0x56/0xd0
> [  228.090133]  [<ffffffff8141de82>] ? cpuidle_enter_state+0x52/0xd0
> [  228.096220]  [<ffffffff8141dfb6>] cpuidle_idle_call+0xb6/0x200
> [  228.102055]  [<ffffffff8100aa39>] arch_cpu_idle+0x9/0x20
> [  228.107362]  [<ffffffff81087cc0>] cpu_startup_entry+0x80/0x200
> [  228.113197]  [<ffffffff815358a2>] rest_init+0x72/0x80
> [  228.118250]  [<ffffffff81ac4e28>] start_kernel+0x3b2/0x3bf
> [  228.123731]  [<ffffffff81ac4875>] ? repair_env_string+0x5e/0x5e
> [  228.129644]  [<ffffffff81ac45a5>] x86_64_start_reservations+0x2a/0x2c
> [  228.136078]  [<ffffffff81ac4675>] x86_64_start_kernel+0xce/0xd2
> [  228.141998] ---[ end trace 264f2f21a7499135 ]---
> [  228.146625] RPC:       rpcrdma_event_process: event rep
> ffff88084e588810 status 5 opcode 0 length 4294936584
> [  228.156443] RPC:       rpcrdma_event_process: WC opcode 0 status 5,
> connection lost
> [  228.164091] RPC:       rpcrdma_event_process: event rep
> (null) status 5 opcode 0 length 4294936584
> [  228.173906] RPC:       rpcrdma_event_process: event rep
> ffff880848ed0000 status 5 opcode 0 length 4294936584
> [  228.183721] RPC:       rpcrdma_event_process: WC opcode 0 status 5,
> connection lost
> 
>>> 
>>>> 
>>>> Do you (or does anyone) know whether OpenSuSE uses the stock upstream providers, or has any of OFED been applied to this kernel?
>>> 
>>> My first post was misleading -- I use the vanilla 3.10.17 kernel, and the error occurs with and without Mellanox OFED. The above report
>>> references the vanilla kernel.
>>> 
>>> Rafael
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> Regards,
> Klemens
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



