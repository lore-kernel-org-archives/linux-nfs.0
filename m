Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752139Ab1E2Ndt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 May 2011 09:33:49 -0400
Date: Sun, 29 May 2011 09:33:45 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for the kernel formerly to be known as 2.6.40
Message-ID: <20110529133345.GA7145@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following nfsd changes for whatever-version-it-turns-out-to-be are
available from the git repository at

  git://linux-nfs.org/~bfields/linux.git for-2.6.40

A bit of a quiet cycle again, mainly because I've gotten behind--I have
a few more 4.1 patches from Bryan to handle, and some bug reports to
look into.  The latter at least I may try to sneak into -rc2 if they seem
appropriate.

But this includes a forward-port of some tcp performance work from Olga
and Trond, some fixes to the v4/v4.1 server's security negotiation code,
and some 4.1 protocol conformance fixes from Andy Adamson and Mi
Jinlong.  The fix from Andy was for a server bug causing locking to fail
with new versions of the client.

--b.

Andy Adamson (1):
      nfsd v4.1 lOCKT clientid field must be ignored

Bryan Schumaker (3):
      NFSD: Remove setting unused variable in nfsd_vfs_read()
      NFSD: Check status from nfsd4_map_bcts_dir()
      NFSD: Remove unused variable from nfsd4_decode_bind_conn_to_session()

Daniel Mack (1):
      nfsd: make local functions static

J. Bruce Fields (10):
      svcrpc: note network-order types in svc_process_calldir
      svcrpc: close connection if client sends short packet
      SUNRPC: Don't wait for full record to receive tcp data
      Merge branch 'for-2.6.39' into for-2.6.40
      svcrpc: complete svsk processing on cb receive failure
      nfsd: distinguish functions of NFSD_MAY_* flags
      nfsd4: allow fh_verify caller to skip pseudoflavor checks
      nfsd4: introduce OPDESC helper
      nfsd4: make fh_verify responsibility of nfsd_lookup_dentry caller
      nfsd4: fix wrongsec handling for PUTFH + op cases

Mi Jinlong (4):
      nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1 correctly
      nfsd41: add flag checking for create_session
      nfsd41: compare request's opcnt with session's maxops at nfsd4_sequence
      nfsd41: error out on repeated RECLAIM_COMPLETE

Olga Kornievskaia (1):
      svcrpc: take advantage of tcp autotuning

Trond Myklebust (3):
      SUNRPC: requeue tcp socket less frequently
      SUNRPC: svc_tcp_recvfrom cleanup
      svcrpc: copy cb reply instead of pages

 fs/nfsd/export.c               |    6 -
 fs/nfsd/lockd.c                |    1 -
 fs/nfsd/nfs3proc.c             |    2 +-
 fs/nfsd/nfs3xdr.c              |    2 +-
 fs/nfsd/nfs4proc.c             |   73 ++++++++-
 fs/nfsd/nfs4state.c            |   42 ++++-
 fs/nfsd/nfs4xdr.c              |   11 +-
 fs/nfsd/nfsfh.c                |    2 +-
 fs/nfsd/vfs.c                  |   33 +++--
 fs/nfsd/vfs.h                  |    6 +-
 include/linux/nfs4.h           |    8 +-
 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |  336 ++++++++++++++++++++++------------------
 13 files changed, 323 insertions(+), 200 deletions(-)
