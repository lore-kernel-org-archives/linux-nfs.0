Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=114.111.35.228
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794460883;
	b=RN8IEab2k0CUMZRK4iEctb47msW/Li0tCVpTNIqmWc4VRkap8yYMMXXf2bmIT/N2IDJv
	 866Zq/x2oPm3VymdlRUr6TQp85Q5GggtWskYGTL88mQqCQ+K+qmatkeqni8BExda0MKZ4
	 bd7E+Pvm56W9pFLZk20SLpVs9dodmfFHhWIfdCPJxdZEiU6fQNEaa9h/QIbVoAPZV/yAc
	 DqfhHAAAie5Oxtqe9UOK3GuE/ZSIQd5OiaQf+D8BYq45bYSG2o52kj2xhqL/sTmdir1A3
	 PS47HgxZxkCfiOjxxfg0uj/3XXQqJjsC+vjlzWtlqoceheTuJ+OhDV0pJXcjzUD1+5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794460883;
	h=DMARC-Filter:X-Originating-IP:Received:DKIM-Signature:X-Session-ID:
	 X-Originating-IP:X-Works-Send-Opt:X-Works-Smtp-Source:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=YQILBZu0VHafbb/PEwV9bvCOruIDFvJhbtzsSaHgXAM=;
	b=p16NZIRhQ7B+tnyEoKo+o3OuPCfmxWFwwYtzeWxpXrlP0dctiSRbKard05lBeuApgm6H
	 6j4Mvv9qK2dbzPg5CkbWOaAogtDJgPoyhPje1qbuIDkJ/Ey2Pl6s9s4OfVcCSkJvf1W3v
	 BV/nTpI/5ICE8bUhExxKDybz94KgYX9uHqKL37SpPl6pNGag6uOmZAqMae1ZVuyEMey1J
	 AsR1Mh1l3oiFm0DrHfEwDSEyHfoIwmUkLm7GahphMyqvA6y+0m21XFj2MqvSYxB9Mc3EE
	 sPnr1QGN8xrlO7HNDQffL/dv7gqmkWXk/eWNUXtIY1XRchmQGlsxHNwrKH55fBXejoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=naver.com;
	spf=pass smtp.mailfrom=naver.com;
	dkim=pass header.d=naver.com header.i=@naver.com header.a=rsa-sha256 header.s=s20171208 header.b=KSHaodhj;
	arc=none smtp.remote-ip=114.111.35.228
Received: from cvsmtppost04.nm.naver.com (cvsmtppost04.nm.naver.com [114.111.35.228])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC3E3606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 05:21:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC3E3606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=naver.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=naver.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=naver.com header.i=@naver.com header.a=rsa-sha256 header.s=s20171208 header.b=KSHaodhj
Received: from nv1m-hmac-real-22 ([10.174.201.121])
  by cvsmtppost04.nm.naver.com with ESMTP id QK+B9BGtTL2yYg8UEzhgyw
  for <linux-nfs@vger.kernel.org>;
  Thu, 12 Nov 2026 05:21:13 -0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=naver.com; s=s20171208;
	t=1794460873; bh=xboaKLdhNKtTVxezqECN7DIxSaQRxHU8Z6jdWDtqAIM=;
	h=From:To:Subject:Date:Message-ID:From:Subject:Feedback-ID:
	 X-Works-Security;
	b=KSHaodhjdgihkA79nj2IhwoAFm1zMwVcQnxGj/u75t5thekqoETzA6mAhNZNFHR4M
	 If/yZD4IibmmUvHWnmW5K8hZ63hx8CmKqtNk8wpSw1WiPAezkzHHJXg948OkfjX2xI
	 rXvQnyCgacqQKRqMxHJ6ze9E6YPTXEuzJ+sq/a7bAtYj4np7uJUtCHpWHUN2w7IePb
	 0L6iehGrrlhuz1aNWqJmpmuhedEwCpc8w9u1MtTAJzMHNZQxvWleJhOEPkM3VWR4QU
	 yzW6ZM9oZL3Ki9JOHLr6xboUxzKG3Kuq7vUBATT2AcRUt/Kw3W7KeBET7npN3tws+y
	 HptElgjStAk7g==
X-Session-ID: QvtsGinwSyqTmVBfuZdBAw
X-Works-Send-Opt: C9+CWNFNjHmqjAIYFrkOjAuZaAUwaAt9FxJYEu9YKBmm
X-Works-Smtp-Source: sdnZFAtlFqJZ+HmqFqt/+6E=
Received: from localhost.localdomain ([123.215.20.15])
  by cvnsmtp009.nm.naver.com with ESMTP id QvtsGinwSyqTmVBfuZdBAw
  for <multiple recipients>
  (version=TLSv1.3 cipher=TLS_CHACHA20_POLY1305_SHA256);
  Thu, 12 Nov 2026 05:21:13 -0000
From: Minsu Kim <gsnake7@naver.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org,
	bobtobabz@gmail.com
Subject: [PATCH] rpc.svcgssd: stop using raw pointers as continuation handles
Date: Thu, 12 Nov 2026 14:20:53 +0900
Message-ID: <20261112052054.29215-1-gsnake7@naver.com>
X-Mailer: git-send-email 2.53.0
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

rpc.svcgssd currently serializes gss_ctx_id_t itself as the continuation
handle when gss_accept_sec_context() returns GSS_S_CONTINUE_NEEDED. A
client then sends that value back in a CONTINUE_INIT request, where the
daemon converts it directly into a live GSS context.

This exposes a daemon address and trusts a client-controlled value as a
live GSS context pointer. An unauthenticated NFS client can replace or
replay the handle before rpc.svcgssd passes it to the GSS implementation.

Keep pending contexts in a daemon-owned search tree. Return a random
64-bit ID from /dev/urandom instead of the context pointer. Take the
matching entry before processing a continuation, return the same ID if
negotiation needs another step, and reject unknown IDs with
GSS_S_NO_CONTEXT. Discard the saved context if writing its reply fails.

The behavior was introduced in commit 62c4197d5b41 and first shipped in
nfs-utils 1.0.8-rc1. It remains present in nfs-utils 3.1.1.
rpc.svcgssd is built only when --enable-svcgss is selected, which is
disabled by default.

On an unpatched x86_64 build, an INIT request that required another GSS
step returned an 8-byte value matching the in-process gss_ctx_id_t
address. Modified and stale continuation handles caused invalid memory
accesses and daemon termination.

With this patch, an unknown ID and a consumed ID both returned
GSS_S_NO_CONTEXT, initial negotiations returned opaque 8-byte IDs, and
63 outstanding negotiations produced 63 distinct IDs. I also completed
an NFSv4.2 sec=krb5 mount with the patched daemon, which remained active
throughout the tests. The reproducer and complete logs are available
privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 62c4197d5b41 ("Updates from Kevin Coffman at UMich")
Assisted-by: LLM
Signed-off-by: Minsu Kim <gsnake7@naver.com>
---
 utils/gssd/svcgssd_proc.c | 159 ++++++++++++++++++++++++++++++++++----
 1 file changed, 145 insertions(+), 14 deletions(-)

diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 7fecd1aa..81216c38 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -42,6 +42,11 @@
 #include <rpc/rpc.h>
 
 #include <pwd.h>
+#include <stdint.h>
+/* <search.h> and nfs_prot.h both define struct entry. */
+#define entry search_entry
+#include <search.h>
+#undef entry
 #include <stdio.h>
 #include <unistd.h>
 #include <ctype.h>
@@ -74,6 +79,109 @@ struct svc_cred {
 	gid_t	cr_groups[NGROUPS];
 };
 
+struct pending_context {
+	uint64_t id;
+	gss_ctx_id_t ctx;
+};
+
+static void *pending_contexts;
+
+static int
+pending_context_compare(const void *a, const void *b)
+{
+	const struct pending_context *pa = a;
+	const struct pending_context *pb = b;
+
+	return (pa->id > pb->id) - (pa->id < pb->id);
+}
+
+static struct pending_context *
+pending_context_find(uint64_t id)
+{
+	struct pending_context key = { .id = id };
+	void *result;
+
+	result = tfind(&key, &pending_contexts, pending_context_compare);
+	return result ? *(struct pending_context **)result : NULL;
+}
+
+static int
+pending_context_new_id(uint64_t *id)
+{
+	unsigned char *p = (unsigned char *)id;
+	size_t done = 0;
+	ssize_t len;
+	int fd;
+
+	fd = open("/dev/urandom", O_RDONLY);
+	if (fd < 0)
+		return -1;
+	while (done < sizeof(*id)) {
+		len = read(fd, p + done, sizeof(*id) - done);
+		if (len > 0) {
+			done += len;
+			continue;
+		}
+		if (len < 0 && errno == EINTR)
+			continue;
+		close(fd);
+		return -1;
+	}
+	close(fd);
+	return 0;
+}
+
+static struct pending_context *
+pending_context_take(uint64_t id)
+{
+	struct pending_context *pending = pending_context_find(id);
+
+	if (pending)
+		tdelete(pending, &pending_contexts, pending_context_compare);
+	return pending;
+}
+
+static struct pending_context *
+pending_context_save(struct pending_context *pending, gss_ctx_id_t *ctx)
+{
+	void *result;
+
+	if (!pending) {
+		pending = calloc(1, sizeof(*pending));
+		if (!pending)
+			return NULL;
+		do {
+			if (pending_context_new_id(&pending->id) != 0) {
+				free(pending);
+				return NULL;
+			}
+		} while (pending->id == 0 ||
+			 pending_context_find(pending->id));
+	}
+
+	result = tsearch(pending, &pending_contexts,
+			 pending_context_compare);
+	if (!result) {
+		free(pending);
+		return NULL;
+	}
+	pending->ctx = *ctx;
+	*ctx = GSS_C_NO_CONTEXT;
+	return pending;
+}
+
+static void
+pending_context_discard(struct pending_context *pending)
+{
+	OM_uint32 min_stat;
+
+	tdelete(pending, &pending_contexts, pending_context_compare);
+	if (pending->ctx != GSS_C_NO_CONTEXT)
+		gss_delete_sec_context(&min_stat, &pending->ctx,
+				       GSS_C_NO_BUFFER);
+	free(pending);
+}
+
 static int
 do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 		gss_OID mech, gss_buffer_desc *context_token,
@@ -337,11 +445,13 @@ handle_nullreq(char *cp) {
 	gss_ctx_id_t		ctx = GSS_C_NO_CONTEXT;
 	gss_name_t		client_name = NULL;
 	gss_OID			mech = GSS_C_NO_OID;
+	struct pending_context	*pending = NULL;
 	u_int32_t		maj_stat = GSS_S_FAILURE, min_stat = 0;
 	u_int32_t		ignore_min_stat;
 	struct svc_cred		cred;
 	int32_t			ctx_endtime;
 	char			*hostbased_name = NULL;
+	uint64_t		context_id;
 
 	printerr(1, "handling null request\n");
 
@@ -358,15 +468,21 @@ handle_nullreq(char *cp) {
 #endif
 
 	if (in_handle.length != 0) { /* CONTINUE_INIT case */
-		if (in_handle.length != sizeof(ctx)) {
+		if (in_handle.length != sizeof(context_id)) {
 			printerr(0, "WARNING: handle_nullreq: "
 				    "input handle has unexpected length %zd\n",
 				    in_handle.length);
+			maj_stat = GSS_S_NO_CONTEXT;
+			goto out_err;
+		}
+		memcpy(&context_id, in_handle.value, sizeof(context_id));
+		pending = pending_context_take(context_id);
+		if (!pending) {
+			maj_stat = GSS_S_NO_CONTEXT;
 			goto out_err;
 		}
-		/* in_handle is the context id stored in the out_handle
-		 * for the GSS_S_CONTINUE_NEEDED case below.  */
-		memcpy(&ctx, in_handle.value, in_handle.length);
+		ctx = pending->ctx;
+		pending->ctx = GSS_C_NO_CONTEXT;
 	}
 
 	if (svcgssd_limit_krb5_enctypes()) {
@@ -380,10 +496,19 @@ handle_nullreq(char *cp) {
 	if (maj_stat == GSS_S_CONTINUE_NEEDED) {
 		printerr(1, "gss_accept_sec_context GSS_S_CONTINUE_NEEDED\n");
 
-		/* Save the context handle for future calls */
-		out_handle.length = sizeof(ctx);
-		memcpy(out_handle.value, &ctx, sizeof(ctx));
-		goto continue_needed;
+		pending = pending_context_save(pending, &ctx);
+		if (!pending) {
+			maj_stat = GSS_S_FAILURE;
+			goto out_err;
+		}
+		out_handle.length = sizeof(pending->id);
+		memcpy(out_handle.value, &pending->id, out_handle.length);
+		if (send_response(&in_handle, &in_tok, maj_stat, min_stat,
+				  &out_handle, &out_tok) != 0) {
+			pending_context_discard(pending);
+			pending = NULL;
+		}
+		goto out;
 	}
 	else if (maj_stat != GSS_S_COMPLETE) {
 		printerr(1, "WARNING: gss_accept_sec_context failed\n");
@@ -402,11 +527,17 @@ handle_nullreq(char *cp) {
 		goto out_err;
 	}
 
-	/* Context complete. Pass handle_seq in out_handle to use
-	 * for context lookup in the kernel. */
-	handle_seq++;
-	out_handle.length = sizeof(handle_seq);
-	memcpy(out_handle.value, &handle_seq, sizeof(handle_seq));
+	/* Preserve the handle throughout a multi-step negotiation. */
+	if (pending) {
+		out_handle.length = sizeof(pending->id);
+		memcpy(out_handle.value, &pending->id, out_handle.length);
+		free(pending);
+		pending = NULL;
+	} else {
+		handle_seq++;
+		out_handle.length = sizeof(handle_seq);
+		memcpy(out_handle.value, &handle_seq, sizeof(handle_seq));
+	}
 
 	/* kernel needs ctx to calculate verifier on null response, so
 	 * must give it context before doing null call: */
@@ -421,7 +552,6 @@ handle_nullreq(char *cp) {
 
 	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
 			hostbased_name);
-continue_needed:
 	send_response(&in_handle, &in_tok, maj_stat, min_stat,
 			&out_handle, &out_tok);
 out:
@@ -436,6 +566,7 @@ out:
 	return;
 
 out_err:
+	free(pending);
 	if (ctx != GSS_C_NO_CONTEXT)
 		gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
 	send_response(&in_handle, &in_tok, maj_stat, min_stat,

base-commit: c2dc3ff598dec9786217d22e40eaca3f295e8b45
-- 
2.54.0 (Apple Git-157)

