Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:36908 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757255Ab3BKPXK convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 10:23:10 -0500
From: Yan Burman <yanb@mellanox.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: RE: NFS over RDMA crashing
Date: Mon, 11 Feb 2013 15:19:42 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB8734611518A44@MTLDAG01.mtl.com>
References: <51127B3F.2090200@mellanox.com>
 <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org>
In-Reply-To: <20130207164134.GK3222@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, February 07, 2013 18:42
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
> > > IP: [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma] PGD
> > > 1a0c063 PUD 32f82e063 PMD 32f2fd063 PTE 8000000324dc7161
> > > Oops: 0003 [#1] PREEMPT SMP
> > > Modules linked in: md5 ib_ipoib xprtrdma svcrdma rdma_cm ib_cm
> iw_cm
> > > ib_addr nfsd exportfs netconsole ip6table_filter ip6_tables
> > > iptable_filter ip_tables ebtable_nat nfsv3 nfs_acl ebtables x_tables
> > > nfsv4 auth_rpcgss nfs lockd autofs4 sunrpc target_core_iblock
> > > target_core_file target_core_pscsi target_core_mod configfs 8021q
> > > bridge stp llc ipv6 dm_mirror dm_region_hash dm_log vhost_net
> > > macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support kvm_intel
> > > kvm crc32c_intel microcode pcspkr joydev i2c_i801 lpc_ich mfd_core
> > > ehci_pci ehci_hcd sg ioatdma ixgbe mdio mlx4_ib ib_sa ib_mad ib_core
> > > mlx4_en mlx4_core igb hwmon dca ptp pps_core button dm_mod ext3
> jbd
> > > sd_mod ata_piix libata uhci_hcd megaraid_sas scsi_mod CPU 6
> > > Pid: 4744, comm: nfsd Not tainted 3.8.0-rc5+ #4 Supermicro
> > > X8DTH-i/6/iF/6F/X8DTH
> > > RIP: 0010:[<ffffffffa05f3dfb>]  [<ffffffffa05f3dfb>]
> > > rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > > RSP: 0018:ffff880324c3dbf8  EFLAGS: 00010297
> > > RAX: ffff880324dc8000 RBX: 0000000000000001 RCX: ffff880324dd8428
> > > RDX: ffff880324dc7ff8 RSI: ffff880324dd8428 RDI: ffffffff81149618
> > > RBP: ffff880324c3dd78 R08: 000060f9c0000860 R09: 0000000000000001
> > > R10: ffff880324dd8000 R11: 0000000000000001 R12: ffff8806299dcb10
> > > R13: 0000000000000003 R14: 0000000000000001 R15: 0000000000000010
> > > FS:  0000000000000000(0000) GS:ffff88063fc00000(0000)
> > > knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: ffff880324dc7ff8 CR3: 0000000001a0b000 CR4: 00000000000007e0
> > > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > Process nfsd (pid: 4744, threadinfo ffff880324c3c000, task
> > > ffff880330550000)
> > > Stack:
> > >  ffff880324c3dc78 ffff880324c3dcd8 0000000000000282 ffff880631cec000
> > >  ffff880324dd8000 ffff88062ed33040 0000000124c3dc48 ffff880324dd8000
> > >  ffff88062ed33058 ffff880630ce2b90 ffff8806299e8000 0000000000000003
> > > Call Trace:
> > >  [<ffffffffa05f466e>] svc_rdma_recvfrom+0x3ee/0xd80 [svcrdma]
> > > [<ffffffff81086540>] ? try_to_wake_up+0x2f0/0x2f0
> > > [<ffffffffa045963f>] svc_recv+0x3ef/0x4b0 [sunrpc]
> > > [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
> > > [<ffffffffa0571e5d>] nfsd+0xad/0x130 [nfsd]  [<ffffffffa0571db0>] ?
> > > nfsd_svc+0x740/0x740 [nfsd]  [<ffffffff81071df6>] kthread+0xd6/0xe0
> > > [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
> > > [<ffffffff814b462c>] ret_from_fork+0x7c/0xb0  [<ffffffff81071d20>] ?
> > > __init_kthread_worker+0x70/0x70
> > > Code: 63 c2 49 8d 8c c2 18 02 00 00 48 39 ce 77 e1 49 8b 82 40 0a 00
> > > 00 48 39 c6 0f 84 92 f7 ff ff 90 48 8d 50 f8 49 89 92 40 0a 00 00
> > > <48> c7 40 f8 00 00 00 00 49 8b 82 40 0a 00 00 49 3b 82 30 0a 00 RIP
> > > [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]  RSP
> > > <ffff880324c3dbf8>
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
> > > When I moved to commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I
> > > was no longer getting the server crashes, so the reset of my tests
> > > were done using that point (it is somewhere in the middle of
> > > 3.7.0-rc2).
> >
> > OK, so this part's clearly my fault--I'll work on a patch, but the
> > rdma's use of the ->rq_pages array is pretty confusing.
> 
> Does this help?
> 
> They must have added this for some reason, but I'm not seeing how it could
> have ever done anything....
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

I've been trying to reproduce the problem, but for some reason it does not happen anymore.
The crash is not happening even without the patch now, but NFS over RDMA in 3.8.0-rc5 from net-next is not working.
When running server and client in VM with SRIOV, it times out when trying to mount and oopses on the client when mount command is interrupted.
When running two physical hosts, I get to mount the remote directory, but reading or writing fails with IO error.

I am still doing some checks - I will post my findings when I will have more information.

