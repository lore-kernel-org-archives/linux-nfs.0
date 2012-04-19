Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43777 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932385Ab2DSUbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 16:31:33 -0400
Date: Thu, 19 Apr 2012 16:31:32 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.4
Message-ID: <20120419203132.GA21393@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two nfsd fixes for 3.4 are available from the for-3.4 branch at:

  git://linux-nfs.org/~bfields/linux.git for-3.4

One bugfix, and one minor header fix from Jeff Layton while we're
here.--b.

J. Bruce Fields (1):
      nfsd: don't fail unchecked creates of non-special files

Jeff Layton (1):
      nfsd: include cld.h in the headers_install target

 fs/nfsd/nfs4proc.c        |    8 ++++----
 fs/nfsd/vfs.c             |    2 +-
 include/linux/nfsd/Kbuild |    1 +
 3 files changed, 6 insertions(+), 5 deletions(-)
