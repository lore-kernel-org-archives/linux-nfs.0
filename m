From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: NFS write OOPS with 2.6.29.2
Date: Mon, 4 May 2009 23:14:26 -0700
Message-ID: <20090504231426.2e5a51b0.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0905031552340.1774@praktifix.dwd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Holger Kiehl <Holger.Kiehl@dwd.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758102AbZEEGQ3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0905031552340.1774@praktifix.dwd.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


(cc linux-nfs)

On Sun, 3 May 2009 16:03:38 +0000 (GMT) Holger Kiehl <Holger.Kiehl@dwd.de> wrote:

> Hello
> 
> With plain kernel 2.6.29.2 I get the following OOPS (several of them) when
> writing lots of small files on the client system:
> 
>     May  3 18:48:34 obelix kernel: ------------[ cut here ]------------
>     May  3 18:48:34 obelix kernel: kernel BUG at fs/nfs/write.c:252!

I think this is a well-know bug, and fixes should be available in 2.6.29.3?

>     May  3 18:48:34 obelix kernel: invalid opcode: 0000 [#1] SMP
>     May  3 18:48:34 obelix kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1c.2/0000:11:00.0/0000:12:00.0/irq
>     May  3 18:48:34 obelix kernel: CPU 1
>     May  3 18:48:34 obelix kernel: Modules linked in: nfs lockd nfs_acl auth_rpcgss coretemp smsc47m1 ipmi_si ipmi_msghandler sunrpc binfmt_misc usbhid i5000_edac i2c_i801 uhci_hcd sg i2c_core i5k_amb ehci_hcd usbcore [last unloaded: scsi_wait_scan]
>     May  3 18:48:34 obelix kernel: Pid: 8328, comm: sf_loc Not tainted 2.6.29.2 #2 PRIMERGY RX300 S4
>     May  3 18:48:34 obelix kernel: RIP: 0010:[<ffffffffa010effc>]  [<ffffffffa010effc>] nfs_do_writepage+0xfa/0x196 [nfs]
>     May  3 18:48:34 obelix kernel: RSP: 0018:ffff8807e619bb28  EFLAGS: 00010286
>     May  3 18:48:34 obelix kernel: RAX: 0000000000000001 RBX: ffffe2001ba1dcc0 RCX: 0000000000000015
>     May  3 18:48:34 obelix kernel: RDX: 0000000000000000 RSI: 0000000000600020 RDI: ffff8807ec10e950
>     May  3 18:48:34 obelix kernel: RBP: ffff8807e619bb58 R08: ffff88082cf52540 R09: ffff88083cc74440
>     May  3 18:48:34 obelix kernel: R10: 0000000000000000 R11: 00000000fffffffa R12: ffff88082cf52540
>     May  3 18:48:34 obelix kernel: R13: ffff8807ec10ea9c R14: ffffe2001ba1dcc0 R15: ffff8807ec10e9e8
>     May  3 18:48:34 obelix kernel: FS:  00007f03010276f0(0000) GS:ffff88083cca3e40(0000) knlGS:0000000000000000
>     May  3 18:48:34 obelix kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>     May  3 18:48:34 obelix kernel: CR2: 00007fb127e21508 CR3: 000000082cf94000 CR4: 00000000000406e0
>     May  3 18:48:34 obelix kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>     May  3 18:48:34 obelix kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>     May  3 18:48:34 obelix kernel: Process sf_loc (pid: 8328, threadinfo ffff8807e619a000, task ffff88082cf84840)
>     May  3 18:48:34 obelix kernel: Stack:
>     May  3 18:48:34 obelix kernel: ffff8807e619bcb8 ffffe2001ba1dcc0 ffffe2001ba1dcc0 0000000000000000
>     May  3 18:48:34 obelix kernel: 0000000000000001 0000000000000000 ffff8807e619bb78 ffffffffa010f50a
>     May  3 18:48:34 obelix kernel: ffffe2001ba1dcc0 ffff8807e619bd68 ffff8807e619bca8 ffffffff8026f964
>     May  3 18:48:34 obelix kernel: Call Trace:
>     May  3 18:48:34 obelix kernel: [<ffffffffa010f50a>] nfs_writepages_callback+0xf/0x20 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffff8026f964>] write_cache_pages+0x246/0x389
>     May  3 18:48:34 obelix kernel: [<ffffffffa010f4fb>] ? nfs_writepages_callback+0x0/0x20 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffff80268c20>] ? find_get_pages_tag+0x3e/0xd9
>     May  3 18:48:34 obelix kernel: [<ffffffffa010f4d1>] nfs_writepages+0xb0/0xda [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa01107f1>] ? nfs_flush_one+0x0/0xd9 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa01107f1>] ? nfs_flush_one+0x0/0xd9 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa01105e5>] __nfs_write_mapping+0x19/0x50 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa0110676>] nfs_write_mapping+0x5a/0x7e [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa01106c3>] nfs_wb_all+0x12/0x14 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa0106096>] nfs_sync_mapping+0x34/0x38 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa0103a7e>] do_setlk+0x89/0xb0 [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffffa0103cc7>] nfs_lock+0x18a/0x19b [nfs]
>     May  3 18:48:34 obelix kernel: [<ffffffff802c1978>] vfs_lock_file+0x1e/0x35
>     May  3 18:48:34 obelix kernel: [<ffffffff802c1b7a>] fcntl_setlk+0x13e/0x278
>     May  3 18:48:34 obelix kernel: [<ffffffff802a0649>] sys_fcntl+0x2bc/0x33a
>     May  3 18:48:34 obelix kernel: [<ffffffff8020b51b>] system_call_fastpath+0x16/0x1b
>     May  3 18:48:34 obelix kernel: Code: 00 4c 89 e7 e8 ba cb ff ff 4c 89 e7 89 c3 e8 05 cc ff ff 85 db 74 a7 e9 82 00 00 00 41 f6 44 24 40 02 74 0b 41 fe 87 b4 00 00 00 <0f> 0b eb fe 4c 89 f7 e8 2d 03 16 e0 85 c0 75 49 49 8b 46 18 ba
>     May  3 18:48:34 obelix kernel: RIP  [<ffffffffa010effc>] nfs_do_writepage+0xfa/0x196 [nfs]
> ...
>
