Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51449 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbaESVCw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 17:02:52 -0400
Message-ID: <537A7174.6080008@oracle.com>
Date: Mon, 19 May 2014 14:02:44 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Klemens Senn <klemens.senn@ims.co.at>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Soft lockup in unloading kernel modules
References: <lkg4ae$hj7$1@ger.gmane.org> <536BA9DE.2060702@gmail.com> <53724CF1.8030509@ims.co.at> <B8C78BF6-A287-4409-A504-76670A68C9A2@oracle.com>
In-Reply-To: <B8C78BF6-A287-4409-A504-76670A68C9A2@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Klements,

Can you add more details on how to unloading the modules (step by step) 
in the bug report?

Thanks
Shirley

On 05/19/2014 10:51 AM, Chuck Lever wrote:
> Hi Klemens-
>
> On May 13, 2014, at 12:48 PM, Klemens Senn <klemens.senn@ims.co.at> wrote:
>
>> Hi Anna,
>>
>> today I retried unloading the kernel modules with your updated kernel
>> and additionally I tried the nfsd-next kernel from J. Bruce Fields and
>> Chuck's nfs-rdma-client kernel.
> I filed
>
>    https://bugzilla.linux-nfs.org/show_bug.cgi?id=252
>
> to track this issue.
>
>
>> In short: None of these was able to unload the kernel modules with an
>> active connection.
>>
>> In detail:
>>
>> With your kernel I got following 3 faults:
>>   o BUG: soft lockup - CPU#0 stuck for 22s! [modprobe:4615]
>>   o BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000003
>>   o BUG: unable to handle kernel paging request at 0000000000005b8c
>>
>> With the nfsd-next kernel I got following results:
>>   o BUG: soft lockup - CPU#0 stuck for 23s! [modprobe:4452]
>>   o module unloading blocks forever, dmesg shows:
>>     nfsd: last server has exited, flushing export cache
>>     waiting module removal not supported: please upgrade
>>   o Kernel keeps running but reports the following:
>>     nfsd: last server has exited, flushing export cache
>>     waiting module removal not supported: please upgrade
>>     svc_xprt_enqueue: threads and transports both waiting??
>>     INFO: task modprobe:4510 blocked for more than 480 seconds.
>>           Not tainted 3.15.0-rc1-bfields-master+ #1
>>     "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>>     modprobe        D ffff88087fc13440     0  4510   4458 0x00000000
>>      ffff88105bb23c58 0000000000000086 ffff88105c14e690 0000000000013440
>>      ffff88105bb23fd8 0000000000013440 ffffffff81a14480 ffff88105c14e690
>>      0000000000000037 ffff88085d7f74d8 ffff88085d7f74e0 7fffffffffffffff
>>     Call Trace:
>>      [<ffffffff815a2424>] schedule+0x24/0x70
>>      [<ffffffff815a18cc>] schedule_timeout+0x1ec/0x260
>>      [<ffffffff8159a504>] ? printk+0x5c/0x5e
>>      [<ffffffff815a3406>] wait_for_completion+0x96/0x100
>>      [<ffffffff81080c90>] ? try_to_wake_up+0x2b0/0x2b0
>>      [<ffffffffa0314039>] cma_remove_one+0x1a9/0x220 [rdma_cm]
>>      [<ffffffffa01fea86>] ib_unregister_device+0x46/0x120 [ib_core]
>>      [<ffffffffa02c5dc9>] mlx4_ib_remove+0x29/0x260 [mlx4_ib]
>>      [<ffffffffa04319d0>] mlx4_remove_device+0xa0/0xc0 [mlx4_core]
>>      [<ffffffffa0431a2b>] mlx4_unregister_interface+0x3b/0xa0 [mlx4_core]
>>      [<ffffffffa02d74cc>] mlx4_ib_cleanup+0x10/0x23 [mlx4_ib]
>>      [<ffffffff810bd612>] SyS_delete_module+0x152/0x220
>>      [<ffffffff81149684>] ? vm_munmap+0x54/0x70
>>      [<ffffffff815ad5a6>] system_call_fastpath+0x1a/0x1f
>>
>> With the nfs-rdma-client I got following results:
>>   o module unloading blocks forever, dmesg shows:
>>     nfsd: last server has exited, flushing export cache
>>     svc_xprt_enqueue: threads and transports both waiting??
>>   o BUG: unable to handle kernel paging request at 0000000000004dec
>>     IP: [<ffffffff815a63b5>] _raw_spin_lock_bh+0x15/0x40
>>     PGD 107ba9a067 PUD 105c093067 PMD 0
>>     Oops: 0002 [#1] SMP
>>     Modules linked in: nfsd nfs_acl auth_rpcgss oid_registry svcrdma
>> dm_mod cpuid nfs fscache lockd sunrpc af_packet 8021q garp stp llc
>> rdma_ucm ib_ucm rdma_cm iw_cm ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en
>> mlx4_ib(-) ib_sa ib_mad ib_core ib_addr sr_mod cdrom usb_storage joydev
>> mlx4_core usbhid x86_pkg_temp_thermal coretemp kvm_intel kvm
>> ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul
>> glue_helper ehci_pci aes_x86_64 ehci_hcd isci iTCO_wdt libsas pcspkr
>> iTCO_vendor_support igb i2c_algo_bit sb_edac lpc_ich edac_core ioatdma
>> usbcore tpm_tis ptp microcode i2c_i801 sg mfd_core scsi_transport_sas
>> ipmi_si usb_common tpm wmi pps_core dca ipmi_msghandler acpi_cpufreq
>> button edd autofs4 xfs libcrc32c crc32c_intel processor thermal_sys
>> scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh
>>     CPU: 14 PID: 4813 Comm: modprobe Not tainted
>> 3.15.0-rc5-cel-nfs-rdma-client-unpatched+ #2
>>     Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0 09/04/2013
>>     task: ffff88085bf96190 ti: ffff88085d42a000 task.ti: ffff88085d42a000
>>     RIP: 0010:[<ffffffff815a63b5>]  [<ffffffff815a63b5>]
>> _raw_spin_lock_bh+0x15/0x40
>>     RSP: 0018:ffff88085d42bd18  EFLAGS: 00010286
>>     RAX: 0000000000010000 RBX: 0000000000004de8 RCX: 0000000000000000
>>     RDX: 000000000000000b RSI: 000000000000000e RDI: 0000000000004dec
>>     RBP: ffff88085d42bd18 R08: ffff88087c611f38 R09: 000000000000a140
>>     R10: 000000000000002b R11: 0000000000000000 R12: ffff88085dcc3c00
>>     R13: ffff88105ca13280 R14: 0000000000004dec R15: 0000000000004df0
>>     FS:  00007f0e49fb5700(0000) GS:ffff88107fcc0000(0000)
>> knlGS:0000000000000000
>>     CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>     CR2: 0000000000004dec CR3: 000000105b027000 CR4: 00000000000407e0
>>     Stack:
>>      ffff88085d42bd58 ffffffffa03bd9f0 0000000001328b88 ffff88085dcc3c00
>>      ffff88085dce8000 ffff88105ca13280 ffff88085dce8260 ffff88085dce81c8
>>      ffff88085d42bd78 ffffffffa0441ce9 ffff88085dce8000 ffff88105ca13240
>>     Call Trace:
>>      [<ffffffffa03bd9f0>] svc_xprt_enqueue+0x50/0x220 [sunrpc]
>>      [<ffffffffa0441ce9>] rdma_cma_handler+0x69/0x180 [svcrdma]
>>      [<ffffffffa031a086>] cma_remove_one+0x1f6/0x220 [rdma_cm]
>>      [<ffffffffa0261a86>] ib_unregister_device+0x46/0x120 [ib_core]
>>      [<ffffffffa02b9dc9>] mlx4_ib_remove+0x29/0x260 [mlx4_ib]
>>      [<ffffffffa02329d0>] mlx4_remove_device+0xa0/0xc0 [mlx4_core]
>>      [<ffffffffa0232a2b>] mlx4_unregister_interface+0x3b/0xa0 [mlx4_core]
>>      [<ffffffffa02cb4cc>] mlx4_ib_cleanup+0x10/0x23 [mlx4_ib]
>>      [<ffffffff810bd6f0>] SyS_delete_module+0x170/0x1f0
>>      [<ffffffff811497f4>] ? vm_munmap+0x54/0x70
>>      [<ffffffff815ae426>] system_call_fastpath+0x1a/0x1f
>>     Code: 5d c3 0f b7 17 66 39 ca 74 f6 f3 90 0f b7 17 66 39 d1 75 f6 5d
>> c3 55 65 81 04 25 20 b9 00 00 00 02 00 00 48 89 e5 b8 00 00 01 00 <f0>
>> 0f c1 07 89 c2 c1 ea 10 66 39 c2 75 04 5d c3 f3 90 0f b7 07
>>     RIP  [<ffffffff815a63b5>] _raw_spin_lock_bh+0x15/0x40
>>      RSP <ffff88085d42bd18>
>>     CR2: 0000000000004dec
>>     ---[ end trace bf1fd548a33cbfc4 ]---
>>     Kernel panic - not syncing: Fatal exception in interrupt
>>     Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range:
>> 0xffffffff80000000-0xffffffff9fffffff)
>>     ---[ end Kernel panic - not syncing: Fatal exception in interrupt
>>
>>
>> Regards,
>> Klemens
>>
>>
>> On 05/08/2014 05:59 PM, Anna Schumaker wrote:
>>> I haven't applied Chuck's recent (v3) patches to that kernel yet (I've been waiting to see if people have comments).  I'll try to push something out today.
>>>
>>> On 05/08/2014 10:28 AM, Senn Klemens wrote:
>>>> Hi,
>>>>
>>>> I am getting a soft lockup on the NFS server on its reboot if at least
>>>> one client mount is established. I am using OpenSUSE 12.3 with the
>>>> nfs-rdma kernel from Anna Schumaker
>>>> (git://git.linux-nfs.org/projects/anna/nfs-rdma.git).
>>>>
>>>> The export on the server side is done with
>>>> /data	*(fsid=0,crossmnt,rw,mp,no_root_squash,sync,no_subtree_check,insecure)
>>>>
>>>> Following command is used for mounting the NFSv4 share:
>>>> mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.19:/ /mnt
>>>>
>>>> The HCA is a Mellanox MT4099 on the server and the client.
>>>>
>>>> The soft lockup can be reproduced by following steps:
>>>>   o server: Start the nfs server
>>>>   o client: Mount the share
>>>>   o client: Do a "ls" in the mounted directory
>>>>   o server: Stop the nfs server
>>>>   o server: Unload the nfs and mlx4 modules or reboot the server (I used
>>>> the openibd init script from the Mellanox driver without having the
>>>> Mellanox stack installed)
>>>>
>>>> The server reports a soft lockup
>>>>   BUG: soft lockup - CPU#0 stuck for 22s! [modprobe:6146]
>>>> most times.
>>>>
>>>> Sometimes I get following kernel panic
>>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000003
>>>> IP: [<ffffffff815a5c35>] _raw_spin_lock_bh+0x15/0x40
>>>> PGD 82a820067 PUD 857832067 PMD 0
>>>> Oops: 0002 [#1] SMP
>>>> Modules linked in: nfsd nfs_acl auth_rpcgss oid_registry nfnetlink_log
>>>> nfnetlink bluetooth rfkill nfsv4 svcrdma dm_mod cpuid nfs fscache lockd
>>>> sunrpc af_packet 8021q garp stp llc rdma_ucm ib_ucm rdma_cm iw_cm
>>>> ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib(-) ib_sa ib_mad ib_core
>>>> ib_addr sr_mod cdrom usb_storage joydev mlx4_core usbhid
>>>> x86_pkg_temp_thermal coretemp kvm_intel kvm ghash_clmulni_intel
>>>> aesni_intel ablk_helper cryptd iTCO_wdt lrw igb gf128mul
>>>> iTCO_vendor_support ehci_pci glue_helper pcspkr i2c_algo_bit isci
>>>> ehci_hcd aes_x86_64 ptp libsas ioatdma lpc_ich microcode sb_edac sg
>>>> pps_core usbcore ipmi_si tpm_tis edac_core scsi_transport_sas i2c_i801
>>>> mfd_core dca usb_common tpm ipmi_msghandler wmi acpi_cpufreq button edd
>>>> autofs4 xfs libcrc32c crc32c_intel processor thermal_sys scsi_dh_rdac
>>>> scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh [last unloaded: oid_registry]
>>>> CPU: 0 PID: 6603 Comm: modprobe Not tainted 3.15.0-rc2-anna-nfs-rdma+ #3
>>>> Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0 09/04/2013
>>>> task: ffff88105b8c6050 ti: ffff88105d814000 task.ti: ffff88105d814000
>>>> RIP: 0010:[<ffffffff815a5c35>]  [<ffffffff815a5c35>]
>>>> _raw_spin_lock_bh+0x15/0x40
>>>> RSP: 0018:ffff88105d815d18  EFLAGS: 00010286
>>>> RAX: 0000000000010000 RBX: ffffffffffffffff RCX: 0000000000000000
>>>> RDX: 000000000000000b RSI: 0000000000000000 RDI: 0000000000000003
>>>> RBP: ffff88105d815d18 R08: ffff88087c611f38 R09: 0000000000000001
>>>> R10: 0000000000000000 R11: 0000000000000000 R12: ffff88087c3c9800
>>>> R13: ffff88107b82ab00 R14: 0000000000000003 R15: 0000000000000007
>>>> FS:  00007fef64612700(0000) GS:ffff88087fc00000(0000) knlGS:0000000000000000
>>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> CR2: 0000000000000003 CR3: 000000087c2c7000 CR4: 00000000000407f0
>>>> Stack:
>>>> ffff88105d815d58 ffffffffa05199f0 ffff88105d815d88 ffff88087c3c9800
>>>> ffff88087c3c9400 ffff88107b82ab00 ffff88087c3c9660 ffff88087c3c95c8
>>>> ffff88105d815d78 ffffffffa0421ce9 ffff88087c3c9400 ffff88107b82aac0
>>>> Call Trace:
>>>> [<ffffffffa05199f0>] svc_xprt_enqueue+0x50/0x220 [sunrpc]
>>>> [<ffffffffa0421ce9>] rdma_cma_handler+0x69/0x180 [svcrdma]
>>>> [<ffffffffa039d086>] cma_remove_one+0x1f6/0x220 [rdma_cm]
>>>> [<ffffffffa01dca86>] ib_unregister_device+0x46/0x120 [ib_core]
>>>> [<ffffffffa032ddc9>] mlx4_ib_remove+0x29/0x260 [mlx4_ib]
>>>> [<ffffffffa02fb9d0>] mlx4_remove_device+0xa0/0xc0 [mlx4_core]
>>>> [<ffffffffa02fba2b>] mlx4_unregister_interface+0x3b/0xa0 [mlx4_core]
>>>> [<ffffffffa033f4cc>] mlx4_ib_cleanup+0x10/0x23 [mlx4_ib]
>>>> [<ffffffff810bd6b2>] SyS_delete_module+0x152/0x220
>>>> [<ffffffff811496e4>] ? vm_munmap+0x54/0x70
>>>> [<ffffffff815adca6>] system_call_fastpath+0x1a/0x1f
>>>> Code: 5d c3 0f b7 17 66 39 ca 74 f6 f3 90 0f b7 17 66 39 d1 75 f6 5d c3
>>>> 55 65 81 04 25 20 b9 00 00 00 02 00 00 48 89 e5 b8 00 00 01 00 <f0> 0f
>>>> c1 07 89 c2 c1 ea 10 66 39 c2 75 04 5d c3 f3 90 0f b7 07
>>>> RIP  [<ffffffff815a5c35>] _raw_spin_lock_bh+0x15/0x40
>>>> RSP <ffff88105d815d18>
>>>> CR2: 0000000000000003
>>>> ---[ end trace 18e02ff413ac4b9b ]---
>>>> Kernel panic - not syncing: Fatal exception in interrupt
>>>> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range:
>>>> 0xffffffff80000000-0xffffffff9fffffff)
>>>> ---[ end Kernel panic - not syncing: Fatal exception in interrupt
>>>>
>>>> Kind regards,
>>>> Klemens
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

