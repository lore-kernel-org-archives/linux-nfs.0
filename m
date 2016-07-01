Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51926 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900AbcGATGg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 15:06:36 -0400
Date: Fri, 1 Jul 2016 15:06:34 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Subject: [GIT PULL] lockd/locks bugfixes for 4.7
Message-ID: <20160701190634.GA23453@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.7-3

----------------------------------------------------------------
One fix for lockd soft lookups in an error path, and one fix for file
leases on overlayfs.

----------------------------------------------------------------
Miklos Szeredi (1):
      locks: use file_inode()

Scott Mayhew (1):
      lockd: unregister notifier blocks if the service fails to come up completely

 fs/lockd/svc.c | 13 ++++++++++---
 fs/locks.c     |  2 +-
 2 files changed, 11 insertions(+), 4 deletions(-)
