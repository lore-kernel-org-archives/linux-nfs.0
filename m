Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42178 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375Ab0HLG4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 02:56:02 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 16:55:21 +1000
Subject: [PATCH 0/2] Use monotonic time stamps in sunrpc auth cache.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812064957.3408.44224.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A 6 month release cycles seems to be popular these days, and it is six
months since I last posted these, so I guess it is time to post them
again (yes, I've been busy and forgot all about them - but I still
think they are important).

If you set your system time backwards, nfsd can end up caching things
much longer than it should.  And if you set if very far forward,
caches will get flushed too early.

So change all time keeping to use a monotonic time based on
getboottime.

A few issues were raised last time I posted these:
   http://www.spinics.net/lists/linux-nfs/msg11515.html
I think they have all been addressed now.

Thanks,
NeilBrown

---

NeilBrown (2):
      sunrpc: extract some common sunrpc_cache code from nfsd
      sunrpc: use monotonic time in expiry cache


 fs/nfs/dns_resolve.c         |    6 +++---
 fs/nfsd/export.c             |    9 +++------
 fs/nfsd/nfs4idmap.c          |    2 +-
 include/linux/sunrpc/cache.h |   23 ++++++++++++++++++++++-
 net/sunrpc/cache.c           |   37 ++++++++++++++++++++-----------------
 5 files changed, 49 insertions(+), 28 deletions(-)

-- 

