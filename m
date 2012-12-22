Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445Ab2LVAtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 19:49:03 -0500
Date: Fri, 21 Dec 2012 19:48:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] Revert "nfsd: warn on odd reply state in nfsd_vfs_read"
Message-ID: <20121222004859.GA30312@fieldses.org>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121221180824.GA27729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This reverts commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e.

This is obviously wrong, and I have no idea how I missed seeing the
warning in testing: I must just not have looked at the right logs.  The
caller bumps rq_resused/rq_next_page, so it will always be hit on a
large enough read.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f0a6d88..d586117 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -934,7 +934,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 			.u.data		= rqstp,
 		};
 
-		WARN_ON_ONCE(rqstp->rq_next_page != rqstp->rq_respages + 1);
 		rqstp->rq_next_page = rqstp->rq_respages + 1;
 		host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 	} else {
-- 
1.7.11.7

