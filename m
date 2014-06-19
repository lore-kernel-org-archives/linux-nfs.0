Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34778 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757787AbaFSOu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:50:58 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so2274590qcv.33
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:50:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Date: Thu, 19 Jun 2014 10:49:06 -0400
Message-Id: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here it is. The long awaited removal of the client_mutex from knfsd.
As many of us are aware, one of the major bottlenecks in NFSv4 serving
is the fact that all compounds are processed while holding a single,
global mutex.

This has an obvious detrimental effect on scalability. I've heard
anecdotal reports of 10x slowdowns with v4 serving vs. v3 on the same
machine, primarily due to it.

This patchset eliminates that mutex and (hopefully!) the bottleneck
that it imposes. The basic idea is to add refcounting to most of the
objects that compounds deal with to ensure that they are pinned while
in use. Spinlocks are used to protect things like the hashtables and
trees that track the objects.

Benny started this set quite some time ago, and Trond took up the
torch early this spring. He then handed it to me to clean up the
remaining bits about a month ago.

I'd like to see this considered for v3.17. Obviously, getting it into
linux-next ASAP would be a good thing once it passes review.

Some other highlights/notes:

- use of lockdep has been greatly increased. I found it was the only
  way to ensure that I didn't create lock inversion problems and such.

- clients are now only looked up once per compund and are cached in
  the cstate. This keeps us from having to keep searching for the
  same client for each compound op.

- openowners and lockowners are now handled more sanely. References
  to them are only held by the stateids that are associated with them,
  and they are destroyed when the last reference to them is put. Also,
  lockowners can now have more than one stateid (in accordance with
  the spec)

- the fault injection code has been overhauled. It should look the same
  to users, but it needed major work to deal with the new locking.
  It's probably possible to consolidate some of that code as well --
  it more cut-and-pastey than I'd like.

- I've added a file to document how all of the moving parts fit
  together. It probably can use more fleshing out, but it's a start.

- the lease handling is now a bit more complex than I'd like. Lease
  removal in particular is currently called under a spinlock, which
  I think we'll need to eventually clean up. For now, this is ok
  since the first thing that vfs_setlease does is lock the i_lock,
  but I think we'll eventually need to do an i_lock pushdown in the
  lease handling code, and ensure that vfs_setlease isn't called
  under a spinlock.

As always, comments and review are welcome.

Benny Halevy (1):
  nfsd4: use cl_lock to synchronize all stateid idr calls

Jeff Layton (40):
  NFSd: Ensure that nfs4_file_get_access enforces share access modes
  locks: add file_has_lease
  NFSd: Protect the nfs4_file delegation fields using the fi_lock
  NFSd: Allow lockowners to hold several stateids
  NFSd: Ensure atomicity of stateid destruction and idr tree removal
  NFSd: Cleanup the freeing of stateids
  nfsd: do filp_close in sc_free callback for lock stateids
  NFSd: Add locking to protect the state owner lists
  nfsd: clean up races in lock stateid searching and creation
  nfsd: clean up lockowner refcounting when finding them
  nfsd: add an operation for unhashing a stateowner
  nfsd: clean up nfs4_release_lockowner
  nfsd: clean up refcounting for lockowners
  nfsd: declare v4.1+ openowners confirmed on creation
  nfsd: make openstateids hold references to their openowners
  nfsd: don't allow CLOSE to proceed until refcount on stateid drops
  lockdep: add lockdep_assert_not_held
  nfsd: add locking to stateowner release
  nfsd: optimize destroy_lockowner cl_lock thrashing
  nfsd: reduce cl_lock trashing in release_openowner
  NFSd: Protect session creation and client confirm using client_lock
  nfsd: protect the close_lru list and oo_last_closed_stid with
    client_lock
  nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
  nfsd: move unhash_client_locked call into mark_client_expired_locked
  nfsd: fix misleading comment
  nfsd: don't destroy client if mark_client_expired_locked fails
  nfsd: don't destroy clients that are busy
  nfsd: abstract out the get and set routines into the fault injection
    ops
  nfsd: add a forget_clients "get" routine with proper locking
  nfsd: add a forget_client set_clnt routine
  nfsd: add nfsd_inject_forget_clients
  nfsd: add a list_head arg to nfsd_foreach_client_lock
  nfsd: add more granular locking to forget_locks fault injector
  nfsd: add more granular locking to forget_openowners fault injector
  nfsd: add more granular locking to *_delegations fault injectors
  nfsd: remove old fault injection infrastructure
  nfsd: remove nfs4_lock_state: nfs4_laundromat
  nfsd: remove nfs4_lock_state: nfs4_state_shutdown_net
  nfsd: remove the client_mutex and the nfs4_lock/unlock_state wrappers
  nfsd: add file documenting new state object model

Trond Myklebust (63):
  nfsd: Protect addition to the file_hashtbl
  NFSd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg
  NFSd: nfs4_preprocess_seqid_op should only set *stpp on success
  NFSd: Add fine grained protection for the nfs4_file->fi_stateids list
  NFSd: Add a mutex to protect the NFSv4.0 open owner replay cache
  NFSd: Add locking to the nfs4_file->fi_fds[] array
  NFSd: Lock owners are not per open stateid
  NFSd: Clean up helper __release_lock_stateid
  NFSd: NFSv4 lock-owners are not associated to a specific file
  NFSd: Cleanup nfs4svc_encode_compoundres
  NFSd: Don't get a session reference without a client reference
  NFSd: Allow struct nfsd4_compound_state to cache the nfs4_client
  NFSd: Move the delegation reference counter into the struct nfs4_stid
  NFSd: Simplify stateid management
  NFSd: Fix delegation revocation
  NFSd: Add reference counting to the lock and open stateids
  NFSd: clean up nfsd4_close_open_stateid
  NFSd: Add a struct nfs4_file field to struct nfs4_stid
  NFSd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
  NFSd: Ensure stateids remain unique until they are freed
  NFSd: Convert delegation counter to an atomic_long_t type
  NFSd: Slight cleanup of find_stateid()
  NFSd: Add reference counting to find_stateid
  NFSd: Add reference counting to lock stateids
  NFSd: nfsd4_locku() must reference the lock stateid
  NFSd: Ensure that nfs4_open_delegation() references the delegation
    stateid
  NFSd: nfsd4_process_open2() must reference the delegation stateid
  NFSd: nfsd4_process_open2() must reference the open stateid
  NFSd: Prepare nfsd4_close() for open stateid referencing
  NFSd: nfsd4_open_confirm() must reference the open stateid
  NFSd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
  NFSd: Migrate the stateid reference into nfs4_preprocess_seqid_op
  NFSd: Migrate the stateid reference into nfs4_lookup_stateid()
  NFSd: Migrate the stateid reference into nfs4_find_stateid_by_type()
  NFSd: Add reference counting to state owners
  NFSd: Keep a reference to the open stateid for the NFSv4.0 replay
    cache
  NFSd: Make lock stateid take a reference to the lockowner
  NFSd: Protect adding/removing open state owners using client_lock
  NFSd: Protect adding/removing lock owners using client_lock
  NFSd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
  NFSd: Cache the client that was looked up in lookup_clientid()
  NFSd: Convert nfsd4_process_open1() to work with lookup_clientid()
  NFSd: Always use lookup_clientid() in nfsd4_process_open1
  NFSd: Move the open owner hash table into struct nfs4_client
  NFSd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
  NFSd: Ensure struct nfs4_client is unhashed before we try to destroy
    it
  NFSd: Ensure that the laundromat unhashes the client before releasing
    locks
  NFSd: Don't require client_lock in free_client
  NFSd: Move create_client() call outside the lock
  NFSd: Protect unconfirmed client creation using client_lock
  NFSd: Protect nfsd4_destroy_clientid using client_lock
  NFSd: Ensure lookup_clientid() takes client_lock
  NFSd: Add assertions to document the nfs4_client/session locking
  NFSd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
  NFSd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
  NFSd: Remove nfs4_lock_state(): nfsd4_release_lockowner
  NFSd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
  NFSd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
  NFSd: Remove nfs4_lock_state(): nfsd4_delegreturn()
  NFSd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
  NFSd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
  NFSd: Remove nfs4_lock_state(): setclientid, setclientid_confirm,
    renew
  NFSd: Remove nfs4_lock_state(): reclaim_complete()

 .../filesystems/nfs/nfsd4-state-objects.txt        |  110 +
 fs/locks.c                                         |   26 +
 fs/nfsd/fault_inject.c                             |  129 +-
 fs/nfsd/netns.h                                    |    5 -
 fs/nfsd/nfs4callback.c                             |   18 +-
 fs/nfsd/nfs4proc.c                                 |   16 +-
 fs/nfsd/nfs4state.c                                | 2569 ++++++++++++++------
 fs/nfsd/nfs4xdr.c                                  |   17 +-
 fs/nfsd/state.h                                    |   86 +-
 fs/nfsd/xdr4.h                                     |    8 +-
 include/linux/fs.h                                 |    6 +
 include/linux/lockdep.h                            |    6 +
 12 files changed, 2052 insertions(+), 944 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/nfsd4-state-objects.txt

-- 
1.9.3

