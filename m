Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757729Ab3CYNUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 09:20:31 -0400
Date: Mon, 25 Mar 2013 09:20:30 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.9
Message-ID: <20130325132030.GC14438@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull bugfixes for 3.9 from the for-3.9 branch at:

  git://linux-nfs.org/~bfields/linux.git for-3.9

Fixes for a couple mistakes in the new DRC code.  And thanks to Kent
Overstreet for noticing we've been sync'ing the wrong range on stable
writes since 3.8.

--b.

----------------------------------------------------------------
Jeff Layton (2):
      nfsd: only unhash DRC entries that are in the hashtable
      nfsd: fix startup order in nfsd_reply_cache_init

Kent Overstreet (1):
      nfsd: fix bad offset use

 fs/nfsd/nfscache.c |   11 ++++++-----
 fs/nfsd/vfs.c      |    3 ++-
 2 files changed, 8 insertions(+), 6 deletions(-)
