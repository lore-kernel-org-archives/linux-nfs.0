Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35150 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134AbcEKKVa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 06:21:30 -0400
Received: by mail-qk0-f194.google.com with SMTP id n62so2438172qkc.2
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 03:21:29 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/9] flexfiles: add kerneldoc header to nfs4_ff_layout_prepare_ds
Date: Wed, 11 May 2016 06:21:11 -0400
Message-Id: <1462962074-6989-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5eff05e9eb4d..61094d59ee3a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -342,7 +342,23 @@ out:
 	return fh;
 }
 
-/* Upon return, either ds is connected, or ds is NULL */
+/**
+ * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
+ * @lseg: the layout segment we're operating on
+ * @ds_idx: index of the DS to use
+ * @fail_return: return layout on connect failure?
+ *
+ * Try to prepare a DS connection to accept an RPC call. This involves
+ * selecting a mirror to use and connecting the client to it if it's not
+ * already connected.
+ *
+ * Since we only need single functioning mirror to satisfy a read, we don't
+ * want to return the layout if there is one. For writes though, any down
+ * mirror should result in a LAYOUTRETURN. @fail_return is how we distinguish
+ * between the two cases.
+ *
+ * Returns a pointer to a connected DS object on success or NULL on failure.
+ */
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			  bool fail_return)
-- 
2.5.5

