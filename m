Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:49271 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbaAITHU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 14:07:20 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS RDMA client hang (fwd)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.DEB.2.00.1401091923380.83455@bridge1.fy.chalmers.se>
Date: Thu, 9 Jan 2014 14:07:06 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <99CA035A-C6DE-430C-810F-540BCC1E5E36@oracle.com>
References: <alpine.DEB.2.00.1401091923380.83455@bridge1.fy.chalmers.se>
To: =?windows-1252?Q?H=E5kan_Johansson?= <f96hajo@chalmers.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 9, 2014, at 1:26 PM, Håkan Johansson <f96hajo@chalmers.se> wrote:

> 
> Two machines, both running debian squeeze.  (the client with a normal NFS root filesystem).  It works to mount an NFS filesystem via IP over IB giving some 650 MB/s.  When I try to follow the instructions at
> 
> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfs-rdma.txt
> 
> the client fails at the very last stage with a kernel panic.

> 192.168.10.10 is the server, 192.168.10.11 is the client
> 
> mount -vvvv -o vers=3,nolock,tcp,proto=rdma,port=20049 192.168.10.10:/scratch.local1 /mnt
> 
> gives
> 
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: no type was given - I'll assume nfs because of the colon
> mount: spec:  "192.168.10.10:/scratch.local1"
> mount: node:  "/mnt"
> mount: types: "nfs"
> mount: opts:  "vers=3,nolock,tcp,proto=rdma,port=20049"
> mount: external mount: argv[0] = "/sbin/mount.nfs"
> mount: external mount: argv[1] = "192.168.10.10:/scratch.local1"
> mount: external mount: argv[2] = "/mnt"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,vers=3,nolock,tcp,proto=rdma,port=20049"
> mount.nfs: timeout set for Thu Jan  9 18:04:46 2014
> mount.nfs: trying text-based options 'vers=3,nolock,tcp,proto=rdma,port=20049,addr=192.168.10.10'
> 
> and then the client is stuck.  On the console there is a kernel panic
> 
> it is a bit long, so abbreviated here.  (The hang seems easily reproducible, so if really might help you, I could probably make a photo or so)
> 
> ----
> 
> ths appreaded with a 3.12 kernel
> 
> rpcdma: connection to 192.168.10.10:20049 closed (-111)
> rpcdma: connection to 192.168.10.10:20049 closed (-111)
> rpcdma: connection to 192.168.10.10:20049 on mlx4_0, memreg 5 slots 32 ird 16
> 
> very similar below.  the below is with a 3.10 kernel.  in both cases from debian.  also tested with a 3.2 kernel
> 
> general protection fault: 0000 [#1] SMP
> 
> call trace:
> <IRQ>
> tasklet_action+0x73/0xc2
> __do_softirq
> irq_exit
> do_IRQ
> common_interrupt
> <EOI>
> clockevents_program_event
> arch_local_irq_enable
> cpuidle_enter_state
> cpuidle_idle_call
> arch_cpu_idle
> cpu_startup_entry
> start_kernel
> repair_cpu_string
> x86_64_start_kernel
> 
> RIP    rpcrdma_run_tasklet  [xprtrdma]
> 
> ----
> 
> client is a sandy bridge E3-1245
> 
> I bring the infiniband up like this:
> 
> modprobe ib_mthca
> modprobe ib_ipoib
> modprobe mlx4_ib
> modprobe ib_mad
> modprobe ib_umad
> modprobe ib_urdma
> modprobe rdma_cm
> modprobe rdma_ucm
> ibstat
> /etc/init.d/opensm restart
> /sbin/ifconfig ib0 inet 192.168.10.11 up
> IPTABLES=/sbin/iptables
> $IPTABLES -t filter -A OUTPUT -o ib0 -j ACCEPT
> $IPTABLES -t filter -A INPUT -i ib0 -j ACCEPT
> /etc/init.d/opensm restart
> 
> modprobe xprtrdma
> 
> and similar on the server.
> 
> Both have
> 
> InfiniBand: Mellanox Technologies MT25418 [ConnectX VPI PCIe 2.0 2.5GT/s - IB DDR / 10GigE] (rev a0) adapters.
> 
> http://www.ebay.com/itm/HP-452372-001-Infiniband-PCI-E-4X-DDR-Dual-Port-Storage-Host-Channel-Adapter-HCA-/360657396651?pt=UK_Computing_ComputerComponents_InterfaceCards&hash=item53f8db23ab
> 
> Any suggestions?
> 
> ---
> 
> I first sent this mail to nfs-rdma-devel@lists.sourceforge.net (as
> suggested in)
> 
> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfs-rdma.txt
> 
> but got:
> 
> sog-mx-1.v43.ch3.sourceforge.com gave this error: unknown user
> 
> mailing list does not exist any longer?

That documentation is probably out of date.

I don’t see anything immediately wrong with your configuration, but NFS/RDMA has suffered from some bit rot over the past few years.  The current upstream kernels are known to have data corruption bugs and panics.

I recommend staying with NFS on IPoIB for the time being.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



