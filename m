Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54554 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351Ab3CDGKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 01:10:40 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 04 Mar 2013 17:09:32 +1100
Subject: [PATCH 0/2] two fixes for races in SUNRPC. - Take 2.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <20130304060801.1352.97857.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,
 these two patches fix (I believe) the races recently reported
by Bodo Stroesser.

This version removes the 'return' from cache_deqeue() as discussed.

Thanks,
NeilBrown


---

NeilBrown (2):
      sunrpc/cache: remove races with queuing an upcall.
      sunrpc/cache: use cache_fresh_unlocked consistently and correctly.


 net/sunrpc/cache.c |   37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

-- 
Signature

