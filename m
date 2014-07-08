Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:56350 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbaGHSEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:36 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so5548055qcr.2
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 000/101] nfsd: eliminate the client_mutex
Date: Tue,  8 Jul 2014 14:02:48 -0400
Message-Id: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4 significant changes:

- rebased again on top of Bruce's for-3.17 branch

- the patch to add lockdep_assert_not_held has been dropped. There
  was already the same functionality with might_lock(), so the code
  has been switched to use that instead.

- fix for potential races between delegation break callbacks and the
  laundromat has been added. We use the dl_time value as a way to mark
  whether a delegation has been queued to the nn->del_recall_lru list
  at least once. The fault injection code has some similar fixes in a
  token effort to make it less racy.

- put_client_renew now no longer needs to take the client_lock unless
  the refcount is going to zero. put_client also doesn't need the
  client_lock.

- fixed a bug in the error handling when nfs4_set_delegation returns
  error. The code tried to unhash a delegation that had never been
  hashed and could end up dereferencing a bogus sc_file pointer.

- a bug in the handling of the block_delegations call has been fixed.
  It needs to be called under the state_lock. I also added a lockdep
  assertion for that as well.

v3 changes:
- rebased on top of Bruce's for-3.17 branch

- addressed a number of Christoph's review comments. I've generally kept
  the Reviewed-by's intact when I thought I was changing things along the
  lines that he suggested, but please to glance over the results to be
  sure that I did.

- some more reordering of patches. Some more have been moved near the
  front when they don't depend on other changes. I've also tried to group
  them a little more logically so that patches that touch related areas
  are together.

- second pass at overhauling deny handling. This one should close all of
  the potential races with the fi_share_deny field. There are also a
  number of related cleanups to the deny handling.

- st_access_bmap and st_deny_bmap have been shrunk to a byte each, which
  should help reduce the stateid memory footprint.

- scrapped the Documentation/ file and moved most of its content into
  comments above the respective data structures.

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


This time, I'm just posting what hasn't already been merged into Bruce's
for-3.17 branch. I'll plan to keep the following branch updated with the
latest set:

    http://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-devel

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

Jeff Layton (52):
  nfsd: close potential race between delegation break and laundromat
  nfsd: reduce some spinlocking in put_client_renew
  nfsd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg
  nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
  nfsd: remove nfs4_file_put_fd
  nfsd: shrink st_access_bmap and st_deny_bmap
  nfsd: set stateid access and deny bits in nfs4_get_vfs_file
  nfsd: clean up reset_union_bmap_deny
  nfsd: always hold the fi_lock when bumping fi_access refcounts
  nfsd: make deny mode enforcement more efficient and close races in it
  nfsd: cleanup and rename nfs4_check_open
  locks: add file_has_lease to prevent delegation break races
  nfsd: nfs4_alloc_init_lease should take a nfs4_file arg
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Fix delegation revocation
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
  nfsd: clean up and reorganize release_lockowner
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
  nfsd: add some comments to the nfsd4 object definitions

Trond Myklebust (47):
  nfsd: Ensure stateids remain unique until they are freed
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
  nfsd: Add a mutex to protect the NFSv4.0 open owner replay cache
  nfsd: Add locking to the nfs4_file->fi_fds[] array
  nfsd: clean up helper __release_lock_stateid
  nfsd: Simplify stateid management
  nfsd: Add reference counting to the lock and open stateids
  nfsd: Add a struct nfs4_file field to struct nfs4_stid
  nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
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

 fs/locks.c             |   26 +
 fs/nfsd/fault_inject.c |  130 +--
 fs/nfsd/netns.h        |   15 +-
 fs/nfsd/nfs4callback.c |   28 +-
 fs/nfsd/nfs4proc.c     |   13 +-
 fs/nfsd/nfs4state.c    | 2547 ++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfs4xdr.c      |    2 -
 fs/nfsd/state.h        |  170 +++-
 fs/nfsd/xdr4.h         |    5 +-
 include/linux/fs.h     |    6 +
 10 files changed, 2040 insertions(+), 902 deletions(-)

-- 
1.9.3

