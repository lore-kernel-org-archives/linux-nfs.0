Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55008 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756868AbbLBLSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 06:18:33 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NYQ02QG5A2WSMC0@mailout4.samsung.com> for
 linux-nfs@vger.kernel.org; Wed, 02 Dec 2015 20:18:32 +0900 (KST)
From: Vivek Trivedi <t.vivek@samsung.com>
To: linux-nfs@vger.kernel.org
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com,
        Vivek Trivedi <t.vivek@samsung.com>
Subject: [PATCH 2/2] nfs-utils: mount.nfs: fix null pointer derefernce in
 nfs_parse_simple_hostname
Date: Wed, 02 Dec 2015 16:46:38 +0530
Message-id: <1449054998-19308-2-git-send-email-t.vivek@samsung.com>
In-reply-to: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
References: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In function nfs_parse_simple_hostname, hostname can be NULL,
dereferncing it while passing it to free(*hostname) may result in segfault.

Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
---
 utils/mount/parse_dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
index d64b83d..0d3bcb9 100644
--- a/utils/mount/parse_dev.c
+++ b/utils/mount/parse_dev.c
@@ -118,7 +118,8 @@ static int nfs_parse_simple_hostname(const char *dev,
 	if (pathname) {
 		*pathname = strndup(colon, path_len);
 		if (*pathname == NULL) {
-			free(*hostname);
+			if (hostname)
+				free(*hostname);
 			return nfs_pdn_nomem_err();
 		}
 	}
-- 
1.7.9.5

