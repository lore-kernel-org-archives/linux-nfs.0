Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34558 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbJNHSc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 03:18:32 -0400
Received: by pabws5 with SMTP id ws5so15463831pab.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 00:18:31 -0700 (PDT)
Subject: Re: NULL pointer dereference using pnfs with block layout
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FF77DD.8070807@gmail.com> <561CFD01.3080201@gmail.com>
 <CAHQdGtSapCjT+ABSx=8maLN2KQJFFsW-v-F7BYy6wYykKfs0BA@mail.gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <561E01BA.4040109@gmail.com>
Date: Wed, 14 Oct 2015 15:18:18 +0800
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSapCjT+ABSx=8maLN2KQJFFsW-v-F7BYy6wYykKfs0BA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/13/2015 21:45, Trond Myklebust wrote:
> On Tue, Oct 13, 2015 at 8:45 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> ping ...
>>
>> What's your opinion about this problem ?
>>
>> If read/write of block layout file with bad length (res.count != arg.count),
>> should nfs retry?  NFS try to call rpc_restart_call_prepare() right now,
>> that cause a panic with uninitialized task.
> 
> The client should not be attempting to read more data than what was
> requested by the O_DIRECT read request. It should be strictly
> respecting the boundaries of the user buffer that was supplied.

Yes, that's right.

> Any idea why this is happening?

As post before, bl_read_pagelist() return a longer result that causes the panic.

>>> [ 1004.001842] bl_read_pagelist enter nr_pages 1 offset 2048 count 2048
>>> [ 1004.002110] bl_read_pagelist: pg_offset 2048
>>> [ 1004.002370] bl_read_pagelist: pg_len 2048 is_dio
>>> [ 1004.002617] bl_read_pagelist: pg_len 2048 after do_add_page_to_bio
>>> [ 1004.002853] bl_read_pagelist: 2048 4096 "(isect << SECTOR_SHIFT) < header->inode->i_size"
>>> [ 1004.003774] NFS: nfs_pgio_result:     0, (status 0), tk_ops      (null)
>>> [ 1004.003989] --> nfs4_read_done
>>> [ 1004.004224] nfs_readpage_done: 0
>>> [ 1004.004459] nfs_pgio_result: 0
>>> [ 1004.004691] nfs_readpage_result: eof 0, res.count 4096, args.count 2048
>>> [ 1004.004926] nfs_readpage_retry: tk_ops           (null)

I test with the following program with pnfs of block layout, 

-------------------------------------------------------
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{
        char buf[2048];
        char *filename = NULL;
        int fd = -1;

        if (argc < 2) {
                printf("Usage: %s filename\n", argv[0]);
                return 0;
        }

        filename = argv[1];
        fd = open(filename, O_RDONLY | O_DIRECT);
        if (fd < 0) {
                printf("Open %s fail: %m\n", filename);
                return 1;
        }

        if (lseek(fd, 2048, SEEK_SET) != 2048) {
                printf("Seek %s's 2048 fail: %m\n", filename);
                goto out;
        }

        if (read(fd, buf, sizeof(buf)) != sizeof(buf))
                printf("Read 2048 bityes data from %s fail: %m\n", filename);
out:
        close(fd);
        return 0;
}

thanks,
Kinglong Mee

>> On 9/21/2015 11:22, Kinglong Mee wrote:
>>> It caused by rpc_restart_call_prepare with an uninitialized task
>>> for the pnfs do I/O locally without sending any RPC to MDS.
>>>
>>> Some debug messages,
>>>
>>> [ 1004.001842] bl_read_pagelist enter nr_pages 1 offset 2048 count 2048
>>> [ 1004.002110] bl_read_pagelist: pg_offset 2048
>>> [ 1004.002370] bl_read_pagelist: pg_len 2048 is_dio
>>> [ 1004.002617] bl_read_pagelist: pg_len 2048 after do_add_page_to_bio
>>> [ 1004.002853] bl_read_pagelist: 2048 4096 "(isect << SECTOR_SHIFT) < header->inode->i_size"
>>> [ 1004.003774] NFS: nfs_pgio_result:     0, (status 0), tk_ops      (null)
>>> [ 1004.003989] --> nfs4_read_done
>>> [ 1004.004224] nfs_readpage_done: 0
>>> [ 1004.004459] nfs_pgio_result: 0
>>> [ 1004.004691] nfs_readpage_result: eof 0, res.count 4096, args.count 2048
>>> [ 1004.004926] nfs_readpage_retry: tk_ops           (null)
>>>
>>> Panic messages as,
>>>
>>> [ 1004.005170] BUG: unable to handle kernel NULL pointer dereference at           (null)
>>> [ 1004.005452] IP: [<ffffffffa0075f8a>] rpc_restart_call_prepare+0x2a/0x50 [sunrpc]
>>> [ 1004.005702] PGD 0
>>> [ 1004.005937] Oops: 0000 [#1]
>>> [ 1004.006175] Modules linked in: blocklayoutdriver(OE) nfsv4(OE) nfs(OE) fscache(E) xfs libcrc32c btrfs coretemp crct10dif_pclmul ppdev crc32_pclmul crc32c_intel ghash_clmulni_intel vmw_balloon vmw_vmci parport_pc parport nfsd(OE) shpchp xor raid6_pq i2c_piix4 auth_rpcgss nfs_acl lockd(E) grace sunrpc(E) vmwgfx drm_kms_helper ttm drm serio_raw e1000 mptspi scsi_transport_spi mptscsih ata_generic mptbase pata_acpi [last unloaded: fscache]
>>> [ 1004.007611] CPU: 0 PID: 3489 Comm: kworker/0:2 Tainted: G           OE   4.3.0-rc1+ #252
>>> [ 1004.007920] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/20/2014
>>> [ 1004.008571] Workqueue: events bl_read_cleanup [blocklayoutdriver]
>>> [ 1004.008917] task: ffff88006ceab080 ti: ffff880017700000 task.ti: ffff880017700000
>>> [ 1004.009315] RIP: 0010:[<ffffffffa0075f8a>]  [<ffffffffa0075f8a>] rpc_restart_call_prepare+0x2a/0x50 [sunrpc]
>>> [ 1004.010152] RSP: 0018:ffff880017703cc8  EFLAGS: 00010246
>>> [ 1004.010589] RAX: 0000000000000000 RBX: ffff880017726000 RCX: 0000000000000006
>>> [ 1004.011007] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800177260d8
>>> [ 1004.011428] RBP: ffff880017703cc8 R08: 0000000000000001 R09: 0000000000000000
>>> [ 1004.011831] R10: 0000000000000000 R11: 0000000000000001 R12: ffff8800177260d8
>>> [ 1004.012237] R13: ffff8800686008b0 R14: 0000000000000000 R15: ffff880017726160
>>> [ 1004.012666] FS:  0000000000000000(0000) GS:ffffffff81c29000(0000) knlGS:0000000000000000
>>> [ 1004.013478] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [ 1004.013930] CR2: 0000000000000000 CR3: 000000006ccbe000 CR4: 00000000001406f0
>>> [ 1004.014592] Stack:
>>> [ 1004.015103]  ffff880017703cf0 ffffffffa04c436e ffff8800177260d8 ffff880017726000
>>> [ 1004.015611]  ffff8800686008b0 ffff880017703d18 ffffffffa04c2fb8 ffff880017726160
>>> [ 1004.016105]  ffff880017726000 ffff88007ff43100 ffff880017703d40 ffffffffa05349c4
>>> [ 1004.016565] Call Trace:
>>> [ 1004.017071]  [<ffffffffa04c436e>] nfs_readpage_result+0x11e/0x130 [nfs]
>>> [ 1004.017546]  [<ffffffffa04c2fb8>] nfs_pgio_result+0x88/0xa0 [nfs]
>>> [ 1004.018009]  [<ffffffffa05349c4>] pnfs_ld_read_done+0x44/0xf0 [nfsv4]
>>> [ 1004.018469]  [<ffffffffa04a8532>] bl_read_cleanup+0x22/0x50 [blocklayoutdriver]
>>> [ 1004.018938]  [<ffffffff810a388c>] process_one_work+0x21c/0x4c0
>>> [ 1004.019406]  [<ffffffff810a37dd>] ? process_one_work+0x16d/0x4c0
>>> [ 1004.019876]  [<ffffffff810a3b7a>] worker_thread+0x4a/0x440
>>> [ 1004.020339]  [<ffffffff810a3b30>] ? process_one_work+0x4c0/0x4c0
>>> [ 1004.020795]  [<ffffffff810a3b30>] ? process_one_work+0x4c0/0x4c0
>>> [ 1004.021289]  [<ffffffff810a8d85>] kthread+0xf5/0x110
>>> [ 1004.021735]  [<ffffffff810a8c90>] ? kthread_create_on_node+0x240/0x240
>>> [ 1004.022177]  [<ffffffff8172cd1f>] ret_from_fork+0x3f/0x70
>>> [ 1004.022604]  [<ffffffff810a8c90>] ? kthread_create_on_node+0x240/0x240
>>> [ 1004.023025] Code: 00 0f 1f 44 00 00 31 c0 f6 87 e9 00 00 00 01 55 48 89 e5 75 29 48 8b 47 58 48 c7 47 50 80 42 07 a0 c7 87 e4 00 00 00 00 00 00 00 <48> 83 38 00 74 0f 48 c7 47 50 b0 f1 07 a0 b8 01 00 00 00 5d c3
>>> [ 1004.024344] RIP  [<ffffffffa0075f8a>] rpc_restart_call_prepare+0x2a/0x50 [sunrpc]
>>> [ 1004.024773]  RSP <ffff880017703cc8>
>>> [ 1004.025228] CR2: 0000000000000000
>>>
> 
