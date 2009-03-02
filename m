From: Ben Myers <bpm@sgi.com>
Subject: Re: [PATCH] sunrpc: xprt is not connected until after sock is set
Date: Mon, 2 Mar 2009 10:36:00 -0600
Message-ID: <20090302163600.GI15475@sgi.com>
References: <20090223201108.GB3308@merfinllc.com> <20090225023900.GD15475@sgi.com> <20090226001744.GB7613@merfinllc.com> <20090227235434.GH15475@sgi.com> <1235781463.20549.33.camel@heimdal.trondhjem.org> <20090228013457.GF7706@merfinllc.com> <1235785237.20549.51.camel@heimdal.trondhjem.org> <20090228050707.GB22330@merfinllc.com> <1235844568.7677.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org, neilb@suse.de
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44246 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754305AbZCBQeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 11:34:04 -0500
In-Reply-To: <1235844568.7677.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Sat, Feb 28, 2009 at 01:09:28PM -0500, Trond Myklebust wrote:
> On Fri, 2009-02-27 at 21:07 -0800, Aaron Straus wrote:
> > It seems like xs_sendpages does check if sock is NULL and returns
> > -ENOTCONN in that case.

Here's a trace that shows the above:

Starting kernel based NFS server: idmapd mountd statd nfsdrpc.nfsd[4502]: NaT co
nsumption 17179869216 [1]
Modules linked in: nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ib_ipoib ib_cm
 ib_sa ipv6 ib_uverbs ib_umad iw_cxgb3 cxgb3 mlx4_en mlx4_ib mlx4_core binfmt_mi
sc fuse dm_crypt crypto_blkcipher nls_iso8859_1 loop dm_mod sr_mod cdrom ib_mthc
a tg3 ib_mad shpchp sg ib_core button libphy pci_hotplug qla2xxx mptctl usbhid h
id ff_memless ohci_hcd ehci_hcd usbcore sd_mod crc_t10dif ide_generic mptfc scsi
_transport_fc scsi_tgt mptspi scsi_transport_spi qla1280 sata_vsc sgiioc4 ioc4 x
fs fan ide_pci_generic siimage ide_core mptsas mptscsih mptbase scsi_transport_s
as thermal processor thermal_sys hwmon pata_sil680 libata scsi_mod dock
Supported: Yes

Pid: 4502, CPU 2, comm:             rpc.nfsd
psr : 0000101008526030 ifs : 800000000000040d ip  : [<a0000002044acf30>]    Not 
tainted (2.6.27.15-2-default)
ip is at xs_udp_send_request+0x270/0x340 [sunrpc]
unat: 0000000000000000 pfs : 000000000000040d rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : aa99aaa6aa5aa999
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000002044acd30 b6  : a0000002044accc0 b7  : a0000002044c8fe0
f6  : 1003e000000000000222e f7  : 1003e00000000000004e2
f8  : 1003e00000000000009c4 f9  : 1003e0000001f3eb1b6ce
f10 : 1003e93b691609417c0ec f11 : 1003e0000000000000013
r1  : a0000002044d9760 r2  : a000000204511ba0 r3  : a000000204511ba0
r8  : ffffffffffffff95 r9  : e0000060431825a8 r10 : a000000204511ce0
r11 : 0000000000000000 r12 : e0000060434cfc30 r13 : e0000060434c0000
r14 : 0000000000000000 r15 : e00000607bd79198 r16 : a0000002044e9fa8
r17 : e000006078fc6040 r18 : 0000000000000054 r19 : e000006043182668
r20 : ffffffffffffff95 r21 : 00000001000023ca r22 : e000006078fc6148
r23 : a000000100efa780 r24 : a000000204511ce0 r25 : 0000000000000000
r26 : e000006078fc613c r27 : e00000607bd795a8 r28 : 0000000000000000
r29 : e00000607bd796e0 r30 : 0000000000000000 r31 : e00000607b3dc000

Call Trace:
 [<a000000100016a30>] show_stack+0x50/0xa0
                                sp=e0000060434cf790 bsp=e0000060434c1720
 [<a0000001000172a0>] show_regs+0x820/0x860
                                sp=e0000060434cf960 bsp=e0000060434c16c8
 [<a0000001000266a0>] die+0x1a0/0x2e0
                                sp=e0000060434cf960 bsp=e0000060434c1688
 [<a000000100026830>] die_if_kernel+0x50/0x80
                                sp=e0000060434cf960 bsp=e0000060434c1658
 [<a0000001006e79a0>] ia64_fault+0xac0/0xb60
                                sp=e0000060434cf960 bsp=e0000060434c1610
 [<a00000010000c7a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e0000060434cfa60 bsp=e0000060434c1610
 [<a0000002044acf30>] xs_udp_send_request+0x270/0x340 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c15a0
 [<a0000002044a9a20>] xprt_transmit+0x3a0/0x620 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c1560
 [<a0000002044a28a0>] call_transmit+0x600/0x720 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c1520
 [<a0000002044b5690>] __rpc_execute+0x1d0/0x7a0 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c14a0
 [<a0000002044b5ce0>] rpc_execute+0x80/0xa0 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c1480
 [<a0000002044a43d0>] rpc_run_task+0xf0/0x120 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c1460
 [<a0000002044a46e0>] rpc_call_sync+0xe0/0x160 [sunrpc]
                                sp=e0000060434cfc30 bsp=e0000060434c1430
 [<a0000002044ca500>] rpcb_register_call+0x120/0x220 [sunrpc]
                                sp=e0000060434cfc70 bsp=e0000060434c13e8
 [<a0000002044ca7b0>] rpcb_register+0x1b0/0x1e0 [sunrpc]
                                sp=e0000060434cfcc0 bsp=e0000060434c1398
 [<a0000002044bd200>] svc_register+0x1e0/0x360 [sunrpc]
                                sp=e0000060434cfd20 bsp=e0000060434c1310
 [<a0000002044c0c50>] svc_setup_socket+0x150/0x9a0 [sunrpc]
                                sp=e0000060434cfd30 bsp=e0000060434c12c0
 [<a0000002044c3e10>] svc_addsock+0x1d0/0x480 [sunrpc]
                                sp=e0000060434cfd40 bsp=e0000060434c1270
 [<a000000204b52550>] write_ports+0x1f0/0x6c0 [nfsd]
                                sp=e0000060434cfdd0 bsp=e0000060434c1228
 [<a000000204b54270>] nfsctl_transaction_write+0xf0/0x1c0 [nfsd]
                                sp=e0000060434cfe20 bsp=e0000060434c11e8
 [<a0000001001b6a90>] vfs_write+0x1b0/0x360
                                sp=e0000060434cfe20 bsp=e0000060434c1198
 [<a0000001001b6de0>] sys_write+0x80/0x100
                                sp=e0000060434cfe20 bsp=e0000060434c1120
 [<a00000010000c600>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000060434cfe30 bsp=e0000060434c1120
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e0000060434d0000 bsp=e0000060434c1120

If I read it correctly the xs_sendpages return value is in r8, -ENOTCONN.  We
had xs_udp_finish_connecting in rpciod racing with the above write.

> > The problem is that now in xs_udp_send_request falls into the default:
> > section of that switch statement and tries to do the:
> > 
> > > > +		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
> > 
> > but sock is NULL, so I think that's the oops.
> 
> OK, that makes a lot of sense. We should definitely fix up both
> xs_tcp_send_request() and xs_udp_send_request() to deal correctly with
> that error.

With the patch as it stands I think we will not get into
xs_udp_send_request because xprt_prepare_transmit will have returned
-ENOTCONN and the rpc retried in __rpc_execute:

rpc_execute
	__rpc_execute
		call_transmit
		|       xprt_prepare_transmit
		|               if (!xprt_connected) return -ENOTCONN   *here 
		|       xprt_transmit
		|		xs_udp_send_request

It looks like we just need to protect sock_xprt->sock with respect to
the value of rpc_xprt->state, and Aaron suggested a barrier to do that.
Alternatively we could add a lock to rpc_xprt.

What is your recommendation?

Thanks!
	Ben
