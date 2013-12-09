Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46846 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934Ab3LIKLC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 05:11:02 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so4958519pdj.30
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 02:11:01 -0800 (PST)
Message-ID: <52A5972D.7080705@gmail.com>
Date: Mon, 09 Dec 2013 18:10:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: get rid of unused macro definition
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since defined in Linux-2.6.12-rc2, READTIME has not been used.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ee7237f..fd48536 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -103,11 +103,6 @@ xdr_error:					\
 	(x) = (u64)ntohl(*p++) << 32;		\
 	(x) |= ntohl(*p++);			\
 } while (0)
-#define READTIME(x)       do {			\
-	p++;					\
-	(x) = ntohl(*p++);			\
-	p++;					\
-} while (0)
 #define READMEM(x,nbytes) do {			\
 	x = (char *)p;				\
 	p += XDR_QUADLEN(nbytes);		\
-- 
1.8.4.2
