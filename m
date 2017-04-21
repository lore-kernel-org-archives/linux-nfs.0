Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54742 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161570AbdDUUet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Apr 2017 16:34:49 -0400
Date: Fri, 21 Apr 2017 16:34:48 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] 4.11 nfsd bugfix
Message-ID: <20170421203448.GD19775@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.11-2

Fix a 4.11 regression that triggers a BUG() on an attempt to use an
unsupported NFSv4 compound op.

(Apologies for what's probably a last-minute fix.  I was hoping to have
a few more ready to roll up with it, but they'll probably have to wait
till next week.)

--b.

Olga Kornievskaia (1):
      nfsd: fix oops on unsupported operation

 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
