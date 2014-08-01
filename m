Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35622 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbaHAUZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 16:25:34 -0400
Date: Fri, 1 Aug 2014 16:25:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v3 00/38] nfsd: stateid and stateowner refcounting
 overhaul
Message-ID: <20140801202529.GE24461@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 09:34:05PM -0400, Jeff Layton wrote:
> v3:
> - fix intermediate regression in nfsd4_close_open_stateid

These all look OK to me; applying for 3.17.--b.

> 
> v2:
> - rename functions from *_generic_stateid to *_ol_stateid
> - eliminate some nfs4_put_* wrappers around nfs4_put_stid
> - clean up lock stateid allocation and initialization
> - reorder patches to reduce churn
> - handle open/lock stateids individually in nfsd4_free_stateid
> - add ops struct for stateowners
> - combine v4.0 replay cache patches
> 
> Here is the next swath of patches for the nfsd client_mutex removal
> series. The main focus of this series is to add refcounting to open and
> lock stateids and to use those to drive their management and eventual
> destruction. Additionally, we add refcounting to the open and lock
> stateowners and use that refcount to manage their lifecycle as well.
> 
> Most of the new locking here is superfluous until we remove the
> client_mutex. This series should apply cleanly to Bruce's for-3.17
> branch now that the delegation patches have been merged.
> 
> Jeff Layton (20):
>   nfsd: Cleanup the freeing of stateids
>   nfsd4: use cl_lock to synchronize all stateid idr calls
>   nfsd: do filp_close in sc_free callback for lock stateids
>   nfsd: Add locking to protect the state owner lists
>   nfsd: clean up races in lock stateid searching and creation
>   nfsd: ensure atomicity in nfsd4_free_stateid and
>     nfsd4_validate_stateid
>   nfsd: Add reference counting to state owners
>   nfsd: Add a mutex to protect the NFSv4.0 open owner replay cache
>   nfsd: clean up lockowner refcounting when finding them
>   nfsd: add an operation for unhashing a stateowner
>   nfsd: clean up refcounting for lockowners
>   nfsd: make openstateids hold references to their openowners
>   nfsd: don't allow CLOSE to proceed until refcount on stateid drops
>   nfsd: clean up and reorganize release_lockowner
>   nfsd: add locking to stateowner release
>   nfsd: optimize destroy_lockowner cl_lock thrashing
>   nfsd: close potential race in nfsd4_free_stateid
>   nfsd: reduce cl_lock thrashing in release_openowner
>   nfsd: don't thrash the cl_lock while freeing an open stateid
>   nfsd: rename unhash_generic_stateid to unhash_ol_stateid
> 
> Trond Myklebust (18):
>   nfsd: Add reference counting to the lock and open stateids
>   nfsd: Add a struct nfs4_file field to struct nfs4_stid
>   nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
>   nfsd: Add reference counting to lock stateids
>   nfsd: nfsd4_locku() must reference the lock stateid
>   nfsd: Ensure that nfs4_open_delegation() references the delegation
>     stateid
>   nfsd: nfsd4_process_open2() must reference the delegation stateid
>   nfsd: nfsd4_process_open2() must reference the open stateid
>   nfsd: Prepare nfsd4_close() for open stateid referencing
>   nfsd: nfsd4_open_confirm() must reference the open stateid
>   nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
>   nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
>   nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
>   nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
>   nfsd: Make lock stateid take a reference to the lockowner
>   nfsd: Protect adding/removing open state owners using client_lock
>   nfsd: Protect adding/removing lock owners using client_lock
>   nfsd: Move the open owner hash table into struct nfs4_client
> 
>  fs/nfsd/netns.h        |    1 -
>  fs/nfsd/nfs4callback.c |    4 +-
>  fs/nfsd/nfs4proc.c     |   12 +-
>  fs/nfsd/nfs4state.c    | 1014 +++++++++++++++++++++++++++++++-----------------
>  fs/nfsd/nfs4xdr.c      |    2 -
>  fs/nfsd/state.h        |   32 +-
>  fs/nfsd/xdr4.h         |    5 +-
>  7 files changed, 695 insertions(+), 375 deletions(-)
> 
> -- 
> 1.9.3
> 
