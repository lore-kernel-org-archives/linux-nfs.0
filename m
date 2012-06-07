Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35946 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761381Ab2FGTGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 15:06:44 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so899257bkc.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2012 12:06:43 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pnfs-obj: disable unloading the module when mounted
Date: Thu,  7 Jun 2012 22:06:30 +0300
Message-Id: <1339095991-26753-2-git-send-email-idank@tonian.com>
In-Reply-To: <1339095991-26753-1-git-send-email-idank@tonian.com>
References: <1339095991-26753-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

or the kernel will oops.

Signed-off-by: Idan Kedar <idank@tonian.com>
---
 fs/nfs/objlayout/objio_osd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 55d0128..b161f97 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -551,6 +551,7 @@ static const struct nfs_pageio_ops objio_pg_write_ops = {
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
+	.owner = THIS_MODULE,
 	.flags                   = PNFS_LAYOUTRET_ON_SETATTR |
 				   PNFS_LAYOUTRET_ON_ERROR,
 
-- 
1.7.6.5

