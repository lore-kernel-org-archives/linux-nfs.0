Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbbAHT3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2015 14:29:19 -0500
Date: Thu, 8 Jan 2015 14:29:18 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.19
Message-ID: <20150108192918.GD14674@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull two nfsd bugfixes from

  git://linux-nfs.org/~bfields/linux.git for-3.19

--b.

----------------------------------------------------------------
J. Bruce Fields (1):
      rpc: fix xdr_truncate_encode to handle buffer ending on page boundary

Jeff Layton (1):
      nfsd: fix fi_delegees leak when fi_had_conflict returns true

 fs/nfsd/nfs4state.c | 2 +-
 net/sunrpc/xdr.c    | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)
