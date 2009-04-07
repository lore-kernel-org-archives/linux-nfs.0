From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsd pull request for 2.6.30
Date: Tue, 07 Apr 2009 09:26:32 -0700
Message-ID: <1239121592.10190.12.camel@heimdal.trondhjem.org>
References: <20090404160851.GC495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758133AbZDGQ1J@vger.kernel.org>
In-Reply-To: <20090404160851.GC495@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-04-04 at 12:08 -0400, J. Bruce Fields wrote:
> Please pull nfsd-releated changes for 2.6.30 from the for-2.6.30 branch
> at:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.30
> 
> This includes the first 4.1 code.  It still needs work, but it's been
> developed out of tree for a while, and it's high time that we move the
> development upstream.  It is off by default and shouldn't impact exiting
> v2/v3/v4.0 behavior.

Linus, if we're merging NFSv4.1 server code, would it be possible to
merge some of the corresponding client code? The motivation for doing so
is the same: to move development into the mainline tree and ensure
minimum impact on the existing NFSv4.0 code.

The current NFSv4.1 client code can be found in the "nfsv41" branch of
the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfsv41

which updates the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/Kconfig               |    9 +
 fs/nfs/client.c              |  124 ++++-
 fs/nfs/direct.c              |    9 +
 fs/nfs/internal.h            |   62 +++
 fs/nfs/nfs4_fs.h             |   37 ++-
 fs/nfs/nfs4proc.c            | 1229 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4renewd.c          |    6 +-
 fs/nfs/nfs4state.c           |  130 ++++-
 fs/nfs/nfs4xdr.c             | 1078 ++++++++++++++++++++++++++++++++-----
 fs/nfs/read.c                |   33 +-
 fs/nfs/super.c               |   12 +
 fs/nfs/unlink.c              |   20 +-
 fs/nfs/write.c               |   31 +-
 include/linux/nfs4.h         |   18 +
 include/linux/nfs_fs_sb.h    |   67 +++-
 include/linux/nfs_xdr.h      |  174 ++++++
 include/linux/nfsd/state.h   |    1 -
 include/linux/sunrpc/clnt.h  |    1 +
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/clnt.c            |   13 +
 net/sunrpc/sched.c           |    2 +-
 21 files changed, 2838 insertions(+), 219 deletions(-)

commit 4770822f16154559c8168c1b7171c9941a7c4d89
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:52 2009 -0400

    nfs41: increment_{open,lock}_seqid
    
    Unlike minorversion0, in nfsv4.1 the open and lock seqids need
    not be incremented by the client and should always be set to zero.
    
    This is implemented using a new nfs_rpc_ops methods -
    increment_open_seqid and increment_lock_seqid
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77358f037de2d3513e7f6101832c6780feceaaba
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:50 2009 -0400

    nfs41: recover lease in _nfs4_lookup_root
    
    This creates the nfsv4.1 session on mount.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77e3e12a9e33c8d4a6636bae777cdc10e6657270
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:49 2009 -0400

    nfs41: get_clid_cred for EXCHANGE_ID
    
    Unlike SETCLIENTID, EXCHANGE_ID requires a machine credential. Do not search
    for credentials other than the machine credential.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 148aa0d163e82004ebbff04f4d19a2442c0cea1b
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:48 2009 -0400

    nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
    
    EXCHANGE_ID has different credential requirements than SETCLIENTID.
    Prepare for a separate credential function.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ce39a8b1d33bbe9efdd0edd19636a9648cf28b0
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:47 2009 -0400

    nfs41: establish sessions-based clientid
    
    nfsv4.1 clientid is established via EXCHANGE_ID rather than
    SETCLIENTID{,_CONFIRM}
    
    This is implemented using a new establish_clid method in
    nfs4_state_recovery_ops.
    
    nfs41: establish clientid via exchange id only if cred != NULL
    
    >From 2.6.26 reclaimer() uses machine cred for setting up the client id
    therefore it is never expected to be NULL.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [removed dprintk]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: lease renewal]
    [revamped patch for new nfs4_state_manager design]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a1c33f040613ba60306743859dc813d62fe5cf4d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:46 2009 -0400

    nfs41: introduce get_state_renewal_cred
    
    Use the machine cred for sending SEQUENCE to renew
    the client's lease.
    
    [revamp patch for new state management design starting 2.6.29]
    [nfs41: support minorversion 1 for nfs4_check_lease]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get cred in exchange_id when cred arg is NULL]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use cl_machined_cred instead of cl_ex_cred]
        Since EXCHANGE_ID insists on using the machine credential, cl_ex_cred is
        not needed. nfs4_proc_exchange_id() is only called if the machine credential
        is available. Remove the credential logic from nfs4_proc_exchange_id.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 75990413508cf47fa17c59c0f0aed7f88d4585d8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:45 2009 -0400

    nfs41: support minorversion 1 for nfs4_check_lease
    
    [moved nfs4_get_renew_cred related changes to
     "nfs41: introduce get_state_renewal_cred"]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 852af20ae01b2f1d7e1ed861ce3c1ae9f345c057
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:44 2009 -0400

    nfs41: lease renewal
    
    Send a NFSv4.1 SEQUENCE op rather than RENEW that was deprecated in
    minorversion 1.
    Use the nfs_client minorversion to select reboot_recover/
    network_partition_recovery/state_renewal ops.
    
    Note: we use reclaimer to create the nfs41 session before there are any
    cl_superblocks for the nfs_client.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [revamped patch for new nfs4_state_manager design]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: obliterate nfs4_state_recovery_ops.renew_lease method]
        moved to nfs4_state_maintenance_ops
    [also undid per-minorversion nfs4_state_recovery_ops here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 31e53cd89f54e58e38e5b47088633c90ba4b2ce3
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:43 2009 -0400

    nfs41: schedule async session reset
    
    Define a new session reset state which is set upon a sequence operation error
    in both the sync and async error handlers.
    
    Place all new requests and all but the last outstanding rpc on the
    slot_tbl_waitq. Spawn the recovery thread when the last slot is free.
    Call nfs4_proc_destroy_session, reinitialize the session, call
    nfs4_proc_create_session, clear the session reset state, and wake up the next
    task on the slot_tbl_waitq.
    
    Return the nfs4_proc_destroy_session status to the session reclaimer and
    check for NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION. Other destroy session
    errors should be handled in nfs4_proc_destroy_session where the call can
    be retried with adjusted arguments.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    nfs41: make nfs4_wait_bit_killable public]
        nfs4_wait_bit_killable to be used by NFSv4.1 session recover logic.
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have create_session work on nfs_client]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: trigger the state manager for session reset]
        Replace the session reset state with the NFS4CLNT_SESSION_SETUP cl_state.
        Place all rpc tasks to sleep on the slot table waitqueue until the slot
        table is drained, then schedule state recovery and wait for it to complete.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs41_session_recovery [ch]
    Replaced by using the nfs4_state_manager.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: nfs4_wait_bit_killable only used locally]
    [nfs41: keep nfs4_wait_bit_killable static]
    [nfs41: keep const nfs_server in nfs4_handle_exception]
    [nfs41: remove session parameter from nfs4_find_slot]
    Signed-off-by: Andy Adamson <andros@netapp.com
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: resset the session from nfs41_setup_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 655af7c1558de7459d3739749435bdcad2b80247
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:42 2009 -0400

    nfs41: kick start nfs41 session recovery when handling errors
    
    Remove checking for any errors that the SEQUENCE operation does not return.
    -NFS4ERR_STALE_CLIENTID, NFS4ERR_EXPIRED, NFS4ERR_CB_PATH_DOWN, NFS4ERR_BACK_CHAN_BUSY, NFS4ERR_OP_NOT_IN_SESSION.
    
    SEQUENCE operation error recovery is very primative, we only reset the session.
    
    Remove checking for any errors that are returned by the SEQUENCE operation, but
    that resetting the session won't address.
    NFS4ERR_RETRY_UNCACHED_REP, NFS4ERR_SEQUENCE_POS,NFS4ERR_TOO_MANY_OPS.
    
    Add error checking for missing SEQUENCE errors that a session reset will
    address.
    NFS4ERR_BAD_HIGH_SLOT, NFS4ERR_DEADSESSION, NFS4ERR_SEQ_FALSE_RETRY.
    
    A reset of the session is currently our only response to a SEQUENCE operation
    error. Don't reset the session on errors where a new session won't help.
    
    Don't reset the session on errors where a new session won't help.
    
    [nfs41: nfs4_async_handle_error update error checking]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: trigger the state manager for session reset]
        Replace session state bit with nfs_client state bit.  Set the
        NFS4CLNT_SESSION_SETUP bit upon a session related error in the sync/async
        error handlers.
    [nfs41: _nfs4_async_handle_error fix session reset error list]
    Sequence operation errors that session reset could help.
    NFS4ERR_BADSESSION
    NFS4ERR_BADSLOT
    NFS4ERR_BAD_HIGH_SLOT
    NFS4ERR_DEADSESSION
    NFS4ERR_CONN_NOT_BOUND_TO_SESSION
    NFS4ERR_SEQ_FALSE_RETRY
    NFS4ERR_SEQ_MISORDERED
    
    Sequence operation errors that a session reset would not help
    
    NFS4ERR_BADXDR
    NFS4ERR_DELAY
    NFS4ERR_REP_TOO_BIG
    NFS4ERR_REP_TOO_BIG_TO_CACHE
    NFS4ERR_REQ_TOO_BIG
    NFS4ERR_RETRY_UNCACHED_REP
    NFS4ERR_SEQUENCE_POS
    NFS4ERR_TOO_MANY_OPS
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41 nfs4_handle_exception fix session reset error list]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs41_sequece_call_done code to nfs41: sequence operation]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1be6eb2e4da3c4a6dcd7909f0d86201c68722536
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:41 2009 -0400

    nfs41: use rpc prepare call state for session reset
    
    [nfs41: change nfs4_restart_rpc argument]
    [nfs41: check for session not minorversion]
    [nfs41: trigger the state manager for session reset]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [always define nfs4_restart_rpc]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e31f7262a4ffc46c920f16283eaf5885649e3c32
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:40 2009 -0400

    nfs41: sunrpc: Export the call prepare state for session reset
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 86648b70f2d895123b1c90b40d308c8d35a7528c
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:39 2009 -0400

    nfs41: add session reset to state manager
    
    Move the code to reset a session from the session_reclaimer to the
    nfs4_state_manager.  Destroy the session, and create a new one. Treat
    NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION as a successful
    nfs4_proc_destroy_session. Signal nfs4_proc_create_session that this is a
    session reset so that the session slot table is re-used.
    
    If the clientid is stale, set both NFS4CLNT_LEASE_EXPIRED and
    NFS4CLNT_SESSION_SETUP bits and retry.
    
    Use a switch statement in nfs4_session_recovery_handle_error for future
    patche which will add handling for other errors.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: session reset in nfs4_recovery_handle_error]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: reset session on nfs4_do_reclaim session reset error]
        If nfs4_do_reclaim gets a session reset error, nfs4_recovery_handle_error
        will set the NFS4CLNT_SESSION_SETUP bit, and the state manager should
        continue processing to reset the session.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_proc_destroy_session declaration here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e8c7f059311b70768ec71d9f4f6336ec6d1b61d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:38 2009 -0400

    nfs41: add session setup to the state manager
    
    At mount, nfs_alloc_client sets the cl_state NFS4CLNT_LEASE_EXPIRED bit
    and nfs4_alloc_session sets the NFS4CLNT_SESSION_SETUP bit, so both bits are
    set when nfs4_lookup_root calls nfs4_recover_expired_lease which schedules
    the nfs4_state_manager and waits for it to complete.
    
    Place the session setup after the clientid establishment in nfs4_state_manager
    so that the session is setup right after the clientid has been established
    without rescheduling the state manager.
    
    Unlike nfsv4.0, the nfs_client struct is not ready to use until the session
    has been established.  Postpone marking the nfs_client struct to NFS_CS_READY
    until after a successful CREATE_SESSION call so that other threads cannot use
    the client until the session is established.
    
    If the EXCHANGE_ID call fails and the session has not been setup (the
    NFS4CLNT_SESSION_SETUP bit is set), mark the client with the error and return.
    
    If the session setup CREATE_SESSION call fails with NFS4ERR_STALE_CLIENTID
    which could occur due to server reboot or network partition inbetween the
    EXCHANGE_ID and CREATE_SESSION call, reset the NFS4CLNT_LEASE_EXPIRED and
    NFS4CLNT_SESSION_SETUP bits and try again.
    
    If the CREATE_SESSION call fails with other errors, mark the client with
    the error and return.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: NFS_CS_SESSION_SETUP cl_cons_state for back channel setup]
      On session setup, the CREATE_SESSION reply races with the server back channel
      probe which needs to succeed to setup the back channel. Set a new
      cl_cons_state NFS_CS_SESSION_SETUP just prior to the CREATE_SESSION call
      and add it as a valid state to nfs_find_client so that the client back channel
      can find the nfs_client struct and won't drop the server backchannel probe.
      Use a new cl_cons_state so that NFSv4.0 back channel behaviour which only
      sets NFS_CS_READY is unchanged.
      Adjust waiting on the nfs_client_active_wq accordingly.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: rename NFS_CS_SESSION_SETUP to NFS_CS_SESSION_INITING]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: set NFS_CL_SESSION_INITING in alloc_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: move session setup into a function]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs4_proc_create_session declaration here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 118875b1403d9bb95165bc011922d71c8d0205f3
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:37 2009 -0400

    nfs41: reset the session slot table
    
    Separated from nfs41: schedule async session reset
    
    Do not kfree the session slot table upon session reset, just re-initialize it.
    Add a boolean to nfs4_proc_create_session to inidicate if this is a
    session reset or a session initialization.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d69c9eb60b865b146f8eea7916114b0d0ca84f45
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:36 2009 -0400

    nfs41: sequence operation
    
    Implement the sequence operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Check returned sessionid, slotid and slot sequenceid in decode_sequence.
    
    If the server returns different values for sessionID, slotID or slot sequence
    number than what was sent, the server is looney tunes.
    
    Pass the sequence operation status to nfs41_sequence_done in order to
    determine when to increment the slot sequence ID.
    
    Free slot is separated from sequence done.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: deref slot table in decode_sequence only for minorversion!=0]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: return ESERVERFAULT in decode_sequence]
    [no sr_session, no sr_flags]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use nfs4_call_sync_sequence to renew session lease]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove nfs4_call_sync_sequence forward definition]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: use struct nfs_client for nfs41_proc_async_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41 nfs41_sequence_call_done update error checking]
    [nfs41 nfs41_sequence_done update error checking]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove switch on error from nfs41_sequence_call_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 457de10de3dc64b28e33c932943b563409ed2e95
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:35 2009 -0400

    nfs41: enable nfs_client only nfs4_async_handle_error
    
    The session is per struct nfs_client, not per nfs_server. Allow the handler
    to be called with no nfs_server which simplifies the nfs4_proc_async_sequence session renewal call and will let it be used by pnfs file layout data servers.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b2118b4b0052b995565c59ae3eac040f84d71076
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:34 2009 -0400

    nfs41: destroy_session operation
    
    Implement the destroy_session operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41; NFS_CS_READY required for DESTROY_SESSION]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5224c0f541e76869198adfb0f71960cb695d8296
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:33 2009 -0400

    nfs41: use session attributes for rsize and wsize
    
    Set the mount points rsize and wsize to the negotiated session fore channel
    maximum response and requeset size. These values will be bound checked in
    nfs_server_set_fsinfo.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_session_set_rwsize into CONFIG_NFS_V4]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c5c6a32238801e3bf8893a2b6db6120df115b03b
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:32 2009 -0400

    nfs41: verify session channel attribues
    
    Invalidate the session if the server returns invalid fore or back channel
    attributes.
    
    Use a KERN_WARNING to report the fatal session estabishment error.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [refactor nfs4_verify_channel_attrs]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 419bcbe17c9a920ba7ffb0f01808c1addc3c807b
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:31 2009 -0400

    nfs41: create_session operation
    
    Implement the create_session operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Set the real fore channel max operations to preserve server resources.
    Note: If the server returns < NFS4_MAX_OPS, the client will very soon
    get an NFS4ERR_TOO_MANY_OPS. A later patch will handle this.
    
    Set the max_rqst_sz and max_resp_sz to PAGE_SIZE - we preallocate the buffers.
    
    Set the back channel max_resp_sz_cached to zero to force the client to
    always set csa_cachethis to FALSE because the current implementation
    of the back channel DRC only supports caching the CB_SEQUENCE operation.
    
    The client back channel server supports one slot, and desires 2 operations
    per compound.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Use the struct nfs_client cl_rpcclient.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_init_channel_attrs, just use nfs41_create_session_args]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use rsize and wsize for session channel attributes]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: set channel max operations]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: set back channel attributes]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: obliterate nfs4_adjust_channel_attrs]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have create_session work on nfs_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: move CONFIG_NFS_V4_1 endif]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    [moved nfs4_init_slot_table definition here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use kcalloc to allocate slot table]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d2c5ee9f241c7c4718050ae4d20967bd4aaa7099
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:30 2009 -0400

    nfs41: get_lease_time
    
    get_lease_time uses the FSINFO rpc operation to
    get the lease time attribute.
    
    nfs4_get_lease_time() is only called from the state manager on session setup
    so don't recover from clientid or sequence level errors.
    
    We do need to recover from NFS4ERR_DELAY or NFS4ERR_GRACE.
    Use NFS4_POLL_RETRY_MIN - the Linux server returns NFS4ERR_DELAY when an
    upcall is needed to resolve an uncached export referenced by a file handle.
    
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have get_lease_time work on nfs_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get_lease_time recover from NFS4ERR_DELAY]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    [define nfs4_get_lease_time_{args,res}]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 63a93b4af49220c74757beb17b5617b72d912b6b
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:29 2009 -0400

    nfs41: exchange_id operation
    
    Implement the exchange_id operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Unlike NFSv4.0, NFSv4.1 requires machine credentials. RPC_AUTH_GSS machine
    credentials will be passed into the kernel at mount time to be available for
    the exchange_id operation.
    
    RPC_AUTH_UNIX root mounts can use the UNIX root credential. Store the root
    credential in the nfs_client struct.
    
    Without a credential, NFSv4.1 state renewal fails.
    
    [nfs41: establish clientid via exchange id only if cred != NULL]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfsd41: move nfstime4 from under CONFIG_NFS_V4_1]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: do not wait a lease time in exchange id]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4c82f4fd3c489a363addd8823f0ea886e25b64ea
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:28 2009 -0400

    nfs41 delegreturn sequence setup done support
    
    Separate delegreturn calls from nfs41: sequence setup/done support
    
    Implement the delegreturn rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 24629c20cb03150b52fa59e44d24cf64559cccc5
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:27 2009 -0400

    nfs41 commit sequence setup done support
    
    Separate commit calls from nfs41: sequence setup/done support
    
    Implement the commit rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT.]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 69338657e1ba669121fb2f927be7c525b8bd53d4
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:26 2009 -0400

    nfs41 write sequence setup done support
    
    Separate write calls from nfs41: sequence setup/done support
    
    Implement the write rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
    [nfs41: separate free slot from sequence done
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT.]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c96e407143642761e246e67a17869ee78e2cb39d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:25 2009 -0400

    nfs41: read sequence setup/done support
    
    Implement the read rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
    [nfs41: separate free slot from sequence done]
    [remove nfs_readargs.nfs_server, use calldata->inode instead]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee4245b7ebd06acf52659baf754aa7cc29533766
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:24 2009 -0400

    nfs41: unlink sequence setup/done support
    
    Implement the rpc_call_prepare methods for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 67e4028d693977e599a4c363d148e6f402de196f
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:23 2009 -0400

    nfs41: locku sequence setup/done support
    
    Separate nfs4_locku calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1769b4107afca8264d16065f2496dc5ddf42fcaf
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:22 2009 -0400

    nfs41: lock sequence setup/done support
    
    Separate nfs4_lock calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    [use nfs4_sequence_done_free_slot]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 728710cb57170486d6bcb1b876d3ab080af67686
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:21 2009 -0400

    nfs41: open sequence setup/done support
    
    Separate nfs4_open calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    [use nfs4_sequence_done_free_slot]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3f8b9c1f4579bf5e2f637320adf63a631b508ec4
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:20 2009 -0400

    nfs41: close sequence setup/done support
    
    Separate nfs4_close calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 79d40b648a5c52bf9bfabf68f1fd51d9e8cb2008
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:19 2009 -0400

    nfs41: nfs41_call_sync_done
    
    Implement nfs4.1 synchronous rpc_call_done method
    that essentially just calls nfs4_sequence_done, that turns
    around and calls nfs41_sequence_done for minorversion1 rpcs.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move adding nfs4_sequence_free_slot from nfs41-separate-free-slot-from-sequence-done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ccbb435d328245a6ba7390fa32160aae65abd479
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:18 2009 -0400

    nfs41: nfs41_sequence_done
    
    Handle session level errors, update slot sequence id and
    sessions bookeeping, free slot.
    
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: bail out early out of nfs41_sequence_done if !res->sr_session]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_sequence_done from nfs41: nfs41_call_sync_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [move nfs4_sequence_free_slot from nfs41: separate free slot from sequence done]
        Don't free the slot until after all rpc_restart_calls have completed.
        Session reset will require more work.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved reset sr_slotid to nfs41_sequence_free_slot]
    [free slot also on unexpectecd error]
    [remove seq_res.sr_session member, use nfs_client's instead]
    [ditch seq_res.sr_flags until used]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [look at sr_slotid for bailing out early from nfs41_sequence_done]
    [nfs41: rpc_wake_up_next if sessions slot was not consumed.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove unused error checking in nfs41_sequence_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs4_has_session check in nfs41_sequence_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs_client pointer check]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 218b9eff6dc63b5eabd0b267b26ba469dc41f089
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:17 2009 -0400

    nfs41: nfs41_sequence_free_slot
    
    [from nfs41: separate free slot from sequence done]
    
    Don't free the slot until after all rpc_restart_calls have completed.
    Session reset will require more work.
    
    As noted by Trond, since we're using rpc_wake_up_next rather than
    rpc_wake_up() we must always wake up the next task in the queue
    either by going through nfs4_free_slot, or just calling
    rpc_wake_up_next if no slot is to be freed.
    
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [got rid of nfs4_sequence_res.sr_session, use nfs_client.cl_session instead]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_wake_up_next if sessions slot was not consumed.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 290f51876d4bb5844e7d19a4f46e14754336028c
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:16 2009 -0400

    nfs41: free slot
    
    Free a slot in the slot table.
    
    Mark the slot as free in the bitmap-based allocation table
    by clearing a bit corresponding to the slotid.
    
    Update lowest_free_slotid if freed slotid is lower than that.
    Update highest_used_slotid.  In the case the freed slotid
    equals the highest_used_slotid, scan downwards for the next
    highest used slotid using the optimized fls* functions.
    
    Finally, wake up thread waiting on slot_tbl_waitq for a free slot
    to become available.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: free slot use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use find_first_zero_bit for nfs4_find_slot]
        While at it, obliterate lowest_free_slotid and fix-up related comments.
        As per review comment 21/85.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use __clear_bit for nfs4_free_slot]
        While at it, fix-up function comment.
        Part of review comment 22/85.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use find_last_bit in nfs4_free_slot to determine highest used slot.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
        Otherwise there's a race (we've hit) with nfs4_free_slot where
        nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
        nfs4_free_slots happen concurrently and call rpc_wake_up_next
        where there's nobody to wake up yet, context goes back to
        nfs41_setup_sequence which goes to sleep when the slot table
        is actually empty now and there's no-one to wake it up anymore.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a2751e14b9fab4e61cd945e230e12a6f83abbf1
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:15 2009 -0400

    nfs41: setup_sequence method
    
    Allocate a slot in the session slot table and set the sequence op arguments.
    
    Called at the rpc prepare stage.
    
    Add a status to nfs41_sequence_res, initialize it to one so that we catch
    rpc level failures which do not go through decode_sequence which sets
    the new status field.
    
    Note that upon an rpc level failure, we don't know if the server processed the
    sequence operation or not. Proceed as if the server did process the sequence
    operation.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [nfs41: sequence args use slotid]
    [nfs41: find slot return slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    As per 11-14-08 review
    [move extern declaration from nfs41: sequence setup/done support]
    [removed sa_session definition, changed sa_cache_this into a u8 to reduce footprint]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
        Otherwise there's a race (we've hit) with nfs4_free_slot where
        nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
        nfs4_free_slots happen concurrently and call rpc_wake_up_next
        where there's nobody to wake up yet, context goes back to
        nfs41_setup_sequence which goes to sleep when the slot table
        is actually empty now and there's no-one to wake it up anymore.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2fdad325fcc4f6353aaa4424e678130a5c20769f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:14 2009 -0400

    nfs41: find slot
    
    Find a free slot using bitmap-based allocation.
    Use the optimized ffz function to find a zero bit
    in the bitmap that indicates a free slot, starting
    the search from the 'lowest_free_slotid' position.
    
    If found, mark the slot as used in the bitmap, get
    the slot's slotid and seqid, and update max_slotid
    to be used by the SEQUENCE operation.
    
    Also, update lowest_free_slotid for next search.
    
    If no free slot was found the caller has to wait
    for a free slot (outside the scope of this function)
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: find slot return slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [use find_first_zero_bit for nfs4_find_slot as per review comment 21/85.]
    [use NFS4_MAX_SLOT_TABLE rather than NFS4_NO_SLOT]
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 73c411819a4946bc177ea686590fc10978cea7af
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:13 2009 -0400

    nfs41: nfs4_setup_sequence
    
    Perform the nfs4_setup_sequence in the rpc_call_prepare state.
    
    If a session slot is not available, we will rpc_sleep_on the
    slot wait queue leaving the tk_action as rpc_call_prepare.
    
    Once we have a session slot, hang on to it even through rpc_restart_calls.
    Ensure the nfs41_sequence_res sr_slot pointer is NULL before rpc_run_task is
    called as nfs41_setup_sequence will only find a new slot if it is NULL.
    
    A future patch will call free slot after any rpc_restart_calls, and handle the
    rpc restart that result from a sequence operation error.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: simplify nfs4_call_sync]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    [nfs41: check for session not minorversion]
    [nfs41: remove rpc_message from nfs41_call_sync_args]
    [moved NFS4_MAX_SLOT_TABLE logic into nfs41_setup_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: expose nfs4_call_sync_session for lease renewal]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove unnecessary return check]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee327ce246215f3b41899d230f13986caeed0435
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:11 2009 -0400

    nfs41: xdr {encode,decode}_sequence
    
    Implement stubs for encode and decode sequence, defined as no-ops when
    CONFIG_NFS_V4_1 is not defined.
    Add the nfsv41 encode and decode sizes. Add encode_sequence to all
    nfs4_enc_* routines and decode_sequence to all nfs4_dec_* routines as required
    by v41.
    
    [was nfs41: minorversion support for xdr]
    [added nfs_client argument to encode_sequence so not to use sequence_args to pass sa_session]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7188cc7f0ec3ffa97dc6bc5d20ab2bbda4e6f3e6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:10 2009 -0400

    nfs41: encode minorversion in compound header
    
    Signed-off-by: Andy Adamdon <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a615aaa049553e6aad2c0120dcfc60530be5713
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:09 2009 -0400

    NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset
    
    As Trond suggested, rather than passing a constant to xdr_inline_pages,
    keep a running count of the expected reply bytes.  In preparation for
    nfs41, where additional op sequence are expteced when talking to nfs41
    servers.
    
    [NFS: cb_compoundhdr.replen is in words not bytes]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get fs_locations replen before encoding the GETATTR]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get getacl replen before encoding the GETATTR]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4ce4c78e67452ae11ceac2acb7ed8a0e6bb290fb
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:08 2009 -0400

    NFS: update hdr->replen for every encode op
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28d355758484aa3ec9a53b1223eebb7abf804f43
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:07 2009 -0400

    NFS: define and initialize compound_hdr.replen
    
    replen holds the running count of expected reply bytes.
    repl will then be used by encoding routines for xdr_inline_pages offset
    after which data bytes are to be received directly into the xdr
    buffer pages.
    
    NOTE: According to the nfsv4 and v4.1 RFCs, the replied tag SHOULD be the same
    is the one sent, but this is not required as a MUST for the server to do so.
    The server may screw us if it replies a tag of a different length in the
    compound result.
    
    [NFS: cb_compoundhdr.replen is in words not bytes]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d11e0f0d9b3fbdc6148801d7788916fe0c5a6e1
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:06 2009 -0400

    NFS: use decode_change_info_maxsz for xdr maxsz calculations
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 58009c0b9687503d9df69bd32cc2bb0afe87e3fd
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:05 2009 -0400

    nfs41: set up seq_res.sr_slotid
    
    Initialize nfs4_sequence_res sr_slotid to NFS4_MAX_SLOT_TABLE.
    
    [was nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [pulled definition of struct nfs4_sequence_res.sr_slotid to here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 30a6b1c902b143ba9ac741b0e4715d2e696ebabc
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:04 2009 -0400

    nfs41: nfs41: pass *session in seq_args and seq_res
    
    To be used for getting the rpc's minorversion and for nfs41 xdr
    {en,de}coding of the sequence operation.
    Reset the seq session ptrs for minorversion=0 rpc calls.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e2455a324fa465996f104d0b4db9f4904d0c6e28
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:03 2009 -0400

    nfs41: introduce nfs4_call_sync
    
    Use nfs4_call_sync rather than rpc_call_sync to provide
    for a nfs41 sessions-enabled interface for sessions manipulation.
    
    The nfs41 rpc logic uses the rpc_call_prepare method to
    recover and create the session, as well as selecting a free slot id
    and the rpc_call_done to free the slot and update slot table
    related metadata.
    
    In the coming patches we'll add rpc prepare and done routines
    for setting up the sequence op and processing the sequence result.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    As per 11-14-08 review.
    Squash into "nfs41: introduce nfs4_call_sync" and "nfs41: nfs4_setup_sequence"
    Define two functions one for v4 and one for v41
    add a pointer to struct nfs4_client to the correct one.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [added BUG() in _nfs4_call_sync_session if !CONFIG_NFS_V4_1]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [group minorversion specific stuff together]
    Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: fixup nfs4_clear_client_minor_version]
    [introduce nfs4_init_client_minor_version() in this patch]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [cleaned-up patch: got rid of nfs_call_sync_t, dprintks, cosmetics, extra server defs]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9442acf145421579d61bd264e7666fd758fdebbf
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:02 2009 -0400

    nfs41: use nfs4_fs_locations_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [find nfs4_fs_locations_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7b2215ef5bd397b453384044256f6d3a61ba62e7
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:01 2009 -0400

    nfs41: use nfs4_setaclres
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs_setaclres]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b3fa4a5024aa0a6f13055e8a806bc0a2e4082152
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:00 2009 -0400

    NFS: get rid of unused xdr decode_setattr(, res) argument
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eeb17359505d1d6536e560c9f5290e44e7afaa79
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:59 2009 -0400

    nfs41: use nfs4_getaclres
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: embed resp_len in nfs_getaclres]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c2e247498e592e693e92050d051c4b7844299f27
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:58 2009 -0400

    nfs41: use nfs4_pathconf_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_pathconf_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 504fd6a3749ad9965989cb97bccdec4744da69c5
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:57 2009 -0400

    nfs41: use nfs4_fsinfo_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_fsinfo_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2c9abe612b8a8b1c6aaae9c5b46083fbe018abab
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:56 2009 -0400

    nfs41: use nfs4_statfs_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_statfs_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 05a5573be4285bc757fc0bc096484cfcf157bf19
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:55 2009 -0400

    nfs41: use nfs4_readlink_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_readlink_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7f8793f65686ab166c0e092d2163c0c4853cf04b
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:54 2009 -0400

    nfs41: use nfs4_server_caps_arg
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_server_caps_arg]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6c89c5e14167a05ffcdaa4dfd75c7f15de9e98a
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:21:53 2009 -0400

    nfs41: sessions client infrastructure
    
    NFSv4.1 Sessions basic data types, initialization, and destruction.
    
    The session is always associated with a struct nfs_client that holds
    the exchange_id results.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [remove extraneous rpc_clnt pointer, use the struct nfs_client cl_rpcclient.
    remove the rpc_clnt parameter from nfs4 nfs4_init_session]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Use the presence of a session to determine behaviour instead of the
    minorversion number.]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [constified nfs4_has_session's struct nfs_client parameter]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Rename nfs4_put_session() to nfs4_destroy_session() and call it from nfs4_free_client() not nfs4_free_server().
    Also get rid of nfs4_get_session() and the ref_count in nfs4_session struct as keeping track of nfs_client should be sufficient]
    Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
    [nfs41: pass rsize and wsize into nfs4_init_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [separated out removal of rpc_clnt parameter from nfs4_init_session ot a
     patch of its own]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Pass the nfs_client pointer into nfs4_alloc_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: don't assign to session->clp->cl_session in nfs4_destroy_session]
    [nfs41: fixup nfs4_clear_client_minor_version]
    [introduce nfs4_clear_client_minor_version() in this patch]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Refactor nfs4_init_session]
        Moved session allocation into nfs4_init_client_minor_version, called from
        nfs4_init_client.
        Leave rwise and wsize initialization in nfs4_init_session, called from
        nfs4_init_server.
        Reverted moving of nfs_fsid definition to nfs_fs_sb.h
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Move NFS4_MAX_SLOT_TABLE define from under CONFIG_NFS_V4_1]
    [Fix comile error when CONFIG_NFS_V4_1 is not set.]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs4_init_slot_table definition to "create_session operation"]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: alloc session with GFP_KERNEL]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a4fad5bb627278d088ae1f32b9a8cf05d0d012b6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:52 2009 -0400

    nfs41: client xdr definitions
    
    Define stubs for sequence args and res data structures and embed
    them in all other nfs4 and nfs41 xdr types.  They are needed for
    sending any op in a nfs41 compound rpc.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    [moved new args/res definitions away, to where they're first used]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 885ec3ea6aabea034c29a1528673a97547a49d04
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:51 2009 -0400

    nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
    
    To be returned to the mount command when trying to mount a v4 server
    using minorversion 1.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 91f3a52a160ad126e91956a44c24c2133d6fb24d
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:50 2009 -0400

    nfs41: Use mount minorversion option
    
    Use the mount minorversion option to initialize the nfs_client cl_minorversion
    and match it in nfs_match_client() when looking up a nfs_client.
    
    [nfs41: remove ifdefs around nfs_client_initdata.minorversion]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit baf0fdcf92df7e9bd71b72bd6c7f5515d29f0c79
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:49 2009 -0400

    nfs41: nfs_client.cl_minorversion
    
    This field is set to the nfsv4 minor version for this mount.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    Note: This patch sets the referral to the same minorversion as the
    current mount. Revisit in future patch.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [removed cl_minorversion assignment in nfs_set_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [always define nfs_client.cl_minorversion]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6e522e4892b87bd1b717dc625edfae9894ba305c
Author: Mike Sager <sager@netapp.com>
Date:   Wed Apr 1 09:21:48 2009 -0400

    nfs41: add mount command option minorversion
    
    mount -t nfs4 -o minorversion=[0|1] specifies whether to use 4.0 or 4.1.
    By default, the minorversion is set to 0.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    [set default minorversion to 0 as per Trond and SteveD's request]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a43cc186595847c4ad9fe3250ab68fba53f54bf
Author: Mike Sager <sager@netapp.com>
Date:   Wed Apr 1 09:21:47 2009 -0400

    nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
    
    If 4.1 isn't supported, NFS4_MAX_MINOR_VERSION will be 0.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7048bdd2af5d8fc115e82cdc307241e3cbe370d0
Author: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Date:   Wed Apr 1 09:21:46 2009 -0400

    nfs41: Add Kconfig symbols for NFSv4.1
    
    Added CONFIG_NFS_V4_1 and made it depend upon CONFIG_NFS_V4 and EXPERIMENTAL.
    Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
    
    At the moment we're expecting folks trying out nfs41 to
    actively participate in the development process by helping us
    debug issues and ideally send patches to fix problems.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
