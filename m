Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:53155 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbaEWMyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:54:49 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so8002648qcv.10
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:54:48 -0700 (PDT)
Message-ID: <537F4503.7030401@gmail.com>
Date: Fri, 23 May 2014 20:54:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 3/5] NFSD: Cleanup unneeded including net/ipv6.h
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 49b28684fdba2c84a3b8e54aaa0faa9ce2e4f140 have remove the using of
ipv6_addr_set_v4mapped(), net/ipv6.h is unneeded now, clean it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 1d56ae3..34cabab 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -17,8 +17,6 @@
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svc_xprt.h>
 
-#include <net/ipv6.h>
-
 #include "nfsd.h"
 #include "nfsfh.h"
 #include "netns.h"
-- 
1.9.3

