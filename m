Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:42820 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761695AbaGRPNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:43 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so3356038qgd.28
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/10] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Fri, 18 Jul 2014 11:13:26 -0400
Message-Id: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Yet another respin of the delegation rework to prepare for client_mutex
removal. This fixes all of the error handling bugs I could find and
should fix up the potential races between setting a delegation and
having it broken.

I also added some cleanup of the delegation setting code itself, moving
the allocation into the nfs4_set_delegation call, so that we can avoid
allocating one when we know there has already been a conflict.

Jeff Layton (7):
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Fix delegation revocation
  nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
  nfsd: drop unused stp arg to alloc_init_deleg
  nfsd: clean up arguments to nfs4_open_delegation
  nfsd: clean up nfs4_set_delegation
  nfsd: give block_delegation and delegation_blocked its own spinlock

Trond Myklebust (3):
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: simplify stateid allocation and file handling
  nfsd: Convert delegation counter to an atomic_long_t type

 fs/nfsd/nfs4state.c | 250 +++++++++++++++++++++++++++++++++-------------------
 fs/nfsd/state.h     |   2 +-
 2 files changed, 161 insertions(+), 91 deletions(-)

-- 
1.9.3

