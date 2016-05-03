Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59138 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519AbcECWb7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 18:31:59 -0400
Date: Wed, 4 May 2016 00:31:49 +0200
From: Francois Romieu <romieu@fr.zoreil.com>
To: Fabio Estevam <festevam@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Cannot use NFS with linux-next 20160429
Message-ID: <20160503223149.GA19739@electric-eye.fr.zoreil.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOMZO5CMu=VbPn_n+ttK_pJUS+VoQueYQiyiMTCTR11FDeCWFg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fabio Estevam <festevam@gmail.com> :
[...]
> Today's next shows some different info:
> 
> [    7.606456]   #0: wm8962-audio
> [    7.672659] VFS: Mounted root (nfs filesystem) readonly on device 0:14.
> [    7.680860] devtmpfs: mounted
> [    7.685664] Freeing unused kernel memory: 1024K (c0c00000 - c0d00000)
> [    7.871481]
> [    7.873004] =================================
> [    7.877381] [ INFO: inconsistent lock state ]
> [    7.881760] 4.6.0-rc6-next-20160503-00002-g51d9962 #351 Not tainted
> [    7.888043] ---------------------------------
> [    7.892419] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> [    7.898449] kworker/0:1H/179 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [    7.904040]  (&syncp->seq#5){+.?...}, at: [<c0752328>] tcp_ack+0x134/0x129c
> [    7.911166] {IN-SOFTIRQ-W} state was registered at:
> [    7.916061]   [<c016cc68>] lock_acquire+0x78/0x98
> [    7.920816]   [<c074ccbc>] tcp_snd_una_update+0x64/0xa8
> [    7.926092]   [<c0752328>] tcp_ack+0x134/0x129c
> [    7.930668]   [<c0755de8>] tcp_rcv_state_process+0x814/0xfc8
> [    7.936375]   [<c075e800>] tcp_v4_do_rcv+0x64/0x1c8
> [    7.941305]   [<c07616c8>] tcp_v4_rcv+0xf00/0xfbc
> [    7.946057]   [<c07374cc>] ip_local_deliver_finish+0xd4/0x550
> [    7.951859]   [<c0737bc4>] ip_local_deliver+0xcc/0xdc
> [    7.956957]   [<c0736d78>] ip_rcv_finish+0xc4/0x744
> [    7.961881]   [<c073809c>] ip_rcv+0x4c8/0x7a8
> [    7.966284]   [<c06fa448>] __netif_receive_skb_core+0x514/0x8ec
> [    7.972251]   [<c06ff854>] __netif_receive_skb+0x2c/0x8c
> [    7.977614]   [<c06ffb50>] netif_receive_skb_internal+0x7c/0x1f0
> [    7.983666]   [<c0700e38>] napi_gro_receive+0x88/0xdc
> [    7.988764]   [<c058fb4c>] fec_enet_rx_napi+0x390/0x9c8
> [    7.994036]   [<c0700724>] net_rx_action+0x148/0x344
> [    7.999046]   [<c012996c>] __do_softirq+0x130/0x2bc
[...]
> [    8.165859] stack backtrace:
> [    8.170247] CPU: 0 PID: 179 Comm: kworker/0:1H Not tainted
> 4.6.0-rc6-next-20160503-00002-g51d9962 #351
> [    8.179572] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [    8.186137] Workqueue: rpciod rpc_async_schedule
> [    8.190791] Backtrace:
> [    8.193307] [<c010b6f8>] (dump_backtrace) from [<c010b894>] > (show_stack+0x18/0x1c)
> [    8.200894]  r6:60000193 r5:ffffffff r4:00000000 r3:eebdc800
> [    8.206692] [<c010b87c>] (show_stack) from [<c03dfbf4>] (dump_stack+0xb0/0xe8)
> [    8.213961] [<c03dfb44>] (dump_stack) from [<c01c72d4>] (print_usage_bug+0x268/0x2dc)
> [    8.221809]  r8:00000004 r7:eebdcd00 r6:eebdc800 r5:c0ae4bbc r4:c0ec6054 r3:eebdc800
> [    8.229712] [<c01c706c>] (print_usage_bug) from [<c016ace0>] (mark_lock+0x29c/0x6b0)
> [    8.237472]  r10:c016a1c8 r8:00000004 r7:eebdc800 r6:00001054 r5:eebdcd00 r4:00000006
> [    8.245456] [<c016aa44>] (mark_lock) from [<c016b644>] (__lock_acquire+0x550/0x17c8)
> [    8.253216]  r10:c0d21d9c r9:000002be r8:c0e97784 r7:eebdc800 r6:c153a09c r5:eebdcd00
> [    8.261188]  r4:00000003 r3:00000001
> [    8.264837] [<c016b0f4>] (__lock_acquire) from [<c016cc68>] (lock_acquire+0x78/0x98)
> [    8.272598]  r10:00000001 r9:c0752328 r8:2d738f6b r7:00000001 r6:c0752328 r5:60000113
> [    8.280568]  r4:00000000
> [    8.283155] [<c016cbf0>] (lock_acquire) from [<c074ccbc>] (tcp_snd_una_update+0x64/0xa8)
> [    8.291261]  r7:00000000 r6:ee6b9500 r5:ee6b9500 r4:ee6b99cc
> [    8.297050] [<c074cc58>] (tcp_snd_una_update) from [<c0752328>] (tcp_ack+0x134/0x129c)
> [    8.304984]  r10:ee6b9570 r9:ee42f9c0 r8:2d738f6b r7:c0d02100 r6:00000002 r5:ee6b9500
> [    8.312956]  r4:00000002
> [    8.315542] [<c07521f4>] (tcp_ack) from [<c0754c08>] (tcp_rcv_established+0x140/0x774)
> [    8.323477]  r10:ee6b9570 r9:ee42f9c0 r8:c0d6bfb3 r7:c155a080 r6:ee6e9a62 r5:ee42f9c0
> [    8.331448]  r4:ee6b9500
> [    8.334039] [<c0754ac8>] (tcp_rcv_established) from [<c075e8fc>] (tcp_v4_do_rcv+0x160/0x1c8)
> [    8.342494]  r8:c0d6bfb3 r7:c155a080 r6:eea79600 r5:ee6b9500 r4:ee42f9c0
> [    8.349348] [<c075e79c>] (tcp_v4_do_rcv) from [<c06e97ac>] (__release_sock+0x94/0x124)
> [    8.357281]  r6:00000000 r5:ee6b9500 r4:00000000 r3:c075e79c
> [    8.363065] [<c06e9718>] (__release_sock) from [<c06e9870>] (release_sock+0x34/0xa4)

The latter now runs with bh enabled. Ask Eric for a proper
replacement of u64_stats_update_ in tcp_snd_una_update.

(it's 00:30 here)

-- 
Ueimor
