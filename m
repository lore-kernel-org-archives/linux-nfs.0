Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:35376 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1IPQOV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2011 12:14:21 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/5] pnfsblock: fix size of upcall message
Date: Fri, 16 Sep 2011 12:14:15 -0400
Message-Id: <1316189659-8799-2-git-send-email-rees@umich.edu>
In-Reply-To: <1316189659-8799-1-git-send-email-rees@umich.edu>
References: <1316189659-8799-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Make the status field explicitly 32 bits.  "...it's unlikely that the kernel
and userspace would differ on the size of an int here, but it might be a
good idea to go ahead and make that explicitly 32 bits in case we end up
dealing with more exotic arches at some point in the future."

Suggested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index f27d827..58dc256 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -150,7 +150,7 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 }
 
 struct bl_dev_msg {
-	int status;
+	int32_t status;
 	uint32_t major, minor;
 };
 
-- 
1.7.6

