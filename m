Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:48300 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752241AbdJPNxz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 09:53:55 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 907AE2805BF
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 15:48:28 +0200 (CEST)
Date: Mon, 16 Oct 2017 15:48:27 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>, stable@vger.kernel.org
Message-ID: <163802068.2268501.1508161707921.JavaMail.zimbra@desy.de>
In-Reply-To: <20170929133643.11841-1-smayhew@redhat.com>
References: <20170929133643.11841-1-smayhew@redhat.com>
Subject: Re: [PATCH] nfs/filelayout: fix oops when freeing filelayout
 segment
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott et al., 

I believe, this fix have to go into stable (down to 3.10?) as well. I hit the same issue with 4.13.5:

[269301.756381] Oops: 0000 [#8] SMP
[269301.756381] Modules linked in: cfg80211 nfnetlink_queue nfnetlink_log bluetooth ecdh_generic rfkill fuse loop binfmt_misc nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 dns_resolver nfs lockd grace fscache nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables btrfs xor raid6_pq coretemp kvm_intel kvm irqbypass snd_hda_codec_idt snd_hda_codec_generic iTCO_wdt ppdev snd_hda_intel gpio_ich iTCO_vendor_support
[269301.756381]  snd_hda_codec snd_hda_core snd_hwdep lpc_ich i2c_i801 winbond_cir rc_core snd_seq snd_seq_device shpchp parport_pc tpm_tis tpm_tis_core tpm parport snd_pcm snd_timer snd soundcore x38_edac acpi_cpufreq auth_rpcgss sunrpc ata_generic pata_acpi nouveau e1000e serio_raw video mxm_wmi wmi firewire_ohci i2c_algo_bit drm_kms_helper firewire_core ttm crc_itu_t drm ptp pata_marvell pps_core [last unloaded: scsi_debug]
[269301.756381] CPU: 1 PID: 11858 Comm: aio-stress Tainted: G      D   I     4.13.5-200.fc26.x86_64 #1
[269301.801103] Hardware name: Comptronic pczW1007/DX38BT, BIOS BTX3810J.86A.1893.2008.1009.1712 10/09/2008
[269301.801103] task: ffff9369e6d6a540 task.stack: ffffbca4938d4000
[269301.801103] RIP: 0010:nfs4_put_deviceid_node+0xc/0x80 [nfsv4]
[269301.801103] RSP: 0018:ffffbca4938d7b60 EFLAGS: 00010246
[269301.801103] RAX: ffffffffc0b8b060 RBX: ffff936985559780 RCX: dead000000000200
[269301.801103] RDX: ffffbca4938d7bf8 RSI: ffff936985559780 RDI: 0000000000000000
[269301.801103] RBP: ffffbca4938d7b70 R08: ffffbca4938d7bf8 R09: ffffbca4938d7bf8
[269301.801103] R10: 00000000000002e0 R11: 0000000000000216 R12: ffffbca4938d7bf8
[269301.801103] R13: ffffbca4938d7bf8 R14: dead000000000200 R15: dead000000000100
[269301.801103] FS:  00007f12056ec700(0000) GS:ffff9369efc80000(0000) knlGS:0000000000000000
[269301.801103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[269301.801103] CR2: 0000000000000030 CR3: 00000000c6355000 CR4: 00000000000406e0
[269301.801103] Call Trace:
[269301.801103]  nfs4_fl_put_deviceid+0xe/0x10 [nfs_layout_nfsv41_files]
[269301.801103]  filelayout_free_lseg+0x24/0x90 [nfs_layout_nfsv41_files]
[269301.801103]  pnfs_free_lseg_list+0x89/0xb0 [nfsv4]
[269301.801103]  pnfs_layoutreturn_free_lsegs+0x76/0x110 [nfsv4]
[269301.801103]  pnfs_roc_release+0x41/0xd0 [nfsv4]
[269301.801103]  nfs4_free_closedata+0x43/0x80 [nfsv4]
[269301.801103]  rpc_free_task+0x30/0x70 [sunrpc]
[269301.801103]  rpc_do_put_task+0x63/0x70 [sunrpc]
[269301.801103]  rpc_put_task+0x10/0x20 [sunrpc]
[269301.801103]  nfs4_do_close+0x21c/0x2e0 [nfsv4]
[269301.801103]  __nfs4_close+0xc7/0x170 [nfsv4]
[269301.801103]  nfs4_close_sync+0x18/0x20 [nfsv4]
[269301.801103]  nfs4_close_context+0x2a/0x30 [nfsv4]
[269301.801103]  __put_nfs_open_context+0x79/0x100 [nfs]
[269301.801103]  nfs_file_clear_open_context+0xba/0xe0 [nfs]
[269301.801103]  nfs_file_release+0x3b/0x50 [nfs]
[269301.801103]  __fput+0xdf/0x1e0
[269301.801103]  ____fput+0xe/0x10
[269301.801103]  task_work_run+0x76/0x90
[269301.801103]  exit_to_usermode_loop+0xab/0xb0
[269301.801103]  syscall_return_slowpath+0x8f/0xa0
[269301.801103]  entry_SYSCALL_64_fastpath+0xa3/0xa5
[269301.801103] RIP: 0033:0x7f120b2d22ed
[269301.801103] RSP: 002b:00007f12056ebe50 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
[269301.801103] RAX: 0000000000000000 RBX: 00000000009c34a0 RCX: 00007f120b2d22ed
[269301.801103] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000004
[269301.801103] RBP: 00000000fffffff4 R08: 0000000000000022 R09: 0000000000000000
[269301.801103] R10: 0000000000000000 R11: 0000000000000293 R12: 00000000009c34a0
[269301.801103] R13: 0000000000000008 R14: 0000000000000000 R15: 00000000009c2110
[269301.801103] Code: 00 00 48 89 c7 e8 15 00 00 00 5b 41 5c 41 5d 5d c3 c6 05 f7 d9 03 00 00 5b 41 5c 41 5d 5d c3 66 66 66 66 90 55 48 89 e5 41 54 53 <48> 8b 47 30 48 89 fb a8 04 74 32 8b 47 60 83 f8 02 74 19 8d 50 
[269301.801103] RIP: nfs4_put_deviceid_node+0xc/0x80 [nfsv4] RSP: ffffbca4938d7b60
[269301.801103] CR2: 0000000000000030
[269301.826832] ---[ end trace a5ecaff0687a5627 ]---


Regards,
   Tigran.


----- Original Message -----
> From: "Scott Mayhew" <smayhew@redhat.com>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker" <anna.schumaker@netapp.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Friday, September 29, 2017 3:36:43 PM
> Subject: [PATCH] nfs/filelayout: fix oops when freeing filelayout segment

> Check for a NULL dsaddr in filelayout_free_lseg() before calling
> nfs4_fl_put_deviceid().  This fixes the following oops:
> 
> [ 1967.645207] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000030
> [ 1967.646010] IP: [<ffffffffc06d6aea>] nfs4_put_deviceid_node+0xa/0x90 [nfsv4]
> [ 1967.646010] PGD c08bc067 PUD 915d3067 PMD 0
> [ 1967.753036] Oops: 0000 [#1] SMP
> [ 1967.753036] Modules linked in: nfs_layout_nfsv41_files ext4 mbcache jbd2 loop
> rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache amd64_edac_mod ipmi_ssif
> edac_mce_amd edac_core kvm_amd sg kvm ipmi_si ipmi_devintf irqbypass pcspkr
> k8temp ipmi_msghandler i2c_piix4 shpchp nfsd auth_rpcgss nfs_acl lockd grace
> sunrpc ip_tables xfs libcrc32c sd_mod crc_t10dif crct10dif_generic
> crct10dif_common amdkfd amd_iommu_v2 radeon i2c_algo_bit drm_kms_helper
> syscopyarea sysfillrect sysimgblt fb_sys_fops mptsas ttm scsi_transport_sas
> mptscsih drm mptbase serio_raw i2c_core bnx2 dm_mirror dm_region_hash dm_log
> dm_mod
> [ 1967.790031] CPU: 2 PID: 1370 Comm: ls Not tainted
> 3.10.0-709.el7.test.bz1463784.x86_64 #1
> [ 1967.790031] Hardware name: IBM BladeCenter LS21 -[7971AC1]-/Server Blade,
> BIOS -[BAE155AUS-1.10]- 06/03/2009
> [ 1967.790031] task: ffff8800c42a3f40 ti: ffff8800c4064000 task.ti:
> ffff8800c4064000
> [ 1967.790031] RIP: 0010:[<ffffffffc06d6aea>]  [<ffffffffc06d6aea>]
> nfs4_put_deviceid_node+0xa/0x90 [nfsv4]
> [ 1967.790031] RSP: 0000:ffff8800c4067978  EFLAGS: 00010246
> [ 1967.790031] RAX: ffffffffc062f000 RBX: ffff8801d468a540 RCX: dead000000000200
> [ 1967.790031] RDX: ffff8800c40679f8 RSI: ffff8800c4067a0c RDI: 0000000000000000
> [ 1967.790031] RBP: ffff8800c4067980 R08: ffff8801d468a540 R09: 0000000000000000
> [ 1967.790031] R10: 0000000000000000 R11: ffffffffffffffff R12: ffff8801d468a540
> [ 1967.790031] R13: ffff8800c40679f8 R14: ffff8801d5645300 R15: ffff880126f15ff0
> [ 1967.790031] FS:  00007f11053c9800(0000) GS:ffff88012bd00000(0000)
> knlGS:0000000000000000
> [ 1967.790031] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1967.790031] CR2: 0000000000000030 CR3: 0000000094b55000 CR4: 00000000000007e0
> [ 1967.790031] Stack:
> [ 1967.790031]  ffff8801d468a540 ffff8800c4067990 ffffffffc062d2fe
> ffff8800c40679b0
> [ 1967.790031]  ffffffffc062b5b4 ffff8800c40679f8 ffff8801d468a540
> ffff8800c40679d8
> [ 1967.790031]  ffffffffc06d39af ffff8800c40679f8 ffff880126f16078
> 0000000000000001
> [ 1967.790031] Call Trace:
> [ 1967.790031]  [<ffffffffc062d2fe>] nfs4_fl_put_deviceid+0xe/0x10
> [nfs_layout_nfsv41_files]
> [ 1967.790031]  [<ffffffffc062b5b4>] filelayout_free_lseg+0x24/0x90
> [nfs_layout_nfsv41_files]
> [ 1967.790031]  [<ffffffffc06d39af>] pnfs_free_lseg_list+0x5f/0x80 [nfsv4]
> [ 1967.790031]  [<ffffffffc06d5a67>] _pnfs_return_layout+0x157/0x270 [nfsv4]
> [ 1967.790031]  [<ffffffffc06c17dd>] nfs4_evict_inode+0x4d/0x70 [nfsv4]
> [ 1967.790031]  [<ffffffff8121de19>] evict+0xa9/0x180
> [ 1967.790031]  [<ffffffff8121e729>] iput+0xf9/0x190
> [ 1967.790031]  [<ffffffffc0652cea>] nfs_dentry_iput+0x3a/0x50 [nfs]
> [ 1967.790031]  [<ffffffff8121ab4f>] shrink_dentry_list+0x20f/0x490
> [ 1967.790031]  [<ffffffff8121b018>] d_invalidate+0xd8/0x150
> [ 1967.790031]  [<ffffffffc065446b>] nfs_readdir_page_filler+0x40b/0x600 [nfs]
> [ 1967.790031]  [<ffffffffc0654bbd>] nfs_readdir_xdr_to_array+0x20d/0x3b0 [nfs]
> [ 1967.790031]  [<ffffffff811f3482>] ? __mem_cgroup_commit_charge+0xe2/0x2f0
> [ 1967.790031]  [<ffffffff81183208>] ? __add_to_page_cache_locked+0x48/0x170
> [ 1967.790031]  [<ffffffffc0654d60>] ? nfs_readdir_xdr_to_array+0x3b0/0x3b0
> [nfs]
> [ 1967.790031]  [<ffffffffc0654d82>] nfs_readdir_filler+0x22/0x90 [nfs]
> [ 1967.790031]  [<ffffffff8118351f>] do_read_cache_page+0x7f/0x190
> [ 1967.790031]  [<ffffffff81215d30>] ? fillonedir+0xe0/0xe0
> [ 1967.790031]  [<ffffffff8118366c>] read_cache_page+0x1c/0x30
> [ 1967.790031]  [<ffffffffc0654f9b>] nfs_readdir+0x1ab/0x6b0 [nfs]
> [ 1967.790031]  [<ffffffffc06bd1c0>] ? nfs4_xdr_dec_layoutget+0x270/0x270
> [nfsv4]
> [ 1967.790031]  [<ffffffff81215d30>] ? fillonedir+0xe0/0xe0
> [ 1967.790031]  [<ffffffff81215c20>] vfs_readdir+0xb0/0xe0
> [ 1967.790031]  [<ffffffff81216045>] SyS_getdents+0x95/0x120
> [ 1967.790031]  [<ffffffff816b9449>] system_call_fastpath+0x16/0x1b
> [ 1967.790031] Code: 90 31 d2 48 89 d0 5d c3 85 f6 74 f5 8d 4e 01 89 f0 f0 0f b1
> 0f 39 f0 74 e2 89 c6 eb eb 0f 1f 40 00 66 66 66 66 90 55 48 89 e5 53 <48> 8b 47
> 30 48 89 fb a8 04 74 3b 8b 57 60 83 fa 02 74 19 8d 4a
> [ 1967.790031] RIP  [<ffffffffc06d6aea>] nfs4_put_deviceid_node+0xa/0x90 [nfsv4]
> [ 1967.790031]  RSP <ffff8800c4067978>
> [ 1967.790031] CR2: 0000000000000030
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
> fs/nfs/filelayout/filelayout.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 44c638b..508126e 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -745,7 +745,8 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
> 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
> 
> 	dprintk("--> %s\n", __func__);
> -	nfs4_fl_put_deviceid(fl->dsaddr);
> +	if (fl->dsaddr != NULL)
> +		nfs4_fl_put_deviceid(fl->dsaddr);
> 	/* This assumes a single RW lseg */
> 	if (lseg->pls_range.iomode == IOMODE_RW) {
> 		struct nfs4_filelayout *flo;
> --
> 2.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
