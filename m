Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41808 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbcFXWMr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jun 2016 18:12:47 -0400
Date: Fri, 24 Jun 2016 18:12:43 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] bugfixes for 4.7
Message-ID: <20160624221243.GN3287@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd changes from the nfsd-4.7-2 tag at:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.7-2

--b.

----------------------------------------------------------------
Fix missing server-side permission checks on setting NFS ACLs.

----------------------------------------------------------------
Andreas Gruenbacher (1):
      posix_acl: Add set_posix_acl

Ben Hutchings (1):
      nfsd: check permissions when setting ACLs

 fs/nfsd/nfs2acl.c | 20 ++++++++++----------
 fs/nfsd/nfs3acl.c | 16 +++++++---------
 fs/nfsd/nfs4acl.c | 16 ++++++++--------
 fs/posix_acl.c    | 42 +++++++++++++++++++++++-------------------
 4 files changed, 48 insertions(+), 46 deletions(-)
