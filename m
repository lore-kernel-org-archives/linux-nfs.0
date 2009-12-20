From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: fix "insecure" export option
Date: Sun, 20 Dec 2009 10:43:35 -0500
Message-ID: <20091220154335.GB2841@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbZLTPnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Dec 2009 10:43:22 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

A typo in 12045a6ee9908b "nfsd: let "insecure" flag vary by
pseudoflavor" reversed the sense of the "insecure" flag.

Reported-by: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

This is a regression introduced by the 2.6.33 nfsd merge.  You can also
pull it from:

	git://linux-nfs.org/~bfields/linux.git for-2.6.33

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 1c12177..55c8e63 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -89,7 +89,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 	int flags = nfsexp_flags(rqstp, exp);
 
 	/* Check if the request originated from a secure port. */
-	if (!rqstp->rq_secure && (flags & NFSEXP_INSECURE_PORT)) {
+	if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
 		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 		dprintk(KERN_WARNING
 		       "nfsd: request from insecure port %s!\n",
-- 
1.6.3.3

