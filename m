Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f43.google.com ([74.125.82.43]:54500 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3EKCmf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:42:35 -0400
Received: by mail-wg0-f43.google.com with SMTP id c11so4502669wgh.34
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:33 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id a4sm1374045wic.5.2013.05.10.19.42.32
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:33 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/38] Revert "SQUASHME: pnfsd: Fix compiler warning when CONFIG_SUNRPC_DEBUG is not set"
Date: Sat, 11 May 2013 05:42:26 +0300
Message-Id: <1368240146-31751-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 93275cbb789cd18eda5f9fa91469fb9c28ed8896.
---
 fs/nfsd/nfs4pnfsds.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsds.c b/fs/nfsd/nfs4pnfsds.c
index ab67523..2732f20 100644
--- a/fs/nfsd/nfs4pnfsds.c
+++ b/fs/nfsd/nfs4pnfsds.c
@@ -170,9 +170,10 @@ static int stateid_hashval(stateid_t *stidp)
 	hashval = stateid_hashval(stidp);
 	list_for_each_entry(local, &ds_stid_hashtbl[hashval], ds_hash)
 		if (!memcmp(&local->ds_stid.si_opaque, &stidp->si_opaque, sizeof(stidp->si_opaque))) {
+			stateid_t *sid = &local->ds_stid;
 			dprintk("NFSD: %s <-- %p ds_flags %lx " STATEID_FMT "\n",
 				__func__, local, local->ds_flags,
-				STATEID_VAL(&local->ds_stid));
+				STATEID_VAL(sid));
 			return local;
 		}
 	return NULL;
-- 
1.7.11.7

