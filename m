Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51026 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726843AbeJSDEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Oct 2018 23:04:13 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2 v2] nfs: remove redundant call to nfs_context_set_write_error()
Date: Thu, 18 Oct 2018 15:01:49 -0400
Message-Id: <0963d6fa00685c2810cd1d5996eb4853a2949057.1539889215.git.bcodding@redhat.com>
In-Reply-To: <1da7a5e6280feaf3fe24673cbcf8138571e26fa4.1539889215.git.bcodding@redhat.com>
References: <1da7a5e6280feaf3fe24673cbcf8138571e26fa4.1539889215.git.bcodding@redhat.com>
In-Reply-To: <1da7a5e6280feaf3fe24673cbcf8138571e26fa4.1539889215.git.bcodding@redhat.com>
References: <1da7a5e6280feaf3fe24673cbcf8138571e26fa4.1539889215.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to call this in the direct, read, or pnfs resend paths and
the only other caller is the write path in nfs_page_async_flush() which
already checks and sets the pg_error on the context.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7e6425791388..a592abb62873 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1174,10 +1174,6 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	return 1;
 
 out_failed:
-	/* remember fatal errors */
-	if (nfs_error_is_fatal(desc->pg_error))
-		nfs_context_set_write_error(req->wb_context,
-						desc->pg_error);
 	nfs_pageio_error_cleanup(desc);
 	return 0;
 }
-- 
2.14.3
