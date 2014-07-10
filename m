Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:59459 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaGJSHo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:44 -0400
Received: by mail-qa0-f45.google.com with SMTP id s7so3431146qap.32
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 00/11] nfsd: deny mode handling overhaul
Date: Thu, 10 Jul 2014 14:07:24 -0400
Message-Id: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the deny mode handling overhaul broken out into a separate
series, as requested by Christoph. I've tried to address most of
his review comments, but I may have missed some. Let me know if
if I did.

Part of the client_mutex removal series involves cleaning up the
handling of deny modes in the server in order to setting and
enforcement atomic.

This does add a new per-nfs4_file spinlock, but in principle it
should never be contended while the client_mutex is still wrapped
around all of this code.

Jeff Layton (8):
  nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
  nfsd: remove nfs4_file_put_fd
  nfsd: shrink st_access_bmap and st_deny_bmap
  nfsd: set stateid access and deny bits in nfs4_get_vfs_file
  nfsd: clean up reset_union_bmap_deny
  nfsd: always hold the fi_lock when bumping fi_access refcounts
  nfsd: make deny mode enforcement more efficient and close races in it
  nfsd: cleanup and rename nfs4_check_open

Trond Myklebust (3):
  nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
  nfsd: Add locking to the nfs4_file->fi_fds[] array
  nfsd: clean up helper __release_lock_stateid

 fs/nfsd/nfs4state.c | 437 ++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h     |  32 +---
 2 files changed, 325 insertions(+), 144 deletions(-)

-- 
1.9.3

