Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:49156 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbaG2Uea (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:30 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so293152qge.18
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 00/38] nfsd: stateid and stateowner refcounting overhaul
Date: Tue, 29 Jul 2014 16:33:43 -0400
Message-Id: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- rename functions from *_generic_stateid to *_ol_stateid
- eliminate some nfs4_put_* wrappers around nfs4_put_stid
- clean up lock stateid allocation and initialization
- reorder patches to reduce churn
- handle open/lock stateids individually in nfsd4_free_stateid
- add ops struct for stateowners
- combine v4.0 replay cache patches

Here is the next swath of patches for the nfsd client_mutex removal
series. The main focus of this series is to add refcounting to open and
lock stateids and to use those to drive their management and eventual
destruction. Additionally, we add refcounting to the open and lock
stateowners and use that refcount to manage their lifecycle as well.

Most of the new locking here is superfluous until we remove the
client_mutex. This series should apply cleanly to Bruce's for-3.17
branch now that the delegation patches have been merged.

Jeff Layton (20):
  nfsd: Cleanup the freeing of stateids
  nfsd4: use cl_lock to synchronize all stateid idr calls
  nfsd: do filp_close in sc_free callback for lock stateids
  nfsd: Add locking to protect the state owner lists
  nfsd: clean up races in lock stateid searching and creation
  nfsd: ensure atomicity in nfsd4_free_stateid and
    nfsd4_validate_stateid
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

Trond Myklebust (18):
  nfsd: Add reference counting to the lock and open stateids
  nfsd: Add a struct nfs4_file field to struct nfs4_stid
  nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
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
  nfsd: Make lock stateid take a reference to the lockowner
  nfsd: Protect adding/removing open state owners using client_lock
  nfsd: Protect adding/removing lock owners using client_lock
  nfsd: Move the open owner hash table into struct nfs4_client

 fs/nfsd/netns.h        |    1 -
 fs/nfsd/nfs4callback.c |    4 +-
 fs/nfsd/nfs4proc.c     |   12 +-
 fs/nfsd/nfs4state.c    | 1014 +++++++++++++++++++++++++++++++-----------------
 fs/nfsd/nfs4xdr.c      |    2 -
 fs/nfsd/state.h        |   32 +-
 fs/nfsd/xdr4.h         |    5 +-
 7 files changed, 695 insertions(+), 375 deletions(-)

-- 
1.9.3

