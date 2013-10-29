Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:55748 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab3J2JjM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:12 -0400
Received: by mail-wi0-f180.google.com with SMTP id ey11so5035160wid.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:11 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 1/7] nfsd4: fix recall_lock use in unhash_delegation
Date: Tue, 29 Oct 2013 11:39:04 +0200
Message-Id: <1383039544-27157-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Access to dp->dl_perclnt must be synchronized by the recall_lock

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a90949a..a403502 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -436,8 +436,8 @@ static void unhash_stid(struct nfs4_stid *s)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
+	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&recall_lock);
-- 
1.8.3.1

