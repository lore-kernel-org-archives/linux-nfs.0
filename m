Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42213 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749Ab1CQRT0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 13:19:26 -0400
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 13:19:09 -0400
Message-ID: <1300382349.28305.24.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.39" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.39

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/filesystems/nfs/pnfs.txt |    7 +
 Documentation/kernel-parameters.txt    |    8 +
 fs/nfs/callback_proc.c                 |    2 +-
 fs/nfs/client.c                        |  131 +++++++++---
 fs/nfs/direct.c                        |    8 +-
 fs/nfs/file.c                          |    4 -
 fs/nfs/idmap.c                         |   90 +++++++--
 fs/nfs/internal.h                      |   22 ++
 fs/nfs/nfs3proc.c                      |    1 +
 fs/nfs/nfs4_fs.h                       |   28 +++
 fs/nfs/nfs4filelayout.c                |  361 +++++++++++++++++++++++++++++---
 fs/nfs/nfs4filelayout.h                |   19 ++-
 fs/nfs/nfs4filelayoutdev.c             |  252 ++++++++++++++++++++---
 fs/nfs/nfs4proc.c                      |  123 ++++++++++--
 fs/nfs/nfs4renewd.c                    |    6 +-
 fs/nfs/nfs4state.c                     |    6 +
 fs/nfs/nfs4xdr.c                       |   38 ++--
 fs/nfs/pagelist.c                      |   22 ++-
 fs/nfs/pnfs.c                          |  330 ++++++++++++++---------------
 fs/nfs/pnfs.h                          |  118 ++++++-----
 fs/nfs/proc.c                          |    1 +
 fs/nfs/read.c                          |  127 +++++++----
 fs/nfs/super.c                         |  284 +++++++------------------
 fs/nfs/write.c                         |  153 +++++++++-----
 include/linux/nfs_fs.h                 |    2 +-
 include/linux/nfs_fs_sb.h              |    4 +-
 include/linux/nfs_idmap.h              |    9 +-
 include/linux/nfs_iostat.h             |    2 +
 include/linux/nfs_page.h               |    6 +-
 include/linux/nfs_xdr.h                |   16 ++-
 include/linux/sunrpc/clnt.h            |    1 +
 include/linux/sunrpc/xprt.h            |    3 +-
 net/sunrpc/auth_gss/auth_gss.c         |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c    |    2 +-
 net/sunrpc/clnt.c                      |   18 +-
 net/sunrpc/sched.c                     |   29 +--
 net/sunrpc/xprt.c                      |   25 +--
 net/sunrpc/xprtrdma/rpc_rdma.c         |   86 ++++----
 net/sunrpc/xprtrdma/verbs.c            |   53 ++++-
 net/sunrpc/xprtrdma/xprt_rdma.h        |    1 +
 40 files changed, 1600 insertions(+), 800 deletions(-)

commit 8e26de238fd794c8ea56a5c98bf67c40cfeb051d
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Thu Mar 17 18:54:23 2011 +0300

    RPC: killing RPC tasks races fixed
    
    RPC task RPC_TASK_QUEUED bit is set must be checked before trying to wake up
    task rpc_killall_tasks() because task->tk_waitqueue can not be set (equal to
    NULL).
    Also, as Trond Myklebust mentioned, such approach (instead of checking
    tk_waitqueue to NULL) allows us to "optimise away the call to
    rpc_wake_up_queued_task() altogether for those
    tasks that aren't queued".
    
    Here is an example of dereferencing of tk_waitqueue equal to NULL:
    
    CPU 0               	CPU 1				CPU 2
    --------------------	---------------------	--------------------------
    nfs4_run_open_task
    rpc_run_task
    rpc_execute
    rpc_set_active
    rpc_make_runnable
    (waiting)
    			rpc_async_schedule
    			nfs4_open_prepare
    			nfs_wait_on_sequence
    						nfs_umount_begin
    						rpc_killall_tasks
    						rpc_wake_up_task
    						rpc_wake_up_queued_task
    						spin_lock(tk_waitqueue == NULL)
    						BUG()
    			rpc_sleep_on
    			spin_lock(&q->lock)
    			__rpc_sleep_on
    			task->tk_waitqueue = q
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@openvz.org>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba3c578de274a5438bafbce03f9225936698051c
Author: j223yang@asset.uwaterloo.ca <j223yang@asset.uwaterloo.ca>
Date:   Wed Mar 16 11:16:22 2011 -0400

    xprt: remove redundant check
    
    remove redundant check.
    
    Signed-off-by: Jinqiu Yang <crindy646@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8de240a9074b72b156d9e6d53f00076e6cd5f03
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 15 19:56:30 2011 -0400

    SUNRPC: Convert struct rpc_xprt to use atomic_t counters
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e020c6800c9621a77223bf2c1ff68180e41e8ebf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 15 19:56:30 2011 -0400

    SUNRPC: Ensure we always run the tk_callback before tk_action
    
    This fixes a race in which the task->tk_callback() puts the rpc_task
    to sleep, setting a new callback. Under certain circumstances, the current
    code may end up executing the task->tk_action before it gets round to the
    callback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 986d4abbddf9e76184f6cabf66654ea8e61bcde5
Author: Randy Dunlap <randy.dunlap@oracle.com>
Date:   Tue Mar 15 17:11:59 2011 -0700

    sunrpc: fix printk format warning
    
    Fix printk format build warning:
    
    net/sunrpc/xprtrdma/verbs.c:1463: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'dma_addr_t'
    
    Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4d4a76f3309edc671918a767b336492fbc80a16d
Author: j223yang@asset.uwaterloo.ca <j223yang@asset.uwaterloo.ca>
Date:   Thu Mar 10 12:40:28 2011 -0500

    xprt: remove redundant null check
    
    'req' is dereferenced before checked for NULL.
    The patch simply removes the check.
    
    Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8f68cd42d85f31fb58dd2cabf3ff4aad0a2bafd9
Author: Stephen Rothwell <sfr@canb.auug.org.au>
Date:   Tue Mar 15 18:37:09 2011 +1100

    nfs: BKL is no longer needed, so remove the include
    
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e0dca7a05df4e23a8f5b07742e99e2a6f7d67db1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 14 18:20:01 2011 -0400

    NFS: Fix a warning in fs/nfs/idmap.c
    
    Commit 45a52a02072b2a7e265f024cfdb00127e08dd9f2 (NFS move nfs_client
    initialization into nfs_get_client) introduces a new warning in
    fs/nfs/idmap.c:
    
    	‘struct rpc_timeout’ declared inside parameter list
    
    Fix it by adding a forward declaration for the struct rpc_timeout
    in include/linux/nfs_xdr.h
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c5cb09b6f898609922f9b873661f6cbc26cb29e1
Author: Rob Landley <rlandley@parallels.com>
Date:   Wed Mar 9 16:02:37 2011 -0600

    Cleanup: Factor out some cut-and-paste code.
    
    Factor out some cut-and-paste code in options parsing.
    Saves about 800 bytes on x86-64.
    
    Signed-off-by: Rob Landley <rlandley@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c12bacec458bef16d843c052f38422862f3da8fe
Author: Rob Landley <rlandley@parallels.com>
Date:   Wed Mar 9 15:54:13 2011 -0600

    cleanup: save 60 lines/100 bytes by combining two mostly duplicate functions.
    
    Eliminate two mostly duplicate functions (nfs_parse_simple_hostname()
    and nfs_parse_protected_hostname()) and instead just make the calling
    function (nfs_parse_devname()) do everything.
    
    Signed-off-by: Rob Landley <rlandley@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ec10f26e1fd5fcceb9c96e508c1292a816199f7
Author: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date:   Tue Feb 22 00:28:34 2011 +0300

    NFS: account direct-io into task io accounting
    
    Account NFS direct-io reads and writes into Task I/O Accounting.
    Do it before complition to handle aio.
    
    NFS have unusual direct-io implementation,
    thus accounting in generic code does not work.
    
    Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f8628220bb395104697be9c447c1085846dfc97c
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Mar 3 00:51:41 2011 +0000

    gss:krb5 only include enctype numbers in gm_upcall_enctypes
    
    Make the value in gm_upcall_enctypes just the enctype values.
    This allows the values to be used more easily elsewhere.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5c635e09cec0feeeb310968e51dad01040244851
Author: Tom Tucker <tom@ogc.us>
Date:   Wed Feb 9 19:45:34 2011 +0000

    RPCRDMA: Fix FRMR registration/invalidate handling.
    
    When the rpc_memreg_strategy is 5, FRMR are used to map RPC data.
    This mode uses an FRMR to map the RPC data, then invalidates
    (i.e. unregisers) the data in xprt_rdma_free. These FRMR are used
    across connections on the same mount, i.e. if the connection goes
    away on an idle timeout and reconnects later, the FRMR are not
    destroyed and recreated.
    
    This creates a problem for transport errors because the WR that
    invalidate an FRMR may be flushed (i.e. fail) leaving the
    FRMR valid. When the FRMR is later used to map an RPC it will fail,
    tearing down the transport and starting over. Over time, more and
    more of the FRMR pool end up in the wrong state resulting in
    seemingly random disconnects.
    
    This fix keeps track of the FRMR state explicitly by setting it's
    state based on the successful completion of a reg/inv WR. If the FRMR
    is ever used and found to be in the wrong state, an invalidate WR
    is prepended, re-syncing the FRMR state and avoiding the connection loss.
    
    Signed-off-by: Tom Tucker <tom@ogc.us>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bd7ea31b9e8a342be76e0fe8d638343886c2d8c5
Author: Tom Tucker <tom@ogc.us>
Date:   Wed Feb 9 19:45:28 2011 +0000

    RPCRDMA: Fix to XDR page base interpretation in marshalling logic.
    
    The RPCRDMA marshalling logic assumed that xdr->page_base was an
    offset into the first page of xdr->page_list. It is in fact an
    offset into the xdr->page_list itself, that is, it selects the
    first page in the page_list and the offset into that page.
    
    The symptom depended in part on the rpc_memreg_strategy, if it was
    FRMR, or some other one-shot mapping mode, the connection would get
    torn down on a base and bounds error. When the badly marshalled RPC
    was retransmitted it would reconnect, get the error, and tear down the
    connection again in a loop forever. This resulted in a hung-mount. For
    the other modes, it would result in silent data corruption. This bug is
    most easily reproduced by writing more data than the filesystem
    has space for.
    
    This fix corrects the page_base assumption and otherwise simplifies
    the iov mapping logic.
    
    Signed-off-by: Tom Tucker <tom@ogc.us>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b064eca2cf6440bf9d5843b24cc4010624031694
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 22 15:44:32 2011 -0800

    NFSv4: Send unmapped uid/gids to the server when using auth_sys
    
    The new behaviour is enabled using the new module parameter
    'nfs4_disable_idmapping'.
    
    Note that if the server rejects an unmapped uid or gid, then
    the client will automatically switch back to using the idmapper.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3ddeb7c5c61d0d6bfd837487d3454ffdb788bb91
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 22 15:44:31 2011 -0800

    NFSv4: Propagate the error NFS4ERR_BADOWNER to nfs4_do_setattr
    
    This will be required in order to switch uid/gid mapping back on if the
    admin has tried to disable it.
    
    Note that we also propagate NFS4ERR_BADNAME at the same time, in order to
    work around a Linux server bug.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e4fd72a17d2703cfd626c55893ac4ca7e7d81ce9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 22 15:44:31 2011 -0800

    NFSv4: cleanup idmapper functions to take an nfs_server argument
    
    ...instead of the nfs_client.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f0b851689a5da2354f19bcbbac30cd2cab45c4a1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 22 15:44:31 2011 -0800

    NFSv4: Send unmapped uid/gids to the server if the idmapper fails
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5cf36cfdc8caa2724738ad0842c5c3dd02f309dc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 22 15:44:31 2011 -0800

    NFSv4: If the server sends us a numeric uid/gid then accept it
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 75247affd7930cc3dcf57f850f0d7898379ef3b3
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Feb 22 15:56:01 2011 -0800

    NFSv4.1: reject zero layout with zeroed stripe unit
    
    Allowing stripe_unit==0 causes the client to crash later on
    when dividing by zero.
    
    Reported-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 36fe432d33e078caee5c954e15e929819c2cacae
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:49 2011 +0000

    NFSv4.1: Clear lseg pointer in ->doio function
    
    Now that we have access to the pointer, clear it immediately after
    the put, instead of in caller.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c76069bda0f17cd3e153e54d9ac01242909c6b15
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:48 2011 +0000

    NFSv4.1: rearrange ->doio args
    
    This will make it possible to clear the lseg pointer in the same
    function as it is put, instead of in the caller nfs_pageio_doio().
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a69aef1496726ed88386dad65abfcc8cd3195304
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:47 2011 +0000

    NFSv4.1: pnfs filelayout driver write
    
    Allows the pnfs filelayout driver to write to the data servers.
    
    Note that COMMIT to data servers will be implemented in a future
    patch.  To avoid improper behavior, for the moment any WRITE to a data
    server that would also require a COMMIT to the data server is sent
    NFS_FILE_SYNC.
    
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ffd10640dc008f6d5a375bd6450755745c63c7d
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:46 2011 +0000

    NFSv4.1: remove GETATTR from ds writes
    
    Any WRITE compound directed to a data server needs to have the
    GETATTR calls suppressed.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0382b74409c6b9ef12c952b50bb44f557a361a43
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Mar 3 15:13:45 2011 +0000

    NFSv4.1: implement generic pnfs layer write switch
    
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44b83799a922a153957c65ccfc985a8c902958c8
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:44 2011 +0000

    NFSv4.1: trigger LAYOUTGET for writes
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5053aa568d4017aeb1fa35247d4ad96be262920f
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:43 2011 +0000

    NFSv4.1: Send lseg down into nfs_write_rpcsetup
    
    We grab the lseg sent in from the doio function and attach it to
    each struct nfs_write_data created.  This is how the lseg will be
    sent to the layout driver.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b029bc9b0880cbaf999f580c0ea8f06dd274fc77
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 3 15:13:42 2011 +0000

    NFSv4.1: add callback to nfs4_write_done
    
    Add callback that pnfs layout driver can use to do its own handling
    of data server WRITE response.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d138d5d17be6a60d883e8bd4e22bc218d3adfab3
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Mar 3 15:13:41 2011 +0000

    NFSv4.1: rearrange nfs_write_rpcsetup
    
    Reorder nfs_write_rpcsetup, preparing for a pnfs entry point.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 80fe2b192dbc53261e385dc26d90f5195f1c62e7
Author: Fred Isaman <iisaman@netapp.com>
Date:   Tue Mar 1 01:34:23 2011 +0000

    NFSv4.1: lseg documentation
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 568e8c494ded95a28c5dd8b79b4d3ffb95b6d845
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:22 2011 +0000

    NFSv4.1: turn off pNFS on ds connection failure
    
    If a data server is unavailable, go through MDS.
    
    Mark the deviceid containing the data server as a negative cache entry.
    Do not try to connect to any data server on a deviceid marked as a negative
    cache entry. Mark any layout that tries to use the marked deviceid as failed.
    
    Inodes with a layout marked as fails will not use the layout for I/O, and will
    not perform any more layoutgets.
    Inodes without a layout will still do layoutget, but the layout will get
    marked immediately.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea8eecdd11ee6becd09c095c8efa88aa7df95961
Author: Christoph Hellwig <hch@infradead.org>
Date:   Tue Mar 1 01:34:21 2011 +0000

    NFSv4.1 move deviceid cache to filelayout driver
    
    No need for generic cache with only one user.
    Keep a simple hash of deviceids in the filelayout driver.
    
    Signed-off-by: Christoph Hellwig <hch@infradead.org>
    Acked-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cbdabc7f8bf14ca1d40ab1cb86f64b3bc09716e8
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:20 2011 +0000

    NFSv4.1: filelayout async error handler
    
    Use our own async error handler.
    Mark the layout as failed and retry i/o through the MDS on specified errors.
    
    Update the mds_offset in nfs_readpage_retry so that a failed short-read retry
    to a DS gets correctly resent through the MDS.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc70d7b3189597f313df7bd2da849cfc39063b15
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:19 2011 +0000

    NFSv4.1: filelayout read
    
    Attempt a pNFS file layout read by setting up the nfs_read_data struct and
    calling nfs_initiate_read with the data server rpc client and the
    filelayout rpc call ops.
    
    Error handling is implemented in a subsequent patch.
    
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Tested-by: Guo Mingyang <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cfe7f4120f8b1b9465c333d1e42efd4669b1799f
Author: Fred Isaman <iisaman@netapp.com>
Date:   Tue Mar 1 01:34:18 2011 +0000

    NFSv4.1: filelayout i/o helpers
    
    Prepare for filelayout_read_pagelist with helper functions that find the correct
    data server, filehandle, and offset.
    
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Tigran Mkrtchyan <tigran@anahit.desy.de>
    Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d83217c13531fd59730d77b5c2284e90e56c0a50
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:17 2011 +0000

    NFSv4.1: data server connection
    
    Introduce a data server set_client and init session following the
    nfs4_set_client and  nfs4_init_session convention.
    
    Once a new nfs_client is on the nfs_client_list, the nfs_client cl_cons_state
    serializes access to creating an nfs_client struct with matching properties.
    
    Use the new nfs_get_client() that initializes new clients.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 64419a9b20938d9070fdd8c58c2fa23c911915f8
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:16 2011 +0000

    NFSv4.1: generic read
    
    Separate the rpc run portion of nfs_read_rpcsetup into a new function
    nfs_initiate_read that is called for normal NFS I/O.
    
    Add a pNFS read_pagelist function that is called instead of nfs_intitate_read
    for pNFS reads.
    
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bae724ef95b0d0a1f4518f5451e7c8aabc41f820
Author: Fred Isaman <iisaman@netapp.com>
Date:   Tue Mar 1 01:34:15 2011 +0000

    NFSv4.1: shift pnfs_update_layout locations
    
    Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
    Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
    it to each nfs_read_data so it can be sent to the layout driver.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 94ad1c80e28f9700c84b4d28d1e5302ddf63a6fd
Author: Fred Isaman <iisaman@netapp.com>
Date:   Tue Mar 1 01:34:14 2011 +0000

    NFSv4.1: coelesce across layout stripes
    
    Add a pg_test layout driver hook which is used to avoid coelescing I/O across
    layout stripes.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d684d2ae10a4f95d3035abf698d7d611ff2cd279
Author: Fred Isaman <iisaman@netapp.com>
Date:   Tue Mar 1 01:34:13 2011 +0000

    NFSv4.1: lseg refcounting
    
    Prepare put_lseg and get_lseg to be called from the pNFS I/O code.
    Pull common code from pnfs_lseg_locked to call from pnfs_lseg.
    Inline pnfs_lseg_locked into it's only caller.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 94de8b27d0dcb2608d56a7e5c2941b87e6da7ce3
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:12 2011 +0000

    NFSv4.1: add MDS mount DS only check
    
    The DS only role cannot be used to mount.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d6fb79d433d0a34c36bdf74eaf90857193a6261f
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:11 2011 +0000

    NFSv4.1: new flag for lease time check
    
    Data servers cannot send nfs4_proc_get_lease_time. but still need to setup
    state renewal. Add the NFS_CS_CHECK_LEASE_TIME bit to indicate if the lease
    time can be checked.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d3b4c9d76738df49a7db7682c2518a0ef9f7391d
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:10 2011 +0000

    NFSv4.1: new flag for state renewal check
    
    Data servers not sharing a session with the mount MDS always have an empty
    cl_superblocks list.
    Replace the cl_superblocks empty list check to see if it is time to shut down
    renewd with the NFS_CS_STOP_RENEW bit which is not set by such a data server.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 89d1ea65798953b251e399b17f32d31033889ae0
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:09 2011 +0000

    NFSv4.1: send zero stateid seqid on v4.1 i/o
    
    Data servers require a zero stateid seqid, and there is no advantage to not
    doing the same for all NFSv4.1
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 45a52a02072b2a7e265f024cfdb00127e08dd9f2
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:08 2011 +0000

    NFS move nfs_client initialization into nfs_get_client
    
    Now nfs_get_client returns an nfs_client ready to be used no matter if it was
    found or created.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf9c1387ca80deac792c9ecf1c64dfcc5d1cc768
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:07 2011 +0000

    NFSv4.1: put_layout_hdr can remove nfsi->layout
    
    Prevents an Oops triggered by CB_LAYOUTRECALL and LAYOUTGET race on a
    pnfs_layout_hdr first pnfs_layout_segment.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f78befc417dd7122249706b49520da29ba58451
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 1 01:34:06 2011 +0000

    NFSv4: remove CONFIG_NFS_V4 from nfs_read_data
    
    Cleanup nfs_read_data. We also won't use CONFIG_NFS_V4_1 for additional
    NFSv4.1 fields in subsequent patches.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 136028967a283929c6f01518d0700b73fa622d56
Author: Fred Isaman <iisaman@netapp.com>
Date:   Fri Feb 11 15:42:38 2011 +0000

    NFS: change nfs_writeback_done to return void
    
    The return values are not used by any callers.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 83762c56c1ba7c5b4b92fb32d570661633228bc6
Author: Fred Isaman <iisaman@netapp.com>
Date:   Fri Feb 11 15:42:37 2011 +0000

    NFS: remove pointless if statement in nfs_direct_write_result
    
    The code was doing nothing more in either branch of the if.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eabf5baaaaf41b6a0273043cfb06d53dca67acef
Author: Fred Isaman <iisaman@netapp.com>
Date:   Fri Feb 11 15:42:36 2011 +0000

    RPC: clarify rpc_run_task error handling
    
    rpc_run_task can only fail if it is not passed in a preallocated task.
    However, that is not at all clear with the current code.  So
    remove several impossible to occur failure checks.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cee6a5372f8804f58acc87f07816f64db36718e2
Author: Fred Isaman <iisaman@netapp.com>
Date:   Fri Feb 11 15:42:35 2011 +0000

    RPC: remove check for impossible condition in rpc_make_runnable
    
    queue_work() only returns 0 or 1, never a negative value.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f49f9baac8f63de9cbc17a0a84e04060496e8e76
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Feb 3 18:28:52 2011 +0000

    pnfs: fix pnfs lock inversion of i_lock and cl_lock
    
    The pnfs code was using throughout the lock order i_lock, cl_lock.
    This conflicts with the nfs delegation code.  Rework the pnfs code
    to avoid taking both locks simultaneously.
    
    Currently the code takes the double lock to add/remove the layout to a
    nfs_client list, while atomically checking that the list of lsegs is
    empty.  To avoid this, we rely on existing serializations.  When a
    layout is initialized with lseg count equal zero, LAYOUTGET's
    openstateid serialization is in effect, making it safe to assume it
    stays zero unless we change it.  And once a layout's lseg count drops
    to zero, it is set as DESTROYED and so will stay at zero.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9f52c2525e09854ed6aa4cbd83915a56226d86c1
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Feb 3 18:28:51 2011 +0000

    pnfs: do not need to clear NFS_LAYOUT_BULK_RECALL flag
    
    We do not need to clear the NFS_LAYOUT_BULK_RECALL, as setting it
    guarantees that NFS_LAYOUT_DESTROYED will be set once any outstanding
    io is finished.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38511722446993d926861696194c39ef135d85a4
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Feb 3 18:28:50 2011 +0000

    pnfs: avoid incorrect use of layout stateid
    
    The code could violate the following from RFC5661, section 12.5.3:
    "Once a client has no more layouts on a file, the layout stateid is no
    longer valid and MUST NOT be used."
    
    This can occur when a layout already has a lseg, starts another
    non-everlapping LAYOUTGET, and a CB_LAYOUTRECALL for the existing lseg
    is processed before we hit pnfs_layout_process().
    
    Solve by setting, each time the client has no more lsegs for a file, a
    flag which blocks further use of the layout and triggers its removal.
    
    This also fixes a second bug which occurs in the same instance as
    above.  If we actually use pnfs_layout_process, we add the new lseg to
    the layout, but the layout has been removed from the nfs_client list
    by the intervening CB_LAYOUTRECALL and will not be added back.  Thus
    the newly acquired lseg will not be properly returned in the event of
    a subsequent CB_LAYOUTRECALL.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

