Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45537 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982Ab3IJPaX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 11:30:23 -0400
Date: Tue, 10 Sep 2013 11:30:23 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.12
Message-ID: <20130910153022.GF16011@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd changes for 3.12 are available from

  git://linux-nfs.org/~bfields/linux.git nfsd-next

This was a very quiet cycle!  Just a few bugfixes and some cleanup.

--b.

----------------------------------------------------------------
Harshula Jayasuriya (2):
      nfsd: nfs4_file_get_access: need to be more careful with O_RDWR
      sunrpc: prepare NFS for 2038

J. Bruce Fields (10):
      nfsd4: fix setlease error return
      Merge tag 'v3.11-rc5' into for-3.12 branch
      Revert "nfsd: nfs4_file_get_access: need to be more careful with O_RDWR"
      nfsd4: fix leak of inode reference on delegation failure
      nfsd4: nfsd4_create_clid_dir prints uninitialized data
      svcrpc: remove unused rq_resused
      rpc: clean up decoding of gssproxy linux creds
      rpc: comment on linux_cred encoding, treat all as unsigned
      rpc: fix huge kmalloc's in gss-proxy
      rpc: let xdr layer allocate gssproxy receieve pages

 fs/nfsd/nfs4recover.c                |    2 --
 fs/nfsd/nfs4state.c                  |   33 +++++++++++++++++----------
 include/linux/sunrpc/cache.h         |   22 ++++++++++++++++--
 include/linux/sunrpc/svc.h           |    1 -
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   26 +++++++++++++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.c    |   41 +++++++++++++++++-----------------
 net/sunrpc/auth_gss/gss_rpc_xdr.h    |    5 ++++-
 7 files changed, 91 insertions(+), 39 deletions(-)
