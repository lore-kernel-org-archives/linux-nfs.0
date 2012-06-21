Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932781Ab2FUVvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFSv3: Don't open code stream position calculation in decode_getacl3resok
Date: Thu, 21 Jun 2012 17:51:26 -0400
Message-Id: <1340315487-18309-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-5-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new xdr_stream_pos() helper instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d64a00f..5013bdd 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2341,7 +2341,7 @@ static inline int decode_getacl3resok(struct xdr_stream *xdr,
 	if (result->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
 		goto out;
 
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	hdrlen = xdr_stream_pos(xdr);
 
 	acl = NULL;
 	if (result->mask & NFS_ACL)
-- 
1.7.10.2

