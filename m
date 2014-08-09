Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59997 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbaHITqy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Aug 2014 15:46:54 -0400
Date: Sat, 9 Aug 2014 15:46:53 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PULL] nfsd changes for 3.17
Message-ID: <20140809194652.GA30553@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.17 from

  git://linux-nfs.org/~bfields/linux.git for-3.17

This includes a major rewrite of the NFSv4 state code, which has always
depended on a single mutex.  As an example, open creates are no longer
serialized, fixing a performance regression on NFSv3->NFSv4 upgrades.
Thanks to Jeff, Trond, and Benny, and to Christoph for review.

Also some RDMA fixes from Chuck Lever and Steve Wise, and miscellaneous
fixes from Kinglong Mee and others.

--b.

----------------------------------------------------------------
Christoph Hellwig (1):
      nfsd: fix file access refcount leak when nfsd4_truncate fails

Chuck Lever (3):
      svcrdma: Select NFSv4.1 backchannel transport based on forward channel
      svcrdma: Add zero padding if the client doesn't send it
      svcrdma: Double the default credit limit

Himangi Saraogi (1):
      nfsd4: convert comma to semicolon

J. Bruce Fields (11):
      nfsd: fix rare symlink decoding bug
      nfsd: make NFSv2 null terminate symlink data
      nfsd: let nfsd_symlink assume null-terminated data
      nfsd4: rename cr_linkname->cr_data
      nfsd4: remove unused defer_free argument
      nfsd4: define svcxdr_dupstr to share some common code
      nfsd4: remove nfs4_acl_new
      nfsd4: replace defer_free by svcxdr_tmpalloc
      nfsd4: zero op arguments beyond the 8th compound op
      nfsd4: CREATE_SESSION should update backchannel immediately
      nfsd4: fix out of date comment

Jeff Layton (77):
      nfsd: add __force to opaque verifier field casts
      nfsd: clean up sparse endianness warnings in nfscache.c
      nfsd: nfsd_splice_read and nfsd_readv should return __be32
      nfsd: add appropriate __force directives to filehandle generation code
      nfsd: fix return of nfs4_acl_write_who
      nfsd: properly handle embedded newlines in fault_injection input
      nfsd: add a new /proc/fs/nfsd/max_connections file
      nfsd: declare v4.1+ openowners confirmed on creation
      nfsd: Allow lockowners to hold several stateids
      nfsd: clean up nfsd4_release_lockowner
      nfsd: properly convert return from commit_metadata to __be32
      nfsd: add a nfserrno mapping for -E2BIG to nfserr_fbig
      nfsd: Allow struct nfsd4_compound_state to cache the nfs4_client
      nfsd: close potential race between delegation break and laundromat
      nfsd: reduce some spinlocking in put_client_renew
      nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
      nfsd: remove nfs4_file_put_fd
      nfsd: shrink st_access_bmap and st_deny_bmap
      nfsd: set stateid access and deny bits in nfs4_get_vfs_file
      nfsd: clean up reset_union_bmap_deny
      nfsd: always hold the fi_lock when bumping fi_access refcounts
      nfsd: make deny mode enforcement more efficient and close races in it
      nfsd: cleanup and rename nfs4_check_open
      nfsd: eliminate nfsd4_init_callback
      nfsd: Avoid taking state_lock while holding inode lock in nfsd_break_one_deleg
      nfsd: nfs4_alloc_init_lease should take a nfs4_file arg
      nfsd: silence sparse warning about accessing credentials
      nfsd: fix race that grants unrecallable delegation
      nfsd: bump dl_time when unhashing delegation
      nfsd: ensure that st_access_bmap and st_deny_bmap are initialized to 0
      nfsd: Do not let nfs4_file pin the struct inode
      nfsd: fully unhash delegations when revoking them
      nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
      nfsd: drop unused stp arg to alloc_init_deleg
      nfsd: clean up arguments to nfs4_open_delegation
      nfsd: clean up nfs4_set_delegation
      nfsd: give block_delegation and delegation_blocked its own spinlock
      nfsd: remove dl_fh field from struct nfs4_delegation
      nfsd: print status when nfsd4_open fails to open file it just created
      nfsd4: use cl_lock to synchronize all stateid idr calls
      nfsd: do filp_close in sc_free callback for lock stateids
      nfsd: Add locking to protect the state owner lists
      nfsd: clean up races in lock stateid searching and creation
      nfsd: ensure atomicity in nfsd4_free_stateid and nfsd4_validate_stateid
      nfsd: Add reference counting to state owners
      nfsd: Add a mutex to protect the NFSv4.0 open owner replay cache
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
      nfsd: rename unhash_generic_stateid to unhash_ol_stateid
      nfsd: Protect session creation and client confirm using client_lock
      nfsd: protect the close_lru list and oo_last_closed_stid with client_lock
      nfsd: move unhash_client_locked call into mark_client_expired_locked
      nfsd: don't destroy client if mark_client_expired_locked fails
      nfsd: don't destroy clients that are busy
      nfsd: protect clid and verifier generation with client_lock
      nfsd: abstract out the get and set routines into the fault injection ops
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

Kinglong Mee (11):
      NFSD: Using min/max/min_t/max_t for calculate
      SUNRPC/NFSD: Change to type of bool for rq_usedeferral and rq_splice_ok
      NFSD: Using path_get when assigning path for export
      NFSD: Using exp_get for export getting
      NFSD: Avoid warning message when compile at i686 arch
      NFSD: Remove iattr parameter from nfsd_symlink()
      NFSD: Fix memory leak in encoding denied lock
      NFSD: Check acl returned from get_acl/posix_acl_from_mode
      NFSD: Fix bad checking of space for padding in splice read
      NFSD: Decrease nfsd_users in nfsd_startup_generic fail
      NFSD: Put the reference of nfs4_file when freeing stid

Steve Wise (2):
      svcrdma: send_write() must not overflow the device's max sge
      svcrdma: remove rdma_create_qp() failure recovery logic

Trond Myklebust (61):
      nfsd: Protect addition to the file_hashtbl
      nfsd: Ensure that nfsd_create_setattr commits files to stable storage
      nfsd: nfs4_preprocess_seqid_op should only set *stpp on success
      nfsd: Cleanup nfs4svc_encode_compoundres
      nfsd: clean up nfsd4_close_open_stateid
      nfsd: lock owners are not per open stateid
      nfsd: NFSv4 lock-owners are not associated to a specific file
      nfsd: Don't get a session reference without a client reference
      nfsd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
      nfsd: Convert nfsd4_process_open1() to work with lookup_clientid()
      nfsd: Always use lookup_clientid() in nfsd4_process_open1
      nfsd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
      nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
      nfsd: Add locking to the nfs4_file->fi_fds[] array
      nfsd: clean up helper __release_lock_stateid
      nfsd: Ensure stateids remain unique until they are freed
      SUNRPC: xdr_get_next_encode_buffer should be declared static
      nfsd: Move the delegation reference counter into the struct nfs4_stid
      nfsd: Store the filehandle with the struct nfs4_file
      nfsd: Use the filehandle to look up the struct nfs4_file instead of inode
      nfsd: nfs4_check_fh - make it actually check the filehandle
      nfsd: simplify stateid allocation and file handling
      nfsd: Convert delegation counter to an atomic_long_t type
      SUNRPC: Reduce contention in svc_xprt_enqueue()
      SUNRPC: svc_tcp_write_space: don't clear SOCK_NOSPACE prematurely
      SUNRPC: Allow svc_reserve() to notify TCP socket that space has been freed
      nfsd: Add reference counting to the lock and open stateids
      nfsd: Add a struct nfs4_file field to struct nfs4_stid
      nfsd: Add reference counting to lock stateids
      nfsd: nfsd4_locku() must reference the lock stateid
      nfsd: Ensure that nfs4_open_delegation() references the delegation stateid
      nfsd: nfsd4_process_open2() must reference the delegation stateid
      nfsd: nfsd4_process_open2() must reference the open stateid
      nfsd: Prepare nfsd4_close() for open stateid referencing
      nfsd: nfsd4_open_confirm() must reference the open stateid
      nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
      nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
      nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
      nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
      nfsd: Make lock stateid take a reference to the lockowner
      nfsd: Protect adding/removing open state owners using client_lock
      nfsd: Protect adding/removing lock owners using client_lock
      nfsd: Move the open owner hash table into struct nfs4_client
      nfsd: Ensure struct nfs4_client is unhashed before we try to destroy it
      nfsd: Ensure that the laundromat unhashes the client before releasing locks
      nfsd: Don't require client_lock in free_client
      nfsd: Move create_client() call outside the lock
      nfsd: Protect unconfirmed client creation using client_lock
      nfsd: Protect nfsd4_destroy_clientid using client_lock
      nfsd: Ensure lookup_clientid() takes client_lock
      nfsd: Add lockdep assertions to document the nfs4_client/session locking
      nfsd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
      nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
      nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
      nfsd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
      nfsd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
      nfsd: Remove nfs4_lock_state(): nfsd4_delegreturn()
      nfsd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
      nfsd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
      nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
      nfsd: Remove nfs4_lock_state(): reclaim_complete()

 fs/nfsd/acl.h                            |    2 +-
 fs/nfsd/auth.c                           |    2 +-
 fs/nfsd/export.c                         |    6 +-
 fs/nfsd/export.h                         |    3 +-
 fs/nfsd/fault_inject.c                   |  138 +-
 fs/nfsd/netns.h                          |   23 +-
 fs/nfsd/nfs2acl.c                        |    8 +-
 fs/nfsd/nfs3acl.c                        |    8 +-
 fs/nfsd/nfs3proc.c                       |    9 +-
 fs/nfsd/nfs3xdr.c                        |   30 +-
 fs/nfsd/nfs4acl.c                        |   39 +-
 fs/nfsd/nfs4callback.c                   |   32 +-
 fs/nfsd/nfs4proc.c                       |   62 +-
 fs/nfsd/nfs4state.c                      | 3100 ++++++++++++++++++++----------
 fs/nfsd/nfs4xdr.c                        |  123 +-
 fs/nfsd/nfscache.c                       |   13 +-
 fs/nfsd/nfsctl.c                         |   51 +-
 fs/nfsd/nfsfh.c                          |   12 +-
 fs/nfsd/nfsfh.h                          |   15 +-
 fs/nfsd/nfsproc.c                        |   13 +-
 fs/nfsd/nfssvc.c                         |   21 +-
 fs/nfsd/nfsxdr.c                         |   14 +-
 fs/nfsd/state.h                          |  220 ++-
 fs/nfsd/vfs.c                            |   48 +-
 fs/nfsd/vfs.h                            |    8 +-
 fs/nfsd/xdr4.h                           |   30 +-
 include/linux/cred.h                     |    9 +
 include/linux/sunrpc/svc.h               |    4 +-
 include/linux/sunrpc/svc_rdma.h          |    3 +-
 include/linux/sunrpc/svc_xprt.h          |    2 +
 net/sunrpc/auth_gss/svcauth_gss.c        |    2 +-
 net/sunrpc/svc.c                         |    4 +-
 net/sunrpc/svc_xprt.c                    |   27 +-
 net/sunrpc/svcsock.c                     |   50 +-
 net/sunrpc/xdr.c                         |    3 +-
 net/sunrpc/xprt.c                        |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   28 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   39 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 +-
 39 files changed, 2755 insertions(+), 1468 deletions(-)
