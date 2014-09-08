Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60329 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826AbaIHRHd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Sep 2014 13:07:33 -0400
Date: Mon, 8 Sep 2014 13:07:32 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.17
Message-ID: <20140908170732.GA1776@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull a couple minor nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.17

--b.

----------------------------------------------------------------
J. Bruce Fields (2):
      nfsd4: fix rd_dircount enforcement
      lockd: fix rpcbind crash on lockd startup failure

 fs/lockd/svc.c    |  4 +---
 fs/nfsd/nfs4xdr.c | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 4 deletions(-)
