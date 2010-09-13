Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:63864 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab0IMRW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:56 -0400
Received: by pxi10 with SMTP id 10so2223900pxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:55 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/12] mountd: Ensure cache downcall can handle IPv6 addresses
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:52 -0400
Message-ID: <20100913172252.19017.90295.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 0e8a2f4..f70f4d6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -943,7 +943,7 @@ static int cache_export_ent(char *domain, struct exportent *exp, char *path)
  */
 int cache_export(nfs_export *exp, char *path)
 {
-	char buf[INET_ADDRSTRLEN];
+	char buf[INET6_ADDRSTRLEN];
 	int err;
 	FILE *f;
 

