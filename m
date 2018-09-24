Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:33011 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725937AbeIYEGV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2018 00:06:21 -0400
Received: by mail-it1-f196.google.com with SMTP id j198-v6so5749181ita.0
        for <linux-nfs@vger.kernel.org>; Mon, 24 Sep 2018 15:02:02 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id 132-v6sm129171itz.10.2018.09.24.15.02.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Sep 2018 15:02:01 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Save a few bytes in the nfs_pgio_args/res
Date: Mon, 24 Sep 2018 18:01:05 -0400
Message-Id: <20180924220105.4970-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180924220105.4970-1-trond.myklebust@hammerspace.com>
References: <20180924220105.4970-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save a few bytes by allowing the read/write specific fields of the
structures to share storage.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/nfs_xdr.h | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7f5535e5e852..7981498239f6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -608,9 +608,13 @@ struct nfs_pgio_args {
 	__u32			count;
 	unsigned int		pgbase;
 	struct page **		pages;
-	unsigned int		replen;		/* used by read */
-	const u32 *		bitmask;	/* used by write */
-	enum nfs3_stable_how	stable;		/* used by write */
+	union {
+		unsigned int		replen;			/* used by read */
+		struct {
+			const u32 *		bitmask;	/* used by write */
+			enum nfs3_stable_how	stable;		/* used by write */
+		};
+	};
 };
 
 struct nfs_pgio_res {
@@ -618,10 +622,16 @@ struct nfs_pgio_res {
 	struct nfs_fattr *	fattr;
 	__u32			count;
 	__u32			op_status;
-	int			eof;		/* used by read */
-	unsigned int		replen;		/* used by read */
-	struct nfs_writeverf *	verf;		/* used by write */
-	const struct nfs_server *server;	/* used by write */
+	union {
+		struct {
+			int			eof;		/* used by read */
+			unsigned int		replen;		/* used by read */
+		};
+		struct {
+			struct nfs_writeverf *	verf;		/* used by write */
+			const struct nfs_server *server;	/* used by write */
+		};
+	};
 };
 
 /*
-- 
2.17.1
