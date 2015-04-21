Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932695AbbDUUWT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 16:22:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [PATCH 1/3] nfsd4: disallow ALLOCATE with special stateids
Date: Tue, 21 Apr 2015 16:22:13 -0400
Message-Id: <1429647735-15512-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1429647735-15512-1-git-send-email-bfields@redhat.com>
References: <1429647735-15512-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

vfs_fallocate will hit a NULL dereference if the client tries an
ALLOCATE or DEALLOCATE with a special stateid.  Fix that.  (We also
depend on the open to have broken any conflicting leases or delegations
for us.)

(If it turns out we need to allow special stateid's then we could do a
temporary open here in the special-stateid case, as we do for read and
write.  For now I'm assuming it's not necessary.)

Fixes: 95d871f03cae "nfsd: Add ALLOCATE support"
Cc: stable@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b401da386604..d0848fc6529e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1030,6 +1030,8 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
 		return status;
 	}
+	if (!file)
+		return nfserr_bad_stateid;
 
 	status = nfsd4_vfs_fallocate(rqstp, &cstate->current_fh, file,
 				     fallocate->falloc_offset,
-- 
1.9.3

