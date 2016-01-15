Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45294 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbcAOUqr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2016 15:46:47 -0500
Date: Fri, 15 Jan 2016 15:46:44 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.5
Message-ID: <20160115204644.GA4620@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for the 4.5 merge window from:

	git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.5

----------------------------------------------------------------
Smaller bugfixes and cleanup, including a fix for a failures of
kerberized NFSv4.1 mounts, and Scott Mayhew's work addressing ACK storms
that can affect some high-availability NFS setups.

----------------------------------------------------------------
Chuck Lever (1):
      svcrdma: Do not send XDR roundup bytes for a write chunk

Dan Carpenter (1):
      nfsd: fix a warning message

Geliang Tang (2):
      nfsd: use to_delayed_work
      lockd: use to_delayed_work

J. Bruce Fields (7):
      svcrpc: move some initialization to common code
      nfsd: helper for dup of possibly NULL string
      nfsd: minor consolidation of mach_cred handling code
      nfsd: fix unlikely NULL deref in mach_creds_match
      nfsd4: fix gss-proxy 4.1 mounts for some AD principals
      nfsd: don't base cl_cb_status on stale information
      Revert "svcrdma: Do not send XDR roundup bytes for a write chunk"

Jeff Layton (2):
      nfsd: give up on CB_LAYOUTRECALLs after two lease periods
      nfsd: add new io class tracepoint

Julia Lawall (3):
      nfsd: recover: constify nfsd4_client_tracking_ops structures
      nfsd: constify nfsd4_callback_ops structure
      lockd: constify nlmsvc_binding structure

Kinglong Mee (1):
      nfsd: Fix nfsd leaks sunrpc module references

Scott Mayhew (3):
      sunrpc: Add a function to close temporary transports immediately
      nfsd: Register callbacks on the inetaddr_chain and inet6addr_chain
      lockd: Register callbacks on the inetaddr_chain and inet6addr_chain

 fs/lockd/svc.c                       | 79 +++++++++++++++++++++++++++++++++---
 fs/nfsd/lockd.c                      |  2 +-
 fs/nfsd/netns.h                      |  2 +-
 fs/nfsd/nfs4callback.c               |  6 ++-
 fs/nfsd/nfs4layouts.c                | 39 ++++++++++++------
 fs/nfsd/nfs4recover.c                |  6 +--
 fs/nfsd/nfs4state.c                  | 65 +++++++++++++++++++++--------
 fs/nfsd/nfsfh.h                      | 23 +++++++++++
 fs/nfsd/nfssvc.c                     | 75 ++++++++++++++++++++++++++++++++--
 fs/nfsd/state.h                      |  4 +-
 fs/nfsd/trace.h                      | 41 +++++++++++++++++++
 fs/nfsd/vfs.c                        | 15 +++++++
 include/linux/lockd/bind.h           |  2 +-
 include/linux/sunrpc/svc_xprt.h      |  1 +
 include/linux/sunrpc/svcauth.h       |  9 +++-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  3 ++
 net/sunrpc/svc_xprt.c                | 45 ++++++++++++++++++++
 net/sunrpc/svcauth.c                 |  2 +
 net/sunrpc/svcauth_unix.c            |  8 ----
 19 files changed, 370 insertions(+), 57 deletions(-)
