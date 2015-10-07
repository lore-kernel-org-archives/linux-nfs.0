Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44091 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbJGTSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 15:18:11 -0400
Date: Wed, 7 Oct 2015 15:18:09 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 4.3
Message-ID: <20151007191809.GA27164@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull an nfsd bugfix for 4.3 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.3-1

Just this one RDMA fix for now.--b.

Steve Wise (1):
      svcrdma: handle rdma read with a non-zero initial page offset

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
