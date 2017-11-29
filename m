Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58840 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdK2UrX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 15:47:23 -0500
Date: Wed, 29 Nov 2017 15:47:23 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd fixes for 4.15
Message-ID: <20171129204723.GA7003@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd fixes for 4.15 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.15-1

I screwed up my merge window pull request; I only sent half of what I
meant to.

There were no new features, just bugfixes of various importance and some
very minor cleanup, so I think it's all still appropriate for -rc2.

--b.

----------------------------------------------------------------
Highlights:

	- Fixes from Trond for some races in the NFSv4 state code.
	- Fix from Naofumi Honda for a typo in the blocked lock
	  notificiation code.
	- Fixes from Vasily Averin for some problems starting and
	  stopping lockd especially in network namespaces.

----------------------------------------------------------------
Andrew Elble (2):
      nfsd: fix locking validator warning on nfs4_ol_stateid->st_mutex class
      nfsd: check for use of the closed special stateid

Bhumika Goyal (3):
      sunrpc: make the function arg as const
      NFSD: make cache_detail structures const
      SUNRPC: make cache_detail structures const

Naofumi Honda (1):
      nfsd: fix panic in posix_unblock_lock called from nfs4_laundromat

Trond Myklebust (8):
      nfsd: Fix stateid races between OPEN and CLOSE
      nfsd: Fix another OPEN stateid race
      nfsd: CLOSE SHOULD return the invalid special stateid for NFSv4.x (x>0)
      nfsd: Ensure we don't recognise lock stateids after freeing them
      nfsd4: move find_lock_stateid
      nfsd: Fix race in lock stateid creation
      nfsd: Ensure we check stateid validity in the seqid operation checks
      nfsd: Fix races with check_stateid_generation()

Vasily Averin (9):
      nfsd: remove net pointer from debug messages
      lockd: remove net pointer from messages
      grace: replace BUG_ON by WARN_ONCE in exit_net hook
      lockd: added cleanup checks in exit_net hook
      lockd: lost rollback of set_grace_period() in lockd_down_net()
      race of lockd inetaddr notifiers vs nlmsvc_rqst change
      race of nfsd inetaddr notifiers vs nn->nfsd_serv change
      nlm_shutdown_hosts_net() cleanup
      lockd: fix "list_add double add" caused by legacy signal interface

 fs/lockd/host.c                   |  24 ++--
 fs/lockd/mon.c                    |   3 +-
 fs/lockd/svc.c                    |  38 +++++-
 fs/lockd/svcsubs.c                |   2 +-
 fs/nfs_common/grace.c             |  10 +-
 fs/nfsd/export.c                  |  10 +-
 fs/nfsd/netns.h                   |   3 +
 fs/nfsd/nfs4idmap.c               |   4 +-
 fs/nfsd/nfs4state.c               | 279 +++++++++++++++++++++++++-------------
 fs/nfsd/nfsctl.c                  |   3 +
 fs/nfsd/nfssvc.c                  |  14 +-
 include/linux/sunrpc/cache.h      |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c |   4 +-
 net/sunrpc/cache.c                |   2 +-
 net/sunrpc/svcauth_unix.c         |   4 +-
 15 files changed, 270 insertions(+), 132 deletions(-)
