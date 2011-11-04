Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59759 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755523Ab1KDRI3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 13:08:29 -0400
Subject: [GIT PULL] Please pull NFS client updates for 3.2
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Fri, 04 Nov 2011 13:08:28 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320426508.31405.0.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "nfs-for-3.2" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-3.2

This will update the following files through the appended changesets.

Please note that the pull contains one back-merge, which is needed to
satisfy a dependency between the pnfs object layout update and a recent
exofs update that is already upstream.

  Cheers,
    Trond

----
 fs/exofs/Kconfig             |    2 +-
 fs/nfs/callback_xdr.c        |   12 +-
 fs/nfs/file.c                |    9 +-
 fs/nfs/nfs4filelayout.c      |    7 +-
 fs/nfs/nfs4proc.c            |    6 +
 fs/nfs/nfs4xdr.c             |    2 -
 fs/nfs/objlayout/objio_osd.c |  872 ++++++++++--------------------------------
 fs/nfs/objlayout/objlayout.c |  209 ++++-------
 fs/nfs/objlayout/objlayout.h |   48 ++--
 fs/nfs/pagelist.c            |    2 +-
 fs/nfs/pnfs.c                |   25 +-
 fs/nfs/write.c               |    3 +-
 fs/nfsd/nfssvc.c             |    2 +
 include/linux/nfs_fs.h       |    1 +
 include/linux/sunrpc/clnt.h  |    2 +
 include/linux/sunrpc/svc.h   |    1 +
 net/sunrpc/auth_unix.c       |    3 +
 net/sunrpc/rpcb_clnt.c       |   88 +++--
 net/sunrpc/sunrpc_syms.c     |    3 -
 net/sunrpc/svc.c             |   48 +++-
 20 files changed, 457 insertions(+), 888 deletions(-)

commit 6070295efc90d1093b2031c43380bd7d9673c802
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Nov 4 07:04:10 2011 -0400

    nfs: set vs_hidden on nfs4_callback_version4 (try #2)
    
    This service should not be registered with or unregistered from rpcbind.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 278c023a99b0d6b471d0f4a79835c703482e29ac
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 15:16:54 2011 -0700

    pnfs-obj: Support for RAID5 read-4-write interface.
    
    The ore need suplied a r4w_get_page/r4w_put_page API
    from Filesystem so it can get cache pages to read-into when
    writing parial stripes.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 04291b628c450ab6fdb606836585f16336662a4e
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 15:16:15 2011 -0700

    pnfs-obj: move to ore 03: Remove old raid engine
    
    Finally remove all the old raid engine, which is by now
    dead code.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eecfc6312a24e6d0d2883de0a9a6ccf8e993f472
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 15:15:38 2011 -0700

    pnfs-obj: move to ore 02: move to ORE
    
    In this patch we are actually moving to the ORE.
    (Object Raid Engine).
    
    objio_state holds a pointer to an ore_io_state. Once
    we have an ore_io_state at hand we can call the ore
    for reading/writing. We register on the done path
    to kick off the nfs io_done mechanism.
    
    Again for Ease of reviewing the old code is "#if 0"
    but is not removed so the diff command works better.
    The old code will be removed in the next patch.
    
    fs/exofs/Kconfig::ORE is modified to also be auto-included
    if PNFS_OBJLAYOUT is set. Since we now depend on ORE.
    (See comments in fs/exofs/Kconfig)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit af4f5b54bcf0379089d01518e818f37258708fb7
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 15:04:19 2011 -0700

    pnfs-obj: move to ore 01: ore_layout & ore_components
    
    For Ease of reviewing I split the move to ore into 3 parts
    	move to ore 01: ore_layout & ore_components
    	move to ore 02: move to ORE
    	move to ore 03: Remove old raid engine
    
    This patch modifies the objio_lseg, layout-segment level
    and devices and components arrays to use the ORE types.
    
    Though it will be removed soon, also the raid engine
    is modified to actually compile, possibly run, with
    the new types. So it is the same old raid engine but
    with some new ORE types.
    
    For Ease of reviewing, some of the old code is
    "#if 0" but is not removed so the diff command works
    better. The old code will be removed in the 3rd patch.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e2e04355d9647305c666462a49223f2942a635f0
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 15:03:35 2011 -0700

    pnfs-obj: Rename objlayout_io_state => objlayout_io_res
    
    * All instances of objlayout_io_state => objlayout_io_res
    * All instances of state => oir;
    * All instances of ol_state => oir;
    
    Big but nothing to it
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96218556b03d3c6505e2880a097338bf277fd783
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 14:47:32 2011 -0700

    pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
    
    This is part of moving objio_osd to use the ORE.
    
    objlayout_io_state had two functions:
    1. It was used in the error reporting mechanism at layout_return.
       This function is kept intact.
       (Later patch will rename objlayout_io_state => objlayout_io_res)
    2. Carrier of rw io members into the objio_read/write_paglist API.
       This is removed in this patch.
    
    The {r,w}data received from NFS are passed directly to the
    objio_{read,write}_paglist API. The io_engine is now allocating
    it's own IO state as part of the read/write. The minimal
    functionality that was part of the generic allocation is passed
    to the io_engine.
    
    So part of this patch is rename of:
    	ios->ol_state.foo => ios->foo
    
    At objlayout_{read,write}_done an objlayout_io_state is passed that
    denotes the result of the IO. (Hence the later name change).
    If the IO is successful objlayout calls an objio_free_result() API
    immediately (Which for objio_osd causes the release of the io_state).
    If the IO ended in an error it is hanged onto until reported in
    layout_return and is released later through the objio_free_result()
    API. (All this is not new just renamed and cleaned)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e6c40fe3f4c4967f1cb486191ed4a5d5f55f3f7e
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 14:45:46 2011 -0700

    pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist
    
    objlayout driver was always returning PNFS_ATTEMPTED from it's
    read/write_pagelist operations. Even on error. Fix that.
    
    Start by establishing an error return API from io-engine, by
    not returning ssize_t (length-or-error) but returning "int"
    0=OK, 0>Error. And clean up all return types in io-engine.
    
    Then if io-engine returned error return PNFS_NOT_ATTEMPTED
    to generic layer. (With a dprint)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4cdc685c7d06f659ef6c336d4242005cdd8df401
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 31 14:45:06 2011 -0700

    pnfs-obj: Remove redundant EOF from objlayout_io_state
    
    The EOF calculation was done on .read_pagelist(), cached
    in objlayout_io_state->eof, and set in objlayout_read_done()
    into nfs_read_data->res.eof.
    
    So set it directly into nfs_read_data->res.eof and avoid
    the extra member.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2b72c9ccd22c4a3299e5a358dcd639fb253730f4
Author: Rakib Mullick <rakib.mullick@gmail.com>
Date:   Tue Nov 1 12:23:42 2011 +0600

    nfs: Remove unused variable from write.c
    
    When CONFIG_NFS=y and CONFIG_NFS_V3_{,V4}=n we get the following warning.
    
    	fs/nfs/write.c: In function ‘nfs_writeback_done’:
    	fs/nfs/write.c:1246:21: warning: unused variable ‘server’
    
     Remove the variable 'server' to fix the above warning.
    
    Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f276e49fd108362be3fd67154aaaacf872ea026
Author: Rakib Mullick <rakib.mullick@gmail.com>
Date:   Tue Nov 1 12:16:15 2011 +0600

    nfs: Fix unused variable warning from file.c
    
    Fix the following unused variable warning.
    
    fs/nfs/file.c: In function ‘nfs_file_release’:
    fs/nfs/file.c:140:17: warning: unused variable ‘dentry’
    fs/nfs/file.c: In function ‘nfs_file_read’:
    fs/nfs/file.c:237:9: warning: unused variable ‘count’
    
    Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e414966b81a74745ac8d6bfeda0d95fb721e6d91
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Oct 25 12:18:03 2011 -0400

    NFS: Remove no-op less-than-zero checks on unsigned variables.
    
    Introduced by commit 16b374ca "NFSv4.1: pnfs: filelayout: add driver's
    LAYOUTGET and GETDEVICEINFO infrastructure" (October 20, 2010).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c6e696660213a89a5bfde8b49d539553904c808f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Oct 25 12:17:53 2011 -0400

    NFS: Clean up nfs4_xdr_dec_secinfo()
    
    Clean up: Remove superfluous logic at the tail of
    nfs4_xdr_dec_secinfo() .
    
    Introduced by commit 5a5ea0d4 "NFS: Add secinfo procedure" (March 24,
    2011).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c02f557dd0a026d7147da3b6f7daf52c6ff5580f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Oct 25 12:17:43 2011 -0400

    NFS: Fix documenting comment for nfs_create_request()
    
    Clean up: the first parameter of nfs_create_request() has been
    incorrectly documented since time immemorial (OK, since before
    2.6.12).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d743c3c9c236cc61403a4f7d6283d59ddf68b2bd
Author: Peng Tao <bergwolf@gmail.com>
Date:   Sun Oct 23 20:22:38 2011 -0700

    NFS4: fix cb_recallany decode error
    
    craa_type_mask is bitmap4 per RFC5661. We need to expect a length before
    extracting bitmap value.
    
    Cc: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 92407e75ce45b41c46944891711fd8faf0714d84
Author: Peng Tao <bergwolf@gmail.com>
Date:   Sun Oct 23 20:21:17 2011 -0700

    nfs4: serialize layoutcommit
    
    Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
    And as Trond suggested , there is no need for client to optimize for
    parallel layoutcommit. So add NFS_INO_LAYOUTCOMMITTING flag to
    mark inflight layoutcommit and serialize lalyoutcommit with it.
    Also mark_inode_dirty_sync if pnfs_layoutcommit_inode fails to issue
    layoutcommit.
    
    Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Jim Rees <rees@umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e20de377578e9504f8467c05ab1db98b4935d4ed
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:17:48 2011 +0300

    SUNRPC: remove rpcbind clients destruction on module cleanup
    
    Rpcbind clients destruction during SUNRPC module removing is obsolete since now
    those clients are destroying during last RPC service shutdown.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f0c01da444fbfd63556f301dde15915fd6cbb20
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:17:38 2011 +0300

    SUNRPC: remove rpcbind clients creation during service registering
    
    We don't need this code since rpcbind clients are creating during RPC service
    creation.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 16d0587090ab93206768f726f71d84ecf55e05c4
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:17:28 2011 +0300

    NFSd: call svc rpcbind cleanup explicitly
    
    We have to call svc_rpcb_cleanup() explicitly from nfsd_last_thread() since
    this function is registered as service shutdown callback and thus nobody else
    will done it for us.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e356b1e2a888c59d10a4842995a3273ca2d9086
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:17:18 2011 +0300

    SUNRPC: cleanup service destruction
    
    svc_unregister() call have to be removed from svc_destroy() since it will be
    called in sv_shutdown callback.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e40f5e29ef0909ecba1d759cc930efb7a9a7d935
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:17:08 2011 +0300

    SUNRPC: setup rpcbind clients if service requires it
    
    New function ("svc_uses_rpcbind") will be used to detect, that new service will
    send portmapper register calls. For such services we will create rpcbind
    clients and remove all stale portmap registrations.
    Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
    in case of this field wasn't initialized earlier. This will allow to destroy
    rpcbind clients when no other users of them left.
    
    Note: Currently, any creating service will be detected as portmap user.
    Probably, this is wrong. But now it depends on program versions "vs_hidden"
    flag.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d99085605cd245d8f24858e9d0b06013e13aa044
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:16:58 2011 +0300

    SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
    
    This helpers will be used only for those services, that will send portmapper
    registration calls.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 253fb070e78db981740b000914b04b9203092925
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:16:48 2011 +0300

    SUNRPC: use rpcbind reference counting helpers
    
    All is simple: we just increase users counter if rpcbind clients has been
    created already. Otherwise we create them and set users counter to 1.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 914edb1bb2abe2ae4775368f2ffb7f41010fb81e
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Oct 25 14:16:36 2011 +0300

    SUNRPC: introduce helpers for reference counted rpcbind clients
    
    v6:
    1) added write memory barrier to rpcb_set_local to make sure, that rpcbind
    clients become valid before rpcb_users assignment
    2) explicitly set rpcb_users to 1 instead of incrementing it (looks clearer from
    my pow).
    
    v5: fixed races with rpcb_users in rpcb_get_local()
    
    This helpers will be used for dynamical creation and destruction of rpcbind
    clients.
    Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
    clients has been created already, then we just increase rpcb_users.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc6f55e9f8dac4b6479be67c5c9128ad37bb491f
Author: NeilBrown <neilb@suse.de>
Date:   Tue Oct 25 10:25:49 2011 +1100

    NFS/sunrpc: don't use a credential with extra groups.
    
    The sunrpc layer keeps a cache of recently used credentials and
    'unx_match' is used to find the credential which matches the current
    process.
    
    However unx_match allows a match when the cached credential has extra
    groups at the end of uc_gids list which are not in the process group list.
    
    So if a process with a list of (say) 4 group accesses a file and gains
    access because of the last group in the list, then another process
    with the same uid and gid, and a gid list being the first tree of the
    gids of the original process tries to access the file, it will be
    granted access even though it shouldn't as the wrong rpc credential
    will be used.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


