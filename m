Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56603 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab2LUSIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 13:08:30 -0500
Date: Fri, 21 Dec 2012 13:08:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20121221180824.GA27729@fieldses.org>
References: <20121221153348.GA32151@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121221153348.GA32151@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2012 at 10:33:48AM -0500, Dave Jones wrote:
> Did a mount from a client (also running Linus current), and the
> server spat this out..
> 
> [ 6936.306135] ------------[ cut here ]------------
> [ 6936.306154] WARNING: at net/sunrpc/clnt.c:617 rpc_shutdown_client+0x12a/0x1b0 [sunrpc]()

This is a warning added by 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9
"SUNRPC: add WARN_ON_ONCE for potential deadlock", pointing out that
nfsd is calling shutdown_client from a workqueue, which is a problem
because shutdown_client has to wait on rpc tasks that run on a
workqueue.

I don't believe there's any circular dependency among the workqueues
(we're calling shutdown_client from callback_wq, not rpciod_workqueue),
but 168e4b39d1afb.. says that we could get a deadlock if both are
running on the same kworker thread.

I'm not sure what to do about that.

> [ 6936.306156] Hardware name:         
> [ 6936.306157] Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables xfs coretemp iTCO_wdt iTCO_vendor_support snd_emu10k1 microcode snd_util_mem snd_ac97_codec ac97_bus snd_hwdep snd_seq snd_pcm snd_page_alloc snd_timer e1000e snd_rawmidi snd_seq_device snd emu10k1_gp pcspkr i2c_i801 soundcore gameport lpc_ich mfd_core i82975x_edac edac_core vhost_net tun macvtap macvlan kvm_intel kvm binfmt_misc nfsd auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c zlib_deflate usb_storage firewire_ohci firewire_core sata_sil crc_itu_t radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core floppy
> [ 6936.306214] Pid: 52, comm: kworker/u:2 Not tainted 3.7.0+ #34
> [ 6936.306216] Call Trace:
> [ 6936.306224]  [<ffffffff8106badf>] warn_slowpath_common+0x7f/0xc0
> [ 6936.306227]  [<ffffffff8106bb3a>] warn_slowpath_null+0x1a/0x20
> [ 6936.306235]  [<ffffffffa02c62ca>] rpc_shutdown_client+0x12a/0x1b0 [sunrpc]
> [ 6936.306240]  [<ffffffff81368318>] ? delay_tsc+0x98/0xf0
> [ 6936.306252]  [<ffffffffa034a60b>] nfsd4_process_cb_update.isra.16+0x4b/0x230 [nfsd]
> [ 6936.306256]  [<ffffffff8109677c>] ? __rcu_read_unlock+0x5c/0xa0
> [ 6936.306260]  [<ffffffff81370d46>] ? debug_object_deactivate+0x46/0x130
> [ 6936.306269]  [<ffffffffa034a87d>] nfsd4_do_callback_rpc+0x8d/0xa0 [nfsd]
> [ 6936.306272]  [<ffffffff810900f7>] process_one_work+0x207/0x760
> [ 6936.306274]  [<ffffffff81090087>] ? process_one_work+0x197/0x760
> [ 6936.306277]  [<ffffffff81090afe>] ? worker_thread+0x21e/0x440
> [ 6936.306285]  [<ffffffffa034a7f0>] ? nfsd4_process_cb_update.isra.16+0x230/0x230 [nfsd]
> [ 6936.306289]  [<ffffffff81090a3e>] worker_thread+0x15e/0x440
> [ 6936.306292]  [<ffffffff810908e0>] ? rescuer_thread+0x250/0x250
> [ 6936.306295]  [<ffffffff8109b16d>] kthread+0xed/0x100
> [ 6936.306299]  [<ffffffff810dd86e>] ? put_lock_stats.isra.25+0xe/0x40
> [ 6936.306302]  [<ffffffff8109b080>] ? kthread_create_on_node+0x160/0x160
> [ 6936.306307]  [<ffffffff81711e2c>] ret_from_fork+0x7c/0xb0
> [ 6936.306310]  [<ffffffff8109b080>] ? kthread_create_on_node+0x160/0x160
> [ 6936.306312] ---[ end trace 5bab69e086ae3c6f ]---
> [ 6936.363213] ------------[ cut here ]------------
> [ 6936.363226] WARNING: at fs/nfsd/vfs.c:937 nfsd_vfs_read.isra.13+0x197/0x1b0 [nfsd]()

This warning is unrelated, and is probably just carelessness on my part:
I couldn't see why this condition would happen, and I stuck the warning
in there without looking much harder.  Probably we should just revert
79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e "nfsd: warn on odd reply state
in nfsd_vfs_read" while I go stare at the code.

--b.

> [ 6936.363229] Hardware name:         
> [ 6936.363230] Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables xfs coretemp iTCO_wdt iTCO_vendor_support snd_emu10k1 microcode snd_util_mem snd_ac97_codec ac97_bus snd_hwdep snd_seq snd_pcm snd_page_alloc snd_timer e1000e snd_rawmidi snd_seq_device snd emu10k1_gp pcspkr i2c_i801 soundcore gameport lpc_ich mfd_core i82975x_edac edac_core vhost_net tun macvtap macvlan kvm_intel kvm binfmt_misc nfsd auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c zlib_deflate usb_storage firewire_ohci firewire_core sata_sil crc_itu_t radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core floppy
> [ 6936.363284] Pid: 699, comm: nfsd Tainted: G        W    3.7.0+ #34
> [ 6936.363286] Call Trace:
> [ 6936.363293]  [<ffffffff8106badf>] warn_slowpath_common+0x7f/0xc0
> [ 6936.363296]  [<ffffffff8106bb3a>] warn_slowpath_null+0x1a/0x20
> [ 6936.363302]  [<ffffffffa031ef77>] nfsd_vfs_read.isra.13+0x197/0x1b0 [nfsd]
> [ 6936.363310]  [<ffffffffa0321948>] nfsd_read_file+0x88/0xb0 [nfsd]
> [ 6936.363317]  [<ffffffffa0332956>] nfsd4_encode_read+0x186/0x260 [nfsd]
> [ 6936.363325]  [<ffffffffa03391cc>] nfsd4_encode_operation+0x5c/0xa0 [nfsd]
> [ 6936.363333]  [<ffffffffa032e5a9>] nfsd4_proc_compound+0x289/0x780 [nfsd]
> [ 6936.363339]  [<ffffffffa0319e5b>] nfsd_dispatch+0xeb/0x230 [nfsd]
> [ 6936.363355]  [<ffffffffa02d3d38>] svc_process_common+0x328/0x6d0 [sunrpc]
> [ 6936.363365]  [<ffffffffa02d4433>] svc_process+0x103/0x160 [sunrpc]
> [ 6936.363371]  [<ffffffffa031921b>] nfsd+0xdb/0x160 [nfsd]
> [ 6936.363378]  [<ffffffffa0319140>] ? nfsd_destroy+0x210/0x210 [nfsd]
> [ 6936.363381]  [<ffffffff8109b16d>] kthread+0xed/0x100
> [ 6936.363385]  [<ffffffff810dd86e>] ? put_lock_stats.isra.25+0xe/0x40
> [ 6936.363388]  [<ffffffff8109b080>] ? kthread_create_on_node+0x160/0x160
> [ 6936.363393]  [<ffffffff81711e2c>] ret_from_fork+0x7c/0xb0
> [ 6936.363396]  [<ffffffff8109b080>] ? kthread_create_on_node+0x160/0x160
> [ 6936.363398] ---[ end trace 5bab69e086ae3c70 ]---
> 
