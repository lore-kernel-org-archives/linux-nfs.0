Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE3B5490C0F;
	Thu,  6 Aug 2026 20:20:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047632; cv=none; b=Mf9ZCOIOPKYgPWAuQwaaJ8KS2HeVQjpv/XnSonry9BaK3kwYCo3izTM7L9lzjmA8iQfVEozlLN/cuaETsMlE8cpMfrN0k4GYnFzYsEU7AZNGsg1Otf5PGUrEBUGF1igWSpVplQS+aNtbQQ2iGjZZtzEFdqJt/goqI0+gXWUCHqQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047632; c=relaxed/simple;
	bh=DDbX8FhgiMdnXPpsiweqY2F+CQKrWEC6NkhvD10SiUQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ftHAiE+wJ6CQVKZjvfak+Jj1dW/Oz5hnabggO+V3CSJwBA0N9p+pFNiPkqOD8VJEdzuEqkzMoHO3woyp/sB1HYRNMtDtuLuJfEFfi1vM/wM7bPEh7tUrd5xPEdncMONWji2Nrqbb2EQhY/JNT0KbR7qCHFyzVkVK/j2Jr44pEJ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hnMJOBCe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hnMJOBCe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B1D6D1F00A3A;
	Thu,  6 Aug 2026 20:20:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047630;
	bh=xHv9U2YcK/1Iv660yIM5y3B0NHQ9ZXuBkqt5gVtPeuI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hnMJOBCeDDD2PJOM+OAt9sTDJ537/crQza9jJU0rLzDNvgAQHw4/+tC794QVPFmo2
	 2gerXtbqA71NrdxZVrP7g9d9rYQ3DtjYSvYBkBISUjubyemuy7yDo9RCy3lkQduD53
	 4HSO8NimYNlvr/tTnHzxnBR1xMi4DlHcYxLCt627hjDE2G13AZb8tuTTGcFpvH2vM9
	 eYASE5CfV94s+T9rwGyupoZZNmsl1VVeu94RESdxfQTqQAVKaDovhFEbGSrJk4jnMe
	 SppTLvlOQVi/2QEQfki8zDwSD7DrgBu6HJ/BfjWldkdyeA0PP9XFJiwVP7sHj4RZ+2
	 XaocJQ7FFx6CQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:16 -0400
Subject: [PATCH v2 1/8] SUNRPC: do not credit control-record octets to the
 RPC stream
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-1-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2006; i=cel@kernel.org;
 h=from:subject:message-id; bh=DDbX8FhgiMdnXPpsiweqY2F+CQKrWEC6NkhvD10SiUQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyLNTm+cUFVA0nub4+/rD8J5BOWb9ow2OzvC
 BZipHQl1LiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsiwAKCRAzarMzb2Z/
 l+kGD/9ysxb2ZymxfrazEETf4QzlRqbijzfEIypO5uPuNpQH/kb6gFJ1S47/pCtDIf5UtE7NNkl
 kzCCCBKwYadOo4QTQxIEaYcoTH9cEi9260HvS96m5ImGVNUxZCbePDc3EDqKXEGlIqLiOFQwv3r
 IdJS5TkYkZMGrDeCWl8hjIbGoEeN3iU4er//AmdiPJ2KLPpv4IY32MO57rsq0ujDe4NAYH7OAbs
 J/a9LVWOoE27IXKs1b/9LgItHu9YzDmAwg13f2mhb08ZW48YkluRITLule/mLBvHqf2XVI9YmLq
 BvkEWzZSQwyN4F5fQKoupAcQt+am5R2EUzNtZX78x49SVNz4dxmlism2GMZIuZlclKi1ZGyjPJv
 9dAhiQrMuRhF/vdUfIwt/C6ldAuUSXIk0IntfI+GO8q0VD455gbL/wxVxVkhYco67PLhYzVIjB9
 hZbFB2ZmPMJSoI5df7oBUzjFtSimKcCvAs88PIup+65wKr4BDEGUjGSqxPET4L0FC4pH836tZVw
 khmSCDWj0g7UX3HFh00xcqSFWspS+5SNif4ECOB9elUecL+d5Kwd6EQsbYM/UUJR4wkVfgArqWy
 KN6Y1CNOlHtnMrw22q2JahVYRRRAnKoPJmw3ljXNkD9t0wCQ/O37SyGGi/qH0J+Dih2n6nkgiWI
 /C3ZMvgpltCFNRQ==
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
index 50e5e7f5b762..8e1009302e3b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -289,8 +289,13 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
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

