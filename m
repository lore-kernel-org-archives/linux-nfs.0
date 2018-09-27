Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f66.google.com ([209.85.166.66]:37884 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727769AbeI0V7t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2018 17:59:49 -0400
Received: by mail-io1-f66.google.com with SMTP id v14-v6so2266589iob.4
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2018 08:40:59 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id d11-v6sm689072iok.77.2018.09.27.08.40.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Sep 2018 08:40:58 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4: Save a few bytes in the nfs_pgio_args/res
Date: Thu, 27 Sep 2018 11:40:02 -0400
Message-Id: <20180927154003.11825-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180927154003.11825-1-trond.myklebust@hammerspace.com>
References: <20180927154003.11825-1-trond.myklebust@hammerspace.com>
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
index 7f5535e5e852..343e44166346 100644
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
+			unsigned int		replen;		/* used by read */
+			int			eof;		/* used by read */
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
