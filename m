Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55239 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab3BZGip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2013 01:38:45 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 26 Feb 2013 17:36:41 +1100
Subject: [PATCH 0/2] two fixes for races in SUNRPC.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <20130226063637.6063.34934.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,
 these two patches fix (I believe) the races recently reported
by Bodo Stroesser.

Thanks,
NeilBrown

---

NeilBrown (2):
      sunrpc/cache: remove races with queuing an upcall.
      sunrpc/cache: use cache_fresh_unlocked consistently and correctly.


 net/sunrpc/cache.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

-- 
Signature

