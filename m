Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308AbaFZBsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/8] nfsd4: define svcxdr_dupstr to share some common code
Date: Wed, 25 Jun 2014 21:48:06 -0400
Message-Id: <1403747288-21590-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 13f91ce..8fb0f37 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -202,6 +202,26 @@ defer_free(struct nfsd4_compoundargs *argp, void *p)
 	return 0;
 }
 
+/*
+ * For xdr strings that need to be passed to other kernel api's
+ * as null-terminated strings.
+ *
+ * Note null-terminating in place usually isn't safe since the
+ * buffer might end on a page boundary.
+ */
+static char *
+svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
+{
+	char *p = kmalloc(len + 1, GFP_KERNEL);
+
+	if (!p)
+		return NULL;
+	memcpy(p, buf, len);
+	p[len] = '\0';
+	defer_free(argp, p);
+	return p;
+}
+
 /**
  * savemem - duplicate a chunk of memory for later processing
  * @argp: NFSv4 compound argument structure to be freed with
@@ -415,12 +435,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			return nfserr_badlabel;
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
-		label->data = kzalloc(dummy32 + 1, GFP_KERNEL);
+		label->len = dummy32;
+		label->data = svcxdr_dupstr(argp, buf, dummy32);
 		if (!label->data)
 			return nfserr_jukebox;
-		label->len = dummy32;
-		defer_free(argp, label->data);
-		memcpy(label->data, buf, dummy32);
 	}
 #endif
 
@@ -597,17 +615,9 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		READ_BUF(4);
 		create->cr_datalen = be32_to_cpup(p++);
 		READ_BUF(create->cr_datalen);
-		/*
-		 * The VFS will want a null-terminated string, and
-		 * null-terminating in place isn't safe since this might
-		 * end on a page boundary:
-		 */
-		create->cr_data = kmalloc(create->cr_datalen + 1, GFP_KERNEL);
+		create->cr_data = svcxdr_dupstr(argp, p, create->cr_datalen);
 		if (!create->cr_data)
 			return nfserr_jukebox;
-		memcpy(create->cr_data, p, create->cr_datalen);
-		create->cr_data[create->cr_datalen] = '\0';
-		defer_free(argp, create->cr_data);
 		break;
 	case NF4BLK:
 	case NF4CHR:
-- 
1.7.9.5

