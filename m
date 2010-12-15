Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059Ab0LOQD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:28 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lp2001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:27 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] wave 2: remove unneeded includes from callback_proc.c
Date: Wed, 15 Dec 2010 11:03:11 -0500
Message-Id: <1292428991-30788-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These were added to support now removed code, so they can go too.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index afa51c3..e541b94 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -8,9 +8,6 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/slab.h>
-#include <linux/kthread.h>
-#include <linux/module.h>
-#include <linux/writeback.h>
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-- 
1.7.2.1

