From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] nfs: Fix nfs_parse_mount_options() kfree() leak
Date: Tue, 20 Oct 2009 14:13:46 +0900
Message-ID: <1256015627.12592.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yinghai Lu <yinghai@kernel.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	stable <stable@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:58609 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbZJTFOL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2009 01:14:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>

Fix a (small) memory leak in one of the error paths of
the NFS mount options parsing code.

Reported-by: Yinghai Lu <yinghai@kernel.org>
Reported-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Regression introduced in 2.6.30 by commit a67d18f (NFS: load the
rpc/rdma transport module automatically). Please apply to mainline
+stable...

 fs/nfs/super.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a2c18ac..90be551 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1253,6 +1253,7 @@ static int nfs_parse_mount_options(char *raw,
                        default:
                                dfprintk(MOUNT, "NFS:   unrecognized "
                                                "transport protocol\n");
+                               kfree(string);
                                return 0;
                        }
                        break;


