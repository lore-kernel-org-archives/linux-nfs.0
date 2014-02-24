Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbaBXWIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 17:08:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 3/5] nfsd4: fix test_stateid error reply encoding
Date: Mon, 24 Feb 2014 17:08:45 -0500
Message-Id: <1393279727-29437-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1393279727-29437-1-git-send-email-bfields@redhat.com>
References: <1393279727-29437-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If the entire operation fails then there's nothing to encode.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 668bfe1..d214359 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3473,6 +3473,9 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct nfsd4_test_stateid_id *stateid, *next;
 	__be32 *p;
 
+	if (nfserr)
+		return nfserr;
+
 	RESERVE_SPACE(4 + (4 * test_stateid->ts_num_ids));
 	*p++ = htonl(test_stateid->ts_num_ids);
 
-- 
1.7.9.5

