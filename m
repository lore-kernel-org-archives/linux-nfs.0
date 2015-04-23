Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39955 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966016AbbDWPMG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2015 11:12:06 -0400
Date: Thu, 23 Apr 2015 11:12:05 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT] nfsd changes for 4.0
Message-ID: <20150423151205.GB22158@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.0 from:

  git://linux-nfs.org/~bfields/linux.git for-4.0

A quiet cycle this time; this is basically entirely bugfixes.  The few
that aren't cc'd to stable are cleanup or seemed unlikely to affect
anyone much.

--b.

----------------------------------------------------------------
Andreas Gruenbacher (1):
      uapi: Remove kernel internal declaration

Chengyu Song (1):
      nfsd: NFSD_FAULT_INJECTION depends on DEBUG_FS

Christoph Hellwig (1):
      nfsd: add NFSEXP_PNFS to the exflags array

Giuseppe Cantavenera (1):
      nfsd: fix nsfd startup race triggering BUG_ON

J. Bruce Fields (4):
      nfsd: allow setting acls with unenforceable DENYs
      nfsd4: disallow ALLOCATE with special stateids
      nfsd4: disallow SEEK with special stateids
      nfsd4: fix READ permission checking

Jeff Layton (2):
      nfsd: remove bogus setting of status in nfsd4_process_open2
      nfsd: remove unused status arg to nfsd4_cleanup_open_state

Kinglong Mee (3):
      NFSD: Using path_equal() for checking two paths
      NFSD: Use correct reply size calculating function
      nfsd: Remove duplicate macro define for max sec label length

Mark Salter (1):
      nfsd: eliminate NFSD_DEBUG

 fs/lockd/svcsubs.c               |  2 +-
 fs/nfsd/Kconfig                  |  2 +-
 fs/nfsd/export.c                 |  4 ++--
 fs/nfsd/nfs4acl.c                | 50 +---------------------------------------
 fs/nfsd/nfs4proc.c               | 12 ++++++----
 fs/nfsd/nfs4state.c              |  5 ++--
 fs/nfsd/nfs4xdr.c                | 16 ++++++++-----
 fs/nfsd/nfsctl.c                 | 16 ++++++-------
 fs/nfsd/nfsd.h                   |  2 +-
 fs/nfsd/xdr4.h                   |  3 +--
 include/linux/nfs4.h             |  7 ++++++
 include/uapi/linux/nfs4.h        |  7 ------
 include/uapi/linux/nfsd/debug.h  |  8 -------
 include/uapi/linux/nfsd/export.h |  3 +++
 14 files changed, 45 insertions(+), 92 deletions(-)
