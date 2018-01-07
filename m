Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.smtpout.orange.fr ([80.12.242.124]:29973 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbeAGIvG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jan 2018 03:51:06 -0500
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] NFSv4.1: Ensure 'nfs4_sp4_select_mode()' can report -EINVAL when needed
Date: Sun,  7 Jan 2018 09:50:40 +0100
Message-Id: <20180107085040.6827-1-christophe.jaillet@wanadoo.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 937e3133cd0b, 'nfs4_sp4_select_mode()' always return 0.
Based on the way this commit is written (direct return replaced by some
'ret = -EXXX'), it is likely that returning this error code is expected.

Fixes: 937e3133cd0b ("NFSv4.1: Ensure we clear the SP4_MACH_CRED flags in nfs4_sp4_select_mode()")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
Untested and not sure at all if correct...
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 17a03f2c4330..ae00ac59f59b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7584,7 +7584,7 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 	}
 out:
 	clp->cl_sp4_flags = flags;
-	return 0;
+	return ret;
 }
 
 struct nfs41_exchange_id_data {
-- 
2.14.1

