From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: fix buffer overrun decoding NFSv4 acl
Date: Mon,  1 Sep 2008 14:51:02 -0400
Message-ID: <1220295062-10957-2-git-send-email-bfields@citi.umich.edu>
References: <1220295062-10957-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	David Richter <richterd@citi.umich.edu>
To: stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57155 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbYIASvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Sep 2008 14:51:07 -0400
In-Reply-To: <1220295062-10957-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The array we kmalloc() here is not large enough.

Thanks to Johann Dahm and David Richter for bug report and testing.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: David Richter <richterd@citi.umich.edu>
Tested-by: Johann Dahm <jdahm@umich.edu>
---
 fs/nfsd/nfs4acl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index b6ed383..54b8b41 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -443,7 +443,7 @@ init_state(struct posix_acl_state *state, int cnt)
 	 * enough space for either:
 	 */
 	alloc = sizeof(struct posix_ace_state_array)
-		+ cnt*sizeof(struct posix_ace_state);
+		+ cnt*sizeof(struct posix_user_ace_state);
 	state->users = kzalloc(alloc, GFP_KERNEL);
 	if (!state->users)
 		return -ENOMEM;
-- 
1.5.5.rc1

