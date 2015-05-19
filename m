Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58151 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789AbbESHz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2015 03:55:59 -0400
Date: Tue, 19 May 2015 13:25:49 +0530 (IST)
From: Govindarajulu Varadarajan <_govind@gmx.com>
To: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
cc: clm@fb.com, jbacik@fb.com, dsterba@suse.cz
Subject: btrfs: kernel BUG at mm/page-writeback.c:2286!
Message-ID: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all

I am seeing the following crash on my btrfs filesystem with nfs export.
If I disable the nfs share and reboot, I do not hit the crash. Look like
the crash happens on btrfs with nfs export.

Is this a known issue? Has anyone else faced this? Let me know if you need more
information.

Thanks

mm/page-writeback.c:2286:
int clear_page_dirty_for_io(struct page *page) 
{
         struct address_space *mapping = page_mapping(page);

2286--->BUG_ON(!PageLocked(page));

[  166.769868] BTRFS info (device sdf): no csum found for inode 1154 start 43192320
[  166.774334] BTRFS info (device sdf): csum failed ino 1154 extent 4434247680 csum 1388825687 wanted 0 mirror 0
[  166.774453] ------------[ cut here ]------------
[  166.774481] kernel BUG at mm/page-writeback.c:2286!
[  166.774495] invalid opcode: 0000 [#1] PREEMPT SMP 
[  166.774514] Modules linked in: nfsv3 target_core_user uio target_core_pscsi target_core_file target_core_iblock iscsi_target_mod target_core_mod rpcsec_gss_krb5 nfsv4 dns_resolver coretemp intel_rapl iosf_mbi x86_pkg_temp_thermal intel_powerclamp kvm_intel kvm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel aes_x86_64 iTCO_wdt lrw joydev gf128mul mgag200 glue_helper ablk_helper mousedev evdev pcspkr iTCO_vendor_support cryptd ttm drm_kms_helper drm syscopyarea sysfillrect mac_hid sysimgblt i2c_i801 lpc_ich acpi_power_meter tpm_tis sb_edac edac_core wmi shpchp processor ipmi_si ipmi_msghandler tpm ac button sch_fq_codel ses enclosure sd_mod hid_generic usbhid hid ehci_pci ehci_hcd megaraid_sas scsi_mod usbcore usb_common nfsd auth_rpcgss oid_registry nfs_acl nfs lockd grace sunrpc fscache
[  166.774801]  igb hwmon ptp pps_core i2c_algo_bit i2c_core dca ext4 crc16 mbcache jbd2 crc32c_generic crc32c_intel btrfs xor raid6_pq
[  166.774852] CPU: 4 PID: 806 Comm: nfsd Not tainted 4.1.0-rc3-ARCH-00165-g110bc76 #4
[  166.774873] Hardware name: Cisco Systems Inc UCSC-C240-M3S/UCSC-C240-M3S, BIOS C240M3.1.5.1c.0.013120130509 01/31/2013
[  166.774901] task: ffff88183796c980 ti: ffff881839034000 task.ti: ffff881839034000
[  166.774922] RIP: 0010:[<ffffffff811681f0>]  [<ffffffff811681f0>] clear_page_dirty_for_io+0xd0/0xf0
[  166.774950] RSP: 0018:ffff881839037908  EFLAGS: 00010246
[  166.774965] RAX: 02fffe0000000806 RBX: ffffea0030ffd680 RCX: 0000000000000484
[  166.774985] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffea0030ffd680
[  166.775004] RBP: ffff881839037918 R08: 000000000001ff40 R09: ffff880c474e8600
[  166.775023] R10: ffff880c4fb1ff40 R11: ffffea00311943c0 R12: ffff880c44210300
[  166.775042] R13: 0000000000000001 R14: ffff880c48355b40 R15: 0000000000000000
[  166.775062] FS:  0000000000000000(0000) GS:ffff880c4fb00000(0000) knlGS:0000000000000000
[  166.775083] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  166.775099] CR2: 00007fcfe214e0a0 CR3: 000000000173f000 CR4: 00000000000407e0
[  166.775118] Stack:
[  166.775125]  0000000000000001 ffff880c48355b40 ffff881839037988 ffffffffa0073d32
[  166.775150]  ffff881839037a10 0000000000000050 0000000000001000 ffff880c442101b0
[  166.775174]  ffff880c44210040 ffff881839037a20 ffff880c4937ee40 0000000000000001
[  166.775198] Call Trace:
[  166.775220]  [<ffffffffa0073d32>] lock_and_cleanup_extent_if_need+0x72/0x1f0 [btrfs]
[  166.775248]  [<ffffffffa0074f91>] __btrfs_buffered_write+0x1b1/0x680 [btrfs]
[  166.775273]  [<ffffffffa0078a72>] btrfs_file_write_iter+0x162/0x5a0 [btrfs]
[  166.775295]  [<ffffffff811d469c>] do_iter_readv_writev+0x6c/0xb0
[  166.775312]  [<ffffffff811d4dcb>] do_readv_writev+0x13b/0x280
[  166.775334]  [<ffffffffa0078910>] ? btrfs_sync_file+0x380/0x380 [btrfs]
[  166.775354]  [<ffffffff81200437>] ? inode_to_bdi+0x27/0x60
[  166.775371]  [<ffffffff811d1dd0>] ? finish_no_open+0x20/0x20
[  166.775388]  [<ffffffff8116a229>] ? file_ra_state_init+0x19/0x30
[  166.775405]  [<ffffffff811d25e0>] ? do_dentry_open+0x230/0x320
[  166.775422]  [<ffffffff811d4f99>] vfs_writev+0x39/0x50
[  166.775443]  [<ffffffffa03510c8>] nfsd_vfs_write.isra.15+0xb8/0x380 [nfsd]
[  166.775467]  [<ffffffffa035474c>] nfsd_write+0xec/0x100 [nfsd]
[  166.775487]  [<ffffffffa035b44b>] nfsd3_proc_write+0xbb/0x160 [nfsd]
[  166.776205]  [<ffffffffa034d023>] nfsd_dispatch+0xc3/0x220 [nfsd]
[  166.776922]  [<ffffffffa029c7c2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[  166.777639]  [<ffffffffa029b04c>] svc_process_common+0x45c/0x680 [sunrpc]
[  166.778371]  [<ffffffffa029b383>] svc_process+0x113/0x200 [sunrpc]
[  166.779087]  [<ffffffffa034c9f7>] nfsd+0x107/0x170 [nfsd]
[  166.779765]  [<ffffffffa034c8f0>] ? nfsd_destroy+0x80/0x80 [nfsd]
[  166.780465]  [<ffffffff810978d8>] kthread+0xd8/0xf0
[  166.781137]  [<ffffffff81097800>] ? kthread_create_on_node+0x1c0/0x1c0
[  166.781799]  [<ffffffff8157a722>] ret_from_fork+0x42/0x70
[  166.782443]  [<ffffffff81097800>] ? kthread_create_on_node+0x1c0/0x1c0
[  166.783072] Code: 41 5c 5d c3 0f 1f 80 00 00 00 00 48 89 df e8 f8 0d 03 00 85 c0 75 1c f0 0f ba 33 04 72 85 31 c0 e9 75 ff ff ff 66 0f 1f 44 00 00 <0f> 0b 66 0f 1f 44 00 00 48 89 df e8 60 fe ff ff eb da 66 66 66 
[  166.784408] RIP  [<ffffffff811681f0>] clear_page_dirty_for_io+0xd0/0xf0
[  166.785026]  RSP <ffff881839037908>
[  166.785630] ---[ end trace c20a91c708e09203 ]---


[root@stg ~]#btrfs fi sh
Label: 'stg'  uuid: dd10b751-d2aa-40d1-971f-e15b0062dd11
 	Total devices 14 FS bytes used 101.80GiB
 	devid    1 size 278.46GiB used 9.47GiB path /dev/sdb
 	devid    2 size 278.46GiB used 9.47GiB path /dev/sdc
 	devid    3 size 278.46GiB used 9.47GiB path /dev/sdd
 	devid    4 size 278.46GiB used 9.47GiB path /dev/sde
 	devid    5 size 278.46GiB used 9.47GiB path /dev/sdf
 	devid    6 size 278.46GiB used 9.47GiB path /dev/sdg
 	devid    7 size 278.46GiB used 9.47GiB path /dev/sdh
 	devid    8 size 278.46GiB used 9.47GiB path /dev/sdi
 	devid    9 size 278.46GiB used 9.47GiB path /dev/sdj
 	devid   10 size 278.46GiB used 9.47GiB path /dev/sdk
 	devid   11 size 278.46GiB used 9.47GiB path /dev/sdl
 	devid   12 size 278.46GiB used 9.47GiB path /dev/sdm
 	devid   13 size 278.46GiB used 9.47GiB path /dev/sdn
 	devid   14 size 278.46GiB used 9.47GiB path /dev/sdo

btrfs-progs v4.0

[root@stg ~]#btrfs fi df /mnt/stg
Data, RAID5: total=121.88GiB, used=101.64GiB
System, RAID5: total=208.00MiB, used=16.00KiB
Metadata, RAID5: total=1.02GiB, used=163.70MiB
GlobalReserve, single: total=64.00MiB, used=0.00B

[root@stg ~]#btrfs scru status /mnt/stg
scrub status for dd10b751-d2aa-40d1-971f-e15b0062dd11
 	scrub started at Tue May 19 03:33:26 2015 and finished after 468 seconds
 	total bytes scrubbed: 101.80GiB with 0 errors


[root@stg ~]#cat /etc/exports
/mnt/stg		*(rw,no_root_squash,no_subtree_check,fsid=0,sync)
/var/cache/pacman/pkg/	*(rw,no_root_squash,no_subtree_check,fsid=0,sync)

