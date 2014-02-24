Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbaBXWIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 17:08:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 5/5] nfsd4: make set of large acl return efbig, not resource
Date: Mon, 24 Feb 2014 17:08:47 -0500
Message-Id: <1393279727-29437-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1393279727-29437-1-git-send-email-bfields@redhat.com>
References: <1393279727-29437-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If a client attempts to set an excessively large ACL, return
NFS4ERR_FBIG instead of NFS4ERR_RESOURCE.  I'm not sure FBIG is correct,
but I'm positive RESOURCE is wrong (it isn't even a well-defined error
any more for NFS versions since 4.1).

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d214359..aa04a6a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -294,7 +294,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		READ32(nace);
 
 		if (nace > NFS4_ACL_MAX)
-			return nfserr_resource;
+			return nfserr_fbig;
 
 		*acl = nfs4_acl_new(nace);
 		if (*acl == NULL)
-- 
1.7.9.5

