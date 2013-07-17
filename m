Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54556 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab3GQUev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:34:51 -0400
Date: Wed, 17 Jul 2013 16:34:45 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.11
Message-ID: <20130717203445.GC11977@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd fixes from

  git://linux-nfs.org/~bfields/linux.git for-3.11

Just three minor bugfixes.

--b.

----------------------------------------------------------------
Dan Carpenter (1):
      svcrdma: underflow issue in decode_write_list()

David Jeffery (1):
      lockd: protect nlm_blocked access in nlmsvc_retry_blocked

J. Bruce Fields (1):
      nfsd4: fix minorversion support interface

 fs/lockd/svclock.c                     |    4 ++++
 fs/nfsd/nfs4proc.c                     |    2 +-
 fs/nfsd/nfsd.h                         |    1 -
 fs/nfsd/nfssvc.c                       |   13 +++++++------
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |   20 ++++++++++++++------
 5 files changed, 26 insertions(+), 14 deletions(-)
