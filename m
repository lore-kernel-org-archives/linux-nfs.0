Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:52063 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673Ab3AOCrg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 21:47:36 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so2566161pbc.28
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2013 18:47:35 -0800 (PST)
From: ycnian@gmail.com
To: bhalevy@tonian.com
Cc: linux-nfs@vger.kernel.org, Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] pnfsd: Update the reference of nfs4_layout_state properly
Date: Tue, 15 Jan 2013 10:37:51 +0800
Message-Id: <1358217471-18458-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The reference of nfs4_layout_state is set to 1 when creating.
it isn't necessary to increase the reference again in
nfs4_process_layout_stateid(), otherwise it will lead to a
memory leak.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4pnfsd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2211b50..dd7856c 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -248,10 +248,10 @@ nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
 			status = nfserr_bad_stateid;
 			goto out;
 		}
+		get_layout_state(ls);
 	}
 	status = 0;
 
-	get_layout_state(ls);
 	*lsp = ls;
 	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
 		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
-- 
1.7.4.4

