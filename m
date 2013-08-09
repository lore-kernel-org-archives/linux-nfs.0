Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030743Ab3HITBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Aug 2013 15:01:44 -0400
Date: Fri, 9 Aug 2013 15:01:40 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd fixes for 3.11
Message-ID: <20130809190140.GD10500@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some fixes for a 4.1 feature that in retrospect probably should have
waited for 3.12.... But it appears to be working now.  Please pull:

  git://linux-nfs.org/~bfields/linux.git for-3.11

--b.

----------------------------------------------------------------
J. Bruce Fields (1):
      nfsd4: Fix MACH_CRED NULL dereference

Weston Andros Adamson (1):
      nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID

 fs/nfsd/nfs4proc.c  |    2 +-
 fs/nfsd/nfs4state.c |    2 ++
 fs/nfsd/nfs4xdr.c   |    5 ++---
 3 files changed, 5 insertions(+), 4 deletions(-)
