Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57639 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752524AbaCGRFW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 12:05:22 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Yan Burman'" <yanb@mellanox.com>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        "'Or Gerlitz'" <ogerlitz@mellanox.com>
References: <51127B3F.2090200@mellanox.com> <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org>
In-Reply-To: <20130207164134.GK3222@fieldses.org>
Subject: RE: NFS over RDMA crashing
Date: Fri, 7 Mar 2014 10:59:18 -0600
Message-ID: <003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resurrecting an old issue :)

More inline below...

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Thursday, February 07, 2013 10:42 AM
> To: Yan Burman
> Cc: linux-nfs@vger.kernel.org; swise@opengridcomputing.com; linux-
> rdma@vger.kernel.org; Or Gerlitz
> Subject: Re: NFS over RDMA crashing
> 
> On Wed, Feb 06, 2013 at 05:24:35PM -0500, J. Bruce Fields wrote:
> > On Wed, Feb 06, 2013 at 05:48:15PM +0200, Yan Burman wrote:
> > > When killing mount command that got stuck:
> > > -------------------------------------------
> > >
> > > BUG: unable to handle kernel paging request at ffff880324dc7ff8
> > > IP: [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > > PGD 1a0c063 PUD 32f82e063 PMD 32f2fd063 PTE 8000000324dc7161
> > > Oops: 0003 [#1] PREEMPT SMP
> > > Modules linked in: md5 ib_ipoib xprtrdma svcrdma rdma_cm ib_cm
> iw_cm
> > > ib_addr nfsd exportfs netconsole ip6table_filter ip6_tables
> > > iptable_filter ip_tables ebtable_nat nfsv3 nfs_acl ebtables
x_tables
> > > nfsv4 auth_rpcgss nfs lockd autofs4 sunrpc target_core_iblock
> > > target_core_file target_core_pscsi target_core_mod configfs 8021q
> > > bridge stp llc ipv6 dm_mirror dm_region_hash dm_log vhost_net
> > > macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support kvm_intel
> > > kvm crc32c_intel microcode pcspkr joydev i2c_i801 lpc_ich mfd_core
> > > ehci_pci ehci_hcd sg ioatdma ixgbe mdio mlx4_ib ib_sa ib_mad
> ib_core
> > > mlx4_en mlx4_core igb hwmon dca ptp pps_core button dm_mod ext3
> jbd
> > > sd_mod ata_piix libata uhci_hcd megaraid_sas scsi_mod
> > > CPU 6
> > > Pid: 4744, comm: nfsd Not tainted 3.8.0-rc5+ #4 Supermicro
> > > X8DTH-i/6/iF/6F/X8DTH
> > > RIP: 0010:[<ffffffffa05f3dfb>]  [<ffffffffa05f3dfb>]
> > > rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > > RSP: 0018:ffff880324c3dbf8  EFLAGS: 00010297
> > > RAX: ffff880324dc8000 RBX: 0000000000000001 RCX:
> ffff880324dd8428
> > > RDX: ffff880324dc7ff8 RSI: ffff880324dd8428 RDI: ffffffff81149618
> > > RBP: ffff880324c3dd78 R08: 000060f9c0000860 R09:
> 0000000000000001
> > > R10: ffff880324dd8000 R11: 0000000000000001 R12: ffff8806299dcb10
> > > R13: 0000000000000003 R14: 0000000000000001 R15:
> 0000000000000010
> > > FS:  0000000000000000(0000) GS:ffff88063fc00000(0000)
> knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: ffff880324dc7ff8 CR3: 0000000001a0b000 CR4:
> 00000000000007e0
> > > DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> > > Process nfsd (pid: 4744, threadinfo ffff880324c3c000, task
> ffff880330550000)
> > > Stack:
> > >  ffff880324c3dc78 ffff880324c3dcd8 0000000000000282
> ffff880631cec000
> > >  ffff880324dd8000 ffff88062ed33040 0000000124c3dc48
> ffff880324dd8000
> > >  ffff88062ed33058 ffff880630ce2b90 ffff8806299e8000
> 0000000000000003
> > > Call Trace:
> > >  [<ffffffffa05f466e>] svc_rdma_recvfrom+0x3ee/0xd80 [svcrdma]
> > >  [<ffffffff81086540>] ? try_to_wake_up+0x2f0/0x2f0
> > >  [<ffffffffa045963f>] svc_recv+0x3ef/0x4b0 [sunrpc]
> > >  [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
> > >  [<ffffffffa0571e5d>] nfsd+0xad/0x130 [nfsd]
> > >  [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
> > >  [<ffffffff81071df6>] kthread+0xd6/0xe0
> > >  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
> > >  [<ffffffff814b462c>] ret_from_fork+0x7c/0xb0
> > >  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
> > > Code: 63 c2 49 8d 8c c2 18 02 00 00 48 39 ce 77 e1 49 8b 82 40 0a
00
> > > 00 48 39 c6 0f 84 92 f7 ff ff 90 48 8d 50 f8 49 89 92 40 0a 00 00
> > > <48> c7 40 f8 00 00 00 00 49 8b 82 40 0a 00 00 49 3b 82 30 0a 00
> > > RIP  [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > >  RSP <ffff880324c3dbf8>
> > > CR2: ffff880324dc7ff8
> > > ---[ end trace 06d0384754e9609a ]---
> > >
> > >
> > > It seems that commit afc59400d6c65bad66d4ad0b2daf879cbff8e23e
> > > "nfsd4: cleanup: replace rq_resused count by rq_next_page pointer"
> > > is responsible for the crash (it seems to be crashing in
> > > net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:527)
> > > It may be because I have CONFIG_DEBUG_SET_MODULE_RONX and
> > > CONFIG_DEBUG_RODATA enabled. I did not try to disable them yet.
> > >
> > > When I moved to commit
> 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I
> > > was no longer getting the server crashes,
> > > so the reset of my tests were done using that point (it is
somewhere
> > > in the middle of 3.7.0-rc2).
> >
> > OK, so this part's clearly my fault--I'll work on a patch, but the
> > rdma's use of the ->rq_pages array is pretty confusing.
> 
> Does this help?
> 
> They must have added this for some reason, but I'm not seeing how it
> could have ever done anything....
> 
> --b.
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 0ce7552..e8f25ec 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -520,13 +520,6 @@ next_sge:
>  	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages;
> ch_no++)
>  		rqstp->rq_pages[ch_no] = NULL;
> 
> -	/*
> -	 * Detach res pages. If svc_release sees any it will attempt to
> -	 * put them.
> -	 */
> -	while (rqstp->rq_next_page != rqstp->rq_respages)
> -		*(--rqstp->rq_next_page) = NULL;
> -
>  	return err;
>  }
> 

I can reproduce this server crash readily on a recent net-next tree.  I
added the above change, and see a different crash:

[  192.764773] BUG: unable to handle kernel paging request at
0000100000000000
[  192.765688] IP: [<ffffffff8113c159>] put_page+0x9/0x50
[  192.765688] PGD 0
[  192.765688] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  192.765688] Modules linked in: nfsd lockd nfs_acl exportfs
auth_rpcgss oid_registry svcrdma tg3 ip6table_filter ip6_tables
ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter
ip_tables bridge stp llc autofs4 sunrpc rdma_ucm rdma_cm iw_cm ib_ipoib
ib_cm ib_uverbs ib_umad iw_nes libcrc32c iw_cxgb4 iw_cxgb3 cxgb3 mdio
ib_qib dca mlx4_en ib_mthca vhost_net macvtap macvlan vhost tun
kvm_intel kvm uinput ipmi_si ipmi_msghandler iTCO_wdt
iTCO_vendor_support dcdbas sg microcode pcspkr mlx4_ib ib_sa serio_raw
ib_mad ib_core ib_addr ipv6 ptp pps_core lpc_ich mfd_core i5100_edac
edac_core mlx4_core cxgb4 ext4 jbd2 mbcache sd_mod crc_t10dif
crct10dif_common sr_mod cdrom pata_acpi ata_generic ata_piix radeon ttm
drm_kms_helper drm i2c_algo_bit
[  192.765688]  i2c_core dm_mirror dm_region_hash dm_log dm_mod [last
unloaded: tg3]
[  192.765688] CPU: 1 PID: 6590 Comm: nfsd Not tainted
3.14.0-rc3-pending+ #5
[  192.765688] Hardware name: Dell Inc. PowerEdge R300/0TY179, BIOS
1.3.0 08/15/2008
[  192.765688] task: ffff8800b75c62c0 ti: ffff8801faa4a000 task.ti:
ffff8801faa4a000
[  192.765688] RIP: 0010:[<ffffffff8113c159>]  [<ffffffff8113c159>]
put_page+0x9/0x50
[  192.765688] RSP: 0018:ffff8801faa4be28  EFLAGS: 00010206
[  192.765688] RAX: ffff8801fa9542a8 RBX: ffff8801fa954000 RCX:
0000000000000001
[  192.765688] RDX: ffff8801fa953e10 RSI: 0000000000000200 RDI:
0000100000000000
[  192.765688] RBP: ffff8801faa4be28 R08: 000000009b8d39b9 R09:
0000000000000017
[  192.765688] R10: 0000000000000000 R11: 0000000000000000 R12:
ffff8800cb2e7c00
[  192.765688] R13: ffff8801fa954210 R14: 0000000000000000 R15:
0000000000000000
[  192.765688] FS:  0000000000000000(0000) GS:ffff88022ec80000(0000)
knlGS:0000000000000000
[  192.765688] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  192.765688] CR2: 0000100000000000 CR3: 00000000b9a5a000 CR4:
00000000000007e0
[  192.765688] Stack:
[  192.765688]  ffff8801faa4be58 ffffffffa0881f4e ffff880204dd0e00
ffff8801fa954000
[  192.765688]  ffff880204dd0e00 ffff8800cb2e7c00 ffff8801faa4be88
ffffffffa08825f5
[  192.765688]  ffff8801fa954000 ffff8800b75c62c0 ffffffff81ae5ac0
ffffffffa08cf930
[  192.765688] Call Trace:
[  192.765688]  [<ffffffffa0881f4e>] svc_xprt_release+0x6e/0xf0 [sunrpc]
[  192.765688]  [<ffffffffa08825f5>] svc_recv+0x165/0x190 [sunrpc]
[  192.765688]  [<ffffffffa08cf930>] ? nfsd_pool_stats_release+0x60/0x60
[nfsd]
[  192.765688]  [<ffffffffa08cf9e5>] nfsd+0xb5/0x160 [nfsd]
[  192.765688]  [<ffffffffa08cf930>] ? nfsd_pool_stats_release+0x60/0x60
[nfsd]
[  192.765688]  [<ffffffff8107471e>] kthread+0xce/0xf0
[  192.765688]  [<ffffffff81074650>] ?
kthread_freezable_should_stop+0x70/0x70
[  192.765688]  [<ffffffff81584e2c>] ret_from_fork+0x7c/0xb0
[  192.765688]  [<ffffffff81074650>] ?
kthread_freezable_should_stop+0x70/0x70
[  192.765688] Code: 8d 7b 10 e8 ea fa ff ff 48 c7 03 00 00 00 00 48 83
c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66 66
66 90 <66> f7 07 00 c0 75 32 8b 47 1c 48 8d 57 1c 85 c0 74 1c f0 ff 0a
[  192.765688] RIP  [<ffffffff8113c159>] put_page+0x9/0x50
[  192.765688]  RSP <ffff8801faa4be28>
[  192.765688] CR2: 0000100000000000
crash>

