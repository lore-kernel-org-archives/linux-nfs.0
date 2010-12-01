Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754328Ab0LADrq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 22:47:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fix more NFS readdir regressions
Date: Tue, 30 Nov 2010 22:47:11 -0500
Message-Id: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
References: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

OK. The first patch in this series fixes the regression reported by
Nick Bowler when I apply it to my setup.

The 2 remaining patches are needed in order to ensure that the
VM doesn't free the readdir page cache page while we're trying to
read from it, and to ensure that we don't leak memory...

Linus, please don't apply these patches quite yet. I'd like to continue
tests for a couple more days before I send you the pull request.

Cheers
  Trond

Trond Myklebust (3):
  NFS: Ensure we use the correct cookie in nfs_readdir_xdr_filler
  NFS: lock the readdir page while it is in use
  NFS: Fix a memory leak in nfs_readdir

 fs/nfs/dir.c           |   25 ++++++++++++++++++++++---
 fs/nfs/inode.c         |    1 +
 include/linux/nfs_fs.h |    1 +
 3 files changed, 24 insertions(+), 3 deletions(-)

-- 
1.7.3.2

