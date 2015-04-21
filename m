Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38936 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932694AbbDUUWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 16:22:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>, stable@vger.kernel.org
Subject: [PATCH 2/3] nfsd4: disallow SEEK with special stateids
Date: Tue, 21 Apr 2015 16:22:14 -0400
Message-Id: <1429647735-15512-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1429647735-15512-1-git-send-email-bfields@redhat.com>
References: <1429647735-15512-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If the client uses a special stateid then we'll pass a NULL file to
vfs_llseek.

Fixes: 24bab491220f " NFSD: Implement SEEK"
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: stable@vger.kernel.org
Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d0848fc6529e..4a8314f08a0e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1071,6 +1071,8 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
 		return status;
 	}
+	if (!file)
+		return nfserr_bad_stateid;
 
 	switch (seek->seek_whence) {
 	case NFS4_CONTENT_DATA:
-- 
1.9.3

