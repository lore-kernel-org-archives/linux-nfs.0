Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6817D3D349E;
	Wed,  5 Aug 2026 18:31:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954673; cv=none; b=abhv014fYruWL8stYOAPyNMt2PI36McHFJAGqIRigAJLAjCPapLekI84ueyu14MiL14yt5RcrJLmwWD0gjrdRQG5d3gs7JRS+Vv2iwC7kt1MdNcSE7PhPp7dA+cWvj3GagekhIOREEEpA4ZqIvtafZ1EXt1JmySD5J/dUS4EmFU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954673; c=relaxed/simple;
	bh=EcgvxU98gH9sxI1jJ8ffibVjfSmvvD6OaFx+VR5iZgE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=G9grIJu96yuidrhIFcRygOHPGPKkhNFavmvENu2oXrxTk/0YKJWtnhp8huX9cEH6WIPaAjMR6feuMiO4bAT62+bwmucfoO0SAuZ1pBVvKyspbbwRKwRez/sIsLRwNwBB6AyBh0US0tINYsx+5Mb8ErJxGuzVThnvP9+lUJeUNSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T/EPVvFX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T/EPVvFX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D5041F00AC4;
	Wed,  5 Aug 2026 18:31:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954671;
	bh=j7j66vAswH3ryb0lcjz3keDyctW0OYAJHggwjnN21gQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=T/EPVvFXKLx+0OufGXr06HodmMXQc53zGEOdsarUd+GTEAxEMO99c5Ex4Dm0XFEEy
	 yhJhNs4qrs9ntsnakZvBrP7ogBzS9tiEMdnbHZp+XgMBH4JcGErbTeoGuHAQan1qYG
	 3a3wpY2YLq/8Fte3WEr7B4AODj2RwGLYt2dzrmMEJPF2/0gGBTcdl1E/9p7RGdilJ/
	 WME8rynwfCHcWiR7pDhgdAgUvy4c6duJ3cGtmJAMAJ077E9mQjDVc6DykgMvIYeTCy
	 d+HEoAP4pygJXQq+NRaFo4kch8GXhtEPfojqzJwckr9bpi7iZcqptEjTHXf3oIjrco
	 wnBUKaaot1fug==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:53 -0400
Subject: [PATCH 2/8] SUNRPC: do not credit control-record octets to the RPC
 stream
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-2-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2006; i=cel@kernel.org;
 h=from:subject:message-id; bh=EcgvxU98gH9sxI1jJ8ffibVjfSmvvD6OaFx+VR5iZgE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrJrrxUPEi3D/ag0H3YWIsUAgSkMXMImzLt
 M+a/dfxl1iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 l4ReD/471QnYGUKPQxhgjWZhQ4fwoVeYomFrqobDMgHuHkKOUBDJKxJznTN3500vik7v43EKXH1
 3Kp6MlYDtUU8aUpIfxDztzra5njUGONSpMinLTrIBUpZ93Cd3gjSSyxrantp1OLU9rnwqTErX6B
 6TXghUJDEdVB8tQms+a9vKBbVoDGd1ra8gK74wmNC7J2RPlvIB33doMLa/J8iMvkYz3Qb75w1D/
 WsnS7OXp6TgBEPgUkJm82fZprM53RABEPjy/UdyuLj4ffMkfujVEmpGqcKsDDWYbLHFz/9ccfi/
 NDO440D0LVzMeMvjWgykoACrbg0whWIdr5UI5w9UeNmBgdLOCAHiYjALkCNmSqjTUS/bWtxsqo7
 g5HuEH/UJFHW7I86nexHp50utEw124s1C6qJMfrjFQtDgrEWks85s4W+/WZRtlUuf7U9gYrSDwl
 Bx8XLKcDAWLEO7phOhyMEnInnklET+adexo69W1j7S7TTpFsukCiG6pmIssx8plhqhVaQrAr52M
 Ud9syRH8RZ8B+s4jq6cw2K3jU5slF/ri0LjPg6zJJrYZ2JRHd1EHOOLga7mmLDzJOO4hd+qudKC
 kRMWP/vNwh7BMFuSher/HfbXLqZwaAsMwDamxym9DyHbd4Z6RNTOKUYtmO4Rjh4AviGA7BBbUN+
 /A5Cy0eKowghFuA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_recv_cmsg() receives up to two octets into a local
buffer, and returns that count for any record type other than
TLS_RECORD_TYPE_ALERT. Nothing reached the caller's buffer, but
svc_tcp_read_marker() adds the count to sk_tcplen and
svc_tcp_read_msg()'s caller adds it to sk_datalen. The RPC stream
advances over octets it never received. The fragment marker is
assembled from stale sk_marker octets. The message body comes from
pages nothing wrote.

A conforming client reaches this. RFC 8446 Section 4.6.3 lets either
peer send KeyUpdate once it has sent its Finished, and svcsock has no
rekey path. kTLS leaves the partially consumed record on ctx->rx_list,
so the body drains two octets per svc_tcp_recvfrom() call. Each pair
is credited the same way.

Return -EAGAIN for a record that is not an alert. That is what
svc_tcp_sock_process_cmsg()'s default arm returned before the receive
moved into a local buffer.

Fixes: bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 95146e5eb934..26780600f6c9 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -299,8 +299,13 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0 &&
-	    tls_get_record_type(sock->sk, &u.cmsg) == TLS_RECORD_TYPE_ALERT) {
+	if (ret > 0) {
+		/* Returning the count would credit the RPC stream with
+		 * octets that never reached the caller's buffer.
+		 */
+		if (tls_get_record_type(sock->sk, &u.cmsg) !=
+		    TLS_RECORD_TYPE_ALERT)
+			return -EAGAIN;
 		iov_iter_revert(&msg.msg_iter, ret);
 		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
 	}

-- 
2.54.0

