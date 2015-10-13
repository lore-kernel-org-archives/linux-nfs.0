Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46968 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932310AbbJMSOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2015 14:14:50 -0400
Date: Tue, 13 Oct 2015 14:14:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [GIT PULL] more nfsd bugfixes for 4.3
Message-ID: <20151013181449.GA5190@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull two more nfsd bugfixes for 4.3 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.3-2

Two nfsd fixes, one for an RDMA crash, one for a pnfs/block protocol
bug.

--b.

Christoph Hellwig (1):
      nfsd/blocklayout: accept any minlength

Chuck Lever (1):
      svcrdma: Fix NFS server crash triggered by 1MB NFS WRITE

 fs/nfsd/blocklayout.c                   | 8 --------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 +-
 2 files changed, 1 insertion(+), 9 deletions(-)
