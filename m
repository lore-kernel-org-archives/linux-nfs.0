Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51554 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab2FHMJ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 08:09:58 -0400
Message-ID: <4FD1EB87.1080600@panasas.com>
Date: Fri, 8 Jun 2012 15:09:43 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 2/6] ore: Remove support of partial IO request (NFS crash)
References: <4FD1CEA8.3090105@panasas.com>
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Do to OOM situations the ore might fail to allocate all resources
needed for IO of the full request. If some progress was possible
it would proceed with a partial/short request, for the sake of
forward progress.

Since this crashes NFS-core and exofs is just fine without it just
remove this contraption, and fail.

TODO:
	Support real forward progress with some reserved allocations
	of resources, such as mem pools and/or bio_sets

[Bug since 3.2 Kernel]
CC: Stable Tree <stable@kernel.org>
CC: Benny Halevy <bhalevy@tonian.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 49cf230..24a49d4 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -735,13 +735,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 out:
 	ios->numdevs = devs_in_group;
 	ios->pages_consumed = cur_pg;
-	if (unlikely(ret)) {
-		if (length == ios->length)
-			return ret;
-		else
-			ios->length -= length;
-	}
-	return 0;
+	return ret;
 }
 
 int ore_create(struct ore_io_state *ios)
-- 
1.7.10.2.677.gb6bc67f


