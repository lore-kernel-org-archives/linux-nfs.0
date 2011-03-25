Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57586 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212Ab1CYDMm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 23:12:42 -0400
Date: Thu, 24 Mar 2011 23:12:40 -0400
To: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Subject: [PATCH] nfsd: fix auth_domain reference leak on nlm operations
Message-ID: <20110325031240.GA6479@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Well, that one was fun to track down....  And how did it manage to lurk
for nearly 10 years?

--b.

commit 38069804ed036adbf23aa94eafd5400c4f92fe6b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 24 22:51:14 2011 -0400

    nfsd: fix auth_domain reference leak on nlm operations
    
    This was noticed by users who performed more than 2^32 lock operations
    and hence made this counter overflow (eventually leading to
    use-after-free's).  Setting rq_client to NULL here means that it won't
    later get auth_domain_put() when it should be.
    
    Appears to have been introduced in 2.5.42 by "[PATCH] kNFSd: Move auth
    domain lookup into svcauth" which moved most of the rq_client handling
    to common svcauth code, but left behind this one line.
    
    Cc: Neil Brown <neilb@suse.de>
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 0c6d816..7c831a2 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -38,7 +38,6 @@ nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f, struct file **filp)
 	exp_readlock();
 	nfserr = nfsd_open(rqstp, &fh, S_IFREG, NFSD_MAY_LOCK, filp);
 	fh_put(&fh);
-	rqstp->rq_client = NULL;
 	exp_readunlock();
  	/* We return nlm error codes as nlm doesn't know
 	 * about nfsd, but nfsd does know about nlm..
