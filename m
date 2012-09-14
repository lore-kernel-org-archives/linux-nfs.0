Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.scalarmail.ca ([98.158.95.75]:46538 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab2INTVA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 15:21:00 -0400
Date: Fri, 14 Sep 2012 15:20:56 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: PROBLEM: kernel BUG at fs/nfs/idmap.c:684!
Message-ID: <20120914192056.GA15530@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I just upgraded an NFSv3 client machine to Linux 3.5.3 and am seeing the
following BUG.  It occurs reproducibly a short time after the first
login in to the machine after boot (within one minute).  There's a lot
of nfs4-looking functions in backtrace, which is weird as there are
absolutely no NFSv4 mounts.  The system still mostly works, although
tab completion in my shell seems to either not complete anything or
hang forever, which could be related as there are NFS-mounted
directories in my PATH.

Curiously, there are other machines on the same network running this
same kernel version that do *not* have this problem.  A couple unique
things about the crashing machine that immediately come to mind...

 - Userspace is running Debian stable (so tends to be pretty old).
 - Its onboard network is quite different from our other machines
   (it has a Marvell chipset using the sky2 driver).

Please let me know if you need any more info.

------------[ cut here ]------------
kernel BUG at fs/nfs/idmap.c:684!
invalid opcode: 0000 [#1] PREEMPT SMP 
CPU 0 
Modules linked in: ah4 xfrm4_mode_transport nfs lockd auth_rpcgss nfs_acl sunrpc autofs4 acpi_cpufreq mperf deflate zlib_deflate ctr aes_x86_64 aes_generic des_generic cbc sha512_generic sha256_generic sha1_ssse3 sha1_generic md5 hmac crypto_null af_key xfrm_algo ipv6 loop snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_pcm snd_seq snd_timer snd_seq_device snd soundcore snd_page_alloc i2c_i801 skge coretemp hwmon lpc_ich evdev mfd_core sky2

Pid: 2450, comm: mount.nfs Not tainted 3.5.3 #15 LENOVO 0841A5U/LENOVO
RIP: 0010:[<ffffffffa01d8081>]  [<ffffffffa01d8081>] nfs_idmap_legacy_upcall+0x10c/0x15e [nfs]
RSP: 0018:ffff8800755c53f8  EFLAGS: 00010286
RAX: 0000000000000015 RBX: ffff880078d4ba80 RCX: 0000000000000000
RDX: 0000000000000080 RSI: ffff880076e40ed9 RDI: ffff880078d4ba97
RBP: ffff8800755c5448 R08: ffff880078d4ba82 R09: 0000000000000015
R10: ffff88007f40b000 R11: ffff8800755c5288 R12: ffff880078dfe880
R13: ffff880076dc1f40 R14: ffff880078dfebc0 R15: ffff880078d4b780
FS:  00007fb0bc00d700(0000) GS:ffff88007f400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000dd9000 CR3: 00000000755b8000 CR4: 00000000000407f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mount.nfs (pid: 2450, threadinfo ffff8800755c4000, task ffff88007b838000)
Stack:
 0031396364396565 ffffffff81364e2a ffff880076e40ec4 ffff880076e40ed9
 ffffffff81625be0 ffff880078d4b780 ffff880076dc1f40 ffff880078d4bb40
 ffff880076c16600 ffff880076c166c0 ffff8800755c54e8 ffffffff8115bb02
Call Trace:
 [<ffffffff81364e2a>] ? kmemleak_alloc+0x21/0x3e
 [<ffffffff8115bb02>] request_key_and_link+0x306/0x389
 [<ffffffff810c5378>] ? create_object+0x27e/0x290
 [<ffffffff8115bbd7>] request_key_with_auxdata+0x1b/0x4c
 [<ffffffffa01d81a0>] nfs_idmap_request_key+0xcd/0x187 [nfs]
 [<ffffffffa01d82d4>] nfs_idmap_get_key+0x7a/0x99 [nfs]
 [<ffffffffa01d84ac>] nfs_idmap_lookup_id+0x23/0x52 [nfs]
 [<ffffffffa01d852e>] nfs_map_group_to_gid+0x53/0x5a [nfs]
 [<ffffffffa01d28cf>] decode_getfattr_attrs+0x591/0xa0c [nfs]
 [<ffffffff81001624>] ? __switch_to+0x2d/0x355
 [<ffffffffa01d472d>] T.1600+0x78/0xab [nfs]
 [<ffffffffa01d476e>] decode_getfattr+0xe/0x10 [nfs]
 [<ffffffffa01d4988>] nfs4_xdr_dec_lookup_root+0x54/0x5d [nfs]
 [<ffffffffa016e707>] ? rpc_queue_empty+0x29/0x29 [sunrpc]
 [<ffffffffa01d4934>] ? nfs4_xdr_dec_link+0xa9/0xa9 [nfs]
 [<ffffffffa016f60c>] rpcauth_unwrap_resp+0x56/0x61 [sunrpc]
 [<ffffffffa016e707>] ? rpc_queue_empty+0x29/0x29 [sunrpc]
 [<ffffffffa01d4934>] ? nfs4_xdr_dec_link+0xa9/0xa9 [nfs]
 [<ffffffffa0168d80>] call_decode+0x2c3/0x31b [sunrpc]
 [<ffffffffa016ec9d>] __rpc_execute+0x51/0x179 [sunrpc]
 [<ffffffff8104574b>] ? wake_up_bit+0x20/0x25
 [<ffffffffa016edec>] rpc_execute+0x27/0x2b [sunrpc]
 [<ffffffffa01693cd>] rpc_run_task+0x79/0x81 [sunrpc]
 [<ffffffffa01694b3>] rpc_call_sync+0x3f/0x60 [sunrpc]
 [<ffffffffa01ca253>] _nfs4_call_sync+0xe/0x10 [nfs]
 [<ffffffffa01cbc74>] _nfs4_lookup_root+0x9a/0xa8 [nfs]
 [<ffffffffa01cbcb9>] nfs4_lookup_root+0x37/0x62 [nfs]
 [<ffffffffa01cbd07>] nfs4_proc_get_rootfh+0x23/0x95 [nfs]
 [<ffffffffa01bb87a>] nfs4_get_rootfh+0x36/0xb6 [nfs]
 [<ffffffff81364e2a>] ? kmemleak_alloc+0x21/0x3e
 [<ffffffff810bdd8e>] ? kmem_cache_alloc+0xc9/0xd8
 [<ffffffffa01b7111>] nfs4_server_common_setup+0x57/0xc7 [nfs]
 [<ffffffffa01b7c87>] nfs4_create_server+0x1d7/0x202 [nfs]
 [<ffffffff81364dd8>] ? kmemleak_alloc_percpu+0x63/0x94
 [<ffffffffa01bf7f2>] nfs4_remote_mount+0x36/0x5f [nfs]
 [<ffffffff810c96b2>] mount_fs+0x6b/0x14f
 [<ffffffff810a7824>] ? __alloc_percpu+0xb/0xd
 [<ffffffff810e0385>] vfs_kern_mount+0x66/0xdf
 [<ffffffffa01bfadb>] nfs_do_root_mount+0x96/0xb5 [nfs]
 [<ffffffffa01c060a>] nfs_fs_mount+0x7bf/0x8f8 [nfs]
 [<ffffffffa01bf52e>] ? nfs_fill_super+0xc4/0xc4 [nfs]
 [<ffffffffa01be8dd>] ? nfs_request_mount+0x1b2/0x1b2 [nfs]
 [<ffffffff810c96b2>] mount_fs+0x6b/0x14f
 [<ffffffff810a7824>] ? __alloc_percpu+0xb/0xd
 [<ffffffff810e0385>] vfs_kern_mount+0x66/0xdf
 [<ffffffff810e0468>] do_kern_mount+0x48/0xd8
 [<ffffffff810e0c10>] do_mount+0x718/0x77b
 [<ffffffff810e0cf6>] sys_mount+0x83/0xbd
 [<ffffffff81376522>] system_call_fastpath+0x16/0x1b
Code: b3 84 00 00 00 48 8d 7d c0 c6 43 01 00 e8 59 1e fb e0 85 c0 49 89 5c 24 10 49 c7 44 24 18 8c 00 00 00 78 1e 49 83 7e 08 00 74 04 <0f> 0b eb fe 49 8b 3e 4d 89 6e 08 4c 89 e6 e8 1f 27 fa ff 85 c0 
RIP  [<ffffffffa01d8081>] nfs_idmap_legacy_upcall+0x10c/0x15e [nfs]
 RSP <ffff8800755c53f8>
---[ end trace ee7d4fa42e626e1f ]---
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

