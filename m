Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33171 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbC1Pvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:51:32 -0400
Received: by pdnc3 with SMTP id c3so127446785pdn.0
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:51:31 -0700 (PDT)
Message-ID: <5516CDFB.3040306@gmail.com>
Date: Sat, 28 Mar 2015 23:51:23 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 4/4] nfsd: use NFS4_MAXTAGLEN defined in include/linux/nfs4.h
References: <5516CCDB.4020509@gmail.com>
In-Reply-To: <5516CCDB.4020509@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/xdr4cb.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index c47f6fd..008dd2b 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -1,4 +1,5 @@
-#define NFS4_MAXTAGLEN		20
+
+#include <linux/nfs4.h>
 
 #define NFS4_enc_cb_null_sz		0
 #define NFS4_dec_cb_null_sz		0
-- 
2.3.4

