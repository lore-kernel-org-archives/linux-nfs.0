Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57755 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198Ab1JYMZt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 08:25:49 -0400
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Tue, 25 Oct 2011 14:25:47 +0200
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319545547.2716.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "nfs-for-3.2" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-3.2

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/blocklayout/blocklayout.c    |   58 ++++++++++++----------
 fs/nfs/blocklayout/blocklayout.h    |    4 +-
 fs/nfs/blocklayout/blocklayoutdev.c |   35 +++----------
 fs/nfs/client.c                     |   11 +++-
 fs/nfs/delegation.c                 |    2 +-
 fs/nfs/fscache-index.c              |    4 +-
 fs/nfs/idmap.c                      |   25 +---------
 fs/nfs/inode.c                      |   16 +++---
 fs/nfs/internal.h                   |   10 ----
 fs/nfs/nfs4filelayout.c             |   33 +++----------
 fs/nfs/nfs4proc.c                   |   93 +++++++++++++---------------------
 fs/nfs/pnfs.c                       |   52 ++++++++++----------
 fs/nfs/pnfs.h                       |    5 +-
 fs/nfs/read.c                       |   40 +++++++--------
 fs/nfs/super.c                      |   17 ++++--
 fs/nfs/unlink.c                     |    4 +-
 fs/nfs/write.c                      |   73 ++++++++++++++++-----------
 include/linux/nfs_fs.h              |    1 -
 include/linux/nfs_page.h            |    1 +
 include/linux/nfs_xdr.h             |    5 --
 include/linux/sunrpc/clnt.h         |    3 +-
 include/linux/sunrpc/rpc_pipe_fs.h  |    2 +
 net/sunrpc/addr.c                   |    6 +-
 net/sunrpc/auth_gss/auth_gss.c      |   24 +--------
 net/sunrpc/clnt.c                   |    4 +-
 net/sunrpc/rpc_pipe.c               |   20 ++++++++
 net/sunrpc/rpcb_clnt.c              |    6 +-
 27 files changed, 242 insertions(+), 312 deletions(-)

commit 940aab490215424a269f93d2eba2794fc8b3e269
Author: Malahal Naineni <malahal@us.ibm.com>
Date:   Tue Sep 20 17:27:14 2011 -0700

    Check validity of cl_rpcclient in nfs_server_list_show
    
    As soon as the nfs_client gets created, its cl_rpcclient is set to
    ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
    if the client is ready before using the cl_rpcclient pointer.
    
    Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b6ee8cd2642f6d822dd1a4ba62298b65ff99b72e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Get rid of the nfs_rdata_mempool
    
    We don't need a mempool in order to guarantee reliable NFS read performance.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fba730050d1246d0e6ef44e026e0b584732fec2b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Don't rely on PageError in nfs_readpage_release_partial
    
    Don't rely on the PageError flag to tell us if one of the partial reads of
    the page failed. Instead, replace that with a dedicated flag in the
    struct nfs_page.
    
    Then clean out redundant uses of the PageError flag: the VM no longer
    checks it for reads.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbb5a9abf0d589e9471dc93b18025b7b921d22c9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Get rid of unnecessary calls to ClearPageError() in read code
    
    The generic file read code does that for us anyway.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d00c5d43866720963a265fa3129f3203cac35b8e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Get rid of nfs_restart_rpc()
    
    It can trivially be replaced with rpc_restart_call_prepare.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b8ef70639b609c5d12c618f1d9ffae6ac13aebe3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Get rid of the unused nfs_write_data->flags field
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a1940805d0636c6cdf37636f55b43b9681d53e73
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 19 12:17:29 2011 -0700

    NFS: Get rid of the unused nfs_read_data->flags field
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 08ef7bd3bc04261d14d570ac7eaac3eac947b1ba
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 18 16:11:49 2011 -0700

    NFSv4: Translate NFS4ERR_BADNAME into ENOENT when applied to a lookup
    
    Both LOOKUP and OPEN operations may return NFS4ERR_BADNAME if we send a
    an invalid name as a filename argument. As far as the application is
    concerned, it just has to know that the file doesn't exist, and so
    ENOENT would be the appropriate reply. We should only return EINVAL
    if the filename is being used to _create_ a new object on the
    remote filesystem.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0c2e53f11a6dae9e3af5f50f5ad0382e7c3e0cfa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 18 16:11:22 2011 -0700

    NFS: Remove the unused "lookupfh()" version of nfs4_proc_lookup()
    
    ...and also remove the associated nfs_v4_clientops entry.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a9a4a87a5942e9271523197a90aaa82349c818fb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 17 16:08:46 2011 -0700

    NFS: Use the inode->i_version to cache NFSv4 change attribute information
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 919066d690541f4bd727b0e0fc2f7a20a7e3b3a7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 17 16:08:10 2011 -0700

    SUNRPC: Remove unnecessary export of rpc_sockaddr2uaddr
    
    It is only used internally by the RPC code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d77385f23830ee6c400569bac8b37e6eb3b7d360
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 17 16:08:10 2011 -0700

    SUNRPC: Fix rpc_sockaddr2uaddr
    
    rpc_sockaddr2uaddr is only used by net/sunrpc/rpcb_clnt.c, where
    it is used in a non-blockable context in at least one case.
    
    Add non-blocking capability by adding a gfp_t argument
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 45402c38eec740f52422aafc92937c6a4a8c8c0e
Author: H Hartley Sweeten <hartleys@visionengravers.com>
Date:   Fri Sep 2 14:39:12 2011 -0700

    nfs/super.c: local functions should be static
    
    commit ae50c0b5 "pnfs: client stats" added additional information to
    the output of /proc/self/mountstats. The new functions introduced are
    only used in this file and should be marked static.
    
    If CONFIG_NFS_V4_1 is not defined, empty stub functions are used.  If
    CONFIG_NFS_V4 is not defined these stub functions are not used at all.
    Adding static for the functions results in compile warnings:
    
    fs/nfs/super.c:743: warning: 'show_sessions' defined but not used
    fs/nfs/super.c:756: warning: 'show_pnfs' defined but not used
    
    Fix this by adding a #ifdef CONFIG_NFS_V4 guard around the two
    show_ functions.
    
    Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7542274519b3ba87555410c66e8356ac1e3bc9b3
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:17 2011 -0400

    pnfsblock: fix writeback deadlock
    
    We should check if the sector is already initialized before
    trying to grab the page from page cache. Otherwise when two
    pages of the same block are written back by two threads each
    calling from writepage_locked, it can cause deadlock like bellow.
    
     [ 1080.972099] INFO: task kswapd0:25 blocked for more than 120 seconds.
     [ 1080.972377] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
     [ 1080.972812] kswapd0         D ffff88000c4926c0     0    25      2 0x00000000
     [ 1080.972816]  ffff88000df276b0 0000000000000046 ffff88000df27640 ffffffff81013ba7
     [ 1080.972821]  ffff88000c492310 ffff88000df27fd8 ffff88000df27fd8 00000000001d3440
     [ 1080.972824]  ffff88000c378000 ffff88000c492310 ffff8800175d3d40 ffff880017fc75a8
     [ 1080.972828] Call Trace:
     [ 1080.972860]  [<ffffffff81013ba7>] ? read_tsc+0x9/0x19
     [ 1080.972877]  [<ffffffff810e0b23>] ? lock_page+0x2b/0x2b
     [ 1080.972899]  [<ffffffff81475a1d>] io_schedule+0x63/0x7e
     [ 1080.972902]  [<ffffffff810e0b31>] sleep_on_page+0xe/0x12
     [ 1080.972905]  [<ffffffff81475fe8>] __wait_on_bit_lock+0x46/0x8f
     [ 1080.972916]  [<ffffffff810822d7>] ? lock_release_holdtime.part.7+0x6b/0x72
     [ 1080.972919]  [<ffffffff810e0af6>] __lock_page+0x66/0x68
     [ 1080.972928]  [<ffffffff81072705>] ? autoremove_wake_function+0x3d/0x3d
     [ 1080.972932]  [<ffffffff810e0b1f>] lock_page+0x27/0x2b
     [ 1080.972934]  [<ffffffff810e0bcf>] find_lock_page+0x34/0x57
     [ 1080.972937]  [<ffffffff810e1738>] find_or_create_page+0x34/0x8a
     [ 1080.972947]  [<ffffffffa034245b>] bl_write_pagelist+0x205/0x6da [blocklayoutdriver]
     [ 1080.972951]  [<ffffffffa034145d>] ? bl_free_lseg+0x38/0x38 [blocklayoutdriver]
     [ 1080.972995]  [<ffffffffa02e27b9>] ? nfs_write_rpcsetup+0x118/0x123 [nfs]
     [ 1080.973033]  [<ffffffffa030246b>] pnfs_generic_pg_writepages+0x10b/0x1f4 [nfs]
     [ 1080.973089]  [<ffffffffa02deaae>] nfs_pageio_doio+0x1a/0x43 [nfs]
     [ 1080.973098]  [<ffffffffa02df035>] nfs_pageio_complete+0x16/0x2d [nfs]
     [ 1080.973108]  [<ffffffffa02e2d8f>] nfs_writepage_locked+0xa0/0xbf [nfs]
     [ 1080.973119]  [<ffffffffa02e36a1>] nfs_writepage+0x16/0x2b [nfs]
     [ 1080.973122]  [<ffffffff810e8762>] ? clear_page_dirty_for_io+0x87/0x9a
     [ 1080.973133]  [<ffffffff810efc5b>] shrink_page_list+0x39b/0x6c8
     [ 1080.973139]  [<ffffffff810f03bb>] shrink_inactive_list+0x22c/0x39e
     [ 1080.973144]  [<ffffffff810822d7>] ? lock_release_holdtime.part.7+0x6b/0x72
     [ 1080.973148]  [<ffffffff810f0c33>] shrink_zone+0x445/0x588
     [ 1080.973152]  [<ffffffff810f1a11>] balance_pgdat+0x2c2/0x56b
     [ 1080.973170]  [<ffffffff81254208>] ? __bitmap_weight+0x34/0x80
     [ 1080.973175]  [<ffffffff810f1f78>] kswapd+0x2be/0x2fa
     [ 1080.973179]  [<ffffffff810726c8>] ? __init_waitqueue_head+0x4b/0x4b
     [ 1080.973183]  [<ffffffff810f1cba>] ? balance_pgdat+0x56b/0x56b
     [ 1080.973187]  [<ffffffff81071f69>] kthread+0xa8/0xb0
     [ 1080.973200]  [<ffffffff814806b4>] kernel_thread_helper+0x4/0x10
     [ 1080.973205]  [<ffffffff81071ec1>] ? __init_kthread_worker+0x5a/0x5a
     [ 1080.973210]  [<ffffffff814806b0>] ? gs_change+0x13/0x13
     [ 1080.973213] no locks held by kswapd0/25.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e6d05a757c314ad88d0649d3835a8a1daa964236
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:16 2011 -0400

    pnfsblock: fix NULL pointer dereference
    
    bl_add_page_to_bio returns error pointer. bio should be reset to
    NULL in failure cases as the out path always calls bl_submit_bio.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9b7eecdcfeb943f130d86bbc249fde4994b6fe30
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:15 2011 -0400

    pnfs: recoalesce when ld read pagelist fails
    
    For pnfs pagelist read failure, we need to pg_recoalesce and resend IO to
    mds.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ce160c5ef06cc89c2b6b26bfa5ef7a5ce2c93e0
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:14 2011 -0400

    pnfs: recoalesce when ld write pagelist fails
    
    For pnfs pagelist write failure, we need to pg_recoalesce and resend IO to
    mds.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1b0ae068779874f54b55aac3a2a992bcf3f2c3c4
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:12 2011 -0400

    pnfs: make _set_lo_fail generic
    
    file layout and block layout both use it to set mark layout io failure
    bit. So make it generic.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 760383f1ee4d14b0e0bdf0cddee648d9b8633429
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:11 2011 -0400

    pnfsblock: add missing rpc_put_mount and path_put
    
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c1225158a8dad9e9d5eee8a17dbbd9c7cda05ab9
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Sep 22 21:50:10 2011 -0400

    SUNRPC/NFS: make rpc pipe upcall generic
    
    The same function is used by idmap, gss and blocklayout code. Make it
    generic.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fdc17abbc4b6094b34ee8ff5d91eaba8637594a2
Author: Jim Rees <rees@umich.edu>
Date:   Thu Sep 22 21:50:09 2011 -0400

    pnfsblock: fix size of upcall message
    
    Make the status field explicitly 32 bits.  "...it's unlikely that the kernel
    and userspace would differ on the size of an int here, but it might be a
    good idea to go ahead and make that explicitly 32 bits in case we end up
    dealing with more exotic arches at some point in the future."
    
    Suggested-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 516f2e24faa7548a61d9ba790958528469c2e284
Author: Jim Rees <rees@umich.edu>
Date:   Thu Sep 22 21:50:08 2011 -0400

    pnfsblock: fix return code confusion
    
    Always return PTR_ERR, not NULL, from nfs4_blk_get_deviceinfo and
    nfs4_blk_decode_device.
    
    Check for IS_ERR, not NULL, in bl_set_layoutdriver when calling
    nfs4_blk_get_deviceinfo.
    
    Signed-off-by: Jim Rees <rees@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Cc: stable@kernel.org [3.0]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2da956523526e440ef4f4dd174e26f5ac06fe011
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Oct 12 10:57:42 2011 -0400

    nfs: don't try to migrate pages with active requests
    
    nfs_find_and_lock_request will take a reference to the nfs_page and
    will then put it if the req is already locked. It's possible though
    that the reference will be the last one. That put then can kick off
    a whole series of reference puts:
    
    nfs_page
       nfs_open_context
          dentry
              inode
    
    If the inode ends up being deleted, then the VFS will call
    truncate_inode_pages. That function will try to take the page lock, but
    it was already locked when migrate_page was called. The code
    deadlocks.
    
    Fix this by simply refusing the migration request if PagePrivate is
    already set, indicating that the page is already associated with an
    active read or write request.
    
    We've had a customer test a backported version of this patch and
    the preliminary results seem good.
    
    Cc: stable@kernel.org
    Cc: Andrea Arcangeli <aarcange@redhat.com>
    Reported-by: Harshula Jayasuriya <harshula@redhat.com>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9dd3abbbc708da5e3c53424a5b2c66ab580f97e
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Wed Oct 12 15:09:34 2011 +0800

    nfs: fix bug about IPv6 address scope checking
    
    The result from ipv6_addr_scope() always not be a single SCOPE,
    so we can't use equal to compare the result with IPV6_ADDR_SCOPE_LINKLOCAL
    at nfs_sockaddr_match_ipaddr6.
    
    This patch fixs the problem, and lets checking address before scope_id.
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3236c3e1adc0c7ec83eaff1de2d06746b7c5bb28
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Oct 11 09:49:21 2011 -0400

    nfs: don't redirty inode when ncommit == 0 in nfs_commit_unstable_pages
    
    commit 420e3646 allowed the kernel to reduce the number of unnecessary
    commit calls by skipping the commit when there are a large number of
    outstanding pages.
    
    However, the current test in nfs_commit_unstable_pages does not handle
    the edge condition properly. When ncommit == 0, then that means that the
    kernel doesn't need to do anything more for the inode. The current test
    though in the WB_SYNC_NONE case will return true, and the inode will end
    up being marked dirty. Once that happens the inode will never be clean
    until there's a WB_SYNC_ALL flush.
    
    Fix this by immediately returning from nfs_commit_unstable_pages when
    ncommit == 0.
    
    Mike noticed this problem initially in RHEL5 (2.6.18-based kernel) which
    has a backported version of 420e3646. The inode cache there was growing
    very large. The inode cache was unable to be shrunk since the inodes
    were all marked dirty. Calling sync() would essentially "fix" the
    problem -- the WB_SYNC_ALL flush would result in the inodes all being
    marked clean.
    
    What I'm not clear on is how big a problem this is in mainline kernels
    as the writeback code there is very different. Either way, it seems
    incorrect to re-mark the inode dirty in this case.
    
    Reported-by: Mike McLean <mikem@redhat.com>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Cc: stable@kernel.org [2.6.34+]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 59b7c05fffba030e5d9e72324691e2f99aa69b79
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 17 18:22:55 2011 -0700

    Revert "NFS: Ensure that writeback_single_inode() calls write_inode() when syncing"
    
    This reverts commit b80c3cb628f0ebc241b02e38dd028969fb8026a2.
    
    The reverted commit was rendered obsolete by a VFS fix: commit
    5547e8aac6f71505d621a612de2fca0dd988b439 (writeback: Update dirty flags in
    two steps). We now no longer need to worry about writeback_single_inode()
    missing our marking the inode for COMMIT in 'do_writepages()' call.
    
    Reverting this patch, fixes a performance regression in which the inode
    would continuously get queued to the dirty list, causing the writeback
    code to unnecessarily try to send a COMMIT.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust>
    Tested-by: Simon Kirby <sim@hostway.ca>
    Cc: stable@kernel.org [2.6.35+]


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

