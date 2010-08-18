Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32795 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab0HRWoY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 18:44:24 -0400
Subject: [GIT PULL] Please pull bugfixes for the NFS client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Dr. J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 18:44:19 -0400
Message-ID: <1282171459.8540.132.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/Kconfig                 |    1 -
 fs/nfs/dir.c                   |    9 ++++++++-
 fs/nfs/file.c                  |    2 +-
 fs/nfs/nfs4proc.c              |   11 ++++++-----
 fs/nfs/super.c                 |    7 +++++++
 fs/nfsd/Kconfig                |    1 -
 net/sunrpc/Kconfig             |    9 +++++----
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 ++
 net/sunrpc/xprtrdma/verbs.c    |   22 +++++++++++++++++-----
 net/sunrpc/xprtsock.c          |   28 ++++++++++++++++++++++------
 10 files changed, 68 insertions(+), 24 deletions(-)

commit 0a377cff9428af2da2b293d11e07bc4dbf064ee5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 18 09:25:42 2010 -0400

    NFS: Fix an Oops in the NFSv4 atomic open code
    
    Adam Lackorzynski reports:
    
    with 2.6.35.2 I'm getting this reproducible Oops:
    
    [  110.825396] BUG: unable to handle kernel NULL pointer dereference at
    (null)
    [  110.828638] IP: [<ffffffff811247b7>] encode_attrs+0x1a/0x2a4
    [  110.828638] PGD be89f067 PUD bf18f067 PMD 0
    [  110.828638] Oops: 0000 [#1] SMP
    [  110.828638] last sysfs file: /sys/class/net/lo/operstate
    [  110.828638] CPU 2
    [  110.828638] Modules linked in: rtc_cmos rtc_core rtc_lib amd64_edac_mod
    i2c_amd756 edac_core i2c_core dm_mirror dm_region_hash dm_log dm_snapshot
    sg sr_mod usb_storage ohci_hcd mptspi tg3 mptscsih mptbase usbcore nls_base
    [last unloaded: scsi_wait_scan]
    [  110.828638]
    [  110.828638] Pid: 11264, comm: setchecksum Not tainted 2.6.35.2 #1
    [  110.828638] RIP: 0010:[<ffffffff811247b7>]  [<ffffffff811247b7>]
    encode_attrs+0x1a/0x2a4
    [  110.828638] RSP: 0000:ffff88003bf5b878  EFLAGS: 00010296
    [  110.828638] RAX: ffff8800bddb48a8 RBX: ffff88003bf5bb18 RCX:
    0000000000000000
    [  110.828638] RDX: ffff8800be258800 RSI: 0000000000000000 RDI:
    ffff88003bf5b9f8
    [  110.828638] RBP: 0000000000000000 R08: ffff8800bddb48a8 R09:
    0000000000000004
    [  110.828638] R10: 0000000000000003 R11: ffff8800be779000 R12:
    ffff8800be258800
    [  110.828638] R13: ffff88003bf5b9f8 R14: ffff88003bf5bb20 R15:
    ffff8800be258800
    [  110.828638] FS:  0000000000000000(0000) GS:ffff880041e00000(0063)
    knlGS:00000000556bd6b0
    [  110.828638] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
    [  110.828638] CR2: 0000000000000000 CR3: 00000000be8ef000 CR4:
    00000000000006e0
    [  110.828638] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
    0000000000000000
    [  110.828638] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
    0000000000000400
    [  110.828638] Process setchecksum (pid: 11264, threadinfo
    ffff88003bf5a000, task ffff88003f232210)
    [  110.828638] Stack:
    [  110.828638]  0000000000000000 ffff8800bfbcf920 0000000000000000
    0000000000000ffe
    [  110.828638] <0> 0000000000000000 0000000000000000 0000000000000000
    0000000000000000
    [  110.828638] <0> 0000000000000000 0000000000000000 0000000000000000
    0000000000000000
    [  110.828638] Call Trace:
    [  110.828638]  [<ffffffff81124c1f>] ? nfs4_xdr_enc_setattr+0x90/0xb4
    [  110.828638]  [<ffffffff81371161>] ? call_transmit+0x1c3/0x24a
    [  110.828638]  [<ffffffff813774d9>] ? __rpc_execute+0x78/0x22a
    [  110.828638]  [<ffffffff81371a91>] ? rpc_run_task+0x21/0x2b
    [  110.828638]  [<ffffffff81371b7e>] ? rpc_call_sync+0x3d/0x5d
    [  110.828638]  [<ffffffff8111e284>] ? _nfs4_do_setattr+0x11b/0x147
    [  110.828638]  [<ffffffff81109466>] ? nfs_init_locked+0x0/0x32
    [  110.828638]  [<ffffffff810ac521>] ? ifind+0x4e/0x90
    [  110.828638]  [<ffffffff8111e2fb>] ? nfs4_do_setattr+0x4b/0x6e
    [  110.828638]  [<ffffffff8111e634>] ? nfs4_do_open+0x291/0x3a6
    [  110.828638]  [<ffffffff8111ed81>] ? nfs4_open_revalidate+0x63/0x14a
    [  110.828638]  [<ffffffff811056c4>] ? nfs_open_revalidate+0xd7/0x161
    [  110.828638]  [<ffffffff810a2de4>] ? do_lookup+0x1a4/0x201
    [  110.828638]  [<ffffffff810a4733>] ? link_path_walk+0x6a/0x9d5
    [  110.828638]  [<ffffffff810a42b6>] ? do_last+0x17b/0x58e
    [  110.828638]  [<ffffffff810a5fbe>] ? do_filp_open+0x1bd/0x56e
    [  110.828638]  [<ffffffff811cd5e0>] ? _atomic_dec_and_lock+0x30/0x48
    [  110.828638]  [<ffffffff810a9b1b>] ? dput+0x37/0x152
    [  110.828638]  [<ffffffff810ae063>] ? alloc_fd+0x69/0x10a
    [  110.828638]  [<ffffffff81099f39>] ? do_sys_open+0x56/0x100
    [  110.828638]  [<ffffffff81027a22>] ? ia32_sysret+0x0/0x5
    [  110.828638] Code: 83 f1 01 e8 f5 ca ff ff 48 83 c4 50 5b 5d 41 5c c3 41
    57 41 56 41 55 49 89 fd 41 54 49 89 d4 55 48 89 f5 53 48 81 ec 18 01 00 00
    <8b> 06 89 c2 83 e2 08 83 fa 01 19 db 83 e3 f8 83 c3 18 a8 01 8d
    [  110.828638] RIP  [<ffffffff811247b7>] encode_attrs+0x1a/0x2a4
    [  110.828638]  RSP <ffff88003bf5b878>
    [  110.828638] CR2: 0000000000000000
    [  112.840396] ---[ end trace 95282e83fd77358f ]---
    
    We need to ensure that the O_EXCL flag is turned off if the user doesn't
    set O_CREAT.
    
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df486a25900f4dba9cdc3886c4ac871951c6aef3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 17 17:42:45 2010 -0400

    NFS: Fix the selection of security flavours in Kconfig
    
    Randy Dunlap reports:
    
    ERROR: "svc_gss_principal" [fs/nfs/nfs.ko] undefined!
    
    
    because in fs/nfs/Kconfig, NFS_V4 selects RPCSEC_GSS_KRB5
    and/or in fs/nfsd/Kconfig, NFSD_V4 selects RPCSEC_GSS_KRB5.
    
    RPCSEC_GSS_KRB5 does 5 selects, but none of these is enforced/followed
    by the fs/nfs[d]/Kconfig configs:
    
    	select SUNRPC_GSS
    	select CRYPTO
    	select CRYPTO_MD5
    	select CRYPTO_DES
    	select CRYPTO_CBC
    
    Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0702099bd86c33c2dcdbd3963433a61f3f503901
Author: J. R. Okajima <hooanon05@yahoo.co.jp>
Date:   Wed Aug 11 13:10:16 2010 -0400

    NFS: fix the return value of nfs_file_fsync()
    
    By the commit af7fa16 2010-08-03 NFS: Fix up the fsync code
    close(2) became returning the non-zero value even if it went well.
    nfs_file_fsync() should return 0 when "status" is positive.
    
    Signed-off-by: J. R. Okajima <hooanon05@yahoo.co.jp>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 15cdc644b268a9a9ce73ce0b153129222c254b7b
Author: Tom Tucker <tom@ogc.us>
Date:   Wed Aug 11 12:47:24 2010 -0400

    rpcrdma: Fix SQ size calculation when memreg is FRMR
    
    This patch updates the computation to include the worst case situation
    where three FRMR are required to map a single RPC REQ.
    
    Signed-off-by: Tom Tucker <tom@ogc.us>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a8b80eb38b248cfdf84048dad12073d5cfba3e6
Author: Steve Wise <swise@opengridcomputing.com>
Date:   Wed Aug 11 12:47:08 2010 -0400

    xprtrdma: Do not truncate iova_start values in frmr registrations.
    
    A bad cast causes the iova_start, which in this case is a 64b DMA
    bus address, to be truncated on 32b systems.  This breaks frmrs on
    32b systems.  No cast is needed.
    
    Signed-off-by: Steve Wise <swise@opengridcomputing.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d7ca35a182a626f8ed5596023ad42eb219a332e
Author: Davidlohr Bueso <dave@gnu.org>
Date:   Wed Aug 11 12:42:15 2010 -0400

    nfs: Remove redundant NULL check upon kfree()
    
    Signed-off-by: Davidlohr Bueso <dave@gnu.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9b00c64318cc337846a7a08a5678f5f19aeff188
Author: Patrick J. LoPresti <lopresti@gmail.com>
Date:   Tue Aug 10 17:28:01 2010 -0400

    nfs: Add "lookupcache" to displayed mount options
    
    Running "cat /proc/mounts" fails to display the "lookupcache" option.
    This oversight cost me a bunch of wasted time recently.
    
    The following simple patch fixes it.
    
    CC: stable <stable@kernel.org>
    Signed-off-by: Patrick LoPresti <lopresti@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f5a73672d1811f2fb1dcb62ca90ceb12b2050ae7
Author: Neil Brown <neilb@suse.de>
Date:   Tue Aug 10 10:20:05 2010 -0400

    NFS: allow close-to-open cache semantics to apply to root of NFS filesystem
    
    
    
    To obey NFS cache semantics, the client must verify the cached
    attributes when a file is opened.  In most cases this is done by a call to
    d_validate as one of the last steps in path_walk.
    
    However for the root of a filesystem, d_validate is only ever called
    on the mounted-on filesystem (except when the path ends '.' or '..').
    So NFS has no chance to validate the attributes.
    
    So, in nfs_opendir, we revalidate the attributes if the opened
    directory is the mountpoint.  This may cause double-validation for "."
    and ".." lookups, but that is better than missing regular /path/name
    lookups completely.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 669502ff31d7dba1849aec7ee2450a3c61f57d39
Author: Andy Chittenden <andyc.bluearc@gmail.com>
Date:   Tue Aug 10 10:19:53 2010 -0400

    SUNRPC: fix NFS client over TCP hangs due to packet loss (Bug 16494)
    
    When reusing a TCP connection, ensure that it's aborted if a previous
    shutdown attempt has been made on that connection so that the RPC over
    TCP recovery mechanism succeeds.
    
    Signed-off-by: Andy Chittenden <andyc.bluearc@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


