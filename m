Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55913 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621Ab2GXIVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 04:21:48 -0400
Received: by pbbrp8 with SMTP id rp8so12311730pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 01:21:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343037907-26457-1-git-send-email-idank@tonian.com>
References: <1343037907-26457-1-git-send-email-idank@tonian.com>
From: Idan Kedar <idank@tonian.com>
Date: Tue, 24 Jul 2012 11:21:06 +0300
Message-ID: <CABpMAyLrZxtygHH7FFpOTT0d1r3YX-ZTz-nY55U9fkfwY-qNjg@mail.gmail.com>
Subject: Re: [PATCH 0/3] pnfs: fix a crash when hitting Ctrl+C during LAYOUTGET
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 23, 2012 at 1:05 PM, Idan Kedar <idank@tonian.com> wrote:
> While working on object layout, we have encountered a general protection fault
> in xdr_shrink_bufhead when killing a process performing a lot of reads.
>

full trace:

[  139.546742] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[  139.547044] CPU 0
[  139.547044] Modules linked in: objlayoutdriver1 exofs libore osd
libosd netconsole nfs nfsd lockd fscache nfs_acl auth_rpcgss sunrpc
iscsi_tcp e1000 serio_raw rtc_cmos [last unloaded: libosd]
[  139.547044]
[  139.547044] Pid: 4, comm: kworker/0:0 Not tainted 3.3.0-nfsobj+ #15
innotek GmbH VirtualBox
[  139.547044] RIP: 0010:[<ffffffff812bed7b>]  [<ffffffff812bed7b>]
memcpy+0xb/0x120
[  139.547044] RSP: 0018:ffff88003dd33a98  EFLAGS: 00010202
[  139.547044] RAX: ffff88002f69b3d4 RBX: ffff88002f69b3d4 RCX: 000000000000000d
[  139.547044] RDX: 0000000000000004 RSI: dadfe2dadadad004 RDI: ffff88002f69b3d4
[  139.547044] RBP: ffff88003dd33ae0 R08: 0000000000000000 R09: 0000000000000000
[  139.547044] R10: 0000000000000000 R11: 0000000000000001 R12: 000000000000006c
[  139.547044] R13: 0000000000000004 R14: 000000000000006c R15: ffff88003dd32000
[  139.547044] FS:  0000000000000000(0000) GS:ffff88003e200000(0000)
knlGS:0000000000000000
[  139.547044] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  139.547044] CR2: 00000000019bd028 CR3: 000000003540d000 CR4: 00000000000006f0
[  139.547044] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  139.547044] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  139.547044] Process kworker/0:0 (pid: 4, threadinfo
ffff88003dd32000, task ffff88003dd38000)
[  139.547044] Stack:
[  139.547044]  ffffffffa0048a87 ffff88003dd33fd8 ffff88002f53e518
ffff88003dd33bb8
[  139.547044]  ffff88003b2c4d68 0000000000000ffc 0000000000021000
0000000000021000
[  139.547044]  0000000000000001 ffff88003dd33b50 ffffffffa00493bf
ffff88003dd33b80
[  139.547044] Call Trace:
[  139.547044]  [<ffffffffa0048a87>] ? _copy_from_pages+0xa7/0xe0 [sunrpc]
[  139.547044]  [<ffffffffa00493bf>] xdr_shrink_bufhead+0x7f/0x260 [sunrpc]
[  139.547044]  [<ffffffffa01bc1b0>] ?
nfs4_xdr_dec_getdeviceinfo+0x1d0/0x1d0 [nfs]
[  139.547044]  [<ffffffffa00495f2>] xdr_read_pages+0x42/0x150 [sunrpc]
[  139.547044]  [<ffffffffa01bc338>] nfs4_xdr_dec_layoutget+0x188/0x230 [nfs]
[  139.547044]  [<ffffffffa01bc1b0>] ?
nfs4_xdr_dec_getdeviceinfo+0x1d0/0x1d0 [nfs]
[  139.547044]  [<ffffffffa003f1ed>] rpcauth_unwrap_resp+0x9d/0xd0 [sunrpc]
[  139.547044]  [<ffffffffa01bc1b0>] ?
nfs4_xdr_dec_getdeviceinfo+0x1d0/0x1d0 [nfs]
[  139.547044]  [<ffffffffa0033cc9>] call_decode+0x1c9/0x860 [sunrpc]
[  139.547044]  [<ffffffff8107b8cc>] ? process_one_work+0x13c/0x530
[  139.547044]  [<ffffffffa003d900>] ? __rpc_execute+0x2b0/0x2b0 [sunrpc]
[  139.547044]  [<ffffffffa003d6b6>] __rpc_execute+0x66/0x2b0 [sunrpc]
[  139.547044]  [<ffffffffa003d900>] ? __rpc_execute+0x2b0/0x2b0 [sunrpc]
[  139.547044]  [<ffffffffa003d915>] rpc_async_schedule+0x15/0x20 [sunrpc]
[  139.547044]  [<ffffffff8107b92f>] process_one_work+0x19f/0x530
[  139.547044]  [<ffffffff8107b8cc>] ? process_one_work+0x13c/0x530
[  139.547044]  [<ffffffff8107d449>] worker_thread+0x159/0x340
[  139.547044]  [<ffffffff8107d2f0>] ? manage_workers+0x230/0x230
[  139.547044]  [<ffffffff810825c7>] kthread+0xb7/0xc0
[  139.547044]  [<ffffffff810b22a5>] ? trace_hardirqs_on_caller+0x105/0x190
[  139.547044]  [<ffffffff816ed334>] kernel_thread_helper+0x4/0x10
[  139.547044]  [<ffffffff816eb6b4>] ? retint_restore_args+0x13/0x13
[  139.547044]  [<ffffffff81082510>] ? __init_kthread_worker+0x70/0x70
[  139.547044]  [<ffffffff816ed330>] ? gs_change+0x13/0x13
[  139.547044] Code: 58 48 2b 43 50 88 43 4e 48 83 c4 08 5b 5d c3 90
e8 8b fb ff ff eb e6 90 90 90 90 90 90 90 90 90 48 89 f8 89 d1 c1 e9
03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e
08 4c
[  139.547044] RIP  [<ffffffff812bed7b>] memcpy+0xb/0x120
[  139.547044]  RSP <ffff88003dd33a98>

> we reproduced it on kernel v3.3 as follows:
> * mount an object-based pNFS file system. we used exofs as the MDS. assume the
> mount point is /mnt/pnfs
> * cp -r /bin /mnt/pnfs
> * run:
> cd /mnt/pnfs
> while while true; do
>         echo 3 > /proc/sys/vm/drop_caches;
>         rm -rf bin
>         cp -r bin /tmp &
>         sleep 1
>         kill -s int $!
> done

oops, silly me... here's the correct one

cp -r /bin /mnt/pnfs
cd /mnt/pnfs
while true; do
	rm -rf bin2
	echo 3 > /proc/sys/vm/drop_caches
	cp -r bin bin2 &
	sleep 1
	kill -s int $!
done

> * on my setup it crashed after a couple of minutes, your mileage may vary.
>

...and sometimes within a couple of seconds.

> The first patch is the actual fix. the other two are cleanups.
>
> Idan Kedar (3):
>   pnfs: defer release of pages in layoutget
>   pnfs: nfs4_proc_layoutget returns void
>   pnfs: use size_t for LAYOUTGET response pages count
>
>  fs/nfs/nfs4proc.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfs/pnfs.c     |   39 +---------------------------------
>  fs/nfs/pnfs.h     |    2 +-
>  3 files changed, 60 insertions(+), 42 deletions(-)
>
> --
> 1.7.6.5
>



-- 
idank
