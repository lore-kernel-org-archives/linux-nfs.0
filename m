Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52141 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755344Ab0LTJ4L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 04:56:11 -0500
Message-ID: <4D0F2974.4010100@cn.fujitsu.com>
Date: Mon, 20 Dec 2010 18:01:24 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: NFSv3 list <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: kernel panic when mount NFSv4
References: <4D0731C1.5090100@cn.fujitsu.com>
In-Reply-To: <4D0731C1.5090100@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

hello,

At the latest kernel(2.6.37-rc6), I got warning message as below:

------------[ cut here ]------------
kernel BUG at net/sunrpc/rpc_pipe.c:469!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/module/nfsd/initstate
Modules linked in: nfs fscache nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ipv6 ext3 jbd dm_mirror dm_region_hash dm_log dm_mod sg ppdev 8139too 8139cp r8169 mii parport_pc parport pcspkr serio_raw i2c_i801 iTCO_wdt iTCO_vendor_support snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix usb_storage nouveau ttm drm_kms_helper drm i2c_algo_bit i2c_core video output [last unloaded: scsi_wait_scan]

Pid: 7371, comm: mount.nfs4 Not tainted 2.6.37-rc6+ #2 E945GCZ/ASPIRE AG1720
EIP: 0060:[<fed81f6a>] EFLAGS: 00010246 CPU: 0
EIP is at __rpc_create_common+0x8a/0xc0 [sunrpc]
EAX: f64b4300 EBX: f0c3eb64 ECX: 00001180 EDX: f0c3eb64
ESI: f64b4300 EDI: 00001180 EBP: f09e0000 ESP: f12efd20
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process mount.nfs4 (pid: 7371, ti=f12ee000 task=f0964530 task.ti=f12ee000)
Stack:
 f8456d84 c0520e1a f0c5f21c f12efd6c f0c3eb64 f64b4380 00001180 f8456d84
 fed82121 fed86a60 f09e0000 f48026d0 00000010 00000000 000000d0 f0c5f21c
 f8456d84 f64b4300 f09e0000 11bcc18d 00000005 f8456d84 f09e0000 f28b7400
Call Trace:
 [<c0520e1a>] ? d_lookup+0x2a/0x40
 [<fed82121>] ? rpc_mkpipe+0x111/0x1b0 [sunrpc]
 [<f844ddeb>] ? nfs_idmap_new+0x7b/0x140 [nfs]
 [<c05c42da>] ? strlcpy+0x3a/0x60
 [<f841fc3a>] ? nfs4_set_client+0xea/0x2b0 [nfs]
 [<f841fec1>] ? nfs4_create_server+0xc1/0x2d0 [nfs]
 [<f842afd9>] ? nfs4_remote_mount+0x59/0x2c0 [nfs]
 [<c0510f1d>] ? vfs_kern_mount+0x7d/0x230
 [<f842af80>] ? nfs4_remote_mount+0x0/0x2c0 [nfs]
 [<f842ab2c>] ? nfs_do_root_mount+0x6c/0xa0 [nfs]
 [<f842ac37>] ? nfs4_try_mount+0x37/0xa0 [nfs]
 [<f84291ad>] ? nfs4_validate_text_mount_data+0x7d/0xf0 [nfs]
 [<f842bf22>] ? nfs4_get_sb+0x92/0x2f0 [nfs]
 [<c051102c>] ? vfs_kern_mount+0x18c/0x230
 [<c0524762>] ? get_fs_type+0x32/0xb0
 [<c051112f>] ? do_kern_mount+0x3f/0xe0
 [<c0527356>] ? do_mount+0x306/0x6f0
 [<c0525640>] ? copy_mount_options+0xb0/0x120
 [<c05277ae>] ? sys_mount+0x6e/0xa0
 [<c040a59f>] ? sysenter_do_call+0x12/0x28
Code: af 50 01 00 00 89 fa 89 d8 e8 13 e3 79 c1 89 d8 e8 cc d5 79 c1 31 c0 8b 5c 24 10 8b 74 24 14 8b 7c 24 18 8b 6c 24 1c 83 c4 20 c3 <0f> 0b eb fe 8b 43 28 c7 44 24 08 00 6a d8 fe c7 44 24 04 8f 75
EIP: [<fed81f6a>] __rpc_create_common+0x8a/0xc0 [sunrpc] SS:ESP 0068:f12efd20
---[ end trace 49fbc098c75066aa ]---


