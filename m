Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nautica.notk.org ([91.121.71.147]:40702 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab2E3Lyb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 07:54:31 -0400
Date: Wed, 30 May 2012 13:43:38 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: NFS/RDMA - client crash on mount
Message-ID: <20120530114338.GA28445@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm currently trying to setup a NFS/RDMA server/client pair. base system
is CentOS release 6.2

I tried both the provided kernel 2.6.32-220.el6.x86_64 and a
custom-built 3.4.0 (x86_64), and the result is exactly the same.
Both server and client use nfs-utils version 1.2.3.

Hardware-wise, both servers are virtual machines using softiwarp (
http://gitorious.org/softiwarp ) to emulate the rdma layer.
It might be the source of the problem, but both rping (obviously) and
diod/9pnet_rdma work flawlessly, so I suppose there might be something
else.


Server setup:
# cat /etc/exports 
/tmp 10.3.4.3/255.255.255.255(fsid=0,rw,async,insecure,no_root_squash)
# cat /proc/fs/nfsd/portlist
rdma 20049
udp 2049
tcp 2049
udp 2049
tcp 2049
# echo 32767 > /proc/sys/sunrpc/rpc_debug
 (rdma also on with full debug)




Client setup:
# modprobe xprtrdma
# echo 32767 > /proc/sys/sunrpc/rpc_debug 
# mount -vvv -t nfs -o proto=rdma,port=20049 10.3.4.2:/tmp /mnt/t
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: UID:        0
mount: eUID:       0
mount: spec:  "10.3.4.2:/tmp"
mount: node:  "/mnt/t"
mount: types: "nfs"
mount: opts:  "proto=rdma,port=20049"
mount: external mount: argv[0] = "/sbin/mount.nfs"
mount: external mount: argv[1] = "10.3.4.2:/tmp"
mount: external mount: argv[2] = "/mnt/t"
mount: external mount: argv[3] = "-v"
mount: external mount: argv[4] = "-o"
mount: external mount: argv[5] = "rw,proto=rdma,port=20049"
mount.nfs: timeout set for Wed May 30 08:55:22 2012
mount.nfs: trying text-based options
'proto=rdma,port=20049,vers=4,addr=10.3.4.2,clientaddr=10.3.4.3'
Connection to 10.3.4.3 closed by remote host.


After this, I've lost ssh access, the VM doesn't reply to ping won't
reboot with a soft-reboot.
The login prompt is apparently still live, but won't accept a user.
After reboot, there is no log of what happened whatsoever on the client,
but I could get this backtrace with a netconsole:

RPC:       looking up machine cred for service *
RPC:       xprt_setup_rdma: 10.3.4.2:20049
( 7644/1) siw_add_obj(OBJ9975): IDR New Object
( 7644/1) siw_pd_add(PD9975): New Object
RPC:       rpcrdma_ia_open: FRMR registration specified but not
supported by adapter, using riskier RPCRDMA_ALLPHYSICAL
( 7644/1) siw_mem_add(IDR10286): New Object
( 7644/1) siw_alloc_mr(MEM10286): New Object, UMEM           (null)
( 7644/1) siw_pd_get(PD9975): New refcount: 2
RPC:       rpcrdma_ia_open: memory registration strategy is 6
RPC:       rpcrdma_ep_create: requested max: dtos: send 32 recv 32;
iovs: send 2 recv 1
( 7644/0) siw_add_obj(OBJ23494): IDR New Object
( 7644/0) siw_cq_add(CQ23494): New Object
( 7644/0) siw_req_notify_cq(CQ23494:) flags: 0x       2
RPC:       rpcrdma_buffer_create: max_requests 32
RPC:       created transport ffff880205320000 with 32 slots
RPC:       creating nfs client for 10.3.4.2 (xprt ffff880205320000)
RPC:       creating UNIX authenticator for client ffff8802047f6800
RPC:       new task initialized, procpid 7644
RPC:       allocated task ffff880216294080
RPC:     1 __rpc_execute flags=0x680
RPC:     1 call_start nfs4 proc NULL (sync)
RPC:     1 call_reserve (status 0)
RPC:       xprt_rdma_reserve_xprt: cwndscale 256
RPC:     1 reserved req ffff88020463f200 xid def103c4
RPC:       wake_up_first(ffff880205320178 "xprt_sending")
RPC:     1 call_reserveresult (status 0)
RPC:     1 call_refresh (status 0)
RPC:     1 holding NULL cred ffffffff8185b650
RPC:     1 refreshing NULL cred ffffffff8185b650
RPC:     1 call_refreshresult (status 0)
RPC:     1 call_allocate (status 0)
RPC:       xprt_rdma_allocate: size 88, request 0xffff88020b450000
RPC:     1 call_bind (status 0)
RPC:     1 call_connect xprt ffff880205320000 is not connected
RPC:     1 xprt_connect xprt ffff880205320000 is not connected
RPC:     1 xprt_cwnd_limited cong = 0 cwnd = 256
RPC:     1 sleep_on(queue "xprt_pending" time 4308025979)
RPC:     1 added to queue ffff880205320228 "xprt_pending"
RPC:     1 setting alarm for 60000 ms
RPC:       xprt_rdma_connect_worker: connect
(   41/3) siw_create_qp: new QP on device siw_eth0
(   41/3) siw_add_obj(OBJ26807): IDR New Object
(   41/3) siw_qp_add(QP26807): New Object
(   41/3) siw_pd_get(PD9975): New refcount: 3
-------- siw_ofed_modify_qp -------
IB_QP_STATE
IB_QP_ACCESS_FLAGS
-------- siw_ofed_modify_qp -(end)-
(   41/3) siw_ofed_modify_qp(QP26807): Desired IB QP state: INIT
(   41/3) siw_qp_modify(QP26807)
(   41/3) siw_qp_modify(QP26807): SIW QP state: IDLE => IDLE
(   41/3) siw_qp_modify QP state transition undefined: IDLE => IDLE
(   41/3) siw_ofed_modify_qp(QP26807): Exit with 0
BUG: unable to handle kernel NULL pointer dereference at
(null)
IP: [<ffffffffa01faced>] rpcrdma_ep_connect+0x126/0x2e6 [xprtrdma]
PGD 0 
Oops: 0000 [#1] SMP 
CPU 3 
Modules linked in: netconsole xprtrdma 9pnet_rdma 9p 9pnet fscache
siw(O) rdma_ucm ib_uverbs rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core
ib_addr ipv6 joydev microcode pcspkr virtio_net virtio_balloon i2c_piix4
i2c_core ext4 jbd2 crc16 virtio_blk virtio_pci virtio_ring virtio
uhci_hcd floppy button [last unloaded: scsi_wait_scan]

Pid: 41, comm: kworker/3:1 Tainted: G           O 3.4.0-rdma+ #4 Red Hat
KVM
RIP: 0010:[<ffffffffa01faced>]  [<ffffffffa01faced>]
rpcrdma_ep_connect+0x126/0x2e6 [xprtrdma]
RSP: 0018:ffff88020b55bd20  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880205320568 RCX: 0000000000000001
RDX: 0000000000000003 RSI: ffffffffa01fd6e9 RDI: 0000000000000246
RBP: ffff880205320520 R08: 0000000000000002 R09: 6db6db6db6db6db7
R10: 0000160000000000 R11: 0000000000000400 R12: 0000000000000000
R13: 0000000000000000 R14: ffffffffa01f7c35 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88021fcc0000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000215f4a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/3:1 (pid: 41, threadinfo ffff88020b55a000, task
ffff88020b444870)
Stack:
 ffff88021fcd1c00 ffffffff813cd304 0000000000000000 ffff880216d0e870
 0000000000011c00 64ff880200000004 0000000000011c00 ffff880205320000
 ffff8802053207a0 ffff88021fccd2c0 ffff88021fcd4b00 ffffffffa01f7c35
Call Trace:


On the server, there isn't any record of anything happening either,
dmesg should print something if an rdma connection is established and
sunrpc ought to say something as well.

If the server isn't started, the client doesn't crash - it just times
out as expected:
mount.nfs: mount(2): Connection timed out
mount.nfs: trying text-based options
'proto=rdma,port=20049,vers=4,addr=10.3.4.2,clientaddr=10.3.4.3'
mount.nfs: mount(2): Connection timed out


Also, if it helps, I saw a similar bugreport here:
http://lists.openfabrics.org/pipermail/ewg/2010-January/014604.html but
it didn't get any useful replies




Sooo. Could anyone tell me what goes wrong and give me a clue to fix it?


I tried to give all the info I could gather, but if I forgot something
just ask away, and if there is something I can try I'd gladly do so.


Thanks,
-- 
Asmadeus | Dominique Martinet
