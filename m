Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46583 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab1EXPFM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:05:12 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/12] SQUASHME: Bug in new global-device-cache code
Date: Tue, 24 May 2011 18:04:40 +0300
Message-Id: <1306249480-23212-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NULL deref on first ever call. (When device is not found)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 7997899..7e5542c 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -100,7 +100,7 @@ _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
 
 	rcu_read_lock();
 	d = _lookup_deviceid(ld, clp, id, hash);
-	if (!atomic_inc_not_zero(&d->ref))
+	if (!d || !atomic_inc_not_zero(&d->ref))
 		d = NULL;
 	rcu_read_unlock();
 	return d;
-- 
1.7.2.3

