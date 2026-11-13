Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599052;
	b=fWXC3Pb8Qq5ALEQU/+lb7z67ytCC1K6XVZZsziZRo1WJQsqg+G5BhuS+/MaQO7FO6YdD
	 nGuGS3azLMOX3Fr9d8P7aFHHzoSHcNOEiTGKB0X/AwI9meNh8CXm44cvTwe5VBxw+DRIP
	 kDM0GwARqSzBHlS6muiZ6AWDWzdwOGFktMLr9dl0nWci4Jw38tDdz57mahddqZTqkjwp+
	 HLgTaAWvAxErKv6jOV+t3Q2k2Fr8YkHJ6ivxwD1hBUtTS+JXPRYl6rZKSHixL5poG10ZG
	 46w6ATJKe38vjchyCEGUn37TJBd/4h9iZFXZpVoXr5ndYG/Q4oaAjw3MIl69cI1s2og==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599052;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CkVrdOI4sYk9iR4q4jnNIhm/80c+biMSK/L7Q3IS92o=;
	b=Z2FxieG4AmF7g7Vxw+kq1XC97HkLTeTvN/2K2oM9jdd1IZOWtW2n2vOWAVuibAZASCv4
	 BH/VbIUIHETm9362AjCiRoMn5mod14w5EItjqxZbhZ6LzGM88oEMZokpLgog3X59qvPCK
	 rshFBmfEGtEyjj3PWb2nyszDlxdlvEbomkSkM1Uuc0Frn3bOiTpckCA6PKf9hI7aObyX7
	 MsxCkcvHRwnmssSblCm7hK3CC5DZV7uSSyVztxAswZSLNUPIql+q7g50O/Ww/n2nIXX8Z
	 SPoZSPHn9EN2WDued4e9d7WV48rpwjqp3+rejeRKOAFaQVc3nrKWgxBl7GN6xX/ZqRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bir4vkss;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF2CA606A338
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bir4vkss
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1D011F000CB;
	Fri, 13 Nov 2026 19:44:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599052;
	bh=CkVrdOI4sYk9iR4q4jnNIhm/80c+biMSK/L7Q3IS92o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bir4vkssPJ7GWEjyTDtM0h4H7h4XCQp8WwRlM9ZS36YgMPIjB4RWO4XxN4qjm3526
	 6crHqktwd5sxLxduB/RM21tJpnJWGn7OEDH7aH50bFd6IgyNCQ4xQHnUcJI7Asw4Ch
	 HOHYYN7pk9idCdgwbL0mwyFWDLOQPzRLkDQQ39UqUse7038ysYA45Gv2PuL6SB1JVa
	 jAyI9R7xkAINuEa9b+X9SqPVjSQgqyQiUt4B+LXG5LBHN0g9P6gayD88U8d5qGIst/
	 QCSgS2QaNkaPnaXbh6KgoWqhKwp74lXA3QuKwvFU/0rHpLN5h4eqKOEPeeFwZxojVm
	 +m8xflaM1AbfA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:01 -0500
Subject: [PATCH 3/8] SUNRPC: Send TCP replies from rq_bvec
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261113-svcsock-bvecs-v1-3-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4529; i=cel@kernel.org;
 h=from:subject:message-id; bh=8JOxZX9WGOoTE2++Q+YzmZ9TAVydOL5RrT4cUoh66Qo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHhr+ba+gZxVq4Wbz3JRvr/XunZo7W+waoS
 XORNi/tUMiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l49EEADCKCsGB6vcrRL6ESeqPXUcO9yO4w8a+EC0RNzdoJELig+g3cRCp4aZShRtRcE/NIq8YsU
 ZfxPCFCAMpwkaPBaPE0kqwU+26ZLBQialjBJBCsnauI8Gu7x9PBJ9gJtb2hQwcM1FqaL8i8QOcz
 wOJde5b4oHHK7yU+eIRExerqk8+nVhp2qiylNdut5myzeR+969LUJDW9rDolefIpL/8vww0vukW
 LBUKgdZteXcenjbOISgoS5KvbadJwBq1YDxX38BrfdKmlQCrJfrO+CEt9VWxgARpgDZ7J/KTMLP
 k7oivLuMDpGIS0IJnvOpSaGCxkn3AaDD7nfvuSno8+jSwD+pe4FiB+ypd+Af5L5etd+w6cvuxtA
 WLaIL1HE9Xt86qQoTTmdJ6JbiPUACfSrejMGHDAxrVHJIQGhX6dpCJPa7MVGEpFcbQzwjwH5oWg
 YRPzWWLwwwOfH2U+wuWu5VC7hSke+FhWa7Ex+6g7im22nXfFhZeaX3injKVXuvj5649cfbHyx9C
 Cc9k9OBjbIiO0J1H2ERa4Dw9jV5V2N0ZUa0Cwb3ezkC/yfB+LNbkK0A4yPi/nzrdzeVP8OqkFpn
 VnBChACOBjSX2og+JZhZ/dLD4EGvNaT2Vt0WQW71YLEjanxv42qoxNs9E7Vk1i2hYeyiba55J69
 ktsyTfF5ZeWvWWg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sendmsg() builds the reply's bio_vec array in the per-socket
sk_bvec, so every accepted socket carries an array sized for the largest
reply although the sending thread already has rq_bvec.

Build the array in rq_bvec, and stop allocating sk_bvec for stream
sockets. NFSD finishes its READ and WRITE use of rq_bvec before
svc_send() runs, so the two uses do not overlap. rq_bvec is private to
the thread, so convert rq_res before taking xpt_mutex.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h |  2 ++
 net/sunrpc/svcsock.c       | 40 ++++++++++++++++++----------------------
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 497f56cdf7b5..47545866b41d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -232,6 +232,8 @@ struct svc_rqst {
 	struct page *		*rq_page_end;  /* one past the last reply page */
 
 	struct folio_batch	rq_fbatch;
+
+	/* Scratch array: ->xpo_recvfrom and ->xpo_sendto overwrite it */
 	struct bio_vec		*rq_bvec;
 
 	__be32			rq_xid;		/* transmission id */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index fd2f62652b93..a88ca9b9afd6 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1342,42 +1342,36 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	return 0;	/* record not complete */
 }
 
+#define SVC_TCP_MARKER_BVECS	1
+
 /*
  * MSG_SPLICE_PAGES is used exclusively to reduce the number of
  * copy operations in this path. Therefore the caller must ensure
- * that the pages backing @xdr are unchanging.
+ * that the pages backing rq_res are unchanging.
  */
 static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
-			   rpc_fraghdr marker)
+			   rpc_fraghdr marker, unsigned int count)
 {
 	struct msghdr msg = {
 		.msg_flags	= MSG_SPLICE_PAGES,
 	};
-	int count;
 	void *buf;
 	int ret;
 
 	/* The stream record marker is copied into a temporary page
-	 * fragment buffer so that it can be included in sk_bvec.
+	 * fragment buffer so that it can be included in rq_bvec.
 	 */
 	buf = page_frag_alloc(&svsk->sk_frag_cache, sizeof(marker),
 			      GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 	memcpy(buf, &marker, sizeof(marker));
-	bvec_set_virt(svsk->sk_bvec, buf, sizeof(marker));
+	bvec_set_virt(rqstp->rq_bvec, buf, sizeof(marker));
 
-	count = xdr_buf_to_bvec(svsk->sk_bvec + 1, rqstp->rq_maxpages,
-				&rqstp->rq_res);
-	if (count < 0) {
-		ret = count;
-		goto out;
-	}
-
-	iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, svsk->sk_bvec,
-		      1 + count, sizeof(marker) + rqstp->rq_res.len);
+	iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, rqstp->rq_bvec,
+		      SVC_TCP_MARKER_BVECS + count,
+		      sizeof(marker) + rqstp->rq_res.len);
 	ret = sock_sendmsg(svsk->sk_sock, &msg);
-out:
 	page_frag_free(buf);
 	return ret;
 }
@@ -1398,15 +1392,20 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	struct xdr_buf *xdr = &rqstp->rq_res;
 	rpc_fraghdr marker = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT |
 					 (u32)xdr->len);
-	int sent;
+	int count, sent;
 
 	svc_tcp_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
 	rqstp->rq_xprt_ctxt = NULL;
 
+	BUILD_BUG_ON(SVC_TCP_MARKER_BVECS > RPCSVC_BVEC_HEADROOM);
+	count = svc_rqst_res_to_bvec(rqstp, SVC_TCP_MARKER_BVECS);
+
 	mutex_lock(&xprt->xpt_mutex);
 	if (svc_xprt_is_dead(xprt))
 		goto out_notconn;
-	sent = svc_tcp_sendmsg(svsk, rqstp, marker);
+	sent = count;
+	if (count >= 0)
+		sent = svc_tcp_sendmsg(svsk, rqstp, marker, count);
 	trace_svcsock_tcp_send(xprt, sent);
 	if (sent < 0 || sent != (xdr->len + sizeof(marker)))
 		goto out_close;
@@ -1520,13 +1519,10 @@ void svc_sock_update_bufs(struct svc_serv *serv)
 	spin_unlock_bh(&serv->sv_lock);
 }
 
-static int svc_sock_sendpages(struct svc_serv *serv, struct socket *sock, int flags)
+static int svc_sock_sendpages(struct socket *sock)
 {
 	switch (sock->type) {
 	case SOCK_STREAM:
-		/* +1 for TCP record marker */
-		if (flags & SVC_SOCK_TEMPORARY)
-			return svc_serv_maxpages(serv) + 1;
 		return 0;
 	case SOCK_DGRAM:
 		return SUNRPC_MAX_UDP_SENDPAGES;
@@ -1547,7 +1543,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	int		sendpages;
 	unsigned long	pages;
 
-	sendpages = svc_sock_sendpages(serv, sock, flags);
+	sendpages = svc_sock_sendpages(sock);
 	if (sendpages < 0)
 		return ERR_PTR(sendpages);
 

-- 
2.56.0

