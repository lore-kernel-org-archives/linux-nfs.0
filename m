Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57913 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752393AbaCGUlH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 15:41:07 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Yan Burman'" <yanb@mellanox.com>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        "'Or Gerlitz'" <ogerlitz@mellanox.com>
References: <51127B3F.2090200@mellanox.com> <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org> <003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com>
In-Reply-To: <003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com>
Subject: RE: NFS over RDMA crashing
Date: Fri, 7 Mar 2014 14:41:14 -0600
Message-ID: <005d01cf3a45$94ced0d0$be6c7270$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >
> > Does this help?
> >
> > They must have added this for some reason, but I'm not seeing how it
> > could have ever done anything....
> >
> > --b.
> >
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > index 0ce7552..e8f25ec 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > @@ -520,13 +520,6 @@ next_sge:
> >  	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages;
> > ch_no++)
> >  		rqstp->rq_pages[ch_no] = NULL;
> >
> > -	/*
> > -	 * Detach res pages. If svc_release sees any it will attempt to
> > -	 * put them.
> > -	 */
> > -	while (rqstp->rq_next_page != rqstp->rq_respages)
> > -		*(--rqstp->rq_next_page) = NULL;
> > -
> >  	return err;
> >  }
> >
> 
> I can reproduce this server crash readily on a recent net-next tree.
I
> added the above change, and see a different crash:
> 
> [  192.764773] BUG: unable to handle kernel paging request at
> 0000100000000000
> [  192.765688] IP: [<ffffffff8113c159>] put_page+0x9/0x50
> [  192.765688] PGD 0
> [  192.765688] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  192.765688] Modules linked in: nfsd lockd nfs_acl exportfs
> auth_rpcgss oid_registry svcrdma tg3 ip6table_filter ip6_tables
> ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
> nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter
> ip_tables bridge stp llc autofs4 sunrpc rdma_ucm rdma_cm iw_cm
ib_ipoib
> ib_cm ib_uverbs ib_umad iw_nes libcrc32c iw_cxgb4 iw_cxgb3 cxgb3 mdio
> ib_qib dca mlx4_en ib_mthca vhost_net macvtap macvlan vhost tun
> kvm_intel kvm uinput ipmi_si ipmi_msghandler iTCO_wdt
> iTCO_vendor_support dcdbas sg microcode pcspkr mlx4_ib ib_sa serio_raw
> ib_mad ib_core ib_addr ipv6 ptp pps_core lpc_ich mfd_core i5100_edac
> edac_core mlx4_core cxgb4 ext4 jbd2 mbcache sd_mod crc_t10dif
> crct10dif_common sr_mod cdrom pata_acpi ata_generic ata_piix radeon
> ttm
> drm_kms_helper drm i2c_algo_bit
> [  192.765688]  i2c_core dm_mirror dm_region_hash dm_log dm_mod
> [last
> unloaded: tg3]
> [  192.765688] CPU: 1 PID: 6590 Comm: nfsd Not tainted
> 3.14.0-rc3-pending+ #5
> [  192.765688] Hardware name: Dell Inc. PowerEdge R300/0TY179, BIOS
> 1.3.0 08/15/2008
> [  192.765688] task: ffff8800b75c62c0 ti: ffff8801faa4a000 task.ti:
> ffff8801faa4a000
> [  192.765688] RIP: 0010:[<ffffffff8113c159>]  [<ffffffff8113c159>]
> put_page+0x9/0x50
> [  192.765688] RSP: 0018:ffff8801faa4be28  EFLAGS: 00010206
> [  192.765688] RAX: ffff8801fa9542a8 RBX: ffff8801fa954000 RCX:
> 0000000000000001
> [  192.765688] RDX: ffff8801fa953e10 RSI: 0000000000000200 RDI:
> 0000100000000000
> [  192.765688] RBP: ffff8801faa4be28 R08: 000000009b8d39b9 R09:
> 0000000000000017
> [  192.765688] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff8800cb2e7c00
> [  192.765688] R13: ffff8801fa954210 R14: 0000000000000000 R15:
> 0000000000000000
> [  192.765688] FS:  0000000000000000(0000) GS:ffff88022ec80000(0000)
> knlGS:0000000000000000
> [  192.765688] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  192.765688] CR2: 0000100000000000 CR3: 00000000b9a5a000 CR4:
> 00000000000007e0
> [  192.765688] Stack:
> [  192.765688]  ffff8801faa4be58 ffffffffa0881f4e ffff880204dd0e00
> ffff8801fa954000
> [  192.765688]  ffff880204dd0e00 ffff8800cb2e7c00 ffff8801faa4be88
> ffffffffa08825f5
> [  192.765688]  ffff8801fa954000 ffff8800b75c62c0 ffffffff81ae5ac0
> ffffffffa08cf930
> [  192.765688] Call Trace:
> [  192.765688]  [<ffffffffa0881f4e>] svc_xprt_release+0x6e/0xf0
[sunrpc]
> [  192.765688]  [<ffffffffa08825f5>] svc_recv+0x165/0x190 [sunrpc]
> [  192.765688]  [<ffffffffa08cf930>] ?
nfsd_pool_stats_release+0x60/0x60
> [nfsd]
> [  192.765688]  [<ffffffffa08cf9e5>] nfsd+0xb5/0x160 [nfsd]
> [  192.765688]  [<ffffffffa08cf930>] ?
nfsd_pool_stats_release+0x60/0x60
> [nfsd]
> [  192.765688]  [<ffffffff8107471e>] kthread+0xce/0xf0
> [  192.765688]  [<ffffffff81074650>] ?
> kthread_freezable_should_stop+0x70/0x70
> [  192.765688]  [<ffffffff81584e2c>] ret_from_fork+0x7c/0xb0
> [  192.765688]  [<ffffffff81074650>] ?
> kthread_freezable_should_stop+0x70/0x70
> [  192.765688] Code: 8d 7b 10 e8 ea fa ff ff 48 c7 03 00 00 00 00 48
83
> c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66
66
> 66 90 <66> f7 07 00 c0 75 32 8b 47 1c 48 8d 57 1c 85 c0 74 1c f0 ff 0a
> [  192.765688] RIP  [<ffffffff8113c159>] put_page+0x9/0x50
> [  192.765688]  RSP <ffff8801faa4be28>
> [  192.765688] CR2: 0000100000000000
> crash>

This new crash is here calling put_page() on garbage I guess:

static inline void svc_free_res_pages(struct svc_rqst *rqstp)
{
        while (rqstp->rq_next_page != rqstp->rq_respages) {
                struct page **pp = --rqstp->rq_next_page;
                if (*pp) {
                        put_page(*pp);
                        *pp = NULL;
                }
        }
}
 

