Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36232 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbcHLViT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2016 17:38:19 -0400
Date: Fri, 12 Aug 2016 17:37:19 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] 4.8 nfsd bugfixes
Message-ID: <20160812213719.GC13096@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.8-1

----------------------------------------------------------------
Fixes for the dentry refcounting leak I introduced in 4.8-rc1, and for
races in the LOCK code which appear to go back to the big nfsd state
lock removal from 3.17.

----------------------------------------------------------------
Chuck Lever (1):
      nfsd: Fix race between FREE_STATEID and LOCK

Jeff Layton (1):
      nfsd: don't return an unhashed lock stateid after taking mutex

Josef Bacik (1):
      nfsd: fix dentry refcounting on create

 fs/nfsd/nfs4state.c | 65 +++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/vfs.c       |  9 +++++---
 2 files changed, 54 insertions(+), 20 deletions(-)
