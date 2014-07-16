Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:32974 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934414AbaGPOcN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 10:32:13 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so788113qge.38
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 07:32:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/8] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Wed, 16 Jul 2014 10:31:55 -0400
Message-Id: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a respin of the delegation fixes that I sent yesterday. The main
change is to move the remove_stid calls into the caller in the second
patch instead of keeping it in nfs4_free_stid, per Christoph's
suggestion.

Unfortunately, that causes a pile of merge conflicts in the later
patches, so I need to resend the whole set.

I also include the patch that converts the num_delegations counter to an
atomic_long_t, as I missed that in the earlier series.

There is one more patch that fixes up handling of the cl_revoked list
that comes later, but it can't easily be moved here as it depends on
some locking changes that come later.

Jeff Layton (6):
  nfsd: eliminate nfsd4_init_callback
  nfsd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg
  nfsd: nfs4_alloc_init_lease should take a nfs4_file arg
  locks: add file_has_lease to prevent delegation break races
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Fix delegation revocation

Trond Myklebust (4):
  nfsd: Ensure stateids remain unique until they are freed
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: Simplify stateid management
  nfsd: Convert delegation counter to an atomic_long_t type

 fs/locks.c             |  26 +++++++
 fs/nfsd/nfs4callback.c |  23 ++++--
 fs/nfsd/nfs4state.c    | 197 +++++++++++++++++++++++++++++++------------------
 fs/nfsd/state.h        |   7 +-
 include/linux/fs.h     |   6 ++
 5 files changed, 179 insertions(+), 80 deletions(-)

-- 
1.9.3

