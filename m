Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab2LREp6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 23:45:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: don't leave freed stateid hashed
Date: Mon, 17 Dec 2012 23:45:53 -0500
Message-Id: <1355805953-2473-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1355805953-2473-1-git-send-email-bfields@redhat.com>
References: <1355805953-2473-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note the stateid is hashed early on in init_stid(), but isn't currently
being unhashed on error paths.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8e127b3..ac8ed96c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2983,6 +2983,7 @@ out:
 	}
 	return;
 out_free:
+	unhash_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
 	flag = NFS4_OPEN_DELEGATE_NONE;
-- 
1.7.9.5

