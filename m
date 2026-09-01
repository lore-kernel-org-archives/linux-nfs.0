Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 423694A2A6D
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:19:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294001; cv=none; b=gFvvwGNKX0Q1WMOi8OeWgL5B78LQ41IHgZyS49PPSvdwoAEo6xWqUI6FSn8Fn6bsG0UwUGvbSeeSfGz/e4wi3QXEJ9sCUCH8rYdwwDrp+N8s1ys/4gUrZm7eAnWxr2c/CJA4qXuBrTD7jnEoJ01gkH2il3glrPYBa4pFcwYBGvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294001; c=relaxed/simple;
	bh=1cZl2ogr0bVt5Ws02q9Q6DU0hKsh4oiF0bryM6oPcmY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=saG80XKZ2lNAhENIkIcBTfRPmN/SPYLFv/VtYi64P86w85gpPQlFhoSHwG01RA5hsr5UAHxTS8QNcMB5dL44ZWpSiNKMqyy9az8JbTHz8pAaxRdyXxcJAGNr3r/SDM9IZF8IC/UaW/eDmzRoHeJg3Ukuog1DaT2EsnG0wuP6KRI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bqV0h+0R; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bqV0h+0R"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64DD01F00A3E;
	Tue,  1 Sep 2026 20:19:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788293999;
	bh=weOG5yY3ZpkG3jOobp577A2QmuSHSXGEjl4r/Fgozns=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bqV0h+0RDmVSJK8dDHQWvsvykOxE/XF6Ktim4kzCBTbaSn+oobw3zMzs1rI7vlSne
	 quaolY/gCJaSHHonCGHqxLfU3Tv2GtPTGJOtkOeUDPEZ4ij7XdKgbECDD2IuEUt1p0
	 3y9dK8pFGOdBVAHnc36d9jaAEZ3rFFv1d6JABG29gcR3CAgfBpnaRFfAzBKgS2yy1U
	 GJ+/+RYxaIRG1OW5rrRW369jwlKgGKDydu0h6nCttWW5sXhpuSuZGPhD0PPzG9jfUd
	 /vSTbKqtCiWS7v/TEEqAuIROcYij6YsSS147G8d9lP+0KzZ0R/aLd52m9kXnKOgVjp
	 7LocsKzwHJJuw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:42 -0400
Subject: [PATCH v2 2/8] NFSD: Move the cld upcall message out of the
 caller's stack frame
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-2-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2422; i=cel@kernel.org;
 h=from:subject:message-id; bh=1cZl2ogr0bVt5Ws02q9Q6DU0hKsh4oiF0bryM6oPcmY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNreg0eTqqIRwivayMnsn2kYO7cd0D7kTLQJ
 A+mqIeRnuOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 l0AwD/9yMPiNOvVBEH6IQ8L16ICf8EEL7tAmKnJ0oVvMU49hESwLAUiXwaCe5o+jKax0tyrc/3D
 SC5qUzwn3MS3kxmm1hqZqjtNFyrPWqmo4PQuBSnqvMbN6j1cY0IAHhoL9mdTLBBNwTjcgK235pc
 wiMXKOgMp+ZnKkyv1cFUtZXe2SPT/Vj17YcCXuwY0G0DalbCSBHvXlCyqTqnINOw91u7CvKL/oU
 2OHSbTEl4Dg72YwuoO2WuoKM0lnwXAAx6Tue4xlZSQh1TDL7W0fNrlChQKq236u9mzdRw2wHMuM
 yskvt+pO92PePzs491OLEzwxr2ZYcG8MUAWlC80opjLaascX9VYbwjBOjvTtFEGnj19yMu+E1tI
 jTbUYeyHqC3g1da5Rem+Ms2vasQiZArH74ctoOGyhq68PT9sN8bGe/ZHMfhVeLeDzQUd7SzIbtk
 xuABytGEradwtGQd0Jke9NIJXjpj4o1iOUkSFaYHSNhnECANFe/M2oRLchTdqqtZJf17PdENQfn
 hp5f92MbcxhZ8tK+OHmJHehk31Oxxwc3IPTf+IzWZV4q/wepL240di/U71syN6atzSll1Qzjx69
 Irt0mCLVvTNNkUwEtq2ii9yzounVyVad2hmut6T9PYctRlIR5r6Pv9b1pabedaQ+xY8qU3Fr1zG
 lgDOo7t9yK5/dnw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

__cld_pipe_upcall() builds its struct rpc_pipe_msg on the stack and
hands it to rpc_queue_upcall(), which links it into a list the pipe
owns until the message is released. Only the completion rules keep that
frame alive for as long as the pipe refers to it, and the peer that
drives those rules is an untrusted userspace daemon. The gss and idmap
upcalls do not take that on: each keeps the message in the object it
already allocates.

Do the same here and put the message in struct cld_upcall, beside the
reply buffer it carries. cld_pipe_destroy_msg() then reaches the upcall
from the message directly rather than through msg->data.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 22a9a366d7eb..8dff351aa832 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -650,6 +650,7 @@ struct cld_upcall {
 	struct completion	 cu_done;
 	/* daemon has read the whole upcall; protected by cn_lock */
 	bool			 cu_inflight;
+	struct rpc_pipe_msg	 cu_pipe_msg;
 	union {
 		struct cld_msg_hdr	 cu_hdr;
 		struct cld_msg		 cu_msg;
@@ -661,22 +662,22 @@ static int
 __cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg, struct nfsd_net *nn)
 {
 	int ret;
-	struct rpc_pipe_msg msg;
 	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall, cu_u);
+	struct rpc_pipe_msg *msg = &cup->cu_pipe_msg;
 
-	memset(&msg, 0, sizeof(msg));
-	msg.data = cmsg;
-	msg.len = nn->client_tracking_ops->msglen;
+	memset(msg, 0, sizeof(*msg));
+	msg->data = cmsg;
+	msg->len = nn->client_tracking_ops->msglen;
 
-	ret = rpc_queue_upcall(pipe, &msg);
+	ret = rpc_queue_upcall(pipe, msg);
 	if (ret < 0) {
 		goto out;
 	}
 
 	wait_for_completion(&cup->cu_done);
 
-	if (msg.errno < 0)
-		ret = msg.errno;
+	if (msg->errno < 0)
+		ret = msg->errno;
 out:
 	return ret;
 }
@@ -844,9 +845,8 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 static void
 cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
-	struct cld_msg *cmsg = msg->data;
-	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall,
-						 cu_u.cu_msg);
+	struct cld_upcall *cup = container_of(msg, struct cld_upcall,
+						 cu_pipe_msg);
 	struct cld_net *cn = cup->cu_net;
 
 	/*

-- 
2.54.0

