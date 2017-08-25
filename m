Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37954 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756031AbdHYRXv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 13:23:51 -0400
Date: Fri, 25 Aug 2017 13:23:50 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] second set of 4.13 nfsd bugfixes
Message-ID: <20170825172350.GA28124@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.13-2

Two nfsd bugfixes, neither 4.13 regressions, but both potentially
serious.

--b.

Chuck Lever (1):
      nfsd: Limit end of page list when decoding NFSv4 WRITE

Vadim Lomovtsev (1):
      net: sunrpc: svcsock: fix NULL-pointer exception

 fs/nfsd/nfs4xdr.c    |  6 ++----
 net/sunrpc/svcsock.c | 22 ++++++++++++++++++++--
 2 files changed, 22 insertions(+), 6 deletions(-)
