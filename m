Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26609 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab1HAVKZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 17:10:25 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>, William Andros Adamson <andros@netapp.com>
Cc: Jim Rees <rees@umich.edu>, Christoph Hellwig <hch@infradead.org>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 01 Aug 2011 17:10:06 -0400
In-Reply-To: <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
	 <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu>
	 <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu>
	 <1311988172.16078.15.camel@lade.trondhjem.org>
	 <20110730032621.GB25188@merit.edu>
	 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312233006.23392.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2011-07-30 at 22:25 +0800, Peng Tao wrote: 
> On Sat, Jul 30, 2011 at 11:26 AM, Jim Rees <rees@umich.edu> wrote:
> > Trond Myklebust wrote:
> >
> >  >   Looks like we did find a bug in NFS.
> >  >
> >  > It kind of looks that way.
> >
> >  Is that reproducible on the upstream kernel, or is it something that is
> >  being introduced by the pNFS blocks code?
> >
> > It happens without the blocks module loaded, but it could be from something
> > we did outside the module.  I will test this weekend when I get a chance.
> I tried xfstests again and was able to reproduce a hang on both block
> layout and file layout (upstream commit ed1e62, w/o block layout
> code). It seems it is a bug in pnfs code. I did not see it w/ NFSv4.
> For pnfs block and file layout, it can be reproduced by just running
> xfstests with ./check -nfs. It does not show up every time but is
> likely to happen in less than 10 runs.  Not sure if it is the same one
> Jim reported though.
> 
> block layout trace:
> [  660.039009] BUG: soft lockup - CPU#1 stuck for 22s! [10.244.82.74-ma:29730]
> [  660.039014] Modules linked in: blocklayoutdriver nfs lockd fscache
> auth_rpcgss nfs_acl ebtable_na
> t ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM
> iptable_mangle bridge stp llc sunrpc be2isc
> si ip6t_REJECT iscsi_boot_sysfs nf_conntrack_ipv6 nf_defrag_ipv6 bnx2i
> ip6table_filter cnic uio ip6_
> tables cxgb3i libcxgbi cxgb3 mdio iscsi_tcp libiscsi_tcp libiscsi
> scsi_transport_iscsi ppdev i2c_pii
> x4 i2c_core pcspkr e1000 parport_pc microcode parport vmw_balloon
> shpchp ipv6 floppy mptspi mptscsih
>  mptbase scsi_transport_spi [last unloaded: nfs]
> [  660.039014] CPU 1
> [  660.039014] Modules linked in: blocklayoutdriver nfs lockd fscache
> auth_rpcgss nfs_acl ebtable_na
> t ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM
> iptable_mangle bridge stp llc sunrpc be2isc
> si ip6t_REJECT iscsi_boot_sysfs nf_conntrack_ipv6 nf_defrag_ipv6 bnx2i
> ip6table_filter cnic uio ip6_
> tables cxgb3i libcxgbi cxgb3 mdio iscsi_tcp libiscsi_tcp libiscsi
> scsi_transport_iscsi ppdev i2c_pii
> x4 i2c_core pcspkr e1000 parport_pc microcode parport vmw_balloon
> shpchp ipv6 floppy mptspi mptscsih
>  mptbase scsi_transport_spi [last unloaded: nfs]
> [  660.039014]
> [  660.039014] Pid: 29730, comm: 10.244.82.74-ma Tainted: G      D
> 3.0.0-pnfs+ #2 VMware, Inc. V
> Mware Virtual Platform/440BX Desktop Reference Platform
> [  660.039014] RIP: 0010:[<ffffffff81084f49>]  [<ffffffff81084f49>]
> do_raw_spin_lock+0x1e/0x25
> [  660.039014] RSP: 0018:ffff88001fef5e60  EFLAGS: 00000297
> [  660.039014] RAX: 000000000000002b RBX: ffff88003be19000 RCX: 0000000000000001
> [  660.039014] RDX: 000000000000002a RSI: ffff8800219a7cf0 RDI: ffff880020e4d988
> [  660.039014] RBP: ffff88001fef5e60 R08: 0000000000000000 R09: 000000000000df20
> [  660.039014] R10: 0000000000000000 R11: ffff8800219a7c00 R12: ffff88001fef5df0
> [  660.039014] R13: 00000000c355df1b R14: ffff88003bfaeac0 R15: ffff8800219a7c00
> [  660.039014] FS:  0000000000000000(0000) GS:ffff88003fd00000(0000)
> knlGS:0000000000000000
> [  660.039014] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  660.039014] CR2: 00007fc6122a4000 CR3: 0000000001a04000 CR4: 00000000000006e0
> [  660.039014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  660.039014] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  660.039014] Process 10.244.82.74-ma (pid: 29730, threadinfo
> ffff88001fef4000, task ffff88001fca80
> 00)
> [  660.039014] Stack:
> [  660.039014]  ffff88001fef5e70 ffffffff814585ee ffff88001fef5e90
> ffffffffa02badee
> [  660.039014]  0000000000000000 ffff8800219a7c00 ffff88001fef5ee0
> ffffffffa02bc2d9
> [  660.039014]  ffff880000000000 ffffffffa02d2250 ffff88001fef5ee0
> ffff88002059ba10
> [  660.039014] Call Trace:
> [  660.039014]  [<ffffffff814585ee>] _raw_spin_lock+0xe/0x10
> [  660.039014]  [<ffffffffa02badee>] nfs4_begin_drain_session+0x24/0x8f [nfs]
> [  660.039014]  [<ffffffffa02bc2d9>] nfs4_run_state_manager+0x271/0x517 [nfs]
> [  660.039014]  [<ffffffffa02bc068>] ? nfs4_do_reclaim+0x422/0x422 [nfs]
> [  660.039014]  [<ffffffff810719bf>] kthread+0x84/0x8c
> [  660.039014]  [<ffffffff81460f54>] kernel_thread_helper+0x4/0x10
> [  660.039014]  [<ffffffff8107193b>] ? kthread_worker_fn+0x148/0x148
> [  660.039014]  [<ffffffff81460f50>] ? gs_change+0x13/0x13
> [  660.039014] Code: 00 00 10 00 74 05 e8 a7 59 1b 00 5d c3 55 48 89
> e5 66 66 66 66 90 b8 00 00 01 00 f0 0f c1 07 0f b7 d0 c1 e8 10 39 c2
> 74 07 f3 90 <0f> b7 17 eb f5 5d c3 55 48 89 e5 66 66 66 66 90 8b 07 89
> c2 c1

OK...

Looking at the callback code, I see that if tbl->highest_used_slotid !=
0, then we BUG() while holding the backchannel's tbl->slot_tbl_lock
spinlock. That seems a likely candidate for the above hang.

Andy, how we are guaranteed that tbl->highest_used_slotid won't take
values other than 0, and why do we commit suicide when it does? As far
as I can see, there is no guarantee that we call nfs4_cb_take_slot() in
nfs4_callback_compound(), however we appear to unconditionally call
nfs4_cb_free_slot() provided there is a session.

The other strangeness would be the fact that there is nothing enforcing
the NFS4_SESSION_DRAINING flag. If the session is draining, then the
back-channel simply ignores that and goes ahead with processing the
callback. Is this to avoid deadlocks with the server returning
NFS4ERR_BACK_CHAN_BUSY when the client does a DESTROY_SESSION?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

