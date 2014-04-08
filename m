Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24333 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbaDHAHf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 20:07:35 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: RE: [PATCH] NFS-RDMA: fix qp pointer validation checks
Date: Tue, 8 Apr 2014 00:07:34 +0000
Message-ID: <EE7902D3F51F404C82415C4803930ACD3FDE9B21@CMEXMB1.ad.emulex.com>
References: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com>
 <61E8946F-3722-4707-A948-065D395C365A@primarydata.com>
 <EE7902D3F51F404C82415C4803930ACD3FDE9AE4@CMEXMB1.ad.emulex.com>
 <20CBB511-EB06-485E-A2F9-B8D66806D5B6@primarydata.com>
In-Reply-To: <20CBB511-EB06-485E-A2F9-B8D66806D5B6@primarydata.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the stack trace seen during one of the test cases where rdma_create_qp() made to fail deliberately and nfs-rdma client ended up in Panic. 

<3>ocrdma_mbx_create_qp(0) rq_err
<3>ocrdma_mbx_create_qp(0) sq_err
<3>ocrdma_create_qp(0) error=-22
<1>BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
<1>IP: [<ffffffffa0265451>] ib_destroy_qp+0x21/0x120 [ib_core]
<4>PGD 46427d067 PUD 456244067 PMD 0
<4>Oops: 0000 [#1] SMP
<4>last sysfs file: /sys/kernel/mm/ksm/run
<4>CPU 8
<4>Modules linked in: nfs lockd fscache auth_rpcgss nfs_acl xprtrdma(U) ocrdma(U) be2net(U) ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc autofs4 des_generic ecb md4 nls_utf8 cifs sunrpc rdma_ucm(U) rdma_cm(U) iw_cm(U) ib_addr(U) ib_ipoib(U) ib_cm(U) ib_sa(U) ipv6 ib_uverbs(U) ib_umad(U) iw_nes(U) libcrc32c iw_cxgb4(U) cxgb4(U) iw_cxgb3(U) cxgb3(U) mdio ib_qib(U) mlx4_en(U) mlx4_ib(U) mlx4_core(U) ib_mthca(U) ib_mad(U) ib_core(U) compat(U) vhost_net macvtap macvlan tun kvm uinput power_meter sg microcode i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support igb ptp pps_core ioatdma dca i7core_edac edac_core ext3 jbd mbcache sr_mod cdrom sd_mod crc_t10dif usb_storage pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mirror dm_region_hash dm_log dm_mod [last unloaded: be2net]
<4>
<4>Pid: 1697, comm: events/8 Not tainted 2.6.32-358.el6.x86_64 #1 Cisco Systems Inc R210-2121605W/R210-2121605W
<4>RIP: 0010:[<ffffffffa0265451>]  [<ffffffffa0265451>] ib_destroy_qp+0x21/0x120 [ib_core]
<4>RSP: 0018:ffff880467731cb0  EFLAGS: 00010282
<4>RAX: ffff880467730000 RBX: ffff88046811e000 RCX: ffff88046313a040
<4>RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
<4>RBP: ffff880467731ce0 R08: ffff880467731c78 R09: 0000000000000000
<4>R10: 0000000000000000 R11: 0000000000000000 R12: ffff88046811e210
<4>R13: 0000000000000000 R14: ffff880466696400 R15: ffffe8ffffb01d08
<4>FS:  0000000000000000(0000) GS:ffff880036900000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
<4>CR2: 0000000000000040 CR3: 00000004624b8000 CR4: 00000000000007e0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process events/8 (pid: 1697, threadinfo ffff880467730000, task ffff88046313a040)
<4>Stack:
<4> ffff8804679cd5b8 ffff88046811e000 ffff88046811e210 0000000000000000
<4><d> ffff880466696400 ffffe8ffffb01d08 ffff880467731d00 ffffffffa0588f51
<4><d> ffff8804679cd5e0 ffff8804679cd598 ffff880467731e10 ffffffffa02e9e75
<4>Call Trace:
<4> [<ffffffffa0588f51>] rdma_destroy_qp+0x31/0x50 [rdma_cm]
<4> [<ffffffffa02e9e75>] rpcrdma_ep_connect+0x135/0x3e0 [xprtrdma]
<4> [<ffffffff8150d6e0>] ? thread_return+0x4e/0x76e
<4> [<ffffffffa05d06ae>] ? rpc_wake_up_task_queue_locked+0x18e/0x270 [sunrpc]
<4> [<ffffffffa02e6ff0>] ? xprt_rdma_connect_worker+0x0/0xc0 [xprtrdma]
<4> [<ffffffffa02e7032>] xprt_rdma_connect_worker+0x42/0xc0 [xprtrdma]
<4> [<ffffffff81090ac0>] worker_thread+0x170/0x2a0
<4> [<ffffffff81096c80>] ? autoremove_wake_function+0x0/0x40
<4> [<ffffffff81090950>] ? worker_thread+0x0/0x2a0
<4> [<ffffffff81096916>] kthread+0x96/0xa0
<4> [<ffffffff8100c0ca>] child_rip+0xa/0x20
<4> [<ffffffff81096880>] ? kthread+0x0/0xa0
<4> [<ffffffff8100c0c0>] ? child_rip+0x0/0x20
<4>Code: 65 f0 4c 8b 6d f8 c9 c3 66 90 55 48 89 e5 48 83 ec 30 48 89 5d d8 4c 89 65 e0 4c 89 6d e8 4c 89 75 f0 4c 89 7d f8 0f 1f 44 00 00 <8b> 57 40 b8 f0 ff ff ff 49 89 fe 85 d2 75 39 4c 8b 67 58 49 39
<1>RIP  [<ffffffffa0265451>] ib_destroy_qp+0x21/0x120 [ib_core]
<4> RSP <ffff880467731cb0>
<4>CR2: 0000000000000040

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@primarydata.com] 
Sent: Tuesday, April 08, 2014 5:31 AM
To: Devesh Sharma
Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks


On Apr 7, 2014, at 19:45, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:

> Hi
> Inline Below:
> 
> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@primarydata.com]
> Sent: Tuesday, April 08, 2014 4:58 AM
> To: Devesh Sharma
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks
> 
> 
> On Apr 7, 2014, at 18:30, devesh.sharma@emulex.com wrote:
> 
>> From: Devesh Sharma <devesh.sharma@emulex.com>
>> 
>> If the rdma_create_qp fails to create qp due to device firmware being 
>> in invalid state xprtrdma still tries to destroy the non-existant qp 
>> and ends up in a NULL pointer reference crash.
>> Adding proper checks for vaidating QP pointer avoids this to happen.
>> 
> 
> As far as I can see, rdma_create_qp() only sets id->qp on success. Otherwise it is left with the same value as it had on entry (i.e. NULL). What am I missing?
> [DS]: If you focus on rpcrdma_ep_connect() function and assume that rdma_create_qp() has failed with some valid error code, then this callback function will return ep->rep_connected = some non-zero.
> Eventually xprt_rdma_connect_worker() will call rpcrdma_ep_connect() 
> again and rpcrdma_ep_connect will try to free-up all the resources, now rdma_destroy_qp() will be called with invalid QP (which is NULL) pointer And hence kernel will panic. Please correct me if I am worng.
> 

AFAICS your patch does nothing to address that problem. Instead it adds tests for IS_ERR(ia->ri_id->qp), which can never happen because ia->ri_id->qp is either NULL or points to a valid structure.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData trond.myklebust@primarydata.com

