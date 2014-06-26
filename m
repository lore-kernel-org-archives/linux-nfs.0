Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:40489 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbaFZTNr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:47 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so3413888qgd.21
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Date: Thu, 26 Jun 2014 15:11:40 -0400
Message-Id: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2 changes:
- rebased on top of v3.16-rc2

- fixed up checkpatch warnings (I'm really starting to hate that 80 column
  limit warning)

- fleshed out patch descriptions. Most of them should now say they are a
  necessary step toward client_mutex removal when it's not otherwise
  obvious. Also, when things touch outside of fs/nfsd, I added Cc lines
  for the appropriate maintainers.

- reordered patches to put more of the ones that don't affect locking
  near the front of the queue. This may make it easier to merge this
  piecemeal.

- I think I have addressed all of Christoph's review comments -- let me
  know if I missed any. For now, I left the Documentation/ patch intact,
  but we don't need to merge it at all if it's objectionable. I may end
  up transplanting it into comments but I ran short of time so I'll defer
  it for now.

- fix race that can occur between concurrent FREE_STATEID and CLOSE. As
  part of that fix, the cl_lock thrashing (and ensuing races) that could
  occur when a stateowner was released has also been eliminated.

- overhaul of access/deny mode handling. Christoph was correct to be
  suspicious. It didn't properly handle the case where a stateid with a
  deny mode was released or downgraded. As a bonus, the new code should be
  much more efficient when you have a long list of stateids as we no longer
  need to walk the entire list to check for deny mode conflicts. I also
  did some cleanup of the file access handling.

- ensure that dl_recall_lru list entries are dequeued before calling
  revoke_delegation (potential memory corruptor).

- Included Christophs fix for the file access leak when nfsd4_truncate
  fails. I took the liberty of adding a commit log message for it and a
  SoB line. Let me know if that's a problem and we can rework it.

For completeness' sake, I'm just re-posting my entire patch queue for
the v2 series. These are also available in my tree at samba.org:

    http://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-devel

I'd still like to see this merged for v3.17, so it would be ideal to
merge this into linux-next soon if possible. Bruce, please let me know
what you think the prospects are.

Original cover letter text follows:

-----------------------[snip]--------------------------

Here it is. The long awaited removal of the client_mutex from knfsd.  As
many of us are aware, one of the major bottlenecks in NFSv4 serving is
the fact that all compounds are processed while holding a single, global
mutex.

This has an obvious detrimental effect on scalability. I've heard
anecdotal reports of 10x slowdowns with v4 serving vs. v3 on the same
machine, primarily due to it.

This patchset eliminates that mutex and (hopefully!) the bottleneck that
it imposes. The basic idea is to add refcounting to most of the objects
that compounds deal with to ensure that they are pinned while in use.
Spinlocks are used to protect things like the hashtables and trees that
track the objects.

Benny started this set quite some time ago, and Trond took up the torch
early this spring. He then handed it to me to clean up the remaining
bits about a month ago.

Benny Halevy (1):
  nfsd4: use cl_lock to synchronize all stateid idr calls

Christoph Hellwig (1):
  nfsd: fix file access refcount leak when nfsd4_truncate fails

Jeff Layton (54):
  nfsd: fix return of nfs4_acl_write_who
  nfsd: add __force to opaque verifier field casts
  nfsd: clean up sparse endianness warnings in nfscache.c
  nfsd: nfsd_splice_read and nfsd_readv should return __be32
  nfsd: add appropriate __force directives to filehandle generation code
  nfsd: properly handle embedded newlines in fault_injection input
  nfsd: wait to initialize work struct just prior to using it
  nfsd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg
  nfsd: Allow lockowners to hold several stateids
  nfsd: clean up nfs4_release_lockowner
  nfsd: declare v4.1+ openowners confirmed on creation
  nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
  nfsd: remove nfs4_file_put_fd
  nfsd: ensure that nfs4_file_get_access enforces deny modes
  nfsd: cleanup nfs4_check_open
  locks: add file_has_lease to prevent delegation break races
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Ensure atomicity of stateid destruction and idr tree removal
  nfsd: Cleanup the freeing of stateids
  nfsd: do filp_close in sc_free callback for lock stateids
  nfsd: Add locking to protect the state owner lists
  nfsd: clean up races in lock stateid searching and creation
  nfsd: ensure atomicity in nfsd4_free_stateid and
    nfsd4_validate_stateid
  nfsd: clean up lockowner refcounting when finding them
  nfsd: add an operation for unhashing a stateowner
  nfsd: clean up refcounting for lockowners
  nfsd: make openstateids hold references to their openowners
  nfsd: don't allow CLOSE to proceed until refcount on stateid drops
  lockdep: add lockdep_assert_not_held
  nfsd: add locking to stateowner release
  nfsd: optimize destroy_lockowner cl_lock thrashing
  nfsd: close potential race in nfsd4_free_stateid
  nfsd: reduce cl_lock thrashing in release_openowner
  nfsd: don't thrash the cl_lock while freeing an open stateid
  nfsd: Protect session creation and client confirm using client_lock
  nfsd: protect the close_lru list and oo_last_closed_stid with
    client_lock
  nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
  nfsd: move unhash_client_locked call into mark_client_expired_locked
  nfsd: don't destroy client if mark_client_expired_locked fails
  nfsd: don't destroy clients that are busy
  nfsd: protect clid and verifier generation with client_lock
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

Trond Myklebust (61):
  nfsd: Protect addition to the file_hashtbl
  nfsd: nfs4_preprocess_seqid_op should only set *stpp on success
  nfsd: Cleanup nfs4svc_encode_compoundres
  nfsd: Don't get a session reference without a client reference
  nfsd: Allow struct nfsd4_compound_state to cache the nfs4_client
  nfsd: lock owners are not per open stateid
  nfsd: NFSv4 lock-owners are not associated to a specific file
  nfsd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
  nfsd: clean up nfsd4_close_open_stateid
  nfsd: Cache the client that was looked up in lookup_clientid()
  nfsd: Convert nfsd4_process_open1() to work with lookup_clientid()
  nfsd: Always use lookup_clientid() in nfsd4_process_open1
  nfsd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
  nfsd: Add a mutex to protect the NFSv4.0 open owner replay cache
  nfsd: Add locking to the nfs4_file->fi_fds[] array
  nfsd: clean up helper __release_lock_stateid
  nfsd: Simplify stateid management
  nfsd: Fix delegation revocation
  nfsd: Add reference counting to the lock and open stateids
  nfsd: Add a struct nfs4_file field to struct nfs4_stid
  nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
  nfsd: Ensure stateids remain unique until they are freed
  nfsd: Convert delegation counter to an atomic_long_t type
  nfsd: Slight cleanup of find_stateid()
  nfsd: Add reference counting to lock stateids
  nfsd: nfsd4_locku() must reference the lock stateid
  nfsd: Ensure that nfs4_open_delegation() references the delegation
    stateid
  nfsd: nfsd4_process_open2() must reference the delegation stateid
  nfsd: nfsd4_process_open2() must reference the open stateid
  nfsd: Prepare nfsd4_close() for open stateid referencing
  nfsd: nfsd4_open_confirm() must reference the open stateid
  nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
  nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
  nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
  nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
  nfsd: Add reference counting to state owners
  nfsd: Keep a reference to the open stateid for the NFSv4.0 replay
    cache
  nfsd: Make lock stateid take a reference to the lockowner
  nfsd: Protect adding/removing open state owners using client_lock
  nfsd: Protect adding/removing lock owners using client_lock
  nfsd: Move the open owner hash table into struct nfs4_client
  nfsd: Ensure struct nfs4_client is unhashed before we try to destroy
    it
  nfsd: Ensure that the laundromat unhashes the client before releasing
    locks
  nfsd: Don't require client_lock in free_client
  nfsd: Move create_client() call outside the lock
  nfsd: Protect unconfirmed client creation using client_lock
  nfsd: Protect nfsd4_destroy_clientid using client_lock
  nfsd: Ensure lookup_clientid() takes client_lock
  nfsd: Add lockdep assertions to document the nfs4_client/session
    locking
  nfsd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
  nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
  nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
  nfsd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
  nfsd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
  nfsd: Remove nfs4_lock_state(): nfsd4_delegreturn()
  nfsd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
  nfsd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
  nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm,
    renew
  nfsd: Remove nfs4_lock_state(): reclaim_complete()

 .../filesystems/nfs/nfsd4-state-objects.txt        |  105 +
 fs/locks.c                                         |   26 +
 fs/nfsd/fault_inject.c                             |  138 +-
 fs/nfsd/netns.h                                    |   11 +-
 fs/nfsd/nfs4acl.c                                  |    2 +-
 fs/nfsd/nfs4callback.c                             |   22 +-
 fs/nfsd/nfs4proc.c                                 |   24 +-
 fs/nfsd/nfs4state.c                                | 2818 ++++++++++++++------
 fs/nfsd/nfs4xdr.c                                  |   17 +-
 fs/nfsd/nfscache.c                                 |   13 +-
 fs/nfsd/nfsfh.c                                    |   10 +-
 fs/nfsd/nfsfh.h                                    |   15 +-
 fs/nfsd/state.h                                    |   87 +-
 fs/nfsd/vfs.c                                      |    7 +-
 fs/nfsd/vfs.h                                      |    4 +-
 fs/nfsd/xdr4.h                                     |    8 +-
 include/linux/fs.h                                 |    6 +
 include/linux/lockdep.h                            |    4 +
 18 files changed, 2271 insertions(+), 1046 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/nfsd4-state-objects.txt

-- 
1.9.3

