Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36682 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbcEOBHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2016 21:07:01 -0400
Received: by mail-qk0-f195.google.com with SMTP id l68so11320560qkf.3
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2016 18:07:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 09/13] flexfiles: add kerneldoc header to nfs4_ff_layout_prepare_ds
Date: Sat, 14 May 2016 21:06:38 -0400
Message-Id: <1463274402-17746-10-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5532cb14e800..6efd060e731f 100644
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

