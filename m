Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33969 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbcEESZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 14:25:01 -0400
Received: by mail-qk0-f178.google.com with SMTP id r184so47767061qkc.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 11:25:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: hch@lst.de, Anna.Schumaker@netapp.com
Subject: [RFC PATCH 6/6] nfs4: add kerneldoc header to nfs4_ff_layout_prepare_ds
Date: Thu,  5 May 2016 14:24:48 -0400
Message-Id: <1462472688-5663-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
References: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
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

