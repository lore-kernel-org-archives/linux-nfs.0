Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4612 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464Ab1D0SxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 14:53:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Return meaningful status from decode_secinfo()
Date: Wed, 27 Apr 2011 14:53:06 -0400
Message-Id: <1303930386-30688-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

When compiling, I was getting this warning:
fs/nfs/nfs4xdr.c: In function ‘decode_secinfo’:
fs/nfs/nfs4xdr.c:4839:6: warning: variable ‘status’ set but not used
[-Wunused-but-set-variable]

We were unconditionally returning 0 as long as there wasn't an error
coming out of xdr_inline_decode().  We probably want to check the error
status coming out of decode_op_hdr() and decode_secinfo_gss(), rather
than assuming that everything is OK all the time.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4xdr.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dddfb57..58768f9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4841,6 +4841,9 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 	int i;
 
 	status = decode_op_hdr(xdr, OP_SECINFO);
+	if (status)
+		goto out;
+
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -4857,13 +4860,14 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 		sec_flavor->flavor = be32_to_cpup(p);
 
 		if (sec_flavor->flavor == RPC_AUTH_GSS) {
-			if (decode_secinfo_gss(xdr, sec_flavor))
+			status = decode_secinfo_gss(xdr, sec_flavor);
+			if (status)
 				break;
 		}
 	}
 
-	return 0;
-
+out:
+	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
-- 
1.7.4.4

