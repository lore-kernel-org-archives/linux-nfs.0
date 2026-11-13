Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599054;
	b=TuxPbwA+aqcIgCoE0Lnc4ZDhBqOTv3YxOo2dSg3z8x6nlUoVSwxo1jMjnjGgL6MDWaFE
	 ymi/GjXO8W0EcbyLVyiXcbAJF/wHzHFvP3FxUfLYS34NdelahLhTpF11Nzl9H8VrNThTc
	 hbDzwP+Ez1Jk1srEmhscAk5cd2FwPM5/FaPKxT3bAwlqDnNbi07WxET7KgLAv9LM5jxq4
	 cJJAF9mxPx7vH22oOGXxLm/AmVIlZLFJm8pVbD9gMlPL9yDzMlQeXSqRXSECp6Ze3wxJb
	 UFiDXZMmVpCgaIUTDBvfGQy+vQFiQlwBVSBLm3S4zSnDReQlK+527+GFWg7CDK04Qhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599054;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ea8B2SU5S5KJ7ltB7R8iF7UdTX3/t4h/MCFD3b7YyZQ=;
	b=thS6jISgZZbV8HWJ351oBA7hZEWvwryLE8YGXK5xAN2ZQj39g1ACiTTu1U6Y3aR50iJf
	 O6zB3ZaGNZnLmsJcIMc9ALjFxMMpsThHEvSO4w6YlrrmXfpg43KirITO43Wwd8gyQXcNf
	 Rr/+9vNWwXCGnpPNQJpV3z43qCIj20zKfhhtoQWakEy7Jf/ypV13V7+Q4OYzLIqlp2Iuj
	 lCsJGq24Qfc16KMnGHrB/BiWZ86wdTiY1s6MFLQyy9bQhNZ179Ta0taMeeLbPhLGvwAXb
	 HPT+hNLqKMpc7CixD5WnXi2fHD6mrk+AaspRuowfCQc/E6jPmQaR7WuOyVvEI8S5Mug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dHcRZtpC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08059606A335
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dHcRZtpC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A0CF1F000CB;
	Fri, 13 Nov 2026 19:44:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599053;
	bh=ea8B2SU5S5KJ7ltB7R8iF7UdTX3/t4h/MCFD3b7YyZQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dHcRZtpCz3yvJ5tg3mDHy+1cwUFBq+v6plUXL3QTAmm6regRpxe4Ow1+Nsv2AH94r
	 nS3ftxaO5OblWtL8EnPhxzcz9b3Cli2I9g5dS6IYNU9iEogqytOEtlCmYyVisFW/QI
	 W0VwT85aJMTsL1LYiTYLptupUycirgUfun1Vs7Wgwur/V3VhNOz/+0dsTcRx0iGHGi
	 d81MEJ1ij0nRvg8NAkwFVi9GbXl+o5Wb2I3FXjZWJXjAaebKNFwZhaa7xPv1xmwscC
	 YSU9fEzy5w4eSoBlRXhSE4tuYVbzH5M/g5tQyDG7tGB+tpUwFhh+NGGS9r7acAvQE/
	 4CSOa1Hwny+0w==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:02 -0500
Subject: [PATCH 4/8] SUNRPC: Send UDP replies from rq_bvec
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
Message-Id: <20261113-svcsock-bvecs-v1-4-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2274; i=cel@kernel.org;
 h=from:subject:message-id; bh=fcoykbAj6DZExNtsCQhi//LnFBbA8SDni1QiWsDEbgY=;
 b=owEBbAKT/ZANAwAKATNqszNvZn+XAcsmYgBq92iHcc22GhMpM/GWgHyTnb+2nm5XoA3A6YMgX
 GGrZ8qv6aqJAjIEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l17AD/dU4PgfC2XxVggnKwFB3A4sue/PGINKO92by9gzYDztwMIO6lhTBAd3IW8/Q9KfjvtR/C3
 llZPmp0AkieYkimnYyyq+tBhIVLgDdxoiXGp/Fh+ECw/UXV8qGlrpxJu7PFd5qAQtgWjFLKI3kj
 Q8AC4vRArDX1fsmWZLAVbx85eeand+9izPx3TIRXexJ4rmT+S9zPau/wyQBf+KCgGAq6HrOUKvr
 qFyIV7MmI5KR4izpcy7d5IlEECaKsiM3bfjbGFpCkSciumA1vdtR37cMVC2tlFms1rUbV/fhKMJ
 rAYE9Lm0ULOWDTnpHeBIxRddfVYZTPe2Fkp/oaFhokxjcSJNN+zQp0XVAdwUtPuBu1hlAdO9kP7
 F2ORzAMs5NsYKNplu4GL8VEWB9hVvghTCDAi7+uMBxI6ldAO7oXzzE9UdmcxnqEQPfkBHqmmFi+
 jZd44LqzQy+NcBxY7khxFcfz23H++hypwVeuxIvGogAtfNl7MEWHKEYYTA8J1rh/n2eGMiuQ7Lp
 3IWWlCVHEcWtFR3XxPA2yaZZ+pXPVLeeaLPFDLVLsJAfmSDaE/m9+ZSeYDHY9vHry92HZDOD1R9
 27bvwqhMq4vkXenle7skT40+ILvnOOf8JHNlQZskZwQxeECI9PpV+3Ib841MSb+PyXjso4uzERG
 06dl+wyMA6XgH
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_udp_sendto() is the last user of the per-socket sk_bvec array.
Once UDP replies are sent from rq_bvec, sk_bvec can be removed.

Convert rq_res into rq_bvec before taking xpt_mutex, as
svc_tcp_sendto() does. A UDP reply is bounded by
RPCSVC_MAXPAYLOAD_UDP, so rq_bvec has room for the reply.

A datagram goes out in one sendmsg, so drop the kernel-doc sentence
about xpt_mutex.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a88ca9b9afd6..77a57bb74235 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -681,16 +681,12 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
  * svc_udp_sendto - Send out a reply on a UDP socket
  * @rqstp: completed svc_rqst
  *
- * xpt_mutex ensures @rqstp's whole message is written to the socket
- * without interruption.
- *
- * Returns the number of bytes sent, or a negative errno.
+ * Return: the number of bytes sent, or a negative errno.
  */
 static int svc_udp_sendto(struct svc_rqst *rqstp)
 {
 	struct svc_xprt *xprt = rqstp->rq_xprt;
 	struct svc_sock	*svsk = container_of(xprt, struct svc_sock, sk_xprt);
-	struct xdr_buf *xdr = &rqstp->rq_res;
 	union {
 		struct cmsghdr	hdr;
 		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
@@ -711,23 +707,24 @@ static int svc_udp_sendto(struct svc_rqst *rqstp)
 
 	svc_set_cmsg_data(rqstp, cmh);
 
+	count = svc_rqst_res_to_bvec(rqstp, 0);
+
 	mutex_lock(&xprt->xpt_mutex);
 
 	if (svc_xprt_is_dead(xprt))
 		goto out_notconn;
 
-	count = xdr_buf_to_bvec(svsk->sk_bvec, SUNRPC_MAX_UDP_SENDPAGES, xdr);
 	if (count < 0) {
 		err = count;
 		goto out_trace;
 	}
 
-	iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, svsk->sk_bvec,
+	iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, rqstp->rq_bvec,
 		      count, rqstp->rq_res.len);
 	err = sock_sendmsg(svsk->sk_sock, &msg);
 	if (err == -ECONNREFUSED) {
 		/* ICMP error on earlier request. */
-		iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, svsk->sk_bvec,
+		iov_iter_bvec(&msg.msg_iter, ITER_SOURCE, rqstp->rq_bvec,
 			      count, rqstp->rq_res.len);
 		err = sock_sendmsg(svsk->sk_sock, &msg);
 	}

-- 
2.56.0

