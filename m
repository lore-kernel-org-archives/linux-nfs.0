Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:57082 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129AbaGUNfP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:35:15 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so5385895qge.16
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:35:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 00/10] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Mon, 21 Jul 2014 09:34:56 -0400
Message-Id: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Ok, I'm hoping we're now on the final respin here. This just cleans
up some nits that Christoph noticed in the last set. It also fixes
a potential bug that Neil noticed around the block_delegations
spinlocking.

Bruce, I noticed that you had merged the last set into your nfsd-next
branch, so let me know if you'd prefer me to do incremental changes
on top of that instead.

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

 fs/nfsd/nfs4state.c | 253 ++++++++++++++++++++++++++++++++--------------------
 fs/nfsd/state.h     |   2 +-
 2 files changed, 159 insertions(+), 96 deletions(-)

-- 
1.9.3

