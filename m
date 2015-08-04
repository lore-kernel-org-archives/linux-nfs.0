Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbbHDVJ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2015 17:09:59 -0400
Date: Tue, 4 Aug 2015 17:09:58 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.2
Message-ID: <20150804210958.GA10729@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull a few nfsd bugfixes for 4.2 from:

  git://linux-nfs.org/~bfields/linux.git for-4.2

--b.

----------------------------------------------------------------
Jeff Layton (1):
      nfsd: do nfs4_check_fh in nfs4_check_file instead of nfs4_check_olstateid

Kinglong Mee (2):
      nfsd: Drop BUG_ON and ignore SECLABEL on absent filesystem
      nfsd: Fix a file leak on nfsd4_layout_setlease failure

 fs/nfsd/nfs4layouts.c |  1 +
 fs/nfsd/nfs4state.c   | 12 ++++++------
 fs/nfsd/nfs4xdr.c     | 11 ++++++-----
 3 files changed, 13 insertions(+), 11 deletions(-)
