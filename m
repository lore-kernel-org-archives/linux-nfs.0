From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client updates and bugfixes
Date: Sun, 13 Dec 2009 14:01:43 -0500
Message-ID: <1260730903.2612.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29028 "HELO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753268AbZLMTCH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Dec 2009 14:02:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/callback.c              |   13 +-
 fs/nfs/callback.h              |   16 ++-
 fs/nfs/callback_proc.c         |   64 ++++++-
 fs/nfs/callback_xdr.c          |   34 +++-
 fs/nfs/client.c                |   14 +-
 fs/nfs/delegation.c            |   77 +++++--
 fs/nfs/delegation.h            |    7 +-
 fs/nfs/dir.c                   |   67 +++----
 fs/nfs/dns_resolve.c           |    4 +-
 fs/nfs/internal.h              |   54 +++---
 fs/nfs/nfs4_fs.h               |   12 +-
 fs/nfs/nfs4proc.c              |  458 +++++++++++++++++++++++++---------------
 fs/nfs/nfs4state.c             |  225 ++++++++++++++------
 fs/nfs/nfs4xdr.c               |  135 ++++++++++--
 fs/nfs/read.c                  |   12 +-
 fs/nfs/super.c                 |  104 +++++++--
 fs/nfs/unlink.c                |    2 +-
 fs/nfs/write.c                 |    8 +-
 include/linux/nfs4.h           |    3 +
 include/linux/nfs_fs_sb.h      |    1 +
 include/linux/nfs_xdr.h        |   13 +-
 include/linux/sunrpc/sched.h   |    2 +
 net/sunrpc/addr.c              |   10 +-
 net/sunrpc/auth.c              |   39 ++--
 net/sunrpc/auth_gss/auth_gss.c |    6 +-
 net/sunrpc/clnt.c              |   54 ++++-
 net/sunrpc/rpcb_clnt.c         |  104 +++++++--
 net/sunrpc/sunrpc_syms.c       |    3 +
 net/sunrpc/xprt.c              |    4 +
 net/sunrpc/xprtsock.c          |    2 +-
 30 files changed, 1078 insertions(+), 469 deletions(-)

commit 190f38e5cedc910940b1da9015f00458c18f97b4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 10 09:05:55 2009 -0500

    NFS: Fix nfs_migrate_page()
    
    The call to migrate_page() will cause the page->private field to be
    cleared.
    Also fix up the locking around the page->private transfer, so that we ensure
    that calls to nfs_page_find_request() don't end up racing.
    
    Finally, fix up a double free bug: nfs_unlock_request() already calls
    nfs_release_request() for us...
    
    Reported-by: Wu Fengguang <fengguang.wu@intel.com>
    Tested-by: Andi Kleen <andi@firstfloor.org>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 053e324f67b9921fe7de0c4cbc720d29cb4bf207
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Wed Dec 9 23:15:22 2009 +0530

    rpc: remove unneeded function parameter in gss_add_msg()
    
    The pointer to struct gss_auth parameter in gss_add_msg is not really needed
    after commit 5b7ddd4a. Zap it.
    
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7cab89b275fd5647e72b781ac41b58a214640334
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Tue Dec 8 14:35:28 2009 -0500

    nfs41: Invoke RECLAIM_COMPLETE on all new client ids
    
    The NFSv4.1 spec indicates RECLAIM_COMPLETE is to be issued
    whenever a client establishes a new client id, not only after
    detecting the server has rebooted.
    
    Set the NFS4CLNT_RECLAIM_REBOOT bit after every new client id has
    been established.  This enables us to issue RECLAIM_COMPLETE
    during the wrap up of the NFS4CLNT_RECLAIM_REBOOT state.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 480e3243df156e39eea6c91057e2ae612a6bbe19
Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Tue Dec 8 13:13:03 2009 -0500

    SUNRPC: IS_ERR/PTR_ERR confusion
    
    IS_ERR returns 1 or 0, PTR_ERR returns the error value.
    
    Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 88069f77e1ac580a495762ce7a631c251c52cb90
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 8 08:33:16 2009 -0500

    NFSv41: Fix a potential state leakage when restarting nfs4_close_prepare
    
    Currently, if the call to nfs4_setup_sequence() in nfs4_close_prepare
    fails, any later retries will fail to launch an RPC call, due to the fact
    that the &state->flags will have been cleared.
    Ditto if nfs4_close_done() triggers a call to the NFSv4.1 version of
    nfs_restart_rpc().
    
    We therefore move the actual clearing of the state->flags to
    nfs4_close_done(), when we know that the RPC call was successful.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 74e7bb73a3e0d15a7db10b0f2b2efdeeef36609e
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Mon Dec 7 09:48:30 2009 -0500

    nfs41: Handle NFSv4.1 session errors in the delegation recall code
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 79708861189eb89dea6711bd0464b097b69e7c79
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Mon Dec 7 09:23:21 2009 -0500

    nfs41: Retry delegation return if it failed with session error
    
    Update nfs4_delegreturn_done() to retry the operation after setting the
    NFS4CLNT_SESSION_SETUP bit to indicate the need to reset the session.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bcfa49f6f931ce4097309ca8501d842a6f0ac860
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Mon Dec 7 09:22:29 2009 -0500

    nfs41: Handle session errors during delegation return
    
    Add session error handling to nfs4_open_delegation_recall()
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f455848a11cbbf15989609a46b24e81a6f13a08e
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Mon Dec 7 09:16:09 2009 -0500

    nfs41: Mark stateids in need of reclaim if state manager gets stale clientid
    
    The state manager was not marking the stateids as needing to be reclaimed
    after reestablishing the clientid.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0110ee152b69f8cbde19d8bc1dd59e197e419d76
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Dec 7 09:00:24 2009 -0500

    NFS: Fix up the declaration of nfs4_restart_rpc when NFSv4 not configured
    
    Also rename it: it is used in generic code, and so should not have a 'nfs4'
    prefix.
    
    Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9dfdf404c99347e2e224e25f8626e7b6399a05cd
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sun Dec 6 12:57:34 2009 -0500

    nfs41: Don't clear DRAINING flag on NFS4ERR_STALE_CLIENTID
    
    If CREATE_SESSION fails with NFS4ERR_STALE_CLIENTID, don't clear the
    NFS4CLNT_SESSION_DRAINING flag and don't wake RPCs waiting for the
    session to be reestablished.  We don't have a session yet, so there
    is no reason to wake other RPCs.
    
    This avoids sending spurious compounds with bogus sequenceID during
    session and state recovery.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    [Trond.Myklebust@netapp.com: cleaned up patch by adding the
                                 nfs41_begin/end_drain_session() helpers]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9430fb6b5315f7bc94b05be915c64ebfefc55bbc
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sun Dec 6 12:23:46 2009 -0500

    nfs41: nfs41_setup_state_renewal
    
    Move call to get the lease time and the setup of the state
    renewal out of nfs4_create_session so that it can be called
    after clearing the DRAINING flag.  We use the getattr RPC
    to obtain the lease time, which requires a sequence slot.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bcb56164ceb21317208eee89c829580d51b84a6d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Dec 5 19:32:19 2009 -0500

    NFSv41: More cleanups
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 35dc1d74a8d97a302a202ccb6751bf2bdbf5173e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Dec 5 19:32:19 2009 -0500

    NFSv41: Fix up some bugs in the NFS4CLNT_SESSION_DRAINING code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d61e612a728fb9bf848c4383f8f6645e822d5b57
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Dec 5 19:32:19 2009 -0500

    NFSv41: Clean up slot table management
    
    We no longer need to maintain a distinction between nfs41_sequence_done and
    nfs41_sequence_free_slot.
    
    This fixes a number of slot table leakages in the NFSv4.1 code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f26468fb9384e73fb357d2e84d3e9c88c7d1129d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Dec 5 19:32:11 2009 -0500

    NFSv41: Fix nfs4_proc_create_session
    
    We should not assume that nfs41_init_clientid() will always want to
    initialise the session. If it is being called due to a server reboot, then
    we just want to reset the session after re-establishing the clientid.
    
    Fix this by getting rid of the 'reset' parameter in
    nfs4_proc_create_session(), and instead relying on whether or not the
    session slot table pointer is non-NULL.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit da6ebfe34a3921cfb47b938fb819abc78c6080e5
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sat Dec 5 16:08:41 2009 -0500

    nfs41: Invoke RECLAIM_COMPLETE
    
    This patch invokes RECLAIM_COMPLETE after the client is done
    reclaiming state.
    
    There are interpretations of the spec that suggest that
    RECLAIM_COMPLETE should also be issued after a new clientid
    has been obtained from the server and even if there is no
    state to reclaim.  This tells the server that the client
    has no state to reclaim even if the client isn't aware the
    server may have rebooted.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fce5c838e13392cc88a1330d1471fe6419e02ed7
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sat Dec 5 16:08:41 2009 -0500

    nfs41: RECLAIM_COMPLETE functionality
    
    Implements RECLAIM_COMPLETE as an asynchronous RPC.
    NFS4ERR_DELAY is retried, NFS4ERR_DEADSESSION invokes the error handling
    but does not result in a retry, since we don't want to have a lingering
    RECLAIM_COMPLETE call sent in the middle of a possible new state recovery
    cycle.  If a session reset occurs, a new wave of reclaim operations will
    follow, containing their own RECLAIM_COMPLETE call.  We don't want a
    retry to get on the way of recovery by incorrectly indicating to the
    server that we're done reclaiming state.
    
    A subsequent patch invokes the functionality.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 180197536b15d5862b389ce90b46ec8d004056f6
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sat Dec 5 16:08:40 2009 -0500

    nfs41: RECLAIM_COMPLETE XDR functionality
    
    XDR encoding and decoding for RECLAIM_COMPLETE.  Implements the necessary
    encoding to indicate reclaim complete for the entire client.  In the future,
    it can be extended to provide reclaim complete functionality for a single
    file system after migration.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b173218bd7dfa5723ab96cc37b32dc380446bab
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Sat Dec 5 16:08:39 2009 -0500

    Cleanup some NFSv4 XDR decode comments
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0556d1a6958ba15659ac2089ebc0a3c5e71f08a8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Dec 5 15:03:20 2009 -0500

    NFSv41: nfs4_reset_session must always set NFS4CLNT_SESSION_DRAINING
    
    Otherwise we have no guarantees that other processes won't start another
    RPC call while we're resetting the session.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2597641deae82c9a95e255518da189ab557da0af
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:48:55 2009 -0500

    nfs41: v2 fix cb_recall bug
    
    in NFSv4.1 the seqid part of a stateid in CB_RECALL must be 0
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0629e370dd5819efa5cf8d418a8e6729efe388ef
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:46:14 2009 -0500

    nfs41: check SEQUENCE status flag
    
    the server can indicate a number of error conditions by setting the
    appropriate bits in the SEQUENCE operation. The client re-establishes
    state with the server when it receives one of those, with the action
    depending on the specific case.
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2449ea2e191123729b2dc37a06fcb9d6ea7e2736
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:36:55 2009 -0500

    nfs41: V2 adjust max_rqst_sz, max_resp_sz w.r.t to rsize, wsize
    
    The v4.1 client should take into account the desired rsize, wsize when
    negotiating the max size in CREATE_SESSION. Accordingly, it should use
    rsize, wsize that are smaller than the session negotiated values.
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7b183d0d432ab3525ae29511a5348ead3e790620
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:33:25 2009 -0500

    nfs41: remove server-only EXCHGID4_FLAG_CONFIRMED_R flag from exchange_id
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4882ef72cd9a5c006087ca94a228323018eac29f
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:30:21 2009 -0500

    nfs41: add support for the exclusive create flags
    
    In v4.1 the client MUST/SHOULD use the EXCLUSIVE4_1 flag instead of
    EXCLUSIVE4, and GUARDED when the server supports persistent sessions.
    For now (and until we support suppattr_exclcreat), we don't send any
    attributes with EXCLUSIVE4_1 relying in the subsequent SETATTR as in v4.0
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d8cb1a7ce36d44602946f06af4267da304fb4011
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:29:53 2009 -0500

    nfs41: check if session exists and if it is persistent
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 31f0960778c78198957cf02cc970d92b72b929e4
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:27:02 2009 -0500

    nfs41: V2 initial support for CB_RECALL_ANY
    
    For now the clients returns _all_ the delegations of the specificed type
    it holds
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c79571a508801e055a0be583d6dc70bddad7bb64
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:20:52 2009 -0500

    nfs4: V2 return/expire delegations depending on their type
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b4a6f4966efc7e70dc8d8a9e60744de6845b14bf
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:19:11 2009 -0500

    nfs4: minor delegation cleaning
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 07bccc2dd4e8745859f0fa7d120ea39320fbcdbf
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Sat Dec 5 13:19:01 2009 -0500

    nfs41: add support for callback with RPC version number 4
    
    The NFSv4.1 spec-29 (18.36.3) says that the server MUST use an ONC RPC
    (program) version number equal to 4 in callbacks sent to the client.
    For now we allow both versions 1 and 4.
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b9e2d41f1f0360be08809d4e3bb56b67be6241a
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 16:02:14 2009 -0500

    nfs41: only state manager sets NFS4CLNT_SESSION_SETUP
    
    Replace sync and async handlers setting of the NFS4CLNT_SESSION_SETUP bit with
    setting NFS4CLNT_CHECK_LEASE, and let the state manager decide to reset the session.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 691daf3b0c410c8bcab6735796be03ea446e1924
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:39 2009 -0500

    nfs41: drain session cleanup
    
    Do not wake up the next slot_tbl_waitq task in nfs4_free_slot because we
    may be draining the slot. Either signal the state manager that the session
    is drained (the state manager wakes up tasks) OR wake up the next task.
    
    In nfs41_sequence_done, the slot dereference is only needed in the sequence
    operation success case.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea028ac92541ac30bf202ed94cb53eec2ea0c9d6
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:38 2009 -0500

    nfs41: nfs41: fix state manager deadlock in session reset
    
    If the session is reset during state recovery, the state manager thread can
    sleep on the slot_tbl_waitq causing a deadlock.
    
    Add a completion framework to the session.  Have the state manager thread set
    a new session state (NFS4CLNT_SESSION_DRAINING) and wait for the session slot
    table to drain.
    
    Signal the state manager thread in nfs41_sequence_free_slot when the
    NFS4CLNT_SESSION_DRAINING bit is set and the session is drained.
    
    Reported-by: Trond Myklebust <trond@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 05f0d2364726c92f6b870db654967088349379fe
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:37 2009 -0500

    nfs41: remove nfs4_recover_session
    
    nfs4_recover_session can put rpciod to sleep. Just use nfs4_schedule_recovery.
    
    Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2628eddff15cb38b7246d5c18e2f7dc3e2c0d0c2
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:35 2009 -0500

    nfs41: don't clear tk_action on success
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ba9bf8e5160b0b4ebc56f64ad445c6c0ecdac1d
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:34 2009 -0500

    nfs41: fix switch in nfs4_recovery_handle_error
    
    Do not fall through and set NFS4CLNT_SESSION_RESET bit on NFS4ERR_EXPIRED
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9179237e2b2b4d34b5821cca3db280ebbc8694a
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:32 2009 -0500

    nfs41: fix switch in nfs4_handle_exception
    
    Do not fall through and call nfs4_delay on session error handling.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 36bbe34239f63377b5179ad32fd13cd71d6e1ba7
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:30 2009 -0500

    nfs41: free the slot on unhandled read errors
    
    nfs4_read_done returns zero on unhandled errors. nfs_readpage_result will
    return on a negative tk_status without freeing the slot.
    Call nfs4_sequence_free_slot on unhandled errors in nfs4_read_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e608e79f1bf4b967afcf57777e63b5f0939b00e8
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:29 2009 -0500

    nfs41: call free slot from nfs4_restart_rpc
    
    nfs41_sequence_free_slot can be called multiple times on SEQUENCE operation
    errors.
    No reason to inline nfs4_restart_rpc
    
    Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
    
    nfs_writeback_done and nfs_readpage_retry call nfs4_restart_rpc outside the
    error handler, and the slot is not freed prior to restarting in the rpc_prepare
    state during session reset.
    
    Fix this by moving the call to nfs41_sequence_free_slot from the error
    path of nfs41_sequence_done into nfs4_restart_rpc, and by removing the test
    for NFS4CLNT_SESSION_SETUP.
    Always free slot and goto the rpc prepare state on async errors.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d9ddde94aed01c4618cf6f70883cc511c3b2b62
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:27 2009 -0500

    nfs41: nfs4_get_lease_time will never session reset
    
    Make this clear by calling rpc_restart-call.
    Prepare for nfs4_restart_rpc() to free slots.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6df08189ffd33d8357759561dba49d25c0335858
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:55:05 2009 -0500

    nfs41: rename cl_state session SETUP bit to RESET
    
    The bit is no longer used for session setup, only for session reset.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4d643d1dfa9349164fe928e255f68020d91dbfe0
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Dec 4 15:52:24 2009 -0500

    nfs41: add create session into establish_clid
    
    Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
    
    Resetting the clientid from the state manager could result in not confirming
    the clientid due to create session not being called.
    
    Move the create session call from the NFS4CLNT_SESSION_SETUP state manager
    initialize session case into the NFS4CLNT_LEASE_EXPIRED case establish_clid
    call.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44ed3556bad809797f7b06a4a88918fd8a23d6fe
Author: NeilBrown <neilb@suse.de>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFS4ERR_FILE_OPEN handling in Linux/NFS
    
    NFS4ERR_FILE_OPEN is return by the server when an operation cannot be
    performed because the file is currently open and local (to the server)
    semantics prohibit the operation while the file is open.
    A typical case is a RENAME operation on an MS-Windows platform, which
    prevents rename while the file is open.
    
    While it is possible that such a condition is transitory, it is also
    very possible that the file will be held open for an extended period
    of time thus preventing the operation.
    
    The current behaviour of Linux/NFS is to retry the operation
    indefinitely.  This is not appropriate - we do not expect a rename to
    take an arbitrary amount of time to complete.
    
    Rather, and error should be returned.  The most obvious error code
    would be EBUSY, which is a legal at least for 'rename' and 'unlink',
    and accurately captures the reason for the error.
    
    This patch allows a few retries until about 2 seconds have elapsed,
    then returns EBUSY.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 24e93025ee434a58d35e5abb283c5bcc9a13e477
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Thu Dec 3 15:58:56 2009 -0500

    nfs: clean up sillyrenaming in nfs_rename()
    
    The d_instantiate(new_dentry, NULL) is superfluous, the dentry is
    already negative.  Rehashing this dummy dentry isn't needed either,
    d_move() works fine on an unhashed target.
    
    The re-checking for busy after a failed nfs_sillyrename() is bogus
    too: new_dentry->d_count < 2 would be a bug here.
    
    Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 27226104e60964f21717e0f452cecd45c85a64c6
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Thu Dec 3 15:58:56 2009 -0500

    nfs: dont unhash target if renaming a directory
    
    Move unhashing the target to after the check for existence and being a
    non-directory.
    
    If renaming a directory then the VFS already unhashes the target if it
    is not busy.  If it's busy then acquiring more references during the
    rename makes no difference.
    
    Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28f79a1a695e7a5b00af3b6713b449e08581ffbb
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Thu Dec 3 15:58:56 2009 -0500

    nfs: fix comments in nfs_rename()
    
    Comments are wrong or out of date.  In particular d_drop() doesn't
    free the inode it just unhashes the dentry.  And if target is a
    directory then it is not checked for being busy.
    
    Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e48de5ec25b37d42292c876c1d3337766aae89bd
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Thu Dec 3 15:58:56 2009 -0500

    nfs: remove unnecessary check from nfs_rename()
    
    VFS already checks if both source and target are directories.
    
    Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9c4c761a629caa5572c1a29a8288416070d5d6b7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFSv4.1: Handle NFSv4.1 session errors in the lock recovery code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a28becc35e5c8f1fabb707bcd8a473712653de6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: soft connect semantics for UDP
    
    Introduce soft connect behavior for UDP transports.  In this case, a
    major timeout returns ETIMEDOUT instead of EIO.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit caabea8a565fb4e16f8e58e16bb9d535e591b709
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Use soft connect semantics when performing RPC ping
    
    Currently, if a remote RPC service is unreachable, an RPC ping will
    hang until the underlying transport connect attempt times out.  A more
    desirable behavior might be to have the ping fail immediately so upper
    layers can recover appropriately.
    
    In the case of an NFS mount, for instance, this would mean the
    mount(2) system call could fail immediately if the server isn't
    listening, rather than hanging uninterruptibly for more than 3
    minutes.
    
    Change rpc_ping() so that it fails immediately for connection-oriented
    transports.  rpc_create() will then fail immediately for such
    transports if an RPC ping was requested.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 012da158f636347c4eb28fd1e1cca020fef5e54d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Use soft connects for autobinding over TCP
    
    Autobinding is handled by the rpciod process, not in user processes
    that are generating regular RPC requests.  Thus autobinding is usually
    not affected by signals targetting user processes, such as KILL or
    timer expiration events.
    
    In addition, an RPC request generated by a user process that has
    RPC_TASK_SOFTCONN set and needs to perform an autobind will hang if
    the remote rpcbind service is not available.
    
    For rpcbind queries on connection-oriented transports, let's use the
    new soft connect semantic to return control to the user's process
    quickly, if the kernel's rpcbind client can't connect to the remote
    rpcbind service.
    
    Logic is introduced in call_bind_status() to handle connection errors
    that occurred during an asynchronous rpcbind query.  The logic
    abandons the rpcbind query if the RPC request has SOFTCONN set, and
    retries after a few seconds in the normal case.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2a76b3bfa22993fc09166bd6a8db0dbe902b6813
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Use TCP for local rpcbind upcalls
    
    Use TCP with the soft connect semantic for local rpcbind upcalls so
    the kernel can detect immediately if the local rpcbind daemon is not
    running.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit c526611dd631b2802b6b0221ffb306c5fa25c86c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Use a cached RPC client and transport for rpcbind upcalls
    
    The kernel's rpcbind client creates and deletes an rpc_clnt and its
    underlying transport socket for every upcall to the local rpcbind
    daemon.
    
    When starting a typical NFS server on IPv4 and IPv6, the NFS service
    itself does three upcalls (one per version) times two upcalls (one
    per transport) times two upcalls (one per address family), making 12,
    plus another one for the initial call to unregister previous NFS
    services.  Starting the NLM service adds an additional 13 upcalls,
    for similar reasons.
    
    (Currently the NFS service doesn't start IPv6 listeners, but it will
    soon enough).
    
    Instead, let's create an rpc_clnt for rpcbind upcalls during the
    first local rpcbind query, and cache it.  This saves the overhead of
    creating and destroying an rpc_clnt and a socket for every upcall.
    
    The new logic also prevents the kernel from attempting an RPCB_SET or
    RPCB_UNSET if it knows from the start that the local portmapper does
    not support rpcbind protocol version 4.  This will cut down on the
    number of rpcbind upcalls in legacy environments.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 5a46211540a83871196489247f57da2bdde58d87
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Simplify synopsis of rpcb_local_clnt()
    
    Clean up: At one point, rpcb_local_clnt() handled IPv6 loopback
    addresses too, but it doesn't any more; only IPv4 loopback is used
    now.  Get rid of the @addr and @addrlen arguments to
    rpcb_local_clnt().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 09a21c4102c8f7893368553273d39c0cadedf9af
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Allow RPCs to fail quickly if the server is unreachable
    
    The kernel sometimes makes RPC calls to services that aren't running.
    Because the kernel's RPC client always assumes the hard retry semantic
    when reconnecting a connection-oriented RPC transport, the underlying
    reconnect logic takes a long while to time out, even though the remote
    may have responded immediately with ECONNREFUSED.
    
    In certain cases, like upcalls to our local rpcbind daemon, or for NFS
    mount requests, we'd like the kernel to fail immediately if the remote
    service isn't reachable.  This allows another transport to be tried
    immediately, or the pending request can be abandoned quickly.
    
    Introduce a per-request flag which controls how call_transmit_status()
    behaves when request transmission fails because the server cannot be
    reached.
    
    We don't want soft connection semantics to apply to other errors.  The
    default case of the switch statement in call_transmit_status() no
    longer falls through; the fall through code is copied to the default
    case, and a "break;" is added.
    
    The transport's connection re-establishment timeout is also ignored for
    such requests.  We want the request to fail immediately, so the
    reconnect delay is skipped.  Additionally, we don't want a connect
    failure here to further increase the reconnect timeout value, since
    this request will not be retried.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 206a134b4d8abf57cd34dffacf993869355b9aac
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Check explicitly for tk_status == 0 in call_transmit_status()
    
    The success case, where task->tk_status == 0, is by far the most
    frequent case in call_transmit_status().
    
    The default: arm of the switch statement in call_transmit_status()
    handles the 0 case.  default: was moved close to the top of the switch
    statement in call_transmit_status() under the theory that the compiler
    places object code for the earliest arms of a switch statement first,
    making the CPU do less work.
    
    The default: arm of a switch statement, however, is executed only
    after all the other cases have been checked.  Even if the compiler
    rearranges the object code, the default: arm is the "last resort",
    meaning all of the other cases have been explicitly exhausted.  That
    makes the current arrangement about as inefficient as it gets for the
    common case.
    
    To fix this, add an explicit check for zero before the switch
    statement.  That forces the compiler to do the zero check first, no
    matter what optimizations it might try to do to the switch statement.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dd47f96c077b4516727e497e4b6fd47a06778c0a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFS: Revert default r/wsize behavior
    
    When the "rsize=" or "wsize=" mount options are not specified,
    text-based mounts have slightly different behavior than legacy binary
    mounts.  Text-based mounts use the smaller of the server's maximum
    and the client's maximum, but binary mounts use the smaller of the
    server's _preferred_ size and the client's maximum.
    
    This difference is actually pretty subtle.  Most servers advertise
    the same value as their maximum and their preferred transfer size, so
    the end result is the same in most cases.
    
    The reason for this difference is that for text-based mounts, if
    r/wsize are not specified, they are set to the largest value supported
    by the client.  For legacy mounts, the values are set to zero if these
    options are not specified.
    
    nfs_server_set_fsinfo() can negotiate the transfer size defaults
    correctly in any case.  There's no need to specify any particular
    value as default in the text-based option parsing logic.
    
    Note that nfs4 doesn't use nfs_server_set_fsinfo(), but the mount.nfs4
    command does set rsize and wsize to 0 if the user didn't specify these
    options.  So, make the same change for text-based NFSv4 mounts.
    
    Thanks to James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org> for reporting and
    diagnosing the problem.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d250e190fb9b06f4c595eade88b3d0b705fb330a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFS: Display compressed (shorthand) IPv6 in /proc/mounts
    
    Recent changes to snprintf() introduced the %pI6c formatter, which can
    display an IPv6 address with standard shorthanding.  Use this new
    formatter when displaying IPv6 server addresses in /proc/mounts.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dd1fd90fe65e2e642f0e58e2ff4849f317a6c43d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    SUNRPC: Display compressed (shorthand) IPv6 presentation addresses
    
    Recent changes to snprintf() introduced the %pI6c formatter, which can
    display an IPv6 address with standard shorthanding.  Using a
    shorthanded address can save us a few bytes of memory for each stored
    presentation address, or a few bytes on the wire when sending these in
    a universal address.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a01878aac57eac6eb4bf194788ab2cc440490d0f
Author: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFS: reorder nfs4_sequence_regs to remove 8 bytes of padding on 64 bits
    
    reorder nfs4_sequence_args to remove 8 bytes of padding on 64 bit
    builds.
    
    The size of this structure drops to 24 bytes from 32 and reduces the
    text size of nfs.ko.
    On my x86_64 size reports
    
    		text       data     bss
    2.6.32-rc5 	200996	   8512	    432	 209940	  33414	nfs.ko
    +patch 		200884	   8512	    432	 209828	  333a4	nfs.ko
    
    
    Signed-off-by: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee671b016fbfc26d69c3fe02e28706222beb1149
Author: Jeff Layton <jlayton@redhat.com>
Date:   Thu Dec 3 15:58:56 2009 -0500

    NFS: convert proto= option to use netids rather than a protoname
    
    Solaris uses netids as values for the proto= option, so that when
    someone specifies "tcp6" they get traffic over TCP + IPv6. Until
    recently, this has never really been an issue for Linux since it didn't
    support NFS over IPv6. The netid and the protocol name were generally
    always the same (modulo any strange configuration in /etc/netconfig).
    
    The solaris manpage documents their proto= option as:
    
        proto= _netid_ | rdma
    
    This patch is intended to bring Linux closer to how the Solaris proto=
    option works, by declaring a static netid mapping in the kernel and
    converting the proto= and mountproto= options to follow it and display
    the proper values in /proc/mounts.
    
    Much of this functionality will need to be provided by a userspace
    mount.nfs patch. Chuck Lever has a patch to change mount.nfs in
    the same way. In principle, we could do *all* of this in userspace but
    that would mean that the options in /proc/mounts may not match the
    options used by userspace.
    
    The alternative to the static mapping here is to add a mechanism to
    upcall to userspace for netid's. I'm not opposed to that option, but
    it'll probably mean more overhead (and quite a bit more code). Rather
    than shoot for that at first, I figured it was probably better to
    start simply.
    
    Comments welcome.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d4e935bd67ca05db4119b67801d9ece6ae139f05
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Dec 3 15:58:33 2009 -0500

    The rpc server does not require that service threads take the BKL.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1185a552e3d78807031f4021c5edb60d3e8838f1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:54:02 2009 -0500

    NFSv4: Ensure nfs4_close_context() is declared as static
    
    Fix another 'sparse' warning in fs/nfs/nfs4proc.c
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0a6566ecd3afc74aad11c2e07794ff5529c13862
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:54:01 2009 -0500

    NFSv4: Ensure nfs_dns_lookup() and nfs_dns_update() are declared static
    
    Fix two 'sparse' warnings in fs/nfs/dns_resolve.c
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b6d408ba8c8be3646dea6f80a2fe55ac403119c8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:53:22 2009 -0500

    NFSv4: Fix up error handling in the state manager main loop.
    
    The nfs4_state_manager should not be looking at the error values when
    deciding whether or not to loop round in order to handle a higher priority
    state recovery task. It should rather be looking at the clp->cl_state.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a9ed2e2583747fb3139a764c317fac58893b968f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:53:21 2009 -0500

    NFSv4: Handle NFS4ERR_GRACE when recovering an expired lease.
    
    If our lease expires, and the server reboots while we're recovering, we
    need to be able to wait until the grace period is over.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c8b7ae3d3221536228260757444ee10c6d71793f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:53:21 2009 -0500

    NFSv4: Ensure the state manager handles NFS4ERR_NO_GRACE correctly
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4f7cdf18e14f81860b856ef7694ef58eb1a751c0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:53:20 2009 -0500

    NFSv4: The state manager shouldn't exit on errors that were handled
    
    nfs4_recovery_handle_error() will correctly handle errors such as
    NFS4ERR_CB_PATH_DOWN, however because they are still passed back to the
    main loop in nfs4_state_manager(), they can cause the latter to exit
    prematurely.
    
    Fix this by letting nfs4_recovery_handle_error() change the error value in
    cases where there is no action required by the caller.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e345e88a774875cec26e097ea3ff2dc40c4f9da2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 15:52:41 2009 -0500

    NFSv4: Fix up the callers of nfs4_state_end_reclaim_reboot
    
    In practice, we need to ensure that we call nfs4_state_end_reclaim_reboot
    in 2 cases:
    
     - If we lose the lease while we were reclaiming state
    OR
     - After we're done with reboot recovery
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d18cc1fda25295416a2855d44c2936db01df9eec
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 08:10:17 2009 -0500

    NFSv4: Fix a potential state manager deadlock when returning delegations
    
    The nfsv4 state manager could potentially deadlock inside
    __nfs_inode_return_delegation() if the server reboots, so that the calls to
    nfs_msync_inode() end up waiting on state recovery to complete.
    
    Also ensure that if a server reboot or network partition causes us to have
    to stop returning delegations, that NFS4CLNT_DELEGRETURN is set so that
    the state manager can resume any outstanding delegation returns after it
    has dealt with the state recovery situation.
    
    Finally, ensure that the state manager doesn't wait for the DELEGRETURN
    call to complete. It doesn't need to, and that too can cause a deadlock.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d327cf7449e6fd5cbac784c641770e9366faa386
Author: J. Bruce Fields <bfields@fieldses.org>
Date:   Thu Dec 3 08:10:17 2009 -0500

    Re: acl trouble after upgrading ubuntu
    
    Subject: [PATCH] nfs: fix acl decoding
    
    Commit 28f566942c6b1d929f5e240e69e7081b77b238d3 "NFS: use dynamically
    computed compound_hdr.replen for xdr_inline_pages offset" accidentally
    changed the amount of space to allow for the acl reply, resulting in an
    IO error on attempts to get an acl.
    
    Reported-by: Paul Rudin <paul-sqPYmOVXOov10XsdtD+oqA@public.gmane.org>
    Cc: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f0380f3d16df8f9e2fcd1d8c16fb0d94370bea99
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 08:10:17 2009 -0500

    RPC: Fix two potential races in put_rpccred
    
    It is possible for rpcauth_destroy_credcache() to cause the rpc credentials
    to be unhashed while put_rpccred is waiting for the rpc_credcache_lock on
    another cpu. Should this happen, then we can end up calling
    hlist_del_rcu(&cred->cr_hash) a second time in put_rpccred, thus causing
    list corruption.
    
    Should the credential actually be hashed, it is also possible for
    rpcauth_lookup_credcache to find and reference it before we get round to
    unhashing it. In this case, the call to rpcauth_unhash_cred will fail, and
    so we should just exit without destroying the cred.
    
    Reported-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit feb8ca37cc3d83c07fd042509ef1e176cfeb2cfa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 08:10:17 2009 -0500

    SUNRPC: Ensure that we honour autoclose before attempting to reconnect
    
    If the XPRT_CLOSE_WAIT flag is set, we need to ensure that we call
    xprt->ops->close() while holding xprt_lock_write() before we can
    start reconnecting.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96f287b0cf512ee537826943c15b0b8647472f70
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 3 08:09:56 2009 -0500

    NFS: BKL removal from the mount code...
    
    None of the code in nfs_umount_begin() or nfs_remount() has any BKL
    dependency.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


