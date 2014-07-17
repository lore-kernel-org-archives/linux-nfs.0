Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:39317 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905AbaGQTMm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 15:12:42 -0400
Received: by mail-qc0-f179.google.com with SMTP id r5so2453964qcx.38
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 12:12:41 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/6] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Thu, 17 Jul 2014 15:12:28 -0400
Message-Id: <1405624354-22388-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- use alternate method for checking for delegation break races after
  getting a lease (just check fi_had_conflict instead)

- drop file_has_lease patch -- no longer needed

- move cl_revoked handling patch into this set. It means altering a
  few of the later patches, but it keeps the set more topically
  coherent

v2:
- move remove_stid call from nfs4_free_stid and into callers

Here's a respin of the delegation fixes that Bruce hasn't yet merged
into his nfsd-next branch. I think this should address most of the
review comments so far.

I'm still not 100% thrilled with the delegation handling as a whole, but
I think it's getting a bit tighter now. I tend to think that we'll need
to rework this at some point in the future (and maybe the generic lease
code as well). I'd prefer to wait until after the rest of the
scalability work is complete before doing that if possible though.

Jeff Layton (3):
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Fix delegation revocation
  nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock

Trond Myklebust (3):
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: simplify stateid allocation and file handling
  nfsd: Convert delegation counter to an atomic_long_t type

 fs/nfsd/nfs4state.c | 148 +++++++++++++++++++++++++++++++++-------------------
 fs/nfsd/state.h     |   2 +-
 2 files changed, 96 insertions(+), 54 deletions(-)

-- 
1.9.3

