Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59012 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754764AbcIPV30 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 17:29:26 -0400
Date: Fri, 16 Sep 2016 17:29:25 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] one more nfsd bugfix for 4.8
Message-ID: <20160916212925.GA10734@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.8-2

--b.

----------------------------------------------------------------
Fix a memory corruption bug that I introduced in 4.7.

----------------------------------------------------------------
Chuck Lever (1):
      svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary allocation")

 net/sunrpc/auth_gss/svcauth_gss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
