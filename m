From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: add dprintk of compound return
Date: Mon, 5 May 2008 20:11:46 -0400
Message-ID: <20080506001146.GM12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33965 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758313AbYEFALr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 20:11:47 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1JtAmY-0005Y9-N9
	for linux-nfs@vger.kernel.org; Mon, 05 May 2008 20:11:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We already print each operation of the compound when debugging is turned
on; printing the result could also help with remote debugging.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

I'm queueing this up for 2.6.27.

--b.

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c309c88..3134843 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -952,6 +952,7 @@ encode_op:
 out:
 	nfsd4_release_compoundargs(args);
 	cstate_free(cstate);
+	dprintk("nfsv4 compound returned %d\n", ntohl(status));
 	return status;
 }
 
-- 
1.5.5.rc1

