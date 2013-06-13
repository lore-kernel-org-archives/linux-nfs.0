Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35825 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab3FMCyo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:54:44 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 13 Jun 2013 12:53:42 +1000
Subject: [PATCH 0/5] Fix assorted races in the sunrpc cache.
Cc: linux-nfs@vger.kernel.org, Bodo Stroesser <bstroesser@ts.fujitsu.com>
Message-ID: <20130613025132.31861.97407.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are a few races possible in the sunrpc cache which can result in
messages being dropped or memory not being freed.

These patches have been tested extensively and appear to remove all
dropped-message errors and memory leaks.

NeilBrown


---

NeilBrown (5):
      sunrpc/cache: remove races with queuing an upcall.
      sunrpc/cache: use cache_fresh_unlocked consistently and correctly.
      sunrpc/cache: ensure items removed from cache do not have pending upcalls.
      net/sunrpc: xpt_auth_cache should be ignored when expired.
      sunrpc: Don't schedule an upcall on a replaced cache entry.


 include/linux/sunrpc/cache.h |   49 ++++++++++++---------------
 net/sunrpc/cache.c           |   75 ++++++++++++++++++++++++------------------
 net/sunrpc/svcauth_unix.c    |    4 +-
 3 files changed, 67 insertions(+), 61 deletions(-)

-- 
Signature

