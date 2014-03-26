Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:30873 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbaCZSPb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Mar 2014 14:15:31 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Kernel oops/panic with NFS over RDMA mount after disrupted Infiniband connection
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5332D425.3030803@ims.co.at>
Date: Wed, 26 Mar 2014 11:15:22 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <4E6350BB-5E9C-40D9-8624-6CAA78E5B902@oracle.com>
References: <5332D425.3030803@ims.co.at>
To: "rafael.reiter" <rafael.reiter@ims.co.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 26, 2014, at 6:20 AM, rafael.reiter <rafael.reiter@ims.co.at> wrote:

> Hello,
> 
> I am looking into a problem with NFS/RDMA with openSuse 12.3 and the 3.10.17 kernel. The following kernel oops, followed by a kernel panic, occurs on
> the client computer after 5-30 seconds when the connection between NFS server and client is disrupted (e.g. by pulling the Infiniband cable on the
> server or using ibportstate to disable the port on the client) and the mounted directory is accessed (cd, ls).
> 
> 
> The export on the server side is done with
> /data
> 172.16.100.0/24(rw,wdelay,crossmnt,insecure,no_root_squash,no_subtree_check,fsid=0,mountpoint)
> 
> Following command is used for mounting the NFSv4 share:
>  mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
> 
> 
> [ 3336.995934] kernel tried to execute NX-protected page - exploit attempt?
> (uid: 0)
> [ 3337.003415] BUG: unable to handle kernel paging request at ffff880842900768
> [ 3337.010404] IP: [<ffff880842900768>] 0xffff880842900767
> [ 3337.015658] PGD 1d7c067 PUD 85d4e1063 PMD 842f48063 PTE 8000000842900163
> [ 3337.022420] Oops: 0011 [#1] SMP
> [ 3337.025681] Modules linked in: xprtrdma(O) auth_rpcgss oid_registry nfsv4
> cpuid af_packet 8021q garp stp llc rdma_ucm(O) ib_ucm(O) rdma_cm(O) iw_cm(O)
> ib_ipoib(O) ib_cm(O) ib_uverbs(O) ib_umad(O) mlx4_en(O) mlx4_ib(O) ib_sa(O)
> ib_mad(O) ib_core(O) ib_addr(O) sr_mod cdrom usb_storage nvidia(PO) joydev
> usbhid mlx4_core(O) compat(O) adm1021 lm90 coretemp nouveau kvm_intel kvm
> crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul
> glue_helper aes_x86_64 acpi_cpufreq iTCO_wdt iTCO_vendor_support microcode
> pcspkr ttm drm_kms_helper sb_edac edac_core isci drm i2c_i801 libsas ehci_pci
> ehci_hcd scsi_transport_sas mxm_wmi sg video usbcore lpc_ich ioatdma mfd_core
> usb_common shpchp pci_hotplug wmi mperf processor thermal_sys button edd fuse
> autofs4 xfs libcrc32c nfsv3 nfs fscache lockd nfs_acl sunrpc igb dca
> i2c_algo_bit ptp pps_core
> [ 3337.102467] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P           O 3.10.17-ims2
> #2
> [ 3337.109863] Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0 09/04/2013
> [ 3337.116736] task: ffffffff81a11440 ti: ffffffff81a00000 task.ti:
> ffffffff81a00000
> [ 3337.124218] RIP: 0010:[<ffff880842900768>]  [<ffff880842900768>]
> 0xffff880842900767
> [ 3337.131892] RSP: 0018:ffff88087fc03e88  EFLAGS: 00010282
> [ 3337.137208] RAX: 0000000000000286 RBX: ffff880842900768 RCX: ffff88085e2454a0
> [ 3337.144335] RDX: ffff88085e2454a0 RSI: 0000000000000286 RDI: ffff88085e245480
> [ 3337.151463] RBP: ffff88087fc03ea0 R08: ffff88085e24b170 R09: 0000000000000040
> [ 3337.158588] R10: 0000000000000003 R11: dead000000100100 R12: ffff88085e245480
> [ 3337.165716] R13: 0000000000000006 R14: 0000000000000006 R15: ffffffff81a5db90
> [ 3337.172842] FS:  0000000000000000(0000) GS:ffff88087fc00000(0000)
> knlGS:0000000000000000
> [ 3337.180932] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3337.186671] CR2: ffff880842900768 CR3: 0000000001a0c000 CR4: 00000000000407f0
> [ 3337.193809] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 3337.200934] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 3337.208061] Stack:
> [ 3337.210073]  ffffffffa04f7cbe ffffffffa04fd388 0000000000000000
> ffff88087fc03ec0
> [ 3337.217530]  ffffffff81049c82 0000000000000001 ffffffff81a050b0
> ffff88087fc03f30
> [ 3337.224987]  ffffffff81049870 ffffffff81a01fd8 00000001000b940f
> 0000000000202000
> [ 3337.232443] Call Trace:
> [ 3337.234903]  <IRQ>
> [ 3337.236838]  [<ffffffffa04f7cbe>] ? rpcrdma_run_tasklet+0x7e/0xc0 [xprtrdma]
> [ 3337.244116]  [<ffffffff81049c82>] tasklet_action+0x52/0xc0
> [ 3337.249611]  [<ffffffff81049870>] __do_softirq+0xe0/0x220
> [ 3337.255014]  [<ffffffff8155cbac>] call_softirq+0x1c/0x30
> [ 3337.260335]  [<ffffffff8100452d>] do_softirq+0x4d/0x80
> [ 3337.265470]  [<ffffffff81049b05>] irq_exit+0x95/0xa0
> [ 3337.270437]  [<ffffffff8100411e>] do_IRQ+0x5e/0xd0
> [ 3337.275224]  [<ffffffff81553eaa>] common_interrupt+0x6a/0x6a
> [ 3337.280884]  <EOI>
> [ 3337.282809]  [<ffffffff81069090>] ? __hrtimer_start_range_ns+0x1c0/0x400
> [ 3337.289729]  [<ffffffff8141de86>] ? cpuidle_enter_state+0x56/0xd0
> [ 3337.295824]  [<ffffffff8141de82>] ? cpuidle_enter_state+0x52/0xd0
> [ 3337.301928]  [<ffffffff8141dfb6>] cpuidle_idle_call+0xb6/0x200
> [ 3337.307764]  [<ffffffff8100aa39>] arch_cpu_idle+0x9/0x20
> [ 3337.313087]  [<ffffffff81087cc0>] cpu_startup_entry+0x80/0x200
> [ 3337.318924]  [<ffffffff815358a2>] rest_init+0x72/0x80
> [ 3337.323984]  [<ffffffff81ac4e28>] start_kernel+0x3b2/0x3bf
> [ 3337.329464]  [<ffffffff81ac4875>] ? repair_env_string+0x5e/0x5e
> [ 3337.335386]  [<ffffffff81ac45a5>] x86_64_start_reservations+0x2a/0x2c
> [ 3337.341820]  [<ffffffff81ac4675>] x86_64_start_kernel+0xce/0xd2
> [ 3337.347732] Code: 88 ff ff e7 33 4f a0 ff ff ff ff 00 b0 dd 57 10 88 ff ff a9
> be a9 be 10 00 00 00 00 01 00 00 00 00 00 00 20 00 00 00 00 00 00 00 <d0> 35 24
> 5e 08 88 ff ff 98 54 24 5e 08 88 ff ff 02 00 00 00 00
> [ 3337.367691] RIP  [<ffff880842900768>] 0xffff880842900767
> [ 3337.373024]  RSP <ffff88087fc03e88>
> [ 3337.376510] CR2: ffff880842900768
> [ 3337.379829] ---[ end trace 3c331859b0aa6701 ]---
> [ 3337.385471] Kernel panic - not syncing: Fatal exception in interrupt
> [ 3337.392852] ------------[ cut here ]------------
> [ 3337.397477] general protection fault: 0000 [#2] SMP
> [ 3337.402476] Modules linked in: xprtrdma(O) auth_rpcgss oid_registry nfsv4
> cpuid af_packet 8021q garp stp llc rdma_ucm(O) ib_ucm(O) rdma_cm(O) iw_cm(O)
> ib_ipoib(O) ib_cm(O) ib_uverbs(O) ib_umad(O) mlx4_en(O) mlx4_ib(O) ib_sa(O)
> ib_mad(O) ib_core(O) ib_addr(O) sr_mod cdrom usb_storage nvidia(PO) joydev
> usbhid mlx4_core(O) compat(O) adm1021 lm90 coretemp nouveau kvm_intel kvm
> crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul
> glue_helper aes_x86_64 acpi_cpufreq iTCO_wdt iTCO_vendor_support microcode
> pcspkr ttm drm_kms_helper sb_edac edac_core isci drm i2c_i801 libsas ehci_pci
> ehci_hcd scsi_transport_sas mxm_wmi sg video usbcore lpc_ich ioatdma mfd_core
> usb_common shpchp pci_hotplug wmi mperf processor thermal_sys button edd fuse
> autofs4 xfs libcrc32c nfsv3 nfs fscache lockd nfs_acl sunrpc igb dca
> i2c_algo_bit ptp pps_core
> [ 3337.478881] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P      D    O 3.10.17-ims2
> #2
> [ 3337.486275] Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0 09/04/2013
> [ 3337.493142] task: ffffffff81a11440 ti: ffffffff81a00000 task.ti:
> ffffffff81a00000
> [ 3337.500624] RIP: 0010:[<ffffffff8102a5fb>]  [<ffffffff8102a5fb>]
> native_apic_msr_write+0x2b/0x30
> [ 3337.509425] RSP: 0018:ffff88087fc036f0  EFLAGS: 00010046
> [ 3337.514732] RAX: 00000000000000f6 RBX: 00000000000005a2 RCX: 000000000000083f
> [ 3337.521858] RDX: 0000000000000000 RSI: 00000000000000f6 RDI: 000000000000003f
> [ 3337.528987] RBP: ffff88087fc036f0 R08: 0000000000000000 R09: 00000000000005a2
> [ 3337.536113] R10: 0000000000000000 R11: 00000000000005a1 R12: 0000000000000046
> [ 3337.543240] R13: 0000000000000001 R14: 00000000000005a2 R15: 0000000000000006
> [ 3337.550367] FS:  0000000000000000(0000) GS:ffff88087fc00000(0000)
> knlGS:0000000000000000
> [ 3337.558447] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3337.564186] CR2: ffff880842900768 CR3: 0000000001a0c000 CR4: 00000000000407f0
> [ 3337.571315] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 3337.578442] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 3337.585568] Stack:
> [ 3337.587589]  ffff88087fc03700 ffffffff8102a4d8 ffff88087fc03710
> ffffffff810064d6
> [ 3337.595045]  ffff88087fc03720 ffffffff810ef9d9 ffff88087fc03730
> ffffffff8104394f
> [ 3337.602502]  ffff88087fc03770 ffffffff81043b65 0000000000000000
> 0000000000000001
> [ 3337.609957] Call Trace:
> [ 3337.612403]  <IRQ>
> [ 3337.614328]  [<ffffffff8102a4d8>] x2apic_send_IPI_self+0x18/0x20
> [ 3337.620552]  [<ffffffff810064d6>] arch_irq_work_raise+0x26/0x40
> [ 3337.626475]  [<ffffffff810ef9d9>] irq_work_queue+0xa9/0xd0
> [ 3337.631963]  [<ffffffff8104394f>] wake_up_klogd+0x2f/0x40
> [ 3337.637356]  [<ffffffff81043b65>] console_unlock+0x205/0x3d0
> [ 3337.643010]  [<ffffffff81044115>] vprintk_emit+0x1c5/0x460
> [ 3337.648499]  [<ffffffff8107c46a>] ? enqueue_entity+0x37a/0x990
> [ 3337.654332]  [<ffffffff81024046>] ? native_smp_send_reschedule+0x56/0x60
> [ 3337.661027]  [<ffffffff815498a9>] printk+0x5c/0x5e
> [ 3337.665814]  [<ffffffff81024046>] ? native_smp_send_reschedule+0x56/0x60
> [ 3337.672516]  [<ffffffff81041d09>] warn_slowpath_common+0x39/0xa0
> [ 3337.678524]  [<ffffffff81041d85>] warn_slowpath_null+0x15/0x20
> [ 3337.684359]  [<ffffffff81024046>] native_smp_send_reschedule+0x56/0x60
> [ 3337.690887]  [<ffffffff8107f084>] trigger_load_balance+0x174/0x210
> [ 3337.697069]  [<ffffffff81073715>] scheduler_tick+0x105/0x140
> [ 3337.702731]  [<ffffffff81051e62>] update_process_times+0x62/0x80
> [ 3337.708738]  [<ffffffff81091219>] tick_sched_handle.isra.10+0x29/0x70
> [ 3337.715172]  [<ffffffff810913a7>] tick_sched_timer+0x47/0x70
> [ 3337.720827]  [<ffffffff81068bea>] __run_hrtimer+0x6a/0x1b0
> [ 3337.726307]  [<ffffffff81342c41>] ? erst_write+0xf1/0x220
> [ 3337.731708]  [<ffffffff81091360>] ? tick_sched_do_timer+0x30/0x30
> [ 3337.737795]  [<ffffffff810694df>] hrtimer_interrupt+0xff/0x230
> [ 3337.743637]  [<ffffffff810250a4>] smp_apic_timer_interrupt+0x64/0xa0
> [ 3337.749991]  [<ffffffff8155c53a>] apic_timer_interrupt+0x6a/0x70
> [ 3337.755993]  [<ffffffff8154980f>] ? panic+0x181/0x1bf
> [ 3337.761049]  [<ffffffff81549779>] ? panic+0xeb/0x1bf
> [ 3337.766023]  [<ffffffff81554bca>] oops_end+0xda/0xe0
> [ 3337.770991]  [<ffffffff815490f9>] no_context+0x24e/0x279
> [ 3337.776307]  [<ffffffff8148f7cb>] ? ip_rcv_finish+0x7b/0x340
> [ 3337.781961]  [<ffffffff815492d9>] __bad_area_nosemaphore+0x1b5/0x1d4
> [ 3337.788316]  [<ffffffff81549306>] bad_area_nosemaphore+0xe/0x10
> [ 3337.794229]  [<ffffffff81557406>] __do_page_fault+0x396/0x4e0
> [ 3337.799971]  [<ffffffff8145d6ac>] ? __netif_receive_skb+0x1c/0x70
> [ 3337.806067]  [<ffffffffa03c6c71>] ? mlx4_ib_poll_cq+0x91/0xe0 [mlx4_ib]
> [ 3337.812681]  [<ffffffffa04f5ff6>] ? rpcrdma_cq_event_upcall+0x246/0x5a0
> [xprtrdma]
> [ 3337.820249]  [<ffffffff81557559>] do_page_fault+0x9/0x10
> [ 3337.825556]  [<ffffffff815540b2>] page_fault+0x22/0x30
> [ 3337.830688]  [<ffffffffa04f7cbe>] ? rpcrdma_run_tasklet+0x7e/0xc0 [xprtrdma]
> [ 3337.837728]  [<ffffffff81049c82>] tasklet_action+0x52/0xc0
> [ 3337.843208]  [<ffffffff81049870>] __do_softirq+0xe0/0x220
> [ 3337.848603]  [<ffffffff8155cbac>] call_softirq+0x1c/0x30
> [ 3337.853916]  [<ffffffff8100452d>] do_softirq+0x4d/0x80
> [ 3337.859048]  [<ffffffff81049b05>] irq_exit+0x95/0xa0
> [ 3337.864007]  [<ffffffff8100411e>] do_IRQ+0x5e/0xd0
> [ 3337.868795]  [<ffffffff81553eaa>] common_interrupt+0x6a/0x6a
> [ 3337.874454]  <EOI>
> [ 3337.876380]  [<ffffffff81069090>] ? __hrtimer_start_range_ns+0x1c0/0x400
> [ 3337.883290]  [<ffffffff8141de86>] ? cpuidle_enter_state+0x56/0xd0
> [ 3337.889377]  [<ffffffff8141de82>] ? cpuidle_enter_state+0x52/0xd0
> [ 3337.895464]  [<ffffffff8141dfb6>] cpuidle_idle_call+0xb6/0x200
> [ 3337.901300]  [<ffffffff8100aa39>] arch_cpu_idle+0x9/0x20
> [ 3337.906613]  [<ffffffff81087cc0>] cpu_startup_entry+0x80/0x200
> [ 3337.912442]  [<ffffffff815358a2>] rest_init+0x72/0x80
> [ 3337.917495]  [<ffffffff81ac4e28>] start_kernel+0x3b2/0x3bf
> [ 3337.922974]  [<ffffffff81ac4875>] ? repair_env_string+0x5e/0x5e
> [ 3337.928888]  [<ffffffff81ac45a5>] x86_64_start_reservations+0x2a/0x2c
> [ 3337.935323]  [<ffffffff81ac4675>] x86_64_start_kernel+0xce/0xd2
> [ 3337.941243] Code: 55 83 ff 20 48 89 e5 74 24 81 ff e0 00 00 00 74 1c 83 ff 30
> 74 17 81 ff d0 00 00 00 74 0f c1 ef 04 31 d2 89 f0 8d 8f 00 08 00 00 <0f> 30 5d
> c3 90 55 81 ff e0 00 00 00 b8 ff ff ff ff 48 89 e5 74
> [ 3337.961200] RIP  [<ffffffff8102a5fb>] native_apic_msr_write+0x2b/0x30
> [ 3337.967653]  RSP <ffff88087fc036f0>
> [ 3337.971139] ---[ end trace 3c331859b0aa6702 ]---
> 
> As deductable from rpcrdma_run_tasklet+0x7e, the problem lies in net/sunrpc/xprtrdma/verbs.c:95:
> 
>  77 static void
>  78 rpcrdma_run_tasklet(unsigned long data)
>  79 {
>  80         struct rpcrdma_rep *rep;
>  81         void (*func)(struct rpcrdma_rep *);
>  82         unsigned long flags;
>  83
>  84         data = data;
>  85         spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
>  86         while (!list_empty(&rpcrdma_tasklets_g)) {
>  87                 rep = list_entry(rpcrdma_tasklets_g.next,
>  88                                  struct rpcrdma_rep, rr_list);
>  89                 list_del(&rep->rr_list);
>  90                 func = rep->rr_func;
>  91                 rep->rr_func = NULL;
>  92                 spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
>  93
>  94                 if (func)
>  95                         func(rep);
>  96                 else
>  97                         rpcrdma_recv_buffer_put(rep);
>  98
>  99                 spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
> 100         }
> 101         spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
> 102 }
> 
> func is a function pointer which, as far as I have seen, has the same value throughout normal operation, but as soon as the connection is lost
> (if-condition in 158 is true), rpcrdma_event_process schedules a tasklet which leads to a faulty pointer func with the value LIST_POISON1
> (0xdead000000100100):
> 
> 158         if (IB_WC_SUCCESS != wc->status) {
> 159                 dprintk("RPC:       %s: WC opcode %d status %X, connection lost\n",
> 160                         __func__, wc->opcode, wc->status);
> 161                 rep->rr_len = ~0U;
> 162                 if (wc->opcode != IB_WC_FAST_REG_MR && wc->opcode != IB_WC_LOCAL_INV)
> 163                         rpcrdma_schedule_tasklet(rep);
> 164                 return;
> 165         }
> 
> In normal operation, rpcrdma_schedule_tasklet is called if wc->opcode is IB_WC_RECV or IB_WC_BIND_MW (verbs.c, line 167-208). I adjusted the
> if-condition in 162 accordingly:
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..9bf8882 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -159,7 +159,7 @@ void rpcrdma_event_process(struct ib_wc *wc)
>                dprintk("RPC:       %s: WC opcode %d status %X, connection lost\n",
>                        __func__, wc->opcode, wc->status);
>                rep->rr_len = ~0U;
> -               if (wc->opcode != IB_WC_FAST_REG_MR && wc->opcode != IB_WC_LOCAL_INV)
> +               if (wc->opcode == IB_WC_RECV || wc->opcode == IB_WC_BIND_MW)
>                        rpcrdma_schedule_tasklet(rep);
>                return;
>        }
> 
> 
> This seems to fix the kernel oops/panic. I guess this is not the most elegant way, and I kindly ask you to improve on this.

Hi Rafael-

I’ll take a look. Can you report your HCA and how you reproduce this issue?

Do you (or does anyone) know whether OpenSuSE uses the stock upstream providers, or has any of OFED been applied to this kernel?


> As similar error is referenced briefly by Yan Burman in this posting from 02/18/2013 12:44 PM.
> 
> Please also consider my other post (which I will post later today) about a failure to reinstate the mount after a lost connection.


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



