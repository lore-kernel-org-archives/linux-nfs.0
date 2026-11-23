Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795425777;
	b=3evquYOOi7X0lL72Drc6IGDiv1hOORDr5twkOrlqRuOXsXuenF/hHwPxZdflOaQCvre4
	 5fjsLrPOUhZRd1Tt2D0O4Z/iVFq6latvtjwj2xhYgqOoHq6K9K5WG4Rl3Rc83Bicwfp62
	 V6H7SNdl4K2eg1V4ezFxibzn9k9YeFOJ/pPpUe+vHSBjf0MkirSxK8XUWuqb/xl5O9yqh
	 o6QtwBicHc3liBy7U+39GYPAzPzeq+W7Q1+X82V8x7ZNEq7LI7UkmKHWhQ/DWr5WkBZgW
	 oyv99jE0i06iO16dmpCz99hW+lMs64rm9gV3meGMWvznn5QZ79Z6f4ahrE/1c3GAxCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795425777;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=ttihPWyR/NsYsWBX7PZmT0he8Bqcm/yabTw6eBiKhsE=;
	b=5anvseF1RNgFr0NJt6jiqs49rHqaCqY3ikd7Ffo3LFV74WJMkVS98RG0fRq0GSUuisGE
	 ZuFwlKyM9cz5x4mwPLOicUTSggdohAWdzzFJSZe3Zv/8xyNgI+ER6OAlatJW4bkdtIr1i
	 ntEwPPW8wKv2RmOhkmrAAR7o/tytjhw9jxuXaRZwImQdN9LnBlH8CMWRM4YsI9TbJXc/I
	 jl0hCTkHdEf4cNEUIWF4AGLXx2ZZ4+u08MpsUqxXdnBB+HEhQ6qvA7oNfEeNkjGfIRSsv
	 klaKSHGfp7fw95BDy2UitvE4RUfH9SxFpWbxrlqL5lk+QMQPclvtHIIA2U8KCRRISVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Pxj1cEil;
	arc=none smtp.remote-ip=209.85.216.52
Received: from mail-pj1-f52.google.com (mail-pj1-f52.google.com [209.85.216.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC49D606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 09:22:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AC49D606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Pxj1cEil
Received: by mail-pj1-f52.google.com with SMTP id 98e67ed59e1d1-3b3e85baf7cso1717965a91.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 01:22:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795425776; x=1796030576; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ttihPWyR/NsYsWBX7PZmT0he8Bqcm/yabTw6eBiKhsE=;
        b=Pxj1cEilYU9U9HiM6KCs5PV9LBUFnnF0KjmTokjD8WxMA3mW42tcoG3hVe0pb/omAD
         QxGTFXmiTKAtlGLWGatKHJs+BdlV5bccFryLjBG5OhLiaDqqhNk3CVEODyZ5wa23sH5Q
         Vo75+2c0YoxG8NYIIFDT4q2BwYwTDZtNnIOBxMNht2dC9VmTVhx7YFNwDv2fQqqut03i
         Gebm4y9Jfl3vcBrdOApj1qzThsOZmXj5k6a91+DvbZJFjroN70M3R0mJ0oeIdFSSu3Mr
         iqFxFvwoWXnXsy7D6OfTfJUjEcy9prpMA7EqWRFiLveJjl+QkG34nUHsFmooLgpQ4RgM
         dICQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795425776; x=1796030576;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ttihPWyR/NsYsWBX7PZmT0he8Bqcm/yabTw6eBiKhsE=;
        b=ttEoEA3ZU/+Dgz6q5IV3Mhr5GbV/nFsdGkpwmFJ2oxCiLUtrMZAaVX3pAZJrOV/8ym
         1kCqy9bhWeVsZJHqSZSrpNkYMxc2FHkxmnLrQ20AR1vPhn9nX1YVf8gqk5nEQmmP4L2m
         4EXd9X3bm2FRndCL1Stne6SmBPoN/t2h6WGa5BYNGqDVUJzd99328YqVCE19GkPJEWje
         SrOWuk7zI1IbITQBaAkmrhS0WsOPhOfetZ8NJDKxA8hTkWSV+pM34vAZkHM/7OFqlFTX
         8HntWx9tf2SEaEZI49YqwDyCpj6VAkd2gqoe1bxOn+rbdzpz06sawjCKiFkGnX6m8nsR
         zdnw==
X-Forwarded-Encrypted: i=1; AL+hErFHpfxPlgiWi5JWgB6OcBxPGOsjsf5D5llCY6ukWenCIem/xuC4CvPhmaIh5cnLJfzj1vEnKB+Q87M=@vger.kernel.org
X-Gm-Message-State: APuU4Z+BgoGNYM8eUzrlKA4AY8pLXuuw6Bkb/NWnKljTaOPnbigz0VtO
	VdzmgATWWsW2CatdVo0KlhO6q6ZMRheBrrYL8uM5jDQtZaBUQYBc8o6u
X-Gm-Gg: AZFdTZdU7jWAemUJpKfA++gFxv77A+7E9WejJNYpuhiiYKDxTDgLUpAQx+jbj4yf0I3
	EqliypjIL4G9zPL7FNh4/2nVb9Tj4S0kkuaBcPIMygSvT2ROrbWDSgJO84fug41uaEtqwnOcjob
	T+YlIV5U5dY9Gmfo6bX4DF9Sf9Ac2XLTiVzVxdh3AWVXSU+rKCW8nY36lpTef6evyonr3RKNXc3
	vJuqB4gQt7NVzPcdg/QOQmCZWMlGRbGpeuXkEe7HLBTVfyzBEQ/FAmXQqiu+joqfVKzHEtAmca1
	4Xisb73g8NfAls7vzbbdQZEd36NJ/yQWGey2MWtUVIlMSswgR58TLoftNCw+G6WWshZEIyFqJ8r
	TsZaNgFzCC7BhmMSLRXHsex3cwde6z8HV1bEDgmnN+Y4dHm0MYx2zPHeUHI+osKtWxg7WffIwlO
	HgSEjsh1xqRGEia1zJ+Kz+GWbzGilCtUITiVjQRMD5qT57iJWvpP406iKzWLr2h2EeYU6o6WVEL
	lLfW8dWFPNO3CH9f/LBSt0gGGCyYrZyiyJiebAmWxLeGzK/RneNfY41Ht81eFVeeet2N1/TdFmi
	0xY3k3+T7dGAoB9IT53A3Zhe4nQHCBTYN12N6Qf/Um439EDgeYf0cPmJ
X-Received: by 2002:a17:90a:e705:b0:3a7:f4d:b23d with SMTP id 98e67ed59e1d1-3b41c97ca8fmr9432433a91.52.1795425775696;
        Mon, 23 Nov 2026 01:22:55 -0800 (PST)
Received: from CSID-DGU-Desktop.tailc339c6.ts.net ([210.94.179.18])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b4afeaaa84sm1401021a91.10.2026.11.23.01.22.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 23 Nov 2026 01:22:55 -0800 (PST)
From: Junyoung Im <jade04342@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	Junyoung Im <jade04342@gmail.com>
Subject: [RFC PATCH 1/1] SUNRPC: complete verified GSS replies after context expiry
Date: Mon, 23 Nov 2026 18:21:04 +0900
Message-Id: <20261123092104.2518133-2-jade04342@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261123092104.2518133-1-jade04342@gmail.com>
References: <20261123092104.2518133-1-jade04342@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An RPCSEC_GSS context can expire while an outstanding request is
waiting for its reply. Even if the server has already executed the
operation, the client rejects the reply verifier, renews its
credentials, and resends the RPC with a new XID.

On NFSv4.0, re-executing non-idempotent operations such as RENAME,
REMOVE, or MKDIR can return ENOENT or EEXIST even though the original
operation succeeded.

Allow an RPCSEC_GSS DATA request to complete using its original reply
after context expiry when the reply passes the required verification
checks and the corresponding request was fully queued to the TCP
socket before the Kerberos context expired.

Match the reply verifier against the request's recorded GSS sequence
numbers, and use the matched sequence number when validating the
integrity- or privacy-protected reply body. Introduce reply-specific
GSS verification callbacks so that Kerberos explicitly distinguishes
cryptographic verification from context lifetime expiry, without
changing the existing strict GSS interfaces.

Record the complete TCP queueing time for each GSS sequence number
and retain the mechanism's actual end time. Limit the exception using
both REALTIME and a fixed BOOTTIME deadline, rejecting it when the
clock evidence is inconsistent. The grace period defaults to 30
seconds, is capped at 120 seconds, and can be disabled.

Accept an expired-context reply provisionally at the verifier stage,
but make the final decision only after all checks required by the
selected security service have completed. A verified original reply
is passed to the RPC result decoder, preserving the actual NFS
result, including NFS errors, without retransmission.

If the original reply cannot be accepted, preserve the existing
credential renewal and retransmission behavior, subject to the
task's retry budget. Ordinary reply verification failures that do
not involve the expiry exception retain their existing handling.

The exception does not permit new requests to use expired contexts,
bypass cryptographic verification, or provide exactly-once semantics
when the original reply cannot be recovered.

Link: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2173036
Signed-off-by: Junyoung Im <jade04342@gmail.com>
---
 include/linux/sunrpc/auth_gss.h         |  10 ++
 include/linux/sunrpc/gss_api.h          |  38 +++++
 include/linux/sunrpc/xprt.h             |  44 +++++
 net/sunrpc/auth_gss/auth_gss.c          | 205 +++++++++++++++++++++---
 net/sunrpc/auth_gss/gss_krb5_internal.h |  10 ++
 net/sunrpc/auth_gss/gss_krb5_mech.c     |  24 +++
 net/sunrpc/auth_gss/gss_krb5_unseal.c   |  52 ++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c     |  53 +++++-
 net/sunrpc/auth_gss/gss_mech_switch.c   |  39 +++++
 net/sunrpc/clnt.c                       |  57 ++++++-
 net/sunrpc/xprt.c                       |  58 +++++++
 net/sunrpc/xprtsock.c                   |   1 +
 12 files changed, 551 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 43e481aa3..0e45a538b 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -76,6 +76,16 @@ struct gss_cl_ctx {
 	struct xdr_netobj	gc_acceptor;
 	u32			gc_win;
 	unsigned long		gc_expiry;
+	/* Expired-reply exception, fixed when the context is imported.
+	 * gc_exc_end_* is the mechanism's end time on REALTIME and on
+	 * BOOTTIME, gc_exc_deadline_* that plus the grace period, all in
+	 * ns; gc_exc_clock_set_seq is the clock-was-set generation they
+	 * were computed in.  gc_exc_end_boot == 0: no exception. */
+	s64			gc_exc_end_real;
+	s64			gc_exc_deadline_real;
+	u64			gc_exc_end_boot;
+	u64			gc_exc_deadline_boot;
+	u32			gc_exc_clock_set_seq;
 	struct rcu_head		gc_rcu;
 };
 
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index bf4ac8a02..adb34ef20 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -69,6 +69,34 @@ u32 gss_unwrap(
 		int			offset,
 		int			len,
 		struct xdr_buf		*inbuf);
+
+/*
+ * Outcome of checking a received reply token.  GSS_RX_VERIFIED_EXPIRED
+ * means the mechanism completed every cryptographic check (and, for
+ * unwrap, left the buffer ready to decode), and only the context
+ * lifetime had passed.  It is reported only by mechanisms that say so
+ * explicitly; it does not by itself make a reply acceptable.
+ */
+enum gss_rx_verdict {
+	GSS_RX_INVALID,
+	GSS_RX_VERIFIED,
+	GSS_RX_VERIFIED_EXPIRED,
+};
+
+struct gss_rx_result {
+	u32			major_status;
+	enum gss_rx_verdict	verdict;
+};
+
+struct gss_rx_result gss_verify_mic_reply(
+		struct gss_ctx		*ctx_id,
+		struct xdr_buf		*message,
+		struct xdr_netobj	*mic_token);
+struct gss_rx_result gss_unwrap_reply(
+		struct gss_ctx		*ctx_id,
+		int			offset,
+		int			len,
+		struct xdr_buf		*inbuf);
 u32 gss_delete_sec_context(
 		struct gss_ctx		**ctx_id);
 
@@ -133,6 +161,16 @@ struct gss_api_ops {
 			struct xdr_buf		*buf);
 	void (*gss_delete_sec_context)(
 			void			*internal_ctx_id);
+	/* Optional: report verification and expiry separately. */
+	struct gss_rx_result (*gss_verify_mic_reply)(
+			struct gss_ctx		*ctx_id,
+			struct xdr_buf		*message,
+			struct xdr_netobj	*mic_token);
+	struct gss_rx_result (*gss_unwrap_reply)(
+			struct gss_ctx		*ctx_id,
+			int			offset,
+			int			len,
+			struct xdr_buf		*buf);
 };
 
 int gss_mech_register(struct gss_api_mech *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 780eaa157..8387c0c44 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -53,6 +53,36 @@ struct net;
 /*
  * This describes a complete RPC request
  */
+/*
+ * RPCSEC_GSS expired-reply exception.  A clock reading taken from one
+ * timekeeper snapshot: REALTIME plus the clock-was-set generation, and
+ * BOOTTIME read right after it.
+ */
+struct rpc_gss_clock {
+	s64			real_ns;
+	u64			boot_ns;
+	u32			clock_set_seq;
+	bool			valid;
+};
+
+/* When the complete record carrying one encoded GSS sequence number was
+ * first accepted by the local TCP socket.  @queued is set last. */
+struct rpc_gss_tx_stamp {
+	bool			queued;
+	struct rpc_gss_clock	clock;
+};
+
+/* Verification state of the reply being decoded. */
+struct rpc_gss_rx_state {
+	u32			verified_seqno;	/* matched by the verifier */
+	bool			header_verified;
+	bool			body_verified;	/* krb5i MIC / krb5p unwrap */
+	bool			expired_seen;	/* exception candidate */
+	bool			retry_expired_reply;
+					/* exception failed: renew the
+					 * credential and resend */
+};
+
 struct rpc_rqst {
 	/*
 	 * This is the user-visible part
@@ -70,6 +100,14 @@ struct rpc_rqst {
 	int			rq_cong;	/* has incremented xprt->cong */
 	u32			rq_seqnos[RPC_GSS_SEQNO_ARRAY_SIZE];	/* past gss req seq nos. */
 	unsigned int		rq_seqno_count;	/* number of entries in rq_seqnos */
+	struct rpc_gss_tx_stamp	rq_gss_tx[RPC_GSS_SEQNO_ARRAY_SIZE];
+					/* parallel to rq_seqnos[] */
+	struct rpc_gss_rx_state	rq_gss_rx;
+	bool			rq_verf_provisional;
+					/* verifier accepted only for an
+					 * expired context: a successful
+					 * reply may still complete, nothing
+					 * else may */
 	int			rq_enc_pages_num;
 	struct page		**rq_enc_pages;	/* scratch pages for use by
 						   gss privacy code */
@@ -135,10 +173,16 @@ static inline int xprt_rqst_add_seqno(struct rpc_rqst *req, u32 seqno)
 	/* Shift array to make room for the newest element at the beginning */
 	memmove(&req->rq_seqnos[1], &req->rq_seqnos[0],
 		(RPC_GSS_SEQNO_ARRAY_SIZE - 1) * sizeof(req->rq_seqnos[0]));
+	memmove(&req->rq_gss_tx[1], &req->rq_gss_tx[0],
+		(RPC_GSS_SEQNO_ARRAY_SIZE - 1) * sizeof(req->rq_gss_tx[0]));
 	req->rq_seqnos[0] = seqno;
+	memset(&req->rq_gss_tx[0], 0, sizeof(req->rq_gss_tx[0]));
 	return 0;
 }
 
+void xprt_gss_clock_sample(struct rpc_gss_clock *clk);
+void xprt_rqst_note_record_queued(struct rpc_rqst *req);
+
 /* RPC transport layer security policies */
 enum xprtsec_policies {
 	RPC_XPRTSEC_NONE = 0,
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e89..a1bbb1942 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/gss_api.h>
 #include <linux/uaccess.h>
 #include <linux/hashtable.h>
+#include <linux/overflow.h>
 
 #include "auth_gss_internal.h"
 #include "../netns.h"
@@ -46,6 +47,11 @@ static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
 
 #define GSS_KEY_EXPIRE_TIMEO 240
 static unsigned int gss_key_expire_timeo = GSS_KEY_EXPIRE_TIMEO;
+/* Seconds after the Kerberos end time during which a reply whose
+ * MIC/unwrap is cryptographically valid may still complete its request.
+ * Read once per context at import; 0 disables the exception. */
+#define GSS_EXPIRED_REPLY_GRACE_MAX 120
+static unsigned int gss_expired_reply_grace = 30;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -175,6 +181,48 @@ gss_alloc_context(void)
 }
 
 #define GSSD_MIN_TIMEOUT (60 * 60)
+
+/*
+ * Fix the expired-reply exception window when the context is imported:
+ * the mechanism's end time on REALTIME (as the mechanism itself checks
+ * it) and the same instant on BOOTTIME, each plus the grace period read
+ * now.  Both are checked later, and only while the clock-was-set
+ * generation is unchanged, so neither a forward nor a backward step of
+ * the wall clock can stretch the window.  Any doubt disables it.
+ */
+static void gss_set_expired_reply_window(struct gss_cl_ctx *ctx,
+					 time64_t krb_end)
+{
+	unsigned int grace = min_t(unsigned int,
+				   READ_ONCE(gss_expired_reply_grace),
+				   GSS_EXPIRED_REPLY_GRACE_MAX);
+	s64 grace_ns = (s64)grace * NSEC_PER_SEC;
+	s64 end_real, deadline_real, left;
+	u64 end_boot, deadline_boot;
+	struct rpc_gss_clock now;
+
+	ctx->gc_exc_end_boot = 0;
+	if (krb_end <= 0 || !grace)
+		return;
+	if (check_mul_overflow((s64)krb_end, (s64)NSEC_PER_SEC, &end_real) ||
+	    check_add_overflow(end_real, grace_ns, &deadline_real))
+		return;
+	/* now.real_ns is read after now.boot_ns, so end_boot is never late */
+	xprt_gss_clock_sample(&now);
+	if (!now.valid)
+		return;
+	if (check_sub_overflow(end_real, now.real_ns, &left) || left <= 0)
+		return;
+	if (check_add_overflow(now.boot_ns, (u64)left, &end_boot) ||
+	    check_add_overflow(end_boot, (u64)grace_ns, &deadline_boot))
+		return;
+	ctx->gc_exc_end_real = end_real;
+	ctx->gc_exc_deadline_real = deadline_real;
+	ctx->gc_exc_deadline_boot = deadline_boot;
+	ctx->gc_exc_clock_set_seq = now.clock_set_seq;
+	ctx->gc_exc_end_boot = end_boot;
+}
+
 static const void *
 gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct gss_api_mech *gm)
 {
@@ -182,6 +230,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	unsigned int seclen;
 	unsigned int timeout;
 	unsigned long now = jiffies;
+	time64_t krb_end = 0;
 	u32 window_size;
 	int ret;
 
@@ -227,12 +276,14 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		p = ERR_PTR(-EFAULT);
 		goto err;
 	}
-	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, NULL, GFP_KERNEL);
+	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx,
+				     &krb_end, GFP_KERNEL);
 	if (ret < 0) {
 		trace_rpcgss_import_ctx(ret);
 		p = ERR_PTR(ret);
 		goto err;
 	}
+	gss_set_expired_reply_window(ctx, krb_end);
 
 	/* is there any trailing data? */
 	if (q == end) {
@@ -1674,7 +1725,70 @@ gss_refresh_null(struct rpc_task *task)
 	return 0;
 }
 
-static u32
+static bool gss_use_reply_seqno(const struct gss_cl_ctx *ctx)
+{
+	return ctx->gc_proc == RPC_GSS_PROC_DATA;
+}
+
+/*
+ * The mechanism verified a reply token for @seqno and saw only that the
+ * context had expired.  The reply may still complete the request when
+ * every one of these holds now:
+ *  - the request is an RPCSEC_GSS DATA request and the context has an
+ *    exception window;
+ *  - @seqno is one of this request's encoded sequence numbers, and the
+ *    whole record carrying it was accepted by the local TCP socket before
+ *    the mechanism's end time on both REALTIME and BOOTTIME;
+ *  - it is no later than end time + grace on both clocks;
+ *  - the wall clock has not been set since the context was imported.
+ */
+static bool gss_reply_exception_allowed(const struct gss_cl_ctx *ctx,
+					const struct rpc_rqst *req, u32 seqno)
+{
+	const struct rpc_gss_tx_stamp *tx = NULL;
+	u32 cseq = ctx->gc_exc_clock_set_seq;
+	struct rpc_gss_clock now;
+	unsigned int i;
+
+	if (!gss_use_reply_seqno(ctx) || !ctx->gc_exc_end_boot)
+		return false;
+	for (i = 0; i < req->rq_seqno_count; i++)
+		if (req->rq_seqnos[i] == seqno) {
+			tx = &req->rq_gss_tx[i];
+			break;
+		}
+	if (!tx || !smp_load_acquire(&tx->queued) || !tx->clock.valid)
+		return false;
+	xprt_gss_clock_sample(&now);
+	if (!now.valid || tx->clock.clock_set_seq != cseq ||
+	    now.clock_set_seq != cseq)
+		return false;
+	if (tx->clock.real_ns >= ctx->gc_exc_end_real ||
+	    tx->clock.boot_ns >= ctx->gc_exc_end_boot)
+		return false;
+	return now.real_ns <= ctx->gc_exc_deadline_real &&
+	       now.boot_ns <= ctx->gc_exc_deadline_boot;
+}
+
+/*
+ * Final decision for a reply that saw an expired context, made once just
+ * before the RPC result is decoded: every check the service needs passed
+ * for the same sequence number, and the exception still holds.
+ */
+static bool gss_expired_reply_complete(const struct gss_cl_ctx *ctx,
+				       u32 service,
+				       const struct rpc_rqst *req)
+{
+	const struct rpc_gss_rx_state *rx = &req->rq_gss_rx;
+
+	if (!rx->header_verified)
+		return false;
+	if (service != RPC_GSS_SVC_NONE && !rx->body_verified)
+		return false;
+	return gss_reply_exception_allowed(ctx, req, rx->verified_seqno);
+}
+
+static struct gss_rx_result
 gss_validate_seqno_mic(struct gss_cl_ctx *ctx, u32 seqno, __be32 *seq, __be32 *p, u32 len)
 {
 	struct kvec iov;
@@ -1687,18 +1801,21 @@ gss_validate_seqno_mic(struct gss_cl_ctx *ctx, u32 seqno, __be32 *seq, __be32 *p
 	xdr_buf_from_iov(&iov, &verf_buf);
 	mic.data = (u8 *)p;
 	mic.len = len;
-	return gss_verify_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
+	return gss_verify_mic_reply(ctx->gc_gss_ctx, &verf_buf, &mic);
 }
 
 static int
 gss_validate(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_cred *cred = req->rq_cred;
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
 	__be32		*p, *seq = NULL;
 	u32		len, maj_stat;
 	int		status;
 	int		i = 1; /* don't recheck the first item */
+	bool bind_seqno = gss_use_reply_seqno(ctx);
+	struct gss_rx_result res;
 
 	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
 	if (!p)
@@ -1712,17 +1829,31 @@ gss_validate(struct rpc_task *task, struct xdr_stream *xdr)
 	if (!p)
 		goto validate_failed;
 
+	if (bind_seqno && !req->rq_seqno_count)
+		goto validate_failed;
 	seq = kmalloc(4, GFP_KERNEL);
 	if (!seq)
 		goto validate_failed;
-	maj_stat = gss_validate_seqno_mic(ctx, task->tk_rqstp->rq_seqnos[0], seq, p, len);
+	res = gss_validate_seqno_mic(ctx, req->rq_seqnos[0], seq, p, len);
 	/* RFC 2203 5.3.3.1 - compute the checksum of each sequence number in the cache */
-	while (unlikely(maj_stat == GSS_S_BAD_SIG && i < task->tk_rqstp->rq_seqno_count))
-		maj_stat = gss_validate_seqno_mic(ctx, task->tk_rqstp->rq_seqnos[i++], seq, p, len);
+	while (unlikely(res.major_status == GSS_S_BAD_SIG && i < req->rq_seqno_count))
+		res = gss_validate_seqno_mic(ctx, req->rq_seqnos[i++], seq, p, len);
+	maj_stat = res.major_status;
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	if (maj_stat)
+	if (res.verdict == GSS_RX_VERIFIED_EXPIRED && bind_seqno &&
+	    gss_reply_exception_allowed(ctx, req, be32_to_cpup(seq))) {
+		/* Provisional: gss_unwrap_resp() decides, and only for a
+		 * reply that rpc_decode_header() finds successful. */
+		req->rq_gss_rx.expired_seen = true;
+		req->rq_verf_provisional = true;
+	} else if (res.verdict != GSS_RX_VERIFIED) {
 		goto bad_mic;
+	}
+	if (bind_seqno) {
+		req->rq_gss_rx.verified_seqno = be32_to_cpup(seq);
+		req->rq_gss_rx.header_verified = true;
+	}
 
 	/* We leave it to unwrap to calculate au_rslack. For now we just
 	 * calculate the length of the verifier: */
@@ -1991,7 +2122,9 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 		      struct xdr_stream *xdr)
 {
 	struct xdr_buf gss_data, *rcv_buf = &rqstp->rq_rcv_buf;
+	u32 expected_seqno = rqstp->rq_gss_rx.verified_seqno;
 	u32 len, offset, seqno, maj_stat;
+	struct gss_rx_result res;
 	struct xdr_netobj mic;
 	int ret;
 
@@ -2006,7 +2139,7 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 	offset = rcv_buf->len - xdr_stream_remaining(xdr);
 	if (xdr_stream_decode_u32(xdr, &seqno))
 		goto unwrap_failed;
-	if (seqno != *rqstp->rq_seqnos)
+	if (seqno != expected_seqno)
 		goto bad_seqno;
 	if (xdr_buf_subsegment(rcv_buf, &gss_data, offset, len))
 		goto unwrap_failed;
@@ -2033,11 +2166,15 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 	if (read_bytes_from_xdr_buf(rcv_buf, offset, mic.data, mic.len))
 		goto unwrap_failed;
 
-	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &gss_data, &mic);
+	res = gss_verify_mic_reply(ctx->gc_gss_ctx, &gss_data, &mic);
+	maj_stat = res.major_status;
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	if (maj_stat != GSS_S_COMPLETE)
+	if (res.verdict == GSS_RX_VERIFIED_EXPIRED)
+		rqstp->rq_gss_rx.expired_seen = true;
+	else if (res.verdict != GSS_RX_VERIFIED)
 		goto bad_mic;
+	rqstp->rq_gss_rx.body_verified = true;
 
 	gss_update_rslack(task, cred, 2, 2 + 1 + XDR_QUADLEN(mic.len));
 	ret = 0;
@@ -2050,7 +2187,7 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 	trace_rpcgss_unwrap_failed(task);
 	goto out;
 bad_seqno:
-	trace_rpcgss_bad_seqno(task, *rqstp->rq_seqnos, seqno);
+	trace_rpcgss_bad_seqno(task, expected_seqno, seqno);
 	goto out;
 bad_mic:
 	trace_rpcgss_verify_mic(task, maj_stat);
@@ -2064,7 +2201,9 @@ gss_unwrap_resp_priv(struct rpc_task *task, struct rpc_cred *cred,
 {
 	struct xdr_buf *rcv_buf = &rqstp->rq_rcv_buf;
 	struct kvec *head = rqstp->rq_rcv_buf.head;
+	u32 expected_seqno = rqstp->rq_gss_rx.verified_seqno;
 	u32 offset, opaque_len, maj_stat;
+	struct gss_rx_result res;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
@@ -2079,15 +2218,19 @@ gss_unwrap_resp_priv(struct rpc_task *task, struct rpc_cred *cred,
 	if (opaque_len <= GSS_KRB5_TOK_HDR_LEN)
 		goto unwrap_failed;
 
-	maj_stat = gss_unwrap(ctx->gc_gss_ctx, offset,
-			      offset + opaque_len, rcv_buf);
+	res = gss_unwrap_reply(ctx->gc_gss_ctx, offset,
+			       offset + opaque_len, rcv_buf);
+	maj_stat = res.major_status;
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	if (maj_stat != GSS_S_COMPLETE)
+	if (res.verdict == GSS_RX_VERIFIED_EXPIRED)
+		rqstp->rq_gss_rx.expired_seen = true;
+	else if (res.verdict != GSS_RX_VERIFIED)
 		goto bad_unwrap;
 	/* gss_unwrap decrypted the sequence number */
-	if (be32_to_cpup(p++) != *rqstp->rq_seqnos)
+	if (be32_to_cpup(p++) != expected_seqno)
 		goto bad_seqno;
+	rqstp->rq_gss_rx.body_verified = true;
 
 	/* gss_unwrap redacts the opaque blob from the head iovec.
 	 * rcv_buf has changed, thus the stream needs to be reset.
@@ -2102,7 +2245,7 @@ gss_unwrap_resp_priv(struct rpc_task *task, struct rpc_cred *cred,
 	trace_rpcgss_unwrap_failed(task);
 	return -EIO;
 bad_seqno:
-	trace_rpcgss_bad_seqno(task, *rqstp->rq_seqnos, be32_to_cpup(--p));
+	trace_rpcgss_bad_seqno(task, expected_seqno, be32_to_cpup(--p));
 	return -EIO;
 bad_unwrap:
 	trace_rpcgss_unwrap(task, maj_stat);
@@ -2164,6 +2307,8 @@ gss_unwrap_resp(struct rpc_task *task, struct xdr_stream *xdr)
 
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
 		goto out_decode;
+	if (!rqstp->rq_gss_rx.header_verified)
+		goto out;
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
 		status = gss_unwrap_resp_auth(task, cred);
@@ -2175,8 +2320,23 @@ gss_unwrap_resp(struct rpc_task *task, struct xdr_stream *xdr)
 		status = gss_unwrap_resp_priv(task, cred, ctx, rqstp, xdr);
 		break;
 	}
-	if (status)
+	if (status) {
+		/* Without the exception the provisionally accepted verifier
+		 * would have been refused as a stale credential: recover the
+		 * same way (see call_decode()). */
+		if (rqstp->rq_verf_provisional)
+			rqstp->rq_gss_rx.retry_expired_reply = true;
 		goto out;
+	}
+	/* A reply that saw an expired context is used only if the exception
+	 * still holds now.  Otherwise it is handled like a verifier refused
+	 * for an expired context: renew the credential and resend. */
+	if (rqstp->rq_gss_rx.expired_seen &&
+	    !gss_expired_reply_complete(ctx, gss_cred->gc_service, rqstp)) {
+		rqstp->rq_gss_rx.retry_expired_reply = true;
+		status = -EIO;
+		goto out;
+	}
 
 out_decode:
 	status = rpcauth_unwrap_resp_decode(task, xdr);
@@ -2306,5 +2466,14 @@ MODULE_PARM_DESC(key_expire_timeo, "Time (in seconds) at the end of a "
 		"credential keys lifetime where the NFS layer cleans up "
 		"prior to key expiration");
 
+module_param_named(expired_reply_grace,
+		   gss_expired_reply_grace,
+		   uint, 0644);
+MODULE_PARM_DESC(expired_reply_grace, "Seconds after the Kerberos context "
+		"end time during which a cryptographically verified reply to "
+		"a request fully queued before that end time completes the "
+		"request instead of being resent (0 disables, max 120; read "
+		"when a context is created)");
+
 module_init(init_rpcsec_gss)
 module_exit(exit_rpcsec_gss)
diff --git a/net/sunrpc/auth_gss/gss_krb5_internal.h b/net/sunrpc/auth_gss/gss_krb5_internal.h
index 3b392e96f..78ecd36bb 100644
--- a/net/sunrpc/auth_gss/gss_krb5_internal.h
+++ b/net/sunrpc/auth_gss/gss_krb5_internal.h
@@ -48,6 +48,16 @@ u32 gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
 		       struct xdr_buf *buf, unsigned int *slack,
 		       unsigned int *align);
 
+struct gss_rx_result
+gss_krb5_verify_mic_v2_reply(struct krb5_ctx *ctx,
+			     struct xdr_buf *message_buffer,
+			     struct xdr_netobj *read_token);
+
+struct gss_rx_result
+gss_krb5_unwrap_v2_reply(struct krb5_ctx *kctx, int offset, int len,
+			 struct xdr_buf *buf, unsigned int *slack,
+			 unsigned int *align);
+
 /*
  * Implementation internal functions
  */
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index c41b5f3e1..9b40924c5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -330,6 +330,28 @@ static u32 gss_krb5_unwrap(struct gss_ctx *gctx, int offset,
 				  &gctx->slack, &gctx->align);
 }
 
+/*
+ * Reply variants: as gss_krb5_verify_mic and gss_krb5_unwrap, but a token
+ * that passed every cryptographic check on an expired context is
+ * reported as GSS_RX_VERIFIED_EXPIRED (unwrap: with @buf fully unwrapped).
+ */
+static struct gss_rx_result
+gss_krb5_verify_mic_reply(struct gss_ctx *gctx,
+			  struct xdr_buf *message_buffer,
+			  struct xdr_netobj *read_token)
+{
+	return gss_krb5_verify_mic_v2_reply(gctx->internal_ctx_id,
+					    message_buffer, read_token);
+}
+
+static struct gss_rx_result
+gss_krb5_unwrap_reply(struct gss_ctx *gctx, int offset, int len,
+		      struct xdr_buf *buf)
+{
+	return gss_krb5_unwrap_v2_reply(gctx->internal_ctx_id, offset, len,
+					buf, &gctx->slack, &gctx->align);
+}
+
 static const struct gss_api_ops gss_kerberos_ops = {
 	.gss_import_sec_context	= gss_krb5_import_sec_context,
 	.gss_get_mic		= gss_krb5_get_mic,
@@ -337,6 +359,8 @@ static const struct gss_api_ops gss_kerberos_ops = {
 	.gss_wrap		= gss_krb5_wrap,
 	.gss_unwrap		= gss_krb5_unwrap,
 	.gss_delete_sec_context	= gss_krb5_delete_sec_context,
+	.gss_verify_mic_reply	= gss_krb5_verify_mic_reply,
+	.gss_unwrap_reply	= gss_krb5_unwrap_reply,
 };
 
 static struct pf_desc gss_kerberos_pfs[] = {
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 4d12d4943..d643a982d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -69,9 +69,10 @@
 # define RPCDBG_FACILITY        RPCDBG_AUTH
 #endif
 
-u32
-gss_krb5_verify_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
-		       struct xdr_netobj *read_token)
+/* Check the MIC token only; the caller decides about the lifetime. */
+static u32
+gss_krb5_check_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
+		      struct xdr_netobj *read_token)
 {
 	const struct krb5_enctype *krb5 = ctx->krb5e;
 	struct crypto_shash *shash = ctx->initiate ?
@@ -82,7 +83,6 @@ gss_krb5_verify_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
 	size_t mic_offset, mic_len;
 	u8 *ptr = read_token->data;
 	__be16 be16_ptr;
-	time64_t now;
 	u8 flags;
 	int nsg, i;
 	int ret;
@@ -125,11 +125,6 @@ gss_krb5_verify_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
 	if (ret)
 		return gss_krb5_errno_to_status(ret);
 
-	/* it got through unscathed.  Make sure the context is unexpired */
-	now = ktime_get_real_seconds();
-	if (now > ctx->endtime)
-		return GSS_S_CONTEXT_EXPIRED;
-
 	/*
 	 * NOTE: the sequence number at ptr + 8 is skipped, rpcsec_gss
 	 * doesn't want it checked; see page 6 of rfc 2203.
@@ -137,3 +132,42 @@ gss_krb5_verify_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
 
 	return GSS_S_COMPLETE;
 }
+
+u32
+gss_krb5_verify_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *message_buffer,
+		       struct xdr_netobj *read_token)
+{
+	u32 maj_stat = gss_krb5_check_mic_v2(ctx, message_buffer, read_token);
+
+	if (maj_stat != GSS_S_COMPLETE)
+		return maj_stat;
+
+	/* it got through unscathed.  Make sure the context is unexpired */
+	if (ktime_get_real_seconds() > ctx->endtime)
+		return GSS_S_CONTEXT_EXPIRED;
+	return GSS_S_COMPLETE;
+}
+
+/* As gss_krb5_verify_mic_v2(), but report a verified token separately
+ * from the context lifetime. */
+struct gss_rx_result
+gss_krb5_verify_mic_v2_reply(struct krb5_ctx *ctx,
+			     struct xdr_buf *message_buffer,
+			     struct xdr_netobj *read_token)
+{
+	struct gss_rx_result res = {
+		.major_status = gss_krb5_check_mic_v2(ctx, message_buffer,
+						      read_token),
+		.verdict = GSS_RX_INVALID,
+	};
+
+	if (res.major_status != GSS_S_COMPLETE)
+		return res;
+	if (ktime_get_real_seconds() > ctx->endtime) {
+		res.major_status = GSS_S_CONTEXT_EXPIRED;
+		res.verdict = GSS_RX_VERIFIED_EXPIRED;
+	} else {
+		res.verdict = GSS_RX_VERIFIED;
+	}
+	return res;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index d3f61c4b5..cffde3f65 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -141,10 +141,17 @@ gss_krb5_wrap_v2(struct krb5_ctx *kctx, int offset,
 	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
 }
 
-u32
-gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
-		   struct xdr_buf *buf, unsigned int *slack,
-		   unsigned int *align)
+/*
+ * With @reply_expired NULL this is the strict unwrap: on an expired
+ * context it fails after decryption and before the final XDR unwrap
+ * cleanup, as before.  Otherwise the authenticated token is fully
+ * unwrapped and *@reply_expired says whether the context lifetime had
+ * passed.
+ */
+static u32
+__gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
+		     struct xdr_buf *buf, unsigned int *slack,
+		     unsigned int *align, bool *reply_expired)
 {
 	time64_t	now;
 	u8		*ptr;
@@ -154,6 +161,7 @@ gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
 	u32		headskip, tailskip;
 	u8		decrypted_hdr[GSS_KRB5_TOK_HDR_LEN];
 	unsigned int	movelen;
+	bool		expired;
 
 
 	dprintk("RPC:       %s\n", __func__);
@@ -216,7 +224,8 @@ gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
 
 	/* it got through unscathed.  Make sure the context is unexpired */
 	now = ktime_get_real_seconds();
-	if (now > kctx->endtime)
+	expired = now > kctx->endtime;
+	if (expired && !reply_expired)
 		return GSS_S_CONTEXT_EXPIRED;
 
 	/*
@@ -241,5 +250,39 @@ gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
 
 	*align = XDR_QUADLEN(GSS_KRB5_TOK_HDR_LEN + headskip);
 	*slack = *align + XDR_QUADLEN(ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
+	if (reply_expired)
+		*reply_expired = expired;
 	return GSS_S_COMPLETE;
 }
+
+u32
+gss_krb5_unwrap_v2(struct krb5_ctx *kctx, int offset, int len,
+		   struct xdr_buf *buf, unsigned int *slack,
+		   unsigned int *align)
+{
+	return __gss_krb5_unwrap_v2(kctx, offset, len, buf, slack, align,
+				    NULL);
+}
+
+/* As gss_krb5_unwrap_v2(), but report a verified, fully unwrapped token
+ * separately from the context lifetime. */
+struct gss_rx_result
+gss_krb5_unwrap_v2_reply(struct krb5_ctx *kctx, int offset, int len,
+			 struct xdr_buf *buf, unsigned int *slack,
+			 unsigned int *align)
+{
+	struct gss_rx_result res = { .verdict = GSS_RX_INVALID };
+	bool expired = false;
+
+	res.major_status = __gss_krb5_unwrap_v2(kctx, offset, len, buf,
+						slack, align, &expired);
+	if (res.major_status != GSS_S_COMPLETE)
+		return res;
+	if (expired) {
+		res.major_status = GSS_S_CONTEXT_EXPIRED;
+		res.verdict = GSS_RX_VERIFIED_EXPIRED;
+	} else {
+		res.verdict = GSS_RX_VERIFIED;
+	}
+	return res;
+}
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 78eab245f..eed152fb1 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -423,6 +423,45 @@ gss_unwrap(struct gss_ctx	*ctx_id,
 		->gss_unwrap(ctx_id, offset, len, buf);
 }
 
+/*
+ * gss_verify_mic_reply / gss_unwrap_reply: as gss_verify_mic / gss_unwrap,
+ * but also say whether the token was cryptographically verified.  A
+ * mechanism without the reply callbacks is only ever VERIFIED on
+ * GSS_S_COMPLETE; GSS_S_CONTEXT_EXPIRED from it stays INVALID.
+ */
+struct gss_rx_result
+gss_verify_mic_reply(struct gss_ctx		*ctx_id,
+		     struct xdr_buf		*message,
+		     struct xdr_netobj		*mic_token)
+{
+	const struct gss_api_ops *ops = ctx_id->mech_type->gm_ops;
+	struct gss_rx_result res = { .verdict = GSS_RX_INVALID };
+
+	if (ops->gss_verify_mic_reply)
+		return ops->gss_verify_mic_reply(ctx_id, message, mic_token);
+	res.major_status = ops->gss_verify_mic(ctx_id, message, mic_token);
+	if (res.major_status == GSS_S_COMPLETE)
+		res.verdict = GSS_RX_VERIFIED;
+	return res;
+}
+
+struct gss_rx_result
+gss_unwrap_reply(struct gss_ctx		*ctx_id,
+		 int			offset,
+		 int			len,
+		 struct xdr_buf		*buf)
+{
+	const struct gss_api_ops *ops = ctx_id->mech_type->gm_ops;
+	struct gss_rx_result res = { .verdict = GSS_RX_INVALID };
+
+	if (ops->gss_unwrap_reply)
+		return ops->gss_unwrap_reply(ctx_id, offset, len, buf);
+	res.major_status = ops->gss_unwrap(ctx_id, offset, len, buf);
+	if (res.major_status == GSS_S_COMPLETE)
+		res.verdict = GSS_RX_VERIFIED;
+	return res;
+}
+
 
 /* gss_delete_sec_context: free all resources associated with context_handle.
  * Note this differs from the RFC 2744-specified prototype in that we don't
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2f076b4bf..3d39f2ba3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2667,6 +2667,28 @@ rpc_check_timeout(struct rpc_task *task)
 	rpcauth_invalcred(task);
 }
 
+/*
+ * The auth flavor accepted the reply verifier only provisionally (see
+ * rq_verf_provisional) and then could not use the reply.  Without the
+ * provisional acceptance rpc_decode_header() would have refused the
+ * verifier as a stale credential: recover the same way, renewing the
+ * credential and resending with a new XID within the same retry budget.
+ */
+static void
+rpc_decode_stale_reply(struct rpc_task *task)
+{
+	rpcauth_invalcred(task);
+	if (!task->tk_cred_retry)
+		return;
+	task->tk_cred_retry--;
+	trace_rpc__stale_creds(task);
+	task->tk_status = 0;
+	task->tk_action = call_reserve;
+	rpc_check_timeout(task);
+	/* Ensure we obtain a new XID if we retry! */
+	xprt_release(task);
+}
+
 /*
  * 7.	Decode the RPC reply
  */
@@ -2721,6 +2743,8 @@ call_decode(struct rpc_task *task)
 		task->tk_action = rpc_exit_task;
 		task->tk_status = rpcauth_unwrap_resp(task, &xdr);
 		xdr_finish_decode(&xdr);
+		if (unlikely(req->rq_gss_rx.retry_expired_reply))
+			rpc_decode_stale_reply(task);
 		return;
 	case -EAGAIN:
 		task->tk_status = 0;
@@ -2775,6 +2799,11 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 	int error;
 	__be32 *p;
 
+	/* Nothing the auth flavor learned from an earlier reply carries over */
+	memset(&task->tk_rqstp->rq_gss_rx, 0,
+	       sizeof(task->tk_rqstp->rq_gss_rx));
+	task->tk_rqstp->rq_verf_provisional = false;
+
 	/* RFC-1014 says that the representation of XDR data must be a
 	 * multiple of four bytes
 	 * - if it isn't pointer subtraction in the NFS client may give
@@ -2796,20 +2825,21 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 	if (error) {
 		struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
-		if (!test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags)) {
-			rpcauth_invalcred(task);
-			if (!task->tk_cred_retry)
-				goto out_err;
-			task->tk_cred_retry--;
-			trace_rpc__stale_creds(task);
-			return -EKEYREJECTED;
-		}
+		if (!test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags))
+			goto out_stale_cred;
 		goto out_verifier;
 	}
 
 	p = xdr_inline_decode(xdr, sizeof(*p));
 	if (!p)
 		goto out_unparsable;
+	/* A verifier the auth flavor accepted only provisionally (an expired
+	 * RPCSEC_GSS context) may complete a successful reply, nothing else:
+	 * handle any other reply as the stale credential it would have been. */
+	if (*p != rpc_success && task->tk_rqstp->rq_verf_provisional) {
+		error = -EACCES;
+		goto out_stale_cred;
+	}
 	switch (*p) {
 	case rpc_success:
 		return 0;
@@ -2848,8 +2878,19 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 out_unparsable:
 	trace_rpc__unparsable(task);
 	error = -EIO;
+	/* Likewise for an unparsable reply after a provisional verifier. */
+	if (task->tk_rqstp->rq_verf_provisional)
+		goto out_stale_cred;
 	goto out_garbage;
 
+out_stale_cred:
+	rpcauth_invalcred(task);
+	if (!task->tk_cred_retry)
+		goto out_err;
+	task->tk_cred_retry--;
+	trace_rpc__stale_creds(task);
+	return -EKEYREJECTED;
+
 out_verifier:
 	trace_rpc_bad_verifier(task);
 	switch (error) {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c11080698..70e0e3eaa 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -45,6 +45,7 @@
 #include <linux/workqueue.h>
 #include <linux/net.h>
 #include <linux/ktime.h>
+#include <linux/timekeeping.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
@@ -1975,6 +1976,63 @@ xprt_init_xid(struct rpc_xprt *xprt)
 	xprt->xid = get_random_u32();
 }
 
+/**
+ * xprt_gss_clock_sample - read the clocks used by the GSS expired-reply rule
+ * @clk: filled in; @clk->valid is false unless all fields are set
+ *
+ * BOOTTIME is read between two REALTIME snapshots, and the reading is
+ * valid only if both snapshots are valid and the clock was not set in
+ * between.  @clk->real_ns is the later REALTIME reading, so it is never
+ * earlier than the instant @clk->boot_ns was read.
+ */
+void xprt_gss_clock_sample(struct rpc_gss_clock *clk)
+{
+	struct system_time_snapshot before, after;
+	u64 boot;
+
+	clk->valid = false;
+	ktime_get_snapshot_id(CLOCK_REALTIME, &before);
+	if (!before.valid)
+		return;
+	boot = ktime_get_boottime_ns();
+	ktime_get_snapshot_id(CLOCK_REALTIME, &after);
+	if (!after.valid ||
+	    after.clock_was_set_seq != before.clock_was_set_seq)
+		return;
+	clk->real_ns = ktime_to_ns(after.systime);
+	clk->boot_ns = boot;
+	clk->clock_set_seq = after.clock_was_set_seq;
+	clk->valid = true;
+}
+EXPORT_SYMBOL_GPL(xprt_gss_clock_sample);
+
+/**
+ * xprt_rqst_note_record_queued - the whole record of @req is in the socket
+ * @req: request whose newest encoded GSS sequence number it carries
+ *
+ * Only the first complete send of each encoded sequence number is kept.
+ *
+ * Serialization of rq_gss_tx[]: entries are shifted and created only by
+ * gss_marshal() in the owning task, and read only by that task while it
+ * decodes a reply.  This function runs in xprt_request_transmit() for
+ * whichever task holds the transport; xprt_transmit() pins @req for the
+ * whole send, and call_encode() waits in xprt_request_dequeue_xprt()
+ * until @req is unpinned before encoding again.  So rq_gss_tx[0] is the
+ * entry for the sequence number in rq_snd_buf and does not move while it
+ * is written.  Its fields are written once, before @queued is set with
+ * release semantics; a reader that acquires @queued == true sees them
+ * complete and they do not change until the owning task encodes again.
+ */
+void xprt_rqst_note_record_queued(struct rpc_rqst *req)
+{
+	struct rpc_gss_tx_stamp *tx = &req->rq_gss_tx[0];
+
+	if (!req->rq_seqno_count || READ_ONCE(tx->queued))
+		return;
+	xprt_gss_clock_sample(&tx->clock);
+	smp_store_release(&tx->queued, true);
+}
+
 static void
 xprt_request_init(struct rpc_task *task)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 173e3b0fd..96eb0f929 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1158,6 +1158,7 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 		if (likely(req->rq_bytes_sent >= msglen)) {
 			req->rq_xmit_bytes_sent += transport->xmit.offset;
 			transport->xmit.offset = 0;
+			xprt_rqst_note_record_queued(req);
 			if (atomic_long_read(&xprt->xmit_queuelen) == 1)
 				tcp_sock_set_cork(transport->inet, false);
 			return 0;
-- 
2.34.1

