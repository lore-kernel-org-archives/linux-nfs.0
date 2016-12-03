Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33734 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f194.google.com with SMTP id j92so14912456ioi.0
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] NFSv4: Add a generic structure for managing layout-private information
Date: Sat,  3 Dec 2016 15:57:18 -0500
Message-Id: <20161203205725.12961-4-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-3-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/nfs_xdr.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bfbd0cace91b..331a3200eb01 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -216,6 +216,20 @@ struct nfs4_get_lease_time_res {
 	struct nfs_fsinfo	       *lr_fsinfo;
 };
 
+struct xdr_stream;
+struct nfs4_xdr_opaque_data;
+
+struct nfs4_xdr_opaque_ops {
+	void (*encode)(struct xdr_stream *, const void *args,
+			const struct nfs4_xdr_opaque_data *);
+	void (*free)(struct nfs4_xdr_opaque_data *);
+};
+
+struct nfs4_xdr_opaque_data {
+	const struct nfs4_xdr_opaque_ops *ops;
+	void *data;
+};
+
 #define PNFS_LAYOUT_MAXSIZE 4096
 
 struct nfs4_layoutdriver_data {
-- 
2.9.3

