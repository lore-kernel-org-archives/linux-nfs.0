Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:44390 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbaGYLel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:41 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so4822745qga.8
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:40 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 0/9] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Fri, 25 Jul 2014 07:34:18 -0400
Message-Id: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v6:
- rebase on top of patches that change how struct nfs4_file is hashed

- add patch to remove the dl_fh field from struct nfs4_delegation

- fix a bug in forget_delegations fault injector

- update some changelogs to be more descriptive

v5:
- fix spinlocking in block_delegations. Lock should be held around all
  of the set_bit calls so we don't race with the swap of the two
  fields.

- eliminate destroy_revoked_delegation (just use nfs4_put_delegation)

- eliminate unneeded NULL pointer check in nfs4_setlease

v4:
- close more potential races in setlease code, and fix some bugs in
  error handling in that code.

- clean up delegation setting functions, eliminating unused arguments
  and avoiding allocations when there has already been a delegation
  break

- add separate spinlock for block_delegations/delegation_blocked code

v3:
- use alternate method for checking for delegation break races after
  getting a lease (just check fi_had_conflict instead)

- drop file_has_lease patch -- no longer needed

- move cl_revoked handling patch into this set. It means altering a
  few of the later patches, but it keeps the set more topically
  coherent

v2:
- move remove_stid call from nfs4_free_stid and into callers

Hopefully this series won't need much introduction now. This is the
delegation rework to prepare for client_mutex removal, now rebased on
top of the changes to nfs4_file hashing.

Jeff Layton (7):
  nfsd: fully unhash delegations when revoking them
  nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
  nfsd: drop unused stp arg to alloc_init_deleg
  nfsd: clean up arguments to nfs4_open_delegation
  nfsd: clean up nfs4_set_delegation
  nfsd: give block_delegation and delegation_blocked its own spinlock
  nfsd: remove dl_fh field from struct nfs4_delegation

Trond Myklebust (2):
  nfsd: simplify stateid allocation and file handling
  nfsd: Convert delegation counter to an atomic_long_t type

 fs/nfsd/nfs4callback.c |   2 +-
 fs/nfsd/nfs4state.c    | 180 +++++++++++++++++++++++++++----------------------
 fs/nfsd/state.h        |   1 -
 3 files changed, 99 insertions(+), 84 deletions(-)

-- 
1.9.3

