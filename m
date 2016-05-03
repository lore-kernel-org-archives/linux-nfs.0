Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36809 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbcECTht (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 15:37:49 -0400
MIME-Version: 1.0
In-Reply-To: <13CA7D80-3F3D-4D92-9E52-1434BD8047DE@oracle.com>
References: <CAOMZO5D9dTFRbT0CMOdM3aGb1cLd+n8udQQH0K=onZ7Z-4onmw@mail.gmail.com>
	<13CA7D80-3F3D-4D92-9E52-1434BD8047DE@oracle.com>
Date: Tue, 3 May 2016 16:37:47 -0300
Message-ID: <CAOMZO5CMu=VbPn_n+ttK_pJUS+VoQueYQiyiMTCTR11FDeCWFg@mail.gmail.com>
Subject: Re: Cannot use NFS with linux-next 20160429
From: Fabio Estevam <festevam@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Sun, May 1, 2016 at 4:52 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Fabio-
>
>> On Apr 29, 2016, at 7:18 PM, Fabio Estevam <festevam@gmail.com> wrote:
>>
>> Hi,
>>
>> NFS is not working on a imx6q-sabresd board running linux-next 20160429:
>>
>> [   15.753317]   #0: wm8962-audio
>> [   15.759437] Root-NFS: no NFS server address
>
> At a glance, that looks like the NFSROOT mount options are
> invalid? First, confirm what is specified on the kernel
> cmdline.

Yes, the kernel command line is correct.

>
> I'm not aware of any recent changes to NFSROOT. Often
> these NFSROOT problems turn out to be related to churn in
> the underlying Ethernet drivers or the generic code that
> handles mounting the root filesystem at boot time.

Today's next shows some different info:

[    7.606456]   #0: wm8962-audio
[    7.672659] VFS: Mounted root (nfs filesystem) readonly on device 0:14.
[    7.680860] devtmpfs: mounted
[    7.685664] Freeing unused kernel memory: 1024K (c0c00000 - c0d00000)
[    7.871481]
[    7.873004] =================================
[    7.877381] [ INFO: inconsistent lock state ]
[    7.881760] 4.6.0-rc6-next-20160503-00002-g51d9962 #351 Not tainted
[    7.888043] ---------------------------------
[    7.892419] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[    7.898449] kworker/0:1H/179 [HC0[0]:SC0[0]:HE1:SE1] takes:
[    7.904040]  (&syncp->seq#5){+.?...}, at: [<c0752328>] tcp_ack+0x134/0x129c
[    7.911166] {IN-SOFTIRQ-W} state was registered at:
[    7.916061]   [<c016cc68>] lock_acquire+0x78/0x98
[    7.920816]   [<c074ccbc>] tcp_snd_una_update+0x64/0xa8
[    7.926092]   [<c0752328>] tcp_ack+0x134/0x129c
[    7.930668]   [<c0755de8>] tcp_rcv_state_process+0x814/0xfc8
[    7.936375]   [<c075e800>] tcp_v4_do_rcv+0x64/0x1c8
[    7.941305]   [<c07616c8>] tcp_v4_rcv+0xf00/0xfbc
[    7.946057]   [<c07374cc>] ip_local_deliver_finish+0xd4/0x550
[    7.951859]   [<c0737bc4>] ip_local_deliver+0xcc/0xdc
[    7.956957]   [<c0736d78>] ip_rcv_finish+0xc4/0x744
[    7.961881]   [<c073809c>] ip_rcv+0x4c8/0x7a8
[    7.966284]   [<c06fa448>] __netif_receive_skb_core+0x514/0x8ec
[    7.972251]   [<c06ff854>] __netif_receive_skb+0x2c/0x8c
[    7.977614]   [<c06ffb50>] netif_receive_skb_internal+0x7c/0x1f0
[    7.983666]   [<c0700e38>] napi_gro_receive+0x88/0xdc
[    7.988764]   [<c058fb4c>] fec_enet_rx_napi+0x390/0x9c8
[    7.994036]   [<c0700724>] net_rx_action+0x148/0x344
[    7.999046]   [<c012996c>] __do_softirq+0x130/0x2bc
[    8.003976]   [<c0129e40>] irq_exit+0xc4/0x138
[    8.008466]   [<c0177920>] __handle_domain_irq+0x74/0xe4
[    8.013838]   [<c01015d8>] gic_handle_irq+0x4c/0x9c
[    8.018763]   [<c010c4b8>] __irq_svc+0x58/0x78
[    8.023251]   [<c08f7db8>] _raw_spin_unlock_irq+0x30/0x34
[    8.028710]   [<c014a03c>] finish_task_switch+0xcc/0x274
[    8.034072]   [<c08f2728>] __schedule+0x23c/0x6f8
[    8.038823]   [<c08f2d0c>] schedule+0x3c/0xa0
[    8.043224]   [<c08f2f74>] schedule_preempt_disabled+0x10/0x14
[    8.049103]   [<c01663b0>] cpu_startup_entry+0x1f4/0x24c
[    8.054468]   [<c08f070c>] rest_init+0x12c/0x16c
[    8.059130]   [<c0c00cbc>] start_kernel+0x340/0x3b0
[    8.064059]   [<1000807c>] 0x1000807c
[    8.067767] irq event stamp: 3601
[    8.071099] hardirqs last  enabled at (3601): [<c08f7d74>]
_raw_spin_unlock_irqrestore+0x38/0x4c
[    8.079936] hardirqs last disabled at (3600): [<c08f7728>]
_raw_spin_lock_irqsave+0x24/0x54
[    8.088336] softirqs last  enabled at (3598): [<c06e9754>]
__release_sock+0x3c/0x124
[    8.096128] softirqs last disabled at (3596): [<c06e985c>]
release_sock+0x20/0xa4
[    8.103654]
[    8.103654] other info that might help us debug this:
[    8.110202]  Possible unsafe locking scenario:
[    8.110202]
[    8.116140]        CPU0
[    8.118601]        ----
[    8.121062]   lock(&syncp->seq#5);
[    8.124547]   <Interrupt>
[    8.127182]     lock(&syncp->seq#5);
[    8.130838]
[    8.130838]  *** DEADLOCK ***
[    8.130838]
[    8.136785] 3 locks held by kworker/0:1H/179:
[    8.141157]  #0:  ("rpciod"){.+.+.+}, at: [<c013e478>]
process_one_work+0x128/0x410
[    8.148965]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<c013e478>]
process_one_work+0x128/0x410
[    8.157630]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<c074af70>]
tcp_sendmsg+0x24/0xb5c
[    8.165859]
[    8.165859] stack backtrace:
[    8.170247] CPU: 0 PID: 179 Comm: kworker/0:1H Not tainted
4.6.0-rc6-next-20160503-00002-g51d9962 #351
[    8.179572] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[    8.186137] Workqueue: rpciod rpc_async_schedule
[    8.190791] Backtrace:
[    8.193307] [<c010b6f8>] (dump_backtrace) from [<c010b894>]
(show_stack+0x18/0x1c)
[    8.200894]  r6:60000193 r5:ffffffff r4:00000000 r3:eebdc800
[    8.206692] [<c010b87c>] (show_stack) from [<c03dfbf4>]
(dump_stack+0xb0/0xe8)
[    8.213961] [<c03dfb44>] (dump_stack) from [<c01c72d4>]
(print_usage_bug+0x268/0x2dc)
[    8.221809]  r8:00000004 r7:eebdcd00 r6:eebdc800 r5:c0ae4bbc
r4:c0ec6054 r3:eebdc800
[    8.229712] [<c01c706c>] (print_usage_bug) from [<c016ace0>]
(mark_lock+0x29c/0x6b0)
[    8.237472]  r10:c016a1c8 r8:00000004 r7:eebdc800 r6:00001054
r5:eebdcd00 r4:00000006
[    8.245456] [<c016aa44>] (mark_lock) from [<c016b644>]
(__lock_acquire+0x550/0x17c8)
[    8.253216]  r10:c0d21d9c r9:000002be r8:c0e97784 r7:eebdc800
r6:c153a09c r5:eebdcd00
[    8.261188]  r4:00000003 r3:00000001
[    8.264837] [<c016b0f4>] (__lock_acquire) from [<c016cc68>]
(lock_acquire+0x78/0x98)
[    8.272598]  r10:00000001 r9:c0752328 r8:2d738f6b r7:00000001
r6:c0752328 r5:60000113
[    8.280568]  r4:00000000
[    8.283155] [<c016cbf0>] (lock_acquire) from [<c074ccbc>]
(tcp_snd_una_update+0x64/0xa8)
[    8.291261]  r7:00000000 r6:ee6b9500 r5:ee6b9500 r4:ee6b99cc
[    8.297050] [<c074cc58>] (tcp_snd_una_update) from [<c0752328>]
(tcp_ack+0x134/0x129c)
[    8.304984]  r10:ee6b9570 r9:ee42f9c0 r8:2d738f6b r7:c0d02100
r6:00000002 r5:ee6b9500
[    8.312956]  r4:00000002
[    8.315542] [<c07521f4>] (tcp_ack) from [<c0754c08>]
(tcp_rcv_established+0x140/0x774)
[    8.323477]  r10:ee6b9570 r9:ee42f9c0 r8:c0d6bfb3 r7:c155a080
r6:ee6e9a62 r5:ee42f9c0
[    8.331448]  r4:ee6b9500
[    8.334039] [<c0754ac8>] (tcp_rcv_established) from [<c075e8fc>]
(tcp_v4_do_rcv+0x160/0x1c8)
[    8.342494]  r8:c0d6bfb3 r7:c155a080 r6:eea79600 r5:ee6b9500 r4:ee42f9c0
[    8.349348] [<c075e79c>] (tcp_v4_do_rcv) from [<c06e97ac>]
(__release_sock+0x94/0x124)
[    8.357281]  r6:00000000 r5:ee6b9500 r4:00000000 r3:c075e79c
[    8.363065] [<c06e9718>] (__release_sock) from [<c06e9870>]
(release_sock+0x34/0xa4)
[    8.370825]  r10:ee6b9500 r9:ee6c1ce4 r8:00000000 r7:00000080
r6:c074b1f0 r5:ee6b9570
[    8.378797]  r4:ee6b9500 r3:ee42f9c0
[    8.382448] [<c06e983c>] (release_sock) from [<c074b1f0>]
(tcp_sendmsg+0x2a4/0xb5c)
[    8.390122]  r6:00000080 r5:ee6b9500 r4:ee6c2000 r3:00000015
[    8.395922] [<c074af4c>] (tcp_sendmsg) from [<c077a824>]
(inet_sendmsg+0x128/0x200)
[    8.403596]  r10:c0d6c136 r9:ee6a4000 r8:ee6c1ce4 r7:00000080
r6:00000000 r5:c0d6c136
[    8.411565]  r4:ee6b9500
[    8.414161] [<c077a6fc>] (inet_sendmsg) from [<c06e41ec>]
(sock_sendmsg+0x1c/0x2c)
