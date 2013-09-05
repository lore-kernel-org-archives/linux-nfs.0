Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37202 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab3IEPtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 11:49:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] rpc: comment on linux_cred encoding, treat all as unsigned
Date: Thu,  5 Sep 2013 11:49:31 -0400
Message-Id: <1378396173-22352-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1378396173-22352-1-git-send-email-bfields@redhat.com>
References: <1378396173-22352-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The encoding of linux creds is a bit confusing.

Also: I think in practice it doesn't really matter whether we treat any
of these things as signed or unsigned, but unsigned seems more
straightforward: uid_t/gid_t are unsigned and it simplifies the ngroups
overflow check.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index f5067b2..3c19c7d 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -166,14 +166,15 @@ static int dummy_dec_opt_array(struct xdr_stream *xdr,
 	return 0;
 }
 
-static int get_s32(struct xdr_stream *xdr, s32 *res)
+static int get_host_u32(struct xdr_stream *xdr, u32 *res)
 {
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (!p)
 		return -EINVAL;
-	memcpy(res, p, sizeof(s32));
+	/* Contents of linux creds are all host-endian: */
+	memcpy(res, p, sizeof(u32));
 	return 0;
 }
 
@@ -182,8 +183,9 @@ static int gssx_dec_linux_creds(struct xdr_stream *xdr,
 {
 	u32 length;
 	__be32 *p;
-	s32 tmp;
-	int N, i, err;
+	u32 tmp;
+	u32 N;
+	int i, err;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
@@ -195,19 +197,19 @@ static int gssx_dec_linux_creds(struct xdr_stream *xdr,
 		return -ENOSPC;
 
 	/* uid */
-	err = get_s32(xdr, &tmp);
+	err = get_host_u32(xdr, &tmp);
 	if (err)
 		return err;
 	creds->cr_uid = make_kuid(&init_user_ns, tmp);
 
 	/* gid */
-	err = get_s32(xdr, &tmp);
+	err = get_host_u32(xdr, &tmp);
 	if (err)
 		return err;
 	creds->cr_gid = make_kgid(&init_user_ns, tmp);
 
 	/* number of additional gid's */
-	err = get_s32(xdr, &tmp);
+	err = get_host_u32(xdr, &tmp);
 	if (err)
 		return err;
 	N = tmp;
@@ -220,7 +222,7 @@ static int gssx_dec_linux_creds(struct xdr_stream *xdr,
 	/* gid's */
 	for (i = 0; i < N; i++) {
 		kgid_t kgid;
-		err = get_s32(xdr, &tmp);
+		err = get_host_u32(xdr, &tmp);
 		if (err)
 			goto out_free_groups;
 		err = -EINVAL;
-- 
1.7.9.5

