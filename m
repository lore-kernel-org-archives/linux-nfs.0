Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab1LDNsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:48:22 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:48:22 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/13] pnfsd-block: reverse boolean_t values so they make sense
Date: Sun,  4 Dec 2011 15:48:16 +0200
Message-Id: <1323006496-13542-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 89249c4..4d2939e 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -57,7 +57,7 @@
 #endif
 
 
-typedef enum {True, False} boolean_t;
+typedef enum {False = 0, True = !False} boolean_t;
 /* ---- block layoutget and commit structure ---- */
 typedef struct bl_layout_rec {
 	struct list_head	blr_hash,
-- 
1.7.6

