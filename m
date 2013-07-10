Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab3GJDIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 23:08:36 -0400
Date: Tue, 9 Jul 2013 23:08:31 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.11
Message-ID: <20130710030831.GC15401@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.11 from the for-3.11 branch at

  git://linux-nfs.org/~bfields/linux.git for-3.11

Changes this time include:

	- 4.1 enabled on the server by default: the last 4.1-specific
	  issues I know of are fixed, so we're not going to find the
	  rest of the bugs without more exposure.
	- Experimental support for NFSv4.2 MAC Labeling (to allow
	  running selinux over NFS), from Dave Quigley.
	- Fixes for some delicate cache/upcall races that could cause
	  rare server hangs; thanks to Neil Brown and Bodo Stroesser for
	  extreme debugging persistence.
	- Fixes for some bugs found at the recent NFS bakeathon, mostly
	  v4 and v4.1-specific, but also a generic bug handling
	  fragmented rpc calls.

--b.

David Quigley (1):
      NFSD: Server implementation of MAC Labeling

J. Bruce Fields (21):
      nfsd4: store correct client minorversion for >=4.2
      security: cap_inode_getsecctx returning garbage
      sunrpc: server back channel needs no rpcbind method
      nfsd4: fix compile in !CONFIG_NFSD_V4_SECURITY_LABEL case
      Merge branch 'for-3.10' into 'for-3.11'
      svcrpc: introduce init_svc_cred
      svcrpc: store gss mech in svc_cred
      nfsd4: implement minimal SP4_MACH_CRED
      nfsd4: fail attempts to request gss on the backchannel
      nfsd4: allow client to send no cb_sec flavors
      nfsd4: clean up nfs4_open_delegation
      nfsd4: fix decoding of compounds across page boundaries
      nfsd4: minor read_buf cleanup
      svcrpc: fix handling of too-short rpc's
      svcrpc: don't error out on small tcp fragment
      nfsd4: delegation-based open reclaims should bypass permissions
      nfsd4: do not throw away 4.1 lock state on last unlock
      nfsd4: return delegation immediately if lease fails
      svcrpc: fix failures to handle -1 uid's
      nfsd4: allow destroy_session over destroyed session
      nfsd4: support minorversion 1 by default

Jim Rees (1):
      nfsd: avoid undefined signed overflow

NeilBrown (5):
      sunrpc/cache: remove races with queuing an upcall.
      sunrpc/cache: use cache_fresh_unlocked consistently and correctly.
      sunrpc/cache: ensure items removed from cache do not have pending upcalls.
      net/sunrpc: xpt_auth_cache should be ignored when expired.
      sunrpc: Don't schedule an upcall on a replaced cache entry.

Steve Dickson (3):
      NFS: Add NFSv4.2 protocol constants
      NFSDv4.2: Add NFS v4.2 support to the NFS server
      NFSD: Don't give out read delegations on creates

Zhao Hongjiang (1):
      nfsd: get rid of the unused functions in vfs

chaoting fan (1):
      sunrpc: the cache_detail in cache_is_valid is unused any more

 fs/nfsd/Kconfig                       |   16 +++
 fs/nfsd/nfs4proc.c                    |   44 ++++++-
 fs/nfsd/nfs4state.c                   |  225 ++++++++++++++++++++++-----------
 fs/nfsd/nfs4xdr.c                     |  169 ++++++++++++++++++++++---
 fs/nfsd/nfsd.h                        |   26 +++-
 fs/nfsd/nfssvc.c                      |    2 +-
 fs/nfsd/state.h                       |    1 +
 fs/nfsd/vfs.c                         |   28 ++++
 fs/nfsd/vfs.h                         |    7 +-
 fs/nfsd/xdr4.h                        |    4 +
 include/linux/nfs4.h                  |    9 ++
 include/linux/sunrpc/cache.h          |   49 ++++---
 include/linux/sunrpc/gss_api.h        |    2 +
 include/linux/sunrpc/svcauth.h        |   11 ++
 net/sunrpc/auth_gss/gss_mech_switch.c |    5 +-
 net/sunrpc/auth_gss/svcauth_gss.c     |   10 +-
 net/sunrpc/cache.c                    |   83 ++++++------
 net/sunrpc/svcauth_unix.c             |    6 +-
 net/sunrpc/svcsock.c                  |    9 +-
 net/sunrpc/xprtsock.c                 |    1 -
 security/capability.c                 |    2 +-
 21 files changed, 527 insertions(+), 182 deletions(-)
