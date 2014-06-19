Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54028 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564AbaFSPBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2014 11:01:25 -0400
Date: Thu, 19 Jun 2014 11:01:23 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kinglong Mee <kinglongmee@gmail.com>, NeilBrown <neilb@suse.de>
Subject: bugfixes for 3.16
Message-ID: <20140619150123.GA4787@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull bugfixes for 3.16 from

  git://linux-nfs.org/~bfields/linux.git for-3.16

Fixes for a new regression from the xdr encoding rewrite, and a
delegation problem we've had for a while (made somewhat more annoying by
the vfs delegation support added in 3.13.)

--b.

----------------------------------------------------------------
Kinglong Mee (1):
      NFSD: fix bug for readdir of pseudofs

NeilBrown (1):
      NFSD: Don't hand out delegations for 30 seconds after recalling them.

 fs/nfsd/nfs4state.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c   |  1 +
 2 files changed, 79 insertions(+)
