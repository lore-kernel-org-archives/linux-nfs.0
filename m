Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:54564 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbaG3M1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:27:45 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so1273565qgd.33
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:27:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 00/37] nfsd: remaining client_mutex removal patches
Date: Wed, 30 Jul 2014 08:27:01 -0400
Message-Id: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the remainder of the client_mutex removal patches,
which should be merged after the stateid and stateowner refcounting
overhaul. The main focus of this part is to ensure that the nfs4_client
refcounting is up to snuff and then to remove the client_mutex.

There's also a series in here that basically rewrites the fault
injection code. That rewrite has some significant holes in it (note the
WARN_ONs when the client refcount goes too high), but it should keep it
limping along for now.

FWIW, I think we should probably go ahead and mark the fault injection
code deprecated in the upcoming merge window and then plan to remove
it in 2-3 releases.

Jeff Layton (19):
  nfsd: Protect session creation and client confirm using client_lock
  nfsd: protect the close_lru list and oo_last_closed_stid with
    client_lock
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

Trond Myklebust (18):
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

 fs/nfsd/fault_inject.c | 130 +++----
 fs/nfsd/netns.h        |  14 +-
 fs/nfsd/nfs4proc.c     |   3 -
 fs/nfsd/nfs4state.c    | 922 +++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h        | 122 +++++--
 5 files changed, 836 insertions(+), 355 deletions(-)

-- 
1.9.3

