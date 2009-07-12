From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] nfs: Keep index within mnt_errtbl[]
Date: Mon, 13 Jul 2009 01:25:01 +0200
Message-ID: <4A5A70CD.2030909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:35428 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbZGLXXf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2009 19:23:35 -0400
Received: by ewy26 with SMTP id 26so2215602ewy.37
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2009 16:23:33 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that index i remains within array mnt_errtbl[] and mnt3_errtbl[].

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 38ef9ea..8b9affc 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -258,7 +258,7 @@ static int decode_status(struct xdr_stream *xdr, struct mountres *res)
 		return -EIO;
 	status = ntohl(*p);
 
-	for (i = 0; i <= ARRAY_SIZE(mnt_errtbl); i++) {
+	for (i = 0; i < ARRAY_SIZE(mnt_errtbl); i++) {
 		if (mnt_errtbl[i].status == status) {
 			res->errno = mnt_errtbl[i].errno;
 			return 0;
@@ -309,7 +309,7 @@ static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 		return -EIO;
 	status = ntohl(*p);
 
-	for (i = 0; i <= ARRAY_SIZE(mnt3_errtbl); i++) {
+	for (i = 0; i < ARRAY_SIZE(mnt3_errtbl); i++) {
 		if (mnt3_errtbl[i].status == status) {
 			res->errno = mnt3_errtbl[i].errno;
 			return 0;
