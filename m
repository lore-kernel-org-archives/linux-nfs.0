Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599055;
	b=GS63NpNkviwbnonxnfrgUXgMw0PqpZc+05r0kQusFTwIaPvSpAs22x49RNMC0WfV49cC
	 tSMwNBEeQtnoSvCA5HWX1HcYfUFcgVjF/9ZOkOzTJM5WtkVyN7cC6nyjIqn6CdbgJ8Jny
	 BNHxXIWDgheKYMPYFSxdq7zz5992BvgArphXyT5C9kqnxZ/U0ucuXZPYlI7fx7LOEeKw9
	 la/ISzYV1ZnSBhguKOme0lva+UDMK5m2qVX0LaSXd2uzV4IgKuOdT16o7eu548hmiS/Wr
	 wejpVw+DB/WhuPbn96/CxXyl278F8Rq7BvZj6WYIZZ+npt4Oiucq0TI1xGbcCEgdyng==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599055;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YMj11EQ44YZ51a+r7J1mSvzlDSi2bHr/0g3vXDCvelM=;
	b=zcLknyfXVCez4an/mivPS3o3nL/MgmxMwPkz1d4rJkVOHgAfLOCcqFZcw28zPqWKPRfd
	 I9Gk+46tR2JQ8gnzuUw7O7Gs0QaCREFAN2yEFXoJr4wUplG1c883UE9o1da/h2Td0qKmk
	 izYqAHhioDkVuMBjwvRAq58R0moroYSKK62XCRdK+Cw22CXUYyBYoT0X/n1s+JSCaOaHH
	 p5Undxy7y0l2KdULX9w+pg+LgdMWl5/0KTXHnZVQaUIws4ZEjJT/MmmOTl5MytE3SF+NB
	 8YgjLGO7vmE820R9Vn5c33t7clfWLb5MN59G0vTpL0buMPMaFOJxnoPVHaW6GMSGDvQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kHKyn7YE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 633A5606A32E
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kHKyn7YE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 38AAA1F000CE;
	Fri, 13 Nov 2026 19:44:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599055;
	bh=YMj11EQ44YZ51a+r7J1mSvzlDSi2bHr/0g3vXDCvelM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kHKyn7YE44MOV7c4qutOnNy40sxqULAHUMJ9onROYmhfdt6wCBjQkdJ61xqBImJSm
	 CRJpLLwlY1vMTjcoK6d/xOKfac4PlOE/2rbhGw1waNoKznX+REMy1CQjKDHdOXqrjU
	 HaSoz/zu6FY/UboiDndSwdqlMwMBeLt98cBCvSFxfCfp9z4nclWl3lz6vG9nAbTRDT
	 R118PL951+Xm/juidEbIiEELiuA0H7MeANL2wOf8QAgx+CLk0AKUj9SXDl0IebhT6a
	 j3/AyQj59gJNBb4P5LSHH6gVs9lk76ttTgQ2PRMHjTc+gKythWK3EMG+pKu268m7YP
	 CxeX99+j7qfZg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:03 -0500
Subject: [PATCH 5/8] SUNRPC: Remove svc_sock::sk_bvec
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
Message-Id: <20261113-svcsock-bvecs-v1-5-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4109; i=cel@kernel.org;
 h=from:subject:message-id; bh=qVZJZcIpgQFuop2USwhfPNj8qwVN0jg9oy6esJ/1thQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iH7S9BxLhuPdQfD8o13xogsKaaFWZPH6DWl
 J7KSp/tz9eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l+siD/0aWZrboJapPO8MHKmEPujqlzIPmPerjm9nHz47NcvDgSOtAMOH/mfrbr9VCF0AFhb4fEB
 jyVV1H6SYL3WDCVgkl+xw09OFZpgRdNwv81aIhXAqmXsbQckW8TEBVYb19eFBuoS+L8Dejz/Xum
 7HoeznYBgiVdZk94UNd3rZB7dstX72Vv4sIjvFJ/FjlP+wl7c0M35xP+hq6u3PTPnnDUMzsSZJB
 3hWyj9Qa1jC1pWaFGFVmpfWNKnkSB7t1GpmRDcenS4LL+MPTWkaOulnYzAIYKqf1o9kh0a13Sjl
 frJmIQ82kXJ0mERrW5mZkJSIcCYtlw6Nac9WFd3W7fGXBbz+m4is1MItHLhiMEPR9/z5EdrY123
 2DPu+rvMVbSl3JxDicdOmFIPxBRfkK0np1FAx3Ta7sejQaQGEhCw3k0ueAeRBKBD9kktC6hhYJh
 eOlLjvWalyQcaClWB+wqHxrJI8h28BGaiw4pyBoYojibKbYYwqMGH3e2H41lJVxoxM1u5+XRsU+
 e8U2HxuCEdGJAolgjEIrW7kdpWnBYEbjMnF58nJkXebckf7vHW/PUYQgiY5tvE3E3moFOJWuyUT
 9K9fkDfd3sNQRUW3eamg/7MWskI6jOjpDieGRyOvfBkc0XbrNfcRkx2OdxOUnTFMnFadgOJftCY
 cXKDFwLQ+Bwqsaw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Both socket transports send from the per-thread rq_bvec, so
sk_bvec, its sizing in svc_sock_sendpages(), and
SUNRPC_MAX_UDP_SENDPAGES have no remaining readers.

Remove them. The default case of svc_sock_sendpages() was the only
check of sock->type on the svc_addsock() path. Without that check a
SOCK_RAW socket with IPPROTO_TCP or IPPROTO_UDP reaches
svc_tcp_init(). Check the type in svc_addsock() instead, after the
-EISCONN and -EBUSY tests so those errors keep precedence over
-EINVAL. The other callers of svc_setup_socket() pass only
SOCK_STREAM or SOCK_DGRAM sockets.

Move the "For sends" comment to sk_frag_cache, which
svc_tcp_sendmsg() allocates from under xpt_mutex.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |  4 +---
 net/sunrpc/svcsock.c           | 40 +++-------------------------------------
 2 files changed, 4 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 372a00882ca6..7bb7781d038a 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -26,9 +26,6 @@ struct svc_sock {
 	void			(*sk_odata)(struct sock *);
 	void			(*sk_owspace)(struct sock *);
 
-	/* For sends (protected by xpt_mutex) */
-	struct bio_vec		*sk_bvec;
-
 	/* private TCP part */
 	/* On-the-wire fragment header: */
 	__be32			sk_marker;
@@ -39,6 +36,7 @@ struct svc_sock {
 	 * received so far in the fragments making up this rpc: */
 	u32			sk_datalen;
 
+	/* For sends (protected by xpt_mutex) */
 	struct page_frag_cache  sk_frag_cache;
 
 	struct completion	sk_handshake_done;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 77a57bb74235..8dc7921a5b91 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -59,17 +59,6 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
-/*
- * For UDP:
- * 1 for header page
- * enough pages for RPCSVC_MAXPAYLOAD_UDP
- * 1 in case payload is not aligned
- * 1 for tail page
- */
-enum {
-	SUNRPC_MAX_UDP_SENDPAGES = 1 + RPCSVC_MAXPAYLOAD_UDP / PAGE_SIZE + 1 + 1
-};
-
 /* To-do: to avoid tying up an nfsd thread while waiting for a
  * handshake request, the request could instead be deferred.
  */
@@ -1516,17 +1505,6 @@ void svc_sock_update_bufs(struct svc_serv *serv)
 	spin_unlock_bh(&serv->sv_lock);
 }
 
-static int svc_sock_sendpages(struct socket *sock)
-{
-	switch (sock->type) {
-	case SOCK_STREAM:
-		return 0;
-	case SOCK_DGRAM:
-		return SUNRPC_MAX_UDP_SENDPAGES;
-	}
-	return -EINVAL;
-}
-
 /*
  * Initialize socket for RPC use and create svc_sock struct
  */
@@ -1537,26 +1515,13 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
-	int		sendpages;
 	unsigned long	pages;
 
-	sendpages = svc_sock_sendpages(sock);
-	if (sendpages < 0)
-		return ERR_PTR(sendpages);
-
 	pages = svc_serv_maxpages(serv);
 	svsk = kzalloc_flex(*svsk, sk_pages, pages);
 	if (!svsk)
 		return ERR_PTR(-ENOMEM);
 
-	if (sendpages) {
-		svsk->sk_bvec = kzalloc_objs(*svsk->sk_bvec, sendpages);
-		if (!svsk->sk_bvec) {
-			kfree(svsk);
-			return ERR_PTR(-ENOMEM);
-		}
-	}
-
 	svsk->sk_maxpages = pages;
 
 	inet = sock->sk;
@@ -1568,7 +1533,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 				     inet->sk_protocol,
 				     ntohs(inet_sk(inet)->inet_sport));
 		if (err < 0) {
-			kfree(svsk->sk_bvec);
 			kfree(svsk);
 			return ERR_PTR(err);
 		}
@@ -1638,6 +1602,9 @@ int svc_addsock(struct svc_serv *serv, struct net *net, const int fd,
 	err = -EBUSY;
 	if (so->sk->sk_user_data)
 		goto out;
+	err = -EINVAL;
+	if (so->type != SOCK_STREAM && so->type != SOCK_DGRAM)
+		goto out;
 	err = -ENOENT;
 	if (!try_module_get(THIS_MODULE))
 		goto out;
@@ -1789,6 +1756,5 @@ static void svc_sock_free(struct svc_xprt *xprt)
 		sock_release(sock);
 
 	page_frag_cache_drain(&svsk->sk_frag_cache);
-	kfree(svsk->sk_bvec);
 	kfree(svsk);
 }

-- 
2.56.0

