Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50447 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757814Ab2EUKlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 06:41:39 -0400
Message-ID: <4FBA1BD4.7090303@panasas.com>
Date: Mon, 21 May 2012 13:41:24 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>, Andy Adamson <andros@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: pnfsd-lexp: Fix compiler warning when CONFIG_SUNRPC_DEBUG
 is not set
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix "Unused variable" warning if CONFIG_SUNRPC_DEBUG is not set

Signed-off-by: Boaz Harrosh <boazharrosh@gmail.com>
---
git diff --stat -p -M fs/nfsd/nfs4pnfsds.c
 fs/nfsd/nfs4pnfsds.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsds.c b/fs/nfsd/nfs4pnfsds.c
index 2732f20..ab67523 100644
--- a/fs/nfsd/nfs4pnfsds.c
+++ b/fs/nfsd/nfs4pnfsds.c
@@ -170,10 +170,9 @@ static int stateid_hashval(stateid_t *stidp)
 	hashval = stateid_hashval(stidp);
 	list_for_each_entry(local, &ds_stid_hashtbl[hashval], ds_hash)
 		if (!memcmp(&local->ds_stid.si_opaque, &stidp->si_opaque, sizeof(stidp->si_opaque))) {
-			stateid_t *sid = &local->ds_stid;
 			dprintk("NFSD: %s <-- %p ds_flags %lx " STATEID_FMT "\n",
 				__func__, local, local->ds_flags,
-				STATEID_VAL(sid));
+				STATEID_VAL(&local->ds_stid));
 			return local;
 		}
 	return NULL;
