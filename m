Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:59666 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757661AbaGOKhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 06:37:55 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so2383500qgd.26
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 03:37:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 0/7] nfsd: more delegation fixes to prepare for client_mutex removal
Date: Tue, 15 Jul 2014 06:37:42 -0400
Message-Id: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I know that the Christoph mentioned pushing out the open and lock
stateid changes next, but we need to finish up the delegation changes in
order to prepare for those. Most of these have been posted before, and
they should be merged on top of the two lm_break callback patches that I
posted yesterday.

Jeff Layton (4):
  nfsd: nfs4_alloc_init_lease should take a nfs4_file arg
  locks: add file_has_lease to prevent delegation break races
  nfsd: Protect the nfs4_file delegation fields using the fi_lock
  nfsd: Fix delegation revocation

Trond Myklebust (3):
  nfsd: Ensure stateids remain unique until they are freed
  nfsd: Move the delegation reference counter into the struct nfs4_stid
  nfsd: Simplify stateid management

 fs/locks.c          |  26 ++++++++++
 fs/nfsd/nfs4state.c | 134 +++++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |   3 +-
 include/linux/fs.h  |   6 +++
 4 files changed, 115 insertions(+), 54 deletions(-)

-- 
1.9.3

