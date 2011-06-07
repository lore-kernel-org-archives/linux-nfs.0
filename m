Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50899 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab1FGRbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:00 -0400
Date: Tue, 7 Jun 2011 13:30:58 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 42/88] SQUASHME: pnfsblock: Fix a memory leak
Message-ID: <b1224e7ad7399d145cbdb0a73379bd65bab9f0c7.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

Array storage is allocated but not freed, free it.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/extents.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 09a7c5c..288a38a 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -181,6 +181,7 @@ static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
 			break;
 		kfree(storage[i]);
 	}
+	kfree(storage);
 	return status;
 }
 
-- 
1.7.4.1

