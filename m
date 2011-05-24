Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36896 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab1EXKyA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 06:54:00 -0400
Message-ID: <4DDB8E2F.8080308@panasas.com>
Date: Tue, 24 May 2011 13:53:35 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] SQUSHME: pnfs: BUG in _deviceid_purge_client
References: <4DDB8DD1.20101@panasas.com>
In-Reply-To: <4DDB8DD1.20101@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
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


