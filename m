Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60150 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/6] nfsd4: fix change attribute endianness
Date: Tue,  1 May 2012 11:45:49 -0400
Message-Id: <1335887149-30420-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Though actually this doesn't matter much, as NFSv4.0 clients are
required to treat the change attribute as opaque.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f839be1..61555e7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1674,12 +1674,12 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 
 static void write32(__be32 **p, u32 n)
 {
-	*(*p)++ = n;
+	*(*p)++ = htonl(n);
 }
 
 static void write64(__be32 **p, u64 n)
 {
-	write32(p, (u32)(n >> 32));
+	write32(p, (n >> 32));
 	write32(p, (u32)n);
 }
 
-- 
1.7.9.5

