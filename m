Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:54550 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab2AYTSl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 14:18:41 -0500
Received: from anubis.ics.muni.cz (94.112.253.31.static.b2b.upcbusiness.cz [94.112.253.31])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q0PJIb2B024058
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 20:18:38 +0100
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.76)
	(envelope-from <xhejtman@anubis.ics.muni.cz>)
	id 1Rq8MD-000181-ME
	for linux-nfs@vger.kernel.org; Wed, 25 Jan 2012 20:18:09 +0100
Date: Wed, 25 Jan 2012 20:18:09 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: Stuck rpciod in kernel 2.6.32
Message-ID: <20120125191809.GV10362@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we use KRB5 for NFSv4 authentication on computing cluster. From time to time,
NFSv4 mount stops to respond as rpciod kernel process gets stuck. I got the
following trace from rpciod. Is this by any chance fixed in any newer kernel?

kernel: [373065.987024] rpciod/0      D 0000000000000000     0  4393      2 0x00000000
kernel: [373065.987036]  ffffffff8145d1f0 0000000000000046 0000000000000000 ffff88087cc630c0
kernel: [373065.987083]  000000000000f000 0000000000017020 000000000000f9e0 ffff88a7fac2bfd8
kernel: [373065.987129]  0000000000015780 0000000000015780 ffff88a7fc3aa350 ffff88a7fc3aa648
kernel: [373065.987176] Call Trace:
kernel: [373065.987207]  [<ffffffff810b439d>] ? sync_page+0x0/0x46
kernel: [373065.987229]  [<ffffffff812fb4fa>] ? io_schedule+0x73/0xb7
kernel: [373065.987250]  [<ffffffff810b43de>] ? sync_page+0x41/0x46
kernel: [373065.987269]  [<ffffffff812fba07>] ? __wait_on_bit+0x41/0x70
kernel: [373065.987286]  [<ffffffff810b4562>] ? wait_on_page_bit+0x6b/0x71
kernel: [373065.987305]  [<ffffffff81064fc0>] ? wake_bit_function+0x0/0x23
kernel: [373065.987330]  [<ffffffff810be302>] ? shrink_page_list+0x14e/0x623
kernel: [373065.987351]  [<ffffffff8105a969>] ? del_timer_sync+0xc/0x16
kernel: [373065.987374]  [<ffffffff8101657d>] ? read_tsc+0xa/0x20
kernel: [373065.987392]  [<ffffffff812fb85c>] ? schedule_timeout+0xad/0xdd
kernel: [373065.987410]  [<ffffffff8106c503>] ? ktime_get_ts+0x68/0xb2
kernel: [373065.987433]  [<ffffffff81099ec6>] ? delayacct_end+0x74/0x7f
kernel: [373065.987451]  [<ffffffff810bd6f3>] ? isolate_pages_global+0x1a0/0x20f
kernel: [373065.987468]  [<ffffffff81065091>] ? finish_wait+0x35/0x60
kernel: [373065.987486]  [<ffffffff81064f92>] ? autoremove_wake_function+0x0/0x2e
kernel: [373065.987503]  [<ffffffff810befd8>] ? shrink_list+0x528/0x767
kernel: [373065.987565]  [<ffffffffa0062480>] ? netxen_nic_update_cmd_producer+0x18/0x49 [netxen_nic]
kernel: [373065.987571]  [<ffffffff810bf497>] ? shrink_zone+0x280/0x342
kernel: [373065.987578]  [<ffffffff8125ae1a>] ? load_pointer+0x1e/0xa1
kernel: [373065.987582]  [<ffffffff810bf922>] ? zone_reclaim+0x276/0x357
kernel: [373065.987585]  [<ffffffff810bd553>] ? isolate_pages_global+0x0/0x20f
kernel: [373065.987588]  [<ffffffff810b8743>] ? zone_watermark_ok+0x20/0xb1
kernel: [373065.987594]  [<ffffffff810c78a0>] ? zone_statistics+0x3c/0x5d
kernel: [373065.987597]  [<ffffffff810b9a6c>] ? get_page_from_freelist+0x1ff/0x760
kernel: [373065.987601]  [<ffffffff810ba334>] ? __alloc_pages_nodemask+0x11c/0x5fc
kernel: [373065.987604]  [<ffffffff810ba334>] ? __alloc_pages_nodemask+0x11c/0x5fc
kernel: [373065.987611]  [<ffffffff812879a0>] ? tcp_current_mss+0x3f/0x5a
kernel: [373065.987614]  [<ffffffff8127fbf6>] ? tcp_sendmsg+0x78b/0x87f
kernel: [373065.987623]  [<ffffffff810e6b0d>] ? new_slab+0x42/0x1ca
kernel: [373065.987625]  [<ffffffff810e6e85>] ? __slab_alloc+0x1f0/0x39b
kernel: [373065.987632]  [<ffffffff81172447>] ? crypto_init_shash_ops+0x68/0xc8
kernel: [373065.987635]  [<ffffffff810e8167>] ? __kmalloc+0xf1/0x141
kernel: [373065.987638]  [<ffffffff81172447>] ? crypto_init_shash_ops+0x68/0xc8
kernel: [373065.987640]  [<ffffffff81172447>] ? crypto_init_shash_ops+0x68/0xc8
kernel: [373065.987647]  [<ffffffff8116d565>] ? __crypto_alloc_tfm+0x7f/0xfe
kernel: [373065.987649]  [<ffffffff8116dbc9>] ? crypto_alloc_base+0x48/0x83
kernel: [373065.987654]  [<ffffffffa04ea316>] ? make_checksum+0x2e/0xee [rpcsec_gss_krb5]
kernel: [373065.987658]  [<ffffffff812fc819>] ? _spin_lock_bh+0x9/0x25
kernel: [373065.987665]  [<ffffffff812438a2>] ? release_sock+0x13/0xa0
kernel: [373065.987668]  [<ffffffffa04e94bf>] ? gss_get_mic_kerberos+0xd7/0x188 [rpcsec_gss_krb5]
kernel: [373065.987674]  [<ffffffffa0408f6e>] ? gss_marshal+0x128/0x18d [auth_rpcgss]
kernel: [373065.987691]  [<ffffffffa03cabb8>] ? call_transmit+0x16c/0x246 [sunrpc]
kernel: [373065.987698]  [<ffffffffa03d135b>] ? __rpc_execute+0x71/0x241 [sunrpc]
kernel: [373065.987704]  [<ffffffff8106195f>] ? worker_thread+0x188/0x21d
kernel: [373065.987710]  [<ffffffffa03d15b8>] ? rpc_async_schedule+0x0/0xc [sunrpc]
kernel: [373065.987713]  [<ffffffff81064f92>] ? autoremove_wake_function+0x0/0x2e
kernel: [373065.987715]  [<ffffffff810617d7>] ? worker_thread+0x0/0x21d
kernel: [373065.987718]  [<ffffffff81064cc5>] ? kthread+0x79/0x81
kernel: [373065.987721]  [<ffffffff81011baa>] ? child_rip+0xa/0x20
kernel: [373065.987723]  [<ffffffff81064c4c>] ? kthread+0x0/0x81
kernel: [373065.987726]  [<ffffffff81011ba0>] ? child_rip+0x0/0x20

-- 
Luká¹ Hejtmánek
