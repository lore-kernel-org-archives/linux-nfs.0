Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:52436 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaEHP7a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 11:59:30 -0400
Message-ID: <536BA9DE.2060702@gmail.com>
Date: Thu, 08 May 2014 11:59:26 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Senn Klemens <klemens.senn@ims.co.at>, linux-nfs@vger.kernel.org
CC: linux-rdma@vger.kernel.org
Subject: Re: Soft lockup in unloading kernel modules
References: <lkg4ae$hj7$1@ger.gmane.org>
In-Reply-To: <lkg4ae$hj7$1@ger.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I haven't applied Chuck's recent (v3) patches to that kernel yet (I've been waiting to see if people have comments).  I'll try to push something out today.

On 05/08/2014 10:28 AM, Senn Klemens wrote:
> Hi,
>
> I am getting a soft lockup on the NFS server on its reboot if at least
> one client mount is established. I am using OpenSUSE 12.3 with the
> nfs-rdma kernel from Anna Schumaker
> (git://git.linux-nfs.org/projects/anna/nfs-rdma.git).
>
> The export on the server side is done with
> /data	*(fsid=0,crossmnt,rw,mp,no_root_squash,sync,no_subtree_check,insecure)
>
> Following command is used for mounting the NFSv4 share:
> mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.19:/ /mnt
>
> The HCA is a Mellanox MT4099 on the server and the client.
>
> The soft lockup can be reproduced by following steps:
>   o server: Start the nfs server
>   o client: Mount the share
>   o client: Do a "ls" in the mounted directory
>   o server: Stop the nfs server
>   o server: Unload the nfs and mlx4 modules or reboot the server (I used
> the openibd init script from the Mellanox driver without having the
> Mellanox stack installed)
>
> The server reports a soft lockup
>   BUG: soft lockup - CPU#0 stuck for 22s! [modprobe:6146]
> most times.
>
> Sometimes I get following kernel panic
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000003
> IP: [<ffffffff815a5c35>] _raw_spin_lock_bh+0x15/0x40
> PGD 82a820067 PUD 857832067 PMD 0
> Oops: 0002 [#1] SMP
> Modules linked in: nfsd nfs_acl auth_rpcgss oid_registry nfnetlink_log
> nfnetlink bluetooth rfkill nfsv4 svcrdma dm_mod cpuid nfs fscache lockd
> sunrpc af_packet 8021q garp stp llc rdma_ucm ib_ucm rdma_cm iw_cm
> ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib(-) ib_sa ib_mad ib_core
> ib_addr sr_mod cdrom usb_storage joydev mlx4_core usbhid
> x86_pkg_temp_thermal coretemp kvm_intel kvm ghash_clmulni_intel
> aesni_intel ablk_helper cryptd iTCO_wdt lrw igb gf128mul
> iTCO_vendor_support ehci_pci glue_helper pcspkr i2c_algo_bit isci
> ehci_hcd aes_x86_64 ptp libsas ioatdma lpc_ich microcode sb_edac sg
> pps_core usbcore ipmi_si tpm_tis edac_core scsi_transport_sas i2c_i801
> mfd_core dca usb_common tpm ipmi_msghandler wmi acpi_cpufreq button edd
> autofs4 xfs libcrc32c crc32c_intel processor thermal_sys scsi_dh_rdac
> scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh [last unloaded: oid_registry]
> CPU: 0 PID: 6603 Comm: modprobe Not tainted 3.15.0-rc2-anna-nfs-rdma+ #3
> Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0 09/04/2013
> task: ffff88105b8c6050 ti: ffff88105d814000 task.ti: ffff88105d814000
> RIP: 0010:[<ffffffff815a5c35>]  [<ffffffff815a5c35>]
> _raw_spin_lock_bh+0x15/0x40
> RSP: 0018:ffff88105d815d18  EFLAGS: 00010286
> RAX: 0000000000010000 RBX: ffffffffffffffff RCX: 0000000000000000
> RDX: 000000000000000b RSI: 0000000000000000 RDI: 0000000000000003
> RBP: ffff88105d815d18 R08: ffff88087c611f38 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff88087c3c9800
> R13: ffff88107b82ab00 R14: 0000000000000003 R15: 0000000000000007
> FS:  00007fef64612700(0000) GS:ffff88087fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000003 CR3: 000000087c2c7000 CR4: 00000000000407f0
> Stack:
>  ffff88105d815d58 ffffffffa05199f0 ffff88105d815d88 ffff88087c3c9800
>  ffff88087c3c9400 ffff88107b82ab00 ffff88087c3c9660 ffff88087c3c95c8
>  ffff88105d815d78 ffffffffa0421ce9 ffff88087c3c9400 ffff88107b82aac0
> Call Trace:
>  [<ffffffffa05199f0>] svc_xprt_enqueue+0x50/0x220 [sunrpc]
>  [<ffffffffa0421ce9>] rdma_cma_handler+0x69/0x180 [svcrdma]
>  [<ffffffffa039d086>] cma_remove_one+0x1f6/0x220 [rdma_cm]
>  [<ffffffffa01dca86>] ib_unregister_device+0x46/0x120 [ib_core]
>  [<ffffffffa032ddc9>] mlx4_ib_remove+0x29/0x260 [mlx4_ib]
>  [<ffffffffa02fb9d0>] mlx4_remove_device+0xa0/0xc0 [mlx4_core]
>  [<ffffffffa02fba2b>] mlx4_unregister_interface+0x3b/0xa0 [mlx4_core]
>  [<ffffffffa033f4cc>] mlx4_ib_cleanup+0x10/0x23 [mlx4_ib]
>  [<ffffffff810bd6b2>] SyS_delete_module+0x152/0x220
>  [<ffffffff811496e4>] ? vm_munmap+0x54/0x70
>  [<ffffffff815adca6>] system_call_fastpath+0x1a/0x1f
> Code: 5d c3 0f b7 17 66 39 ca 74 f6 f3 90 0f b7 17 66 39 d1 75 f6 5d c3
> 55 65 81 04 25 20 b9 00 00 00 02 00 00 48 89 e5 b8 00 00 01 00 <f0> 0f
> c1 07 89 c2 c1 ea 10 66 39 c2 75 04 5d c3 f3 90 0f b7 07
> RIP  [<ffffffff815a5c35>] _raw_spin_lock_bh+0x15/0x40
>  RSP <ffff88105d815d18>
> CR2: 0000000000000003
> ---[ end trace 18e02ff413ac4b9b ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range:
> 0xffffffff80000000-0xffffffff9fffffff)
> ---[ end Kernel panic - not syncing: Fatal exception in interrupt
>
> Kind regards,
> Klemens
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

