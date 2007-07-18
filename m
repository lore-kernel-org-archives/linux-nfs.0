From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/5] nfsd: fix possible read-ahead cache and export table corruption
Date: Wed, 18 Jul 2007 18:57:26 -0400
Message-ID: <11847994502502-git-send-email-bfields@fieldses.org>
References: <20070713114228.3c171a90.akpm@linux-foundation.org>
 <11847994502579-git-send-email-bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, andros@citi.umich.edu,
	"J. Bruce Fields" <bfields@citi.umich.edu>, stable@kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933182AbXGRW5s@vger.kernel.org>
In-Reply-To: <11847994502579-git-send-email-bfields@fieldses.org>
Message-Id: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

The value of nperbucket calculated here is too small--we should be
rounding up instead of down--with the result that the index j in the
following loop can overflow the raparm_hash array.  At least in my case,
the next thing in memory turns out to be export_table, so the symptoms I
see are crashes caused by the appearance of four zeroed-out export
entries in the first bucket of the hash table of exports (which were
actually entries in the readahead cache, a pointer to which had been
written to the export table in this initialization code).

It looks like the bug was probably introduced with commit
fce1456a19f5c08b688c29f00ef90fdfa074c79b ("knfsd: make the readahead
params cache SMP-friendly").

Cc: stable@kernel.org
Cc: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e90f4a8..b8da5dd 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1916,7 +1916,7 @@ nfsd_racache_init(int cache_size)
 		raparm_hash[i].pb_head = NULL;
 		spin_lock_init(&raparm_hash[i].pb_lock);
 	}
-	nperbucket = cache_size >> RAPARM_HASH_BITS;
+	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
 	for (i = 0; i < cache_size - 1; i++) {
 		if (i % nperbucket == 0)
 			raparm_hash[j++].pb_head = raparml + i;
-- 
1.5.3.rc2
