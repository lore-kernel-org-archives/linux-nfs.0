Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C22B280325
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136734; cv=none; b=Va6NbWko9yuLkTAD+sJZDBKcp98ghTVNJQt6crBrivkD8pXaCGxwaHWp14iyNche3M4fGPJXoScFG1Pp5vk6ZI1GLpWtqzAJYebD+FXMtR6XtBkEmcFhqwnA9+pzTKKR4/QnlR6gnkG52Lqj1wyjXmtrDexd50VWKD7bHloFFrM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136734; c=relaxed/simple;
	bh=1cZl2ogr0bVt5Ws02q9Q6DU0hKsh4oiF0bryM6oPcmY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=H1Aa3tTAibBBUHkMAT1S5iW2OLOYrrxs18dOV/FO33lV2HxmXDitxn5EaGfwQxxmJpiaWeI1CoaWoeOGdOCYJ2cFbMia54Dz/oOzDkG7qSqHkc6FD+RlsVABr5rDpuwtdwOyl3VPjn9weyvHe8Q0vxxOndUHEh6z8jpexHR5fhI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S+TzyUAH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S+TzyUAH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5DF0A1F00A3F;
	Mon, 31 Aug 2026 00:38:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136733;
	bh=weOG5yY3ZpkG3jOobp577A2QmuSHSXGEjl4r/Fgozns=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S+TzyUAHWMraXVQ2xNMaAYvSwyT876oD2B/s+LRK6gIXYtoPHuG2nHuGOr1N1AWgB
	 miiGtva9fFs+kjcFCLJqfDSSTD7QBapMacgoVCFd0uE9LbbqVfx9xHlR9MYarofgxP
	 DxWkvaLBebQGLBHLtTqhAnbXTZ2mg6YPnhPpYtir9r5Oc3UVUicIanjHGrNso3CvLD
	 Yc+nqjG6vtx63L6ZqfXlVtbUj2Eg8s4pwEGVRDUMHqczKz/EcXnMdit/eMVKB5KwI+
	 o3r0Ls4luUpU7WLFGXGBvacwD0f8v+T6dHuJwmP1TB3Or+9RXegYqMWw5DUPiJl41l
	 n5PlA1zWeE4CQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 30 Aug 2026 20:38:39 -0400
Subject: [PATCH 2/5] NFSD: Move the cld upcall message out of the caller's
 stack frame
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260830-alemi-v1-2-463f80b9e9a8@kernel.org>
References: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
In-Reply-To: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2422; i=cel@kernel.org;
 h=from:subject:message-id; bh=1cZl2ogr0bVt5Ws02q9Q6DU0hKsh4oiF0bryM6oPcmY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0Z4bXAYJvmIxhhmFQhBZ4odK7WalChc++Ce
 AH8jY7S50CJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNGQAKCRAzarMzb2Z/
 l3BuD/9ohfQ78g72N0vcY6lqWtYyAGAVcAzbgzHS7jVfifvHEVlfmmpgmhxbnTrRUHlLs6bVrNh
 HhdwZKqKA8oPQL4uoDJsOOeQWUUWxzB0iYwkA0vba8oXaxhnprws+lFmFY9+Yp9xc6m8dVelbw/
 o8afnh+mnXkTgAS8JN4gWUt+WCfwNmzwGI2c2L3epzjLGdJEkWYlXnM/myQQQzH51+VDgdgQOuw
 XUD/l86Az8Be4us32Uarja35jJpEYBaCoi+Us4EXPS58kxOn0TZtCwvQ+oA7GxQCtW09VCp5x12
 iNgHongmh1F4Ezkcnf8ZDAw/qcMFPiWvHtilCi4G+OJdsrzkFyEhBlJ9agoWfroBq3j8Q3NPvMp
 qSld9W/CXG2vMWyQygg+MjOamciaYFEVJTzOSHDVXL3PYZrXsXdO5NH1+zM7yHNv15Eqa0TDO4e
 hCELf4p79Q4gwLh69Vsb4awwubtF3FBqwZksLhWg444c+bZ0R7IdG4iZihkpZIJSKC07Ju/7isS
 DgGVupC3K+oz3DdB2/TPGagqdn+B5nINLwmNmWAS/R/9tb2K5w20bzLJo7WaWsCGEnisG2XL49X
 FyHz709KAqJ70kbQJx/hmBklzSUJRpbxx+SmsOHJJDszOspVeaLrzFfyaWVO7QP0QMb9BninbhM
 X+s2IvYDaW1Kjpg==
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

