Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406Ab3JJPPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:15:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] gss_krb5: document that we ignore sequence number
Date: Thu, 10 Oct 2013 11:15:03 -0400
Message-Id: <1381418103-3852-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1381418103-3852-1-git-send-email-bfields@redhat.com>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A couple times recently somebody has noticed that we're ignoring a
sequence number here and wondered whether there's a bug.

In fact, there's not.  Thanks to Andy Adamson for pointing out a useful
explanation in rfc 2203.  Add comments citing that rfc, and remove
"seqnum" to prevent static checkers complaining about unused variables.

Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    8 ++++----
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 ++++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 6cd930f..6c981dd 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -150,7 +150,6 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 	struct xdr_netobj cksumobj = {.len = sizeof(cksumdata),
 				      .data = cksumdata};
 	s32 now;
-	u64 seqnum;
 	u8 *ptr = read_token->data;
 	u8 *cksumkey;
 	u8 flags;
@@ -197,9 +196,10 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 	if (now > ctx->endtime)
 		return GSS_S_CONTEXT_EXPIRED;
 
-	/* do sequencing checks */
-
-	seqnum = be64_to_cpup((__be64 *)ptr + 8);
+	/*
+	 * NOTE: the sequence number at ptr + 8 is skipped, rpcsec_gss
+	 * doesn't want it checked; see page 6 of rfc 2203.
+	 */
 
 	return GSS_S_COMPLETE;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 1da52d1..5040a46 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -489,7 +489,6 @@ static u32
 gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 {
 	s32		now;
-	u64		seqnum;
 	u8		*ptr;
 	u8		flags = 0x00;
 	u16		ec, rrc;
@@ -525,7 +524,10 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	ec = be16_to_cpup((__be16 *)(ptr + 4));
 	rrc = be16_to_cpup((__be16 *)(ptr + 6));
 
-	seqnum = be64_to_cpup((__be64 *)(ptr + 8));
+	/*
+	 * NOTE: the sequence number at ptr + 8 is skipped, rpcsec_gss
+	 * doesn't want it checked; see page 6 of rfc 2203.
+	 */
 
 	if (rrc != 0)
 		rotate_left(offset + 16, buf, rrc);
-- 
1.7.9.5

