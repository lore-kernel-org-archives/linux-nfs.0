Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760092Ab3CIC76 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 21:59:58 -0500
Date: Fri, 8 Mar 2013 21:59:49 -0500
From: Dave Jones <davej@redhat.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: sunrpc ODEBUG assertion.
Message-ID: <20130309025949.GA14176@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

restarted my nfs server, and mounted it from a Mac, and got this..


[47433.585266] WARNING: at lib/debugobjects.c:260 debug_print_object+0x8c/0xb0()
[47433.585269] Hardware name:         
[47433.585273] ODEBUG: assert_init not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
[47433.585275] Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables coretemp microcode pcspkr snd_emu10k1 snd_hwdep snd_util_mem snd_ac97_codec ac97_bus snd_rawmidi snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd e1000e soundcore ptp pps_core vhost_net tun macvtap macvlan kvm_intel kvm nfsd binfmt_misc auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c xor lzo_compress zlib_deflate raid6_pq firewire_ohci firewire_core sata_sil crc_itu_t ata_piix radeon i2c_algo_bit hwmon drm_kms_helper ttm drm i2c_core floppy
[47433.585324] Pid: 611, comm: nfsd Not tainted 3.9.0-rc1+ #80
[47433.585326] Call Trace:
[47433.585330]  [<ffffffff8104abd5>] warn_slowpath_common+0x75/0xa0
[47433.585334]  [<ffffffff8104acb6>] warn_slowpath_fmt+0x46/0x50
[47433.585337]  [<ffffffff8105c326>] ? do_init_timer+0x66/0x70
[47433.585340]  [<ffffffff8134e27c>] debug_print_object+0x8c/0xb0
[47433.585343]  [<ffffffff8105b0f0>] ? timer_debug_hint+0x10/0x10
[47433.585346]  [<ffffffff8134ed93>] debug_object_assert_init+0xe3/0x120
[47433.585349]  [<ffffffff8105d65b>] del_timer+0x2b/0x80
[47433.585353]  [<ffffffff8106fe99>] try_to_grab_pending+0xd9/0x1a0
[47433.585356]  [<ffffffff810700f7>] __cancel_work_timer+0x27/0xf0
[47433.585359]  [<ffffffff810701d3>] cancel_delayed_work_sync+0x13/0x20
[47433.585373]  [<ffffffffa02c9647>] xs_destroy+0x27/0x80 [sunrpc]
[47433.585381]  [<ffffffffa02c65d8>] xprt_destroy+0x78/0xa0 [sunrpc]
[47433.585390]  [<ffffffffa02c8ab1>] xprt_put+0x21/0x30 [sunrpc]
[47433.585398]  [<ffffffffa02c515b>] rpc_free_client+0x16b/0x320 [sunrpc]
[47433.585406]  [<ffffffffa02c5023>] ? rpc_free_client+0x33/0x320 [sunrpc]
[47433.585414]  [<ffffffffa02c4fae>] rpc_release_client+0x6e/0xb0 [sunrpc]
[47433.585423]  [<ffffffffa02c53f5>] rpc_shutdown_client+0xe5/0x170 [sunrpc]
[47433.585427]  [<ffffffff8108ce81>] ? get_parent_ip+0x11/0x50
[47433.585431]  [<ffffffff816ae519>] ? sub_preempt_count+0x79/0xd0
[47433.585442]  [<ffffffffa02db871>] rpcb_put_local+0x141/0x250 [sunrpc]
[47433.585452]  [<ffffffffa02db735>] ? rpcb_put_local+0x5/0x250 [sunrpc]
[47433.585461]  [<ffffffffa02d270e>] svc_rpcb_cleanup+0x1e/0x30 [sunrpc]
[47433.585471]  [<ffffffffa030b444>] nfsd_last_thread+0x1e4/0x210 [nfsd]
[47433.585477]  [<ffffffffa030b265>] ? nfsd_last_thread+0x5/0x210 [nfsd]
[47433.585487]  [<ffffffffa02d2494>] svc_shutdown_net+0x34/0x40 [sunrpc]
[47433.585493]  [<ffffffffa030c0b0>] nfsd_destroy+0x170/0x210 [nfsd]
[47433.585500]  [<ffffffffa030bf45>] ? nfsd_destroy+0x5/0x210 [nfsd]
[47433.585509]  [<ffffffffa02d2859>] ? svc_exit_thread+0x99/0xb0 [sunrpc]
[47433.585516]  [<ffffffffa030c286>] nfsd+0x136/0x160 [nfsd]
[47433.585522]  [<ffffffffa030c150>] ? nfsd_destroy+0x210/0x210 [nfsd]
[47433.585526]  [<ffffffff8107a5fd>] kthread+0xed/0x100
[47433.585529]  [<ffffffff810b3b2e>] ? put_lock_stats.isra.25+0xe/0x40
[47433.585533]  [<ffffffff8107a510>] ? kthread_create_on_node+0x160/0x160
[47433.585536]  [<ffffffff816b2b1c>] ret_from_fork+0x7c/0xb0
[47433.585539]  [<ffffffff8107a510>] ? kthread_create_on_node+0x160/0x160
[47433.585542] ---[ end trace 0ffae049d68a07e1 ]---
[47433.585687] nfsd: last server has exited, flushing export cache
[47433.904483] NFSD: starting 90-second grace period (net ffffffff81cc9380)
[47461.093051] ------------[ cut here ]------------
[47461.093061] WARNING: at lib/debugobjects.c:260 debug_print_object+0x8c/0xb0()
[47461.093063] Hardware name:         
[47461.093067] ODEBUG: assert_init not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
[47461.093069] Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables coretemp microcode pcspkr snd_emu10k1 snd_hwdep snd_util_mem snd_ac97_codec ac97_bus snd_rawmidi snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd e1000e soundcore ptp pps_core vhost_net tun macvtap macvlan kvm_intel kvm nfsd binfmt_misc auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c xor lzo_compress zlib_deflate raid6_pq firewire_ohci firewire_core sata_sil crc_itu_t ata_piix radeon i2c_algo_bit hwmon drm_kms_helper ttm drm i2c_core floppy
[47461.093117] Pid: 9956, comm: nfsd Tainted: G        W    3.9.0-rc1+ #80
[47461.093119] Call Trace:
[47461.093124]  [<ffffffff8104abd5>] warn_slowpath_common+0x75/0xa0
[47461.093127]  [<ffffffff8104acb6>] warn_slowpath_fmt+0x46/0x50
[47461.093130]  [<ffffffff8105c326>] ? do_init_timer+0x66/0x70
[47461.093133]  [<ffffffff8134e27c>] debug_print_object+0x8c/0xb0
[47461.093136]  [<ffffffff8105b0f0>] ? timer_debug_hint+0x10/0x10
[47461.093139]  [<ffffffff8134ed93>] debug_object_assert_init+0xe3/0x120
[47461.093142]  [<ffffffff8105d65b>] del_timer+0x2b/0x80
[47461.093146]  [<ffffffff8106fe99>] try_to_grab_pending+0xd9/0x1a0
[47461.093149]  [<ffffffff810700f7>] __cancel_work_timer+0x27/0xf0
[47461.093152]  [<ffffffff810701d3>] cancel_delayed_work_sync+0x13/0x20
[47461.093166]  [<ffffffffa02c9647>] xs_destroy+0x27/0x80 [sunrpc]
[47461.093174]  [<ffffffffa02c65d8>] xprt_destroy+0x78/0xa0 [sunrpc]
[47461.093183]  [<ffffffffa02c8ab1>] xprt_put+0x21/0x30 [sunrpc]
[47461.093191]  [<ffffffffa02c515b>] rpc_free_client+0x16b/0x320 [sunrpc]
[47461.093200]  [<ffffffffa02c5023>] ? rpc_free_client+0x33/0x320 [sunrpc]
[47461.093209]  [<ffffffffa02c4fae>] rpc_release_client+0x6e/0xb0 [sunrpc]
[47461.093217]  [<ffffffffa02c53f5>] rpc_shutdown_client+0xe5/0x170 [sunrpc]
[47461.093221]  [<ffffffff8108ce81>] ? get_parent_ip+0x11/0x50
[47461.093226]  [<ffffffff816ae519>] ? sub_preempt_count+0x79/0xd0
[47461.093237]  [<ffffffffa02db871>] rpcb_put_local+0x141/0x250 [sunrpc]
[47461.093246]  [<ffffffffa02db735>] ? rpcb_put_local+0x5/0x250 [sunrpc]
[47461.093257]  [<ffffffffa02d270e>] svc_rpcb_cleanup+0x1e/0x30 [sunrpc]
[47461.093266]  [<ffffffffa030b444>] nfsd_last_thread+0x1e4/0x210 [nfsd]
[47461.093272]  [<ffffffffa030b265>] ? nfsd_last_thread+0x5/0x210 [nfsd]
[47461.093283]  [<ffffffffa02d2494>] svc_shutdown_net+0x34/0x40 [sunrpc]
[47461.093289]  [<ffffffffa030c0b0>] nfsd_destroy+0x170/0x210 [nfsd]
[47461.093296]  [<ffffffffa030bf45>] ? nfsd_destroy+0x5/0x210 [nfsd]
[47461.093305]  [<ffffffffa02d2859>] ? svc_exit_thread+0x99/0xb0 [sunrpc]
[47461.093312]  [<ffffffffa030c286>] nfsd+0x136/0x160 [nfsd]
[47461.093318]  [<ffffffffa030c150>] ? nfsd_destroy+0x210/0x210 [nfsd]
[47461.093322]  [<ffffffff8107a5fd>] kthread+0xed/0x100
[47461.093325]  [<ffffffff8107a510>] ? kthread_create_on_node+0x160/0x160
[47461.093328]  [<ffffffff816b2b1c>] ret_from_fork+0x7c/0xb0
[47461.093331]  [<ffffffff8107a510>] ? kthread_create_on_node+0x160/0x160
[47461.093334] ---[ end trace 0ffae049d68a07e2 ]---
[47461.093474] nfsd: last server has exited, flushing export cache
[47461.352324] NFSD: starting 90-second grace period (net ffffffff81cc9380)

