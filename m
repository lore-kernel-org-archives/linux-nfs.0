Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54542 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbdFAUbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 16:31:32 -0400
Date: Thu, 1 Jun 2017 16:31:31 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes
Message-ID: <20170601203131.GA10086@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull a couple nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.12-1

Revert patch accidentally included in the merge window pull request, and
fix a crash that was likely a result of buggy client behavior.

--b.

J. Bruce Fields (2):
      nfsd: Revert "nfsd: check for oversized NFSv2/v3 arguments"
      nfsd4: fix null dereference on replay

 fs/nfsd/nfs3xdr.c          | 23 ++++++-----------------
 fs/nfsd/nfs4proc.c         | 13 ++++++-------
 fs/nfsd/nfsxdr.c           | 13 +++----------
 include/linux/sunrpc/svc.h |  3 ++-
 4 files changed, 17 insertions(+), 35 deletions(-)
