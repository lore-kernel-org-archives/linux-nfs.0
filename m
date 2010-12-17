Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277Ab0LQTBz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 14:01:55 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: 4.1 SECINFO should consume filehandle
Date: Fri, 17 Dec 2010 14:01:49 -0500
Message-Id: <1292612511-14203-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1292612511-14203-1-git-send-email-bfields@redhat.com>
References: <1292612511-14203-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

See the referenced spec language; an attempt by a 4.1 client to use the
current filehandle after a secinfo call should result in a NOFILEHANDLE
error.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0cdfd02..bad4bf8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -769,6 +769,9 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	} else
 		secinfo->si_exp = exp;
 	dput(dentry);
+	if (cstate->minorversion)
+		/* See rfc 5661 section 2.6.3.1.1.8 */
+		fh_put(&cstate->current_fh);
 	return err;
 }
 
-- 
1.7.1

