Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35119 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3FZTVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/7] miscellaneous nfsd bugfixes
Date: Wed, 26 Jun 2013 15:21:20 -0400
Message-Id: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These are fixes for some miscellaneous bugs found at the bakeathon, to
be queued for 3.11.

--b.

J. Bruce Fields (7):
  nfsd4: fix decoding across page boundaries
  nfsd4: minor read_buf cleanup
  svcrpc: fix handling of too-short rpc's
  svcrpc: don't error out on small tcp fragment
  nfsd4: delegation-based open reclaims should bypass permissions
  nfsd4: do not throw away 4.1 lock state on last unlock
  nfsd4: return delegation immediately if lease fails

 fs/nfsd/nfs4proc.c   |  3 ++-
 fs/nfsd/nfs4state.c  | 13 ++++---------
 fs/nfsd/nfs4xdr.c    | 24 ++++++++++++++----------
 net/sunrpc/svcsock.c |  9 +++++++--
 4 files changed, 27 insertions(+), 22 deletions(-)

-- 
1.8.1.4

