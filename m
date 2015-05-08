Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44328 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986AbbEHI5O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:57:14 -0400
From: NeilBrown <neilb@suse.de>
To: linux-raid@vger.kernel.org, Shaohua Li <shli@kernel.org>
Date: Fri, 08 May 2015 18:56:11 +1000
Subject: [PATCH 5/7] md/raid5: don't record new size if resize_stripes fails.
Cc: linux-nfs@vger.kernel.org, "v2.6.17+" <stable@vger.kernel.org>
Message-ID: <20150508085611.19179.2391.stgit@notabene.brown>
In-Reply-To: <20150508085345.19179.8866.stgit@notabene.brown>
References: <20150508085345.19179.8866.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If any memory allocation in resize_stripes fails we will return
-ENOMEM, but in some cases we update conf->pool_size anyway.

This means that if we try again, the allocations will be assumed
to be larger than they are, and badness results.

So only update pool_size if there is no error.

This bug was introduced in 2.6.17 and the patch is suitable for
-stable.

Fixes: ad01c9e3752f ("[PATCH] md: Allow stripes to be expanded in preparation for expanding an array")
Cc: stable@vger.kernel.org (v2.6.17+)
Signed-off-by: NeilBrown <neilb@suse.de>
---
 drivers/md/raid5.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 85dc0e67fb88..9748e525e4c0 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -2216,7 +2216,8 @@ static int resize_stripes(struct r5conf *conf, int newsize)
 
 	conf->slab_cache = sc;
 	conf->active_name = 1-conf->active_name;
-	conf->pool_size = newsize;
+	if (!err)
+		conf->pool_size = newsize;
 	return err;
 }
 


