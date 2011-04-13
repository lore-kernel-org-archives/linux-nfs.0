Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47698 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757107Ab1DMSbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 14:31:34 -0400
Message-ID: <4DA5EC03.9000301@netapp.com>
Date: Wed, 13 Apr 2011 14:31:31 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] NFS: Use correct variable for page bounds checking
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


While decoding a secinfo reply, I store the list of supported sec
flavors on a page accessible through res->flavors.  Before reading
each new flavor, I do some math to determine if there is enough
space left on this page, and I break out of my read look if there
isn't.  In order to perform this check correctly, I need to use the
address of res->flavors, rather than the address of res.

When this loop was broken early I lied to the caller and told them
that the entire list had been decoded.  This could lead to problems
if the caller tries to use any the garbage data claiming to be a
valid sec flavor.  I fixed this by using res->flavors->num_flavors
as a counter, incrementing it every time a sec flavor is 
successfully decoded.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4xdr.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dddfb57..ba952bd 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4838,17 +4838,19 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 	struct nfs4_secinfo_flavor *sec_flavor;
 	int status;
 	__be32 *p;
-	int i;
+	int i, num_flavors;
 
 	status = decode_op_hdr(xdr, OP_SECINFO);
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	res->flavors->num_flavors = be32_to_cpup(p);
 
-	for (i = 0; i < res->flavors->num_flavors; i++) {
+	res->flavors->num_flavors = 0;
+	num_flavors = be32_to_cpup(p);
+
+	for (i = 0; i < num_flavors; i++) {
 		sec_flavor = &res->flavors->flavors[i];
-		if ((char *)&sec_flavor[1] - (char *)res > PAGE_SIZE)
+		if ((char *)&sec_flavor[1] - (char *)res->flavors > PAGE_SIZE)
 			break;
 
 		p = xdr_inline_decode(xdr, 4);
@@ -4860,6 +4862,7 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 			if (decode_secinfo_gss(xdr, sec_flavor))
 				break;
 		}
+		res->flavors->num_flavors++;
 	}
 
 	return 0;
-- 
1.7.4.4

