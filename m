Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46655 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab1EXPFw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:05:52 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/12] SQUSHME: pnfs: BUG in _deviceid_purge_client
Date: Tue, 24 May 2011 18:05:21 +0300
Message-Id: <1306249521-23244-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The atomic_dec_and_test() returns *true* when zero. The !
belongs to atomic_dec(). Fixit

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 7e5542c..37ca215 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -258,7 +258,7 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
 
 	synchronize_rcu();
 	hlist_for_each_entry_safe(d, n, next, &tmp, node)
-		if (!atomic_dec_and_test(&d->ref)) {
+		if (atomic_dec_and_test(&d->ref)) {
 			if (d->ld->free_deviceid_node)
 				d->ld->free_deviceid_node(d);
 			else
-- 
1.7.2.3

