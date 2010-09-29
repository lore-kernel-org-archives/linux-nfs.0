Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63007 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:09:26 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] SQUASHME: pnfs-submit: add missing include file in nfs4filelayoutdev.c
Date: Wed, 29 Sep 2010 13:09:19 +0200
Message-Id: <1285758559-26745-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index bd76794..e4f91f6 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -29,6 +29,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include <linux/vmalloc.h>
 
 #include "internal.h"
 #include "nfs4filelayout.h"
-- 
1.7.2.3

