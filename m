Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37079 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbaDRSpG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:06 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so941918igb.15
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/70] NFSd lock scalability patches
Date: Fri, 18 Apr 2014 14:43:54 -0400
Message-Id: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

In accordance with the traditional Good Friday theme of "suffering", here
is the first draft of the NFSd lock scalability patches for your perusal.
I've only done light testing so far, but since there is a total of 70
patches to review, I figured you might want to start sooner rather than
waiting for the QA folks to finish testing.

During the process, I did notice a bug or two in the existing NFSd code,
and so the first 3 patches are bugfixes that you may want to apply
irrespectively.

In general, what I've tried to do is add reference counting wherever
there is a need to carry structures around outside locks, and to
ensure that we make structures invisible to lookups before we attempt
to free them.

There are still a few optimisations that might be worth considering in
order to reduce the frequency of global locks that are taken. Suggestions
include:
1) Caching the nfs4_client in the struct nfsd4_compound_state
2) Caching the current/save_stateid as references to the actual nfs4_stid in the struct nfsd4_compound_state
3) Converting the stateid/sessionid/clientid global table lookups to use RCU.
4) Converting the file_hashtbl lookups to use RCU

Cheers
  Trond

Benny Halevy (4):
  nfsd4: rename recall_lock to state_lock
  nfsd4: use cl_lock to synchronize all stateid idr calls
  nfsd4: hash deleg stateid only on successful nfs4_set_delegation
  nfsd4: use state_lock for delegation hashing

Trond Myklebust (66):
  NFSd: Ensure we clear the cstate->slot in nfsd4_proc_compound
  NFSd: Move default initialisers from create_client() to alloc_client()
  NFSd: call rpc_destroy_wait_queue() from free_client()
  NFSd: Remove 'inline' designation for free_client()
  NFSd: Mark nfs4_free_lockowner and nfs4_free_openowner as static
    functions
  NFSd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg
  NFSd: Ensure delegation setup is safe w.r.t. break_lease()
  NFSd: Add fine grained protection for the nfs4_file->fi_stateids list
  NFSd: Clean up nfs4_preprocess_stateid_op
  NFSd: Add a mutex to protect the NFSv4.0 open owner replay cache
  NFSd: Add locking to the nfs4_file->fi_fds[] array
  NFSd: Protect the nfs4_file delegation fields using the fi_lock
  NFSd: Lock owners are not per open stateid
  NFSd: Clean up helper __release_lock_stateid
  NFSd: Allow lockowners to hold several stateids
  NFSd: NFSv4 lock-owners are not associated to a specific file
  NFSd: Get rid of the lockowner_ino_hashtbl
  NFSd: Cleanup nfs4svc_encode_compoundres
  NFSd: Don't get a session reference without a client reference
  NFSd: Move the delegation reference counter into the struct nfs4_stid
  NFSd: Simplify stateid management
  NFSd: Fix delegation revocation
  NFSd: Don't let the laundromat reap clients that are referenced
  NFSd: Add reference counting to the lock and open stateids
  NFSd: Add a struct nfs4_file field to struct nfs4_stid
  NFSd: Replace delegation->dl_file with the dl_stid.sc_file
  NFSd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
  NFSd: Ensure stateids remain unique until they are freed
  NFSd: Ensure atomicity of stateid destruction and idr tree removal
  NFSd: Fix atomicity of delegation counter
  NFSd: Slight cleanup of find_stateid()
  NFSd: Add reference counting to find_stateid
  NFSd: nfs4_preprocess_seqid_op should only set *stpp on success
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
  NFSd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
  NFSd: Use the session->se_client  in lookup_clientid()
  NFSd: Convert nfsd4_process_open1() to work with lookup_clientid()
  NFSd: Convert nfs4_check_open_reclaim() to work with lookup_clientid()
  NFSd: Ensure struct nfs4_client is unhashed before we try to destroy
    it
  NFSd: Ensure that the laundromat unhashes the client before releasing
    locks
  NFSd: Don't require client_lock in free_client
  NFSd: Move create_client() call outside the lock
  NFSd: Protect unconfirmed client creation using client_lock
  NFSd: Protect session creation and client confirm using client_lock
  NFSd: Protect nfsd4_destroy_clientid using client_lock
  NFSd: Ensure lookup_clientid() takes client_lock
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

 fs/nfsd/netns.h        |    4 -
 fs/nfsd/nfs4callback.c |   18 +-
 fs/nfsd/nfs4proc.c     |   28 +-
 fs/nfsd/nfs4state.c    | 1239 ++++++++++++++++++++++++++++++------------------
 fs/nfsd/nfs4xdr.c      |   15 +-
 fs/nfsd/state.h        |   46 +-
 fs/nfsd/xdr4.h         |   21 +-
 7 files changed, 819 insertions(+), 552 deletions(-)

-- 
1.9.0

