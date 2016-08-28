Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35184 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756028AbcH1WZH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:07 -0400
Received: by mail-it0-f68.google.com with SMTP id f128so5045349ith.2
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4.1: Remove obsolete and incorrrect assignment in nfs4_callback_sequence
Date: Sun, 28 Aug 2016 18:21:05 -0400
Message-Id: <1472422865-28698-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472422865-28698-5-git-send-email-trond.myklebust@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-3-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-4-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c35932967722..f953ef6b2f2e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -484,7 +484,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out;
 
 	tbl = &clp->cl_session->bc_slot_table;
-	slot = tbl->slots + args->csa_slotid;
 
 	/* Set up res before grabbing the spinlock */
 	memcpy(&res->csr_sessionid, &args->csa_sessionid,
-- 
2.7.4

