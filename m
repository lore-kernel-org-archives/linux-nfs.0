Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64857 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab0CQV4m convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 17:56:42 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 17 Mar 2010 17:55:40 -0400
Message-ID: <1268862940.8335.54.camel@localhost.localdomain>
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
 fs/nfs/callback_xdr.c |    1 +
 fs/nfs/delegation.h   |    6 ++++++
 fs/nfs/dir.c          |    2 +-
 fs/nfs/inode.c        |    2 +-
 fs/nfs/nfs4proc.c     |    1 +
 fs/nfs/pagelist.c     |   23 +++++++++++++----------
 fs/nfs/super.c        |   25 ++++++++++++++++++++-----
 net/sunrpc/xprtsock.c |    8 ++------
 8 files changed, 45 insertions(+), 23 deletions(-)

commit cfbc0683af235106e7dabe92003870b82ad6f0ba
Author: NeilBrown <neilb@suse.de>
Date:   Thu Mar 11 11:20:17 2010 +1100

    NFS: ensure bdi_unregister is called on mount failure.
    
    bdi_unregister is called by nfs_put_super which is only called by
    generic_shutdown_super if ->s_root is not NULL.  So if we error out
    in a circumstance where we called nfs_bdi_register (i.e. server !=
    NULL) but have not set s_root, then we need to call bdi_unregister
    explicitly in nfs_get_sb and various other *_get_sb() functions.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bb6fbc4548b9ae7ebbd06ef72f00229df259d217
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 11 09:19:35 2010 -0500

    NFS: Avoid a deadlock in nfs_release_page
    
    J.R. Okajima reports the following deadlock:
    
    INFO: task kswapd0:305 blocked for more than 120 seconds.
    "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
    kswapd0       D 0000000000000001     0   305      2 0x00000000
     ffff88001f21d4f0 0000000000000046 ffff88001fdea680 ffff88001f21c000
     ffff88001f21dfd8 ffff88001f21c000 ffff88001f21dfd8 ffff88001f21dfd8
     ffff88001fdea040 0000000000014c00 0000000000000001 ffff88001fdea040
    Call Trace:
     [<ffffffff8146155d>] io_schedule+0x4d/0x70
     [<ffffffff810d2be5>] sync_page+0x65/0xa0
     [<ffffffff81461b12>] __wait_on_bit_lock+0x52/0xb0
     [<ffffffff810d2b80>] ? sync_page+0x0/0xa0
     [<ffffffff810d2b64>] __lock_page+0x64/0x70
     [<ffffffff81070ce0>] ? wake_bit_function+0x0/0x40
     [<ffffffff810df1d4>] truncate_inode_pages_range+0x344/0x4a0
     [<ffffffff810df340>] truncate_inode_pages+0x10/0x20
     [<ffffffff8112cbfe>] generic_delete_inode+0x15e/0x190
     [<ffffffff8112cc8d>] generic_drop_inode+0x5d/0x80
     [<ffffffff8112bb88>] iput+0x78/0x80
     [<ffffffff811bc908>] nfs_dentry_iput+0x38/0x50
     [<ffffffff811285f4>] dentry_iput+0x84/0x110
     [<ffffffff811286ae>] d_kill+0x2e/0x60
     [<ffffffff8112912a>] dput+0x7a/0x170
     [<ffffffff8111e925>] path_put+0x15/0x40
     [<ffffffff811c3a44>] __put_nfs_open_context+0xa4/0xb0
     [<ffffffff811cb5d0>] ? nfs_free_request+0x0/0x50
     [<ffffffff811c3b0b>] put_nfs_open_context+0xb/0x10
     [<ffffffff811cb5f9>] nfs_free_request+0x29/0x50
     [<ffffffff81234b7e>] kref_put+0x8e/0xe0
     [<ffffffff811cb594>] nfs_release_request+0x14/0x20
     [<ffffffff811cf769>] nfs_find_and_lock_request+0x89/0xa0
     [<ffffffff811d1180>] nfs_wb_page+0x80/0x110
     [<ffffffff811c0770>] nfs_release_page+0x70/0x90
     [<ffffffff810d18ee>] try_to_release_page+0x5e/0x80
     [<ffffffff810e1178>] shrink_page_list+0x638/0x860
     [<ffffffff810e19de>] shrink_zone+0x63e/0xc40
    
    We can fix this by making the call to put_nfs_open_context() happen when we
    actually remove the write request from the inode (which is done by the
    nfsiod thread in this case).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit b4d2314bb88b07e5a04e6c75b442a1dfcd60e340
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 10 15:21:44 2010 -0500

    NFSv4: Don't ignore the NFS_INO_REVAL_FORCED flag in nfs_revalidate_inode()
    
    If the NFS_INO_REVAL_FORCED flag is set, that means that we don't yet have
    an up to date attribute cache. Even if we hold a delegation, we must
    put a GETATTR on the wire.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 49697ee79242d5f8ac88f1ebc62e583d16bcc687
Author: Steve Dickson <SteveD@redhat.com>
Date:   Tue Oct 13 16:07:33 2009 -0400

    nfs4: Make the v4 callback service hidden
    
    To avoid hangs in the svc_unregister(), on version 4 mounts
    (and unmounts), when rpcbind is not running, make the nfs4 callback
    program an 'hidden' service by setting the 'vs_hidden' flag in the
    nfs4_callback_version structure.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7dd08a570dcf45d52155996fee688405635ee481
Author: Dan Carpenter <error27@gmail.com>
Date:   Sat Mar 6 15:02:22 2010 +0300

    nfs: fix unlikely memory leak
    
    I'll admit that it's unlikely for the first allocation to fail and
    the second one to succeed.  I won't be offended if you ignore this
    patch.
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5fe46e9d733f19a880ef7e516002bd4c2b833e14
Author: Bian Naimeng <biannm@cn.fujitsu.com>
Date:   Mon Mar 8 14:49:01 2010 +0800

    rpc client can not deal with ENOSOCK, so translate it into ENOCONN
    
    If NFSv4 client send a request before connect, or the old connection was broken
    because a ETIMEOUT error catched by call_status, ->send_request will return
    ENOSOCK, but rpc layer can not deal with it, so make sure ->send_request can
    translate ENOSOCK into ENOCONN.
    
    Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


