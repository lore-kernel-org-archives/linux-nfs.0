Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50837 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/13] lockd: Remove unnecessary BUG_ON()s in the xdr client code
Date: Mon, 15 Oct 2012 17:31:04 -0400
Message-Id: <1350336667-18770-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Offset bound checks are done in the NFS client code.
- So are filehandle size checks
- The cookie length is a constant
- The utsname()->nodename is already bounded

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/clnt4xdr.c | 8 --------
 fs/lockd/clntxdr.c  | 8 --------
 2 files changed, 16 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 13ad153..00ec0b9 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -64,10 +64,6 @@ static void nlm4_compute_offsets(const struct nlm_lock *lock,
 {
 	const struct file_lock *fl = &lock->fl;
 
-	BUG_ON(fl->fl_start > NLM4_OFFSET_MAX);
-	BUG_ON(fl->fl_end > NLM4_OFFSET_MAX &&
-				fl->fl_end != OFFSET_MAX);
-
 	*l_offset = loff_t_to_s64(fl->fl_start);
 	if (fl->fl_end == OFFSET_MAX)
 		*l_len = 0;
@@ -122,7 +118,6 @@ static void encode_netobj(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	BUG_ON(length > XDR_MAX_NETOBJ);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, data, length);
 }
@@ -156,7 +151,6 @@ out_overflow:
 static void encode_cookie(struct xdr_stream *xdr,
 			  const struct nlm_cookie *cookie)
 {
-	BUG_ON(cookie->len > NLM_MAXCOOKIELEN);
 	encode_netobj(xdr, (u8 *)&cookie->data, cookie->len);
 }
 
@@ -198,7 +192,6 @@ out_overflow:
  */
 static void encode_fh(struct xdr_stream *xdr, const struct nfs_fh *fh)
 {
-	BUG_ON(fh->size > NFS3_FHSIZE);
 	encode_netobj(xdr, (u8 *)&fh->data, fh->size);
 }
 
@@ -336,7 +329,6 @@ static void encode_caller_name(struct xdr_stream *xdr, const char *name)
 	u32 length = strlen(name);
 	__be32 *p;
 
-	BUG_ON(length > NLM_MAXSTRLEN);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, name, length);
 }
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index d269ada..e12fd2a 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -60,10 +60,6 @@ static void nlm_compute_offsets(const struct nlm_lock *lock,
 {
 	const struct file_lock *fl = &lock->fl;
 
-	BUG_ON(fl->fl_start > NLM_OFFSET_MAX);
-	BUG_ON(fl->fl_end > NLM_OFFSET_MAX &&
-				fl->fl_end != OFFSET_MAX);
-
 	*l_offset = loff_t_to_s32(fl->fl_start);
 	if (fl->fl_end == OFFSET_MAX)
 		*l_len = 0;
@@ -119,7 +115,6 @@ static void encode_netobj(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	BUG_ON(length > XDR_MAX_NETOBJ);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, data, length);
 }
@@ -153,7 +148,6 @@ out_overflow:
 static void encode_cookie(struct xdr_stream *xdr,
 			  const struct nlm_cookie *cookie)
 {
-	BUG_ON(cookie->len > NLM_MAXCOOKIELEN);
 	encode_netobj(xdr, (u8 *)&cookie->data, cookie->len);
 }
 
@@ -195,7 +189,6 @@ out_overflow:
  */
 static void encode_fh(struct xdr_stream *xdr, const struct nfs_fh *fh)
 {
-	BUG_ON(fh->size != NFS2_FHSIZE);
 	encode_netobj(xdr, (u8 *)&fh->data, NFS2_FHSIZE);
 }
 
@@ -330,7 +323,6 @@ static void encode_caller_name(struct xdr_stream *xdr, const char *name)
 	u32 length = strlen(name);
 	__be32 *p;
 
-	BUG_ON(length > NLM_MAXSTRLEN);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, name, length);
 }
-- 
1.7.11.7

