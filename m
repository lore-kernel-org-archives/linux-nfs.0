Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18037 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbaDNXzm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 19:55:42 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: RE: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
Date: Mon, 14 Apr 2014 23:55:40 +0000
Message-ID: <EE7902D3F51F404C82415C4803930ACD3FDED988@CMEXMB1.ad.emulex.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com>
 <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com>
 <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com>
 <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com>
 <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com>
 <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com>
 <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
In-Reply-To: <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Sunday, April 13, 2014 9:31 AM
> To: Devesh Sharma
> Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond Myklebust
> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> 
> 
> On Apr 11, 2014, at 7:51 PM, Devesh Sharma
> <Devesh.Sharma@Emulex.Com> wrote:
> 
> > Hi  Chuck,
> > Yes that is the case, Following is the trace I got.
> >
> > <4>RPC:   355 setting alarm for 60000 ms
> > <4>RPC:   355 sync task going to sleep
> > <4>RPC:       xprt_rdma_connect_worker: reconnect
> > <4>RPC:       rpcrdma_ep_disconnect: rdma_disconnect -1
> > <4>RPC:       rpcrdma_ep_connect: rpcrdma_ep_disconnect status -1
> > <3>ocrdma_mbx_create_qp(0) rq_err
> > <3>ocrdma_mbx_create_qp(0) sq_err
> > <3>ocrdma_create_qp(0) error=-1
> > <4>RPC:       rpcrdma_ep_connect: rdma_create_qp failed -1
> > <4>RPC:   355 __rpc_wake_up_task (now 4296956756)
> > <4>RPC:   355 disabling timer
> > <4>RPC:   355 removed from queue ffff880454578258 "xprt_pending"
> > <4>RPC:       __rpc_wake_up_task done
> > <4>RPC:       xprt_rdma_connect_worker: exit
> > <4>RPC:   355 sync task resuming
> > <4>RPC:   355 xprt_connect_status: error 1 connecting to server 192.168.1.1
> 
> xprtrdma's connect worker is returning "1" instead of a negative errno.
> That's the bug that triggers this chain of events.
default:
                dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
                                "server %s\n", task->tk_pid, -task->tk_status -------------->Mind the Minus(-) sign here.,
                                xprt->servername);
                xprt_release_write(xprt, task);
                task->tk_status = -EIO;
So, ep_connect _is_ returning -EPERM, but xprt is printing -(-EPERM). Off-course EPERM is not handled here which turns into -EIO.
> 
> RPC tasks waiting for the reconnect are awoken. xprt_connect_status()
> doesn't recognize a tk_status of "1", so it turns it into -EIO, and kills each
> waiting RPC task.
> 
> > <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
> > <4>RPC:   355 call_connect_status (status -5)
> > <4>RPC:   355 return 0, status -5
> > <4>RPC:   355 release task
> > <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
> > <4>RPC:       xprt_rdma_free: called on 0x(null)
> 
> And as part of exiting, the RPC task has to free its buffer.
> 
> Not exactly sure why req->rl_nchunks is not zero for an NFSv4 GETATTR.
> This is why rpcrdma_deregister_external() is invoked here.
> 
> Eventually this gets around to attempting to post a LOCAL_INV WR with
> ->qp set to NULL, and the panic below occurs. But xprtrdma has gone off
> the rails well before this (see above).
> 
> I'll look at this more on Monday.
> 
> 
> > <1>BUG: unable to handle kernel NULL pointer dereference at (null)
> > <1>IP: [<ffffffffa05b68ac>] rpcrdma_deregister_frmr_external+0x9c/0xe0
> > [xprtrdma] <4>PGD 454554067 PUD 4665b7067 PMD 0
> > <4>Oops: 0000 [#1] SMP
> > <4>last sysfs file:
> > /sys/devices/pci0000:00/0000:00:03.0/0000:03:00.0/infiniband/ocrdma0/f
> > werr
> > <4>CPU 6
> > <4>Modules linked in: xprtrdma(U) nfs lockd fscache auth_rpcgss
> > nfs_acl ocrdma(U) be2net(U) ip6table_filter ip6_tables ebtable_nat
> > ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
> > nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM
> > iptable_mangle iptable_filter ip_tables bridge stp llc autofs4
> > des_generic ecb md4 nls_utf8 cifs sunrpc rdma_ucm(U) rdma_cm(U)
> > iw_cm(U) ib_addr(U) ib_ipoib(U) ib_cm(U) ib_sa(U) ipv6 ib_uverbs(U)
> > ib_umad(U) iw_nes(U) libcrc32c iw_cxgb4(U) cxgb4(U) iw_cxgb3(U)
> > cxgb3(U) mdio ib_qib(U) mlx4_en(U) mlx4_ib(U) mlx4_core(U)
> ib_mthca(U)
> > ib_mad(U) ib_core(U) compat(U) vhost_net macvtap macvlan tun kvm
> > uinput power_meter sg microcode i2c_i801 i2c_core iTCO_wdt
> > iTCO_vendor_support igb ptp pps_core ioatdma dca i7core_edac
> edac_core
> > ext3 jbd mbcache sr_mod cdrom sd_mod crc_t10dif usb_storage pata_acpi
> > ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas
> > dm_mirror dm_region_hash dm_log dm_mod [last unloaded: be2net] <4>
> > <4>Pid: 3597, comm: ls Not tainted 2.6.32-358.el6.x86_64 #1 Cisco
> > Systems Inc R210-2121605W/R210-2121605W
> > <4>RIP: 0010:[<ffffffffa05b68ac>]  [<ffffffffa05b68ac>]
> > rpcrdma_deregister_frmr_external+0x9c/0xe0 [xprtrdma]
> > <4>RSP: 0018:ffff880465aff9a8  EFLAGS: 00010217
> > <4>RAX: ffff8804673fcc00 RBX: ffff880466578028 RCX: 0000000000000000
> > <4>RDX: ffff880465affa10 RSI: ffff880465aff9a8 RDI: 0000000000000000
> > <4>RBP: ffff880465affa38 R08: 0000000000000000 R09: 0000000000000000
> > <4>R10: 000000000000000f R11: 000000000000000f R12: ffff880454578598
> > <4>R13: ffff880454578000 R14: ffff880466578068 R15: 0000000000000000
> > <4>FS:  00007fe61f3107a0(0000) GS:ffff8800368c0000(0000)
> > knlGS:0000000000000000
> > <4>CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > <4>CR2: 0000000000000000 CR3: 000000046520a000 CR4: 00000000000007e0
> > <4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > <4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > <4>Process ls (pid: 3597, threadinfo ffff880465afe000, task
> > ffff8804639a5500)
> > <4>Stack:
> > <4> 0000000000000000 ffff880462287370 0000000000000000
> > 0000000a00000000 <4><d> 0802dd3b00000002 0000000000000000
> > 0000000000000000 0000000000000000 <4><d> 0000000000000000
> > 0000000000000000 0000000000000000 0000000000000000 <4>Call Trace:
> > <4> [<ffffffff8109c97f>] ? up+0x2f/0x50 <4> [<ffffffffa05b6a03>]
> > rpcrdma_deregister_external+0x113/0x2d0 [xprtrdma] <4>
> > [<ffffffff8150d0d1>] ? printk+0x41/0x48 <4> [<ffffffffa05b44fc>]
> > xprt_rdma_free+0x8c/0x210 [xprtrdma] <4> [<ffffffff81082014>] ?
> > mod_timer+0x144/0x220 <4> [<ffffffffa05c8a60>]
> xprt_release+0xc0/0x220
> > [sunrpc] <4> [<ffffffffa05cff5d>] rpc_release_resources_task+0x1d/0x50
> > [sunrpc] <4> [<ffffffffa05d0a84>] __rpc_execute+0x174/0x350 [sunrpc]
> > <4> [<ffffffff8150d0d1>] ? printk+0x41/0x48 <4> [<ffffffff81096b47>] ?
> > bit_waitqueue+0x17/0xd0 <4> [<ffffffffa05d0cc1>]
> rpc_execute+0x61/0xa0
> > [sunrpc] <4> [<ffffffffa05c73a5>] rpc_run_task+0x75/0x90 [sunrpc] <4>
> > [<ffffffffa05c74c2>] rpc_call_sync+0x42/0x70 [sunrpc] <4>
> > [<ffffffff81143a17>] ? handle_pte_fault+0x487/0xb50 <4>
> > [<ffffffffa074e030>] _nfs4_call_sync+0x30/0x40 [nfs] <4>
> > [<ffffffffa07461dc>] _nfs4_proc_getattr+0xac/0xc0 [nfs] <4>
> > [<ffffffffa07494be>] nfs4_proc_getattr+0x4e/0x70 [nfs] <4>
> > [<ffffffffa072f3e3>] __nfs_revalidate_inode+0xe3/0x220 [nfs] <4>
> > [<ffffffffa072fdb6>] nfs_getattr+0xb6/0x120 [nfs] <4>
> > [<ffffffff81186951>] vfs_getattr+0x51/0x80 <4> [<ffffffff811869e0>]
> > vfs_fstatat+0x60/0x80 <4> [<ffffffff81186b2b>] vfs_stat+0x1b/0x20 <4>
> > [<ffffffff81186b54>] sys_newstat+0x24/0x50 <4> [<ffffffff810dc817>] ?
> > audit_syscall_entry+0x1d7/0x200 <4> [<ffffffff8100b072>]
> > system_call_fastpath+0x16/0x1b
> > <4>Code: 48 89 85 78 ff ff ff 48 8b 40 08 8b 40 1c 89 45 94 b8 ff ff
> > ff ff f0 41 0f c1 85 e0 05 00 00 49 8b 04 24 48 8d 55 d8 48 8b 78 10
> > <48> 8b 07 ff 90 b0 01 00 00 85 c0 89 c3 74 09 80 3d 56 dd 03 00
> > <1>RIP  [<ffffffffa05b68ac>]
> > rpcrdma_deregister_frmr_external+0x9c/0xe0 [xprtrdma] <4> RSP
> > <ffff880465aff9a8>
> > <4>CR2: 0000000000000000
> >
> >> -----Original Message-----
> >> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> >> Sent: Friday, April 11, 2014 1:24 AM
> >> To: Devesh Sharma
> >> Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond
> >> Myklebust
> >> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> >>
> >> Hi Devesh-
> >>
> >> On Apr 10, 2014, at 1:54 PM, Devesh Sharma
> <Devesh.Sharma@Emulex.Com>
> >> wrote:
> >>
> >>> Alright here it is:
> >>>
> >>> <3>ocrdma_mbx_create_qp(0) rq_err
> >>> <3>ocrdma_mbx_create_qp(0) sq_err
> >>> <3>ocrdma_create_qp(0) error=-1
> >>> <1>BUG: unable to handle kernel NULL pointer dereference at (null)
> >>> <1>IP: [<ffffffffa078e8ac>]
> >>> rpcrdma_deregister_frmr_external+0x9c/0xe0
> >>> [xprtrdma]
> >>
> >> As near as I can ascertain, the RDMA connection is torn down while an
> >> NFS workload is running, and a new connection cannot be completely set
> up.
> >>
> >> Can you try this:
> >>
> >> 1. On your client, # rpcdebug -m rpc -s call xprt sched trans
> >>
> >> 2. Reproduce the failure
> >>
> >> 3. Post the relevant contents of /var/log/messages (like the last RPC
> >> request or two before the BUG)
> >>
> >> And post the relevant line in /proc/mounts corresponding to your test
> >> NFS/RDMA mount.
> >>
> >>
> >>> <4>PGD 455942067 PUD 458356067 PMD 0
> >>> <4>Oops: 0000 [#1] SMP
> >>> <4>last sysfs file:
> >>> /sys/devices/pci0000:80/0000:80:03.0/0000:8b:00.1/class
> >>> <4>CPU 1
> >>> <4>Modules linked in: nfs fscache xprtrdma(U) ocrdma(U) fuse
> >>> ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
> >>> iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
> >>> nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter
> >>> ip_tables bridge nfsd lockd nfs_acl auth_rpcgss exportfs autofs4
> >>> sunrpc target_core_iblock target_core_file target_core_pscsi
> >>> target_core_mod configfs bnx2fc cnic uio fcoe libfcoe 8021q garp
> >>> libfc stp llc rdma_ucm(U) rdma_cm(U) iw_cm(U) ib_addr(U) ib_ipoib(U)
> >>> ib_cm(U) ib_sa(U) ipv6 ib_uverbs(U) ib_umad(U) iw_nes(U) libcrc32c
> >>> iw_cxgb4(U) cxgb4(U) iw_cxgb3(U) cxgb3(U) mdio ib_qib(U)
> mlx4_en(U)
> >>> mlx4_ib(U) mlx4_core(U) ib_mthca(U) ib_mad(U) ib_core(U) compat(U)
> >>> vfat fat vhost_net macvtap macvlan tun kvm_intel kvm uinput sg
> >>> cdc_ether usbnet mii microcode i2c_i801 i2c_core iTCO_wdt
> >>> iTCO_vendor_support shpchp igb ptp pps_core ioatdma dca be2net(U)
> >> ext4
> >>> mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif lpfc scsi_transport_fc
> >>> scsi_tgt ahci wmi megaraid_sas dm_mirror dm_region_hash dm_log
> >> dm_mod
> >>> [last unloaded: speedstep_lib] <4>
> >>> <4>Pid: 9204, comm: ls Not tainted 2.6.32-358.el6.x86_64 #1 IBM
> >>> System
> >>> x3650 M4 -[7915AC1]-/00J6528
> >>> <4>RIP: 0010:[<ffffffffa078e8ac>]  [<ffffffffa078e8ac>]
> >>> rpcrdma_deregister_frmr_external+0x9c/0xe0 [xprtrdma]
> >>> <4>RSP: 0018:ffff8804551877f8  EFLAGS: 00010217
> >>> <4>RAX: ffff880462243800 RBX: ffff88045646a028 RCX: 0000000000000000
> >>> <4>RDX: ffff880455187860 RSI: ffff8804551877f8 RDI: 0000000000000000
> >>> <4>RBP: ffff880455187888 R08: 0000000000000000 R09:
> 0000000000000000
> >>> <4>R10: 0000000000000000 R11: 0000000000000000 R12: ffff88047601c598
> >>> <4>R13: ffff88047601c000 R14: ffff88045646a068 R15: 0000000000000000
> >>> <4>FS:  00007fd669be07a0(0000) GS:ffff880028220000(0000)
> >>> knlGS:0000000000000000
> >>> <4>CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>> <4>CR2: 0000000000000000 CR3: 00000004557de000 CR4:
> 00000000000407e0
> >>> <4>DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> >>> <4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> >>> <4>Process ls (pid: 9204, threadinfo ffff880455186000, task
> >>> ffff880456735540)
> >>> <4>Stack:
> >>> <4> 0000000000000000 ffff88045584a700 0000000000000000
> >>> 0000000a00000000 <4><d> 080424b400000002 0000000000000000
> >>> 0000000000000000 0000000000000000 <4><d> 0000000000000000
> >>> 0000000000000000 0000000000000000 0000000000000000 <4>Call Trace:
> >>> <4> [<ffffffffa078ea03>] rpcrdma_deregister_external+0x113/0x2d0
> >>> [xprtrdma] <4> [<ffffffffa078c4fc>] xprt_rdma_free+0x8c/0x210
> >>> [xprtrdma] <4> [<ffffffff81082014>] ? mod_timer+0x144/0x220 <4>
> >>> [<ffffffffa07bba60>] xprt_release+0xc0/0x220 [sunrpc] <4>
> >>> [<ffffffffa07c2f5d>] rpc_release_resources_task+0x1d/0x50 [sunrpc]
> >>> <4> [<ffffffffa07c3a84>] __rpc_execute+0x174/0x350 [sunrpc] <4>
> >>> [<ffffffff81096b47>] ? bit_waitqueue+0x17/0xd0 <4>
> >>> [<ffffffffa07c3cc1>] rpc_execute+0x61/0xa0 [sunrpc] <4>
> >>> [<ffffffffa07ba3a5>] rpc_run_task+0x75/0x90 [sunrpc] <4>
> >>> [<ffffffffa07ba4c2>] rpc_call_sync+0x42/0x70 [sunrpc] <4>
> >>> [<ffffffffa08b6f6d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs] <4>
> >>> [<ffffffffa08b734c>] nfs3_proc_access+0xbc/0x180 [nfs] <4>
> >>> [<ffffffffa089f1e9>] nfs_do_access+0x199/0x3c0 [nfs] <4>
> >>> [<ffffffffa07c6305>] ? generic_lookup_cred+0x15/0x20 [sunrpc] <4>
> >>> [<ffffffffa07c52e0>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc] <4>
> >>> [<ffffffffa089f4b8>] nfs_permission+0xa8/0x1e0 [nfs] <4>
> >>> [<ffffffff8119053d>] __link_path_walk+0xad/0x1030 <4>
> >>> [<ffffffff81143a17>] ? handle_pte_fault+0x487/0xb50 <4>
> >>> [<ffffffff8132b1fa>] ? copy_termios+0x6a/0x80 <4>
> >>> [<ffffffff8119174a>]
> >>> path_walk+0x6a/0xe0 <4> [<ffffffff8119191b>]
> >> do_path_lookup+0x5b/0xa0
> >>> <4> [<ffffffff811925a7>] user_path_at+0x57/0xa0 <4>
> >>> [<ffffffff81194ed2>] ? vfs_ioctl+0x22/0xa0 <4> [<ffffffff811869bc>]
> >>> vfs_fstatat+0x3c/0x80 <4> [<ffffffff81085151>] ?
> >>> do_sigaction+0x91/0x1d0 <4> [<ffffffff81186b2b>] vfs_stat+0x1b/0x20
> >>> <4> [<ffffffff81186b54>] sys_newstat+0x24/0x50 <4>
> >>> [<ffffffff8151311e>] ? do_page_fault+0x3e/0xa0 <4>
> >>> [<ffffffff815104d5>] ? page_fault+0x25/0x30 <4> [<ffffffff8100b072>]
> >>> system_call_fastpath+0x16/0x1b
> >>> <4>Code: 48 89 85 78 ff ff ff 48 8b 40 08 8b 40 1c 89 45 94 b8 ff ff
> >>> ff ff f0 41 0f c1 85 e0 05 00 00 49 8b 04 24 48 8d 55 d8 48 8b 78 10
> >>> <48> 8b 07 ff 90 b0 01 00 00 85 c0 89 c3 74 09 80 3d 56 8d 05 00
> >>> <1>RIP  [<ffffffffa078e8ac>]
> >>> rpcrdma_deregister_frmr_external+0x9c/0xe0 [xprtrdma] <4> RSP
> >>> <ffff8804551877f8>
> >>> <4>CR2: 0000000000000000
> >>>
> >>>> -----Original Message-----
> >>>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> >>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
> >>>> Sent: Thursday, April 10, 2014 11:21 PM
> >>>> To: Devesh Sharma
> >>>> Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond
> >>>> Myklebust
> >>>> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> >>>>
> >>>>
> >>>> On Apr 10, 2014, at 1:42 PM, Devesh Sharma
> >> <Devesh.Sharma@Emulex.Com>
> >>>> wrote:
> >>>>
> >>>>>> However it seems to me the new (!ia->ri_id->qp) checks outside
> >>>>>> the connect logic are unnecessary.
> >>>>>>
> >>>>>> Clearly, as you noticed, the ib_post_{send,recv} verbs do not
> >>>>>> check that their "qp" argument is NULL before dereferencing it.
> >>>>>>
> >>>>>> But I don't understand how xprtrdma can post any operation if the
> >>>>>> transport isn't connected. In other words, how would it be
> >>>>>> possible to call
> >>>>>> rpcrdma_ep_post_recv() if the connect had failed and there was no
> >> QP?
> >>>>>>
> >>>>>> If disconnect wipes ia->ri_id->qp while there are still
> >>>>>> operations in progress, that would be the real bug.
> >>>>> Yes!, But I have seen one more kernel oops where QP is destroyed
> >>>>> and xprtrdma still try to post in LOCAL_INV WR on a NULL QP
> >>>>> pointer and hence
> >>>> system crashes. So, I think what you missioned is really happening.
> >>>>
> >>>> I'd like to see the crash data (back trace, etc), if you've got it.
> >>>>
> >>>> --
> >>>> Chuck Lever
> >>>> chuck[dot]lever[at]oracle[dot]com
> >>>>
> >>>>
> >>>>
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
> >>>> in the body of a message to majordomo@vger.kernel.org More
> >> majordomo
> >>>> info at http://vger.kernel.org/majordomo-info.html
> >>
> >> --
> >> Chuck Lever
> >> chuck[dot]lever[at]oracle[dot]com
> >>
> >>
> >
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
