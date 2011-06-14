Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38155 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:35 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/10] SQUASHME: pnfsd-exofs: Server xdr definisions were moved to a separate header
Date: Tue, 14 Jun 2011 17:36:34 -0400
Message-Id: <1308087394-13207-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Include from export.c the server XDR header

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index c8a7d46..20969bf 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -27,6 +27,8 @@
 #include <linux/nfsd/nfsd4_pnfs.h>
 #include "exofs.h"
 
+#include "../exportfs/pnfs_osd_xdr_srv.h"
+
 static int exofs_layout_type(struct super_block *sb)
 {
 	return LAYOUT_OSD2_OBJECTS;
-- 
1.7.3.4

