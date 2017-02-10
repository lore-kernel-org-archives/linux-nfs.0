Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47700 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751858AbdBJOAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Feb 2017 09:00:44 -0500
Date: Fri, 10 Feb 2017 08:53:07 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 4.10
Message-ID: <20170210135307.GA11284@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.10-3

--b.

----------------------------------------------------------------
This patch turned out to have a couple problems.  The problems are
fixable, but at least one of the fixes is a little ugly.  The original
bug has always been there, so we can wait another week or two to get
this right.

----------------------------------------------------------------
J. Bruce Fields (1):
      nfsd: Revert "nfsd: special case truncates some more"

 fs/nfsd/vfs.c | 97 ++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 60 insertions(+), 37 deletions(-)
