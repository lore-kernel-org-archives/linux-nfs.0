Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f171.google.com ([209.85.217.171]:53729 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbbAMUyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 15:54:20 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so4726522lbi.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 12:54:18 -0800 (PST)
From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: nfs4state: Remove unused function
Date: Tue, 13 Jan 2015 21:57:24 +0100
Message-Id: <1421182644-8258-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the function renew_client() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 fs/nfsd/nfs4state.c |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9c3afe..5d63c5c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -150,16 +150,6 @@ renew_client_locked(struct nfs4_client *clp)
 	clp->cl_time = get_seconds();
 }
 
-static inline void
-renew_client(struct nfs4_client *clp)
-{
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	spin_lock(&nn->client_lock);
-	renew_client_locked(clp);
-	spin_unlock(&nn->client_lock);
-}
-
 static void put_client_renew_locked(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-- 
1.7.10.4

