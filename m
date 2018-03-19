Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41690 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755759AbeCSOgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/10] nfsd4: dp->dl_stid.sc_file doesn't need locking
Date: Mon, 19 Mar 2018 10:36:29 -0400
Message-Id: <1521470194-24840-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The delegation isn't visible to anyone yet.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0466312a2a4e..3fc0682ca799 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4363,9 +4363,10 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		return ERR_PTR(-ENOMEM);
 
 	get_nfs4_file(fp);
+	dp->dl_stid.sc_file = fp;
+
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
-	dp->dl_stid.sc_file = fp;
 	if (!fp->fi_deleg_file) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
-- 
2.14.3

