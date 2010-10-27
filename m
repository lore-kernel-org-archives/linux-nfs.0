Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46177 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab0J0VTP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 17:19:15 -0400
Date: Wed, 27 Oct 2010 23:19:04 +0200
From: Dan Carpenter <error27@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch] nfsd: fix NULL dereference in setattr()
Message-ID: <20101027211904.GJ6062@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The original code would oops if this were called from nfsd4_setattr()
because "filpp" is NULL.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9019e8e..e044d04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3083,9 +3083,10 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		if (status)
 			goto out;
 		renew_client(dp->dl_client);
-		if (filpp)
+		if (filpp) {
 			*filpp = find_readable_file(dp->dl_file);
-		BUG_ON(!*filpp);
+			BUG_ON(!*filpp);
+		}
 	} else { /* open or lock stateid */
 		stp = find_stateid(stateid, flags);
 		if (!stp)
