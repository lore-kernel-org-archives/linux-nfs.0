Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43475 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650AbaEVTcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 40/52] nfsd4: estimate sequence response size
Date: Thu, 22 May 2014 15:32:15 -0400
Message-Id: <1400787148-25941-41-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Otherwise a following patch would turn off all 4.1 zero-copy reads.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7c3df68..f5f608d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1567,6 +1567,12 @@ static inline u32 nfsd4_rename_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op
 		+ op_encode_change_info_maxsz) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_sequence_rsize(struct svc_rqst *rqstp,
+				       struct nfsd4_op *op)
+{
+	return NFS4_MAX_SESSIONID_LEN + 20;
+}
+
 static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	return (op_encode_hdr_size + nfs4_fattr_bitmap_maxsz) * sizeof(__be32);
-- 
1.9.0

