Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 485CE3D3CFD;
	Wed,  5 Aug 2026 18:31:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954682; cv=none; b=pmkQ2TtFlmaYLkGUymxTVLMMQZ7Rio2EOsimKzRDQZ32ZpFpINTsoYWTQ2mwP/+QBUtOUL1yFIsSAvvyrZvctSVZJ/F76ZdkUz4usoloUm5ei9kkXY9QhAEKyHBVqrQ4nrXA3SGEBFLq4RzyYTZHFmQEUDIWFJcQUMHTvdJY+Fc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954682; c=relaxed/simple;
	bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=E37aCDjchx0GiBEBHU//Fhej0aRRJAZauMRXPIFQdra7+NE5MRgDEdJprfEbvEu0sXCVveXpCBFtHBpDnvwKBWQRdk30x14zug8R+H6jwBe8e8nwMHDvXjWK8KJsY9+lY/VUnII7G5k+/eGkx68KBNd2TZizJAZzQjYF/U2ySCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UZCPeDF1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UZCPeDF1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BCCA1F000E9;
	Wed,  5 Aug 2026 18:31:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954677;
	bh=6MFLVkziX3hANiicO2h9CJB3xgQAuAMAQlVIbnpFQHw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UZCPeDF1C61F/rPFYQHnu9dZe7Nga1HdlU+dZTl1XG6j7igroxu/E7sUmedvq9JRR
	 IqhSyYJkJY6z7D/KfQony0Sx4RO/falwXWWDyGCmBXdQiJ3AuX3CyKsK+59JgFN5Xq
	 I4hglJcgrxglYfDepWwla8XDf46ybWdW+esBlndF6vV5OjjDIzAE6z3gw/1W+eo5OE
	 wiguV8PjWKmbWYazDt3Yb/2J970L99qeLGJqQclm9GoZmX8JMgY3yWZ5DSPiGPpvGe
	 kMIHBCRoPfrrbUeR9vWZ2qZOyr0X5wokVctNTymhlzovS8DXwVkIdh9malpeBhG66q
	 +2O31pYEbFB/g==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:59 -0400
Subject: [PATCH 8/8] SUNRPC: fold xs_sock_process_cmsg() into its only
 caller
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-8-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4767; i=cel@kernel.org;
 h=from:subject:message-id; bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4Fspouxp5p/KhrCamK9ZYwdhriXxsNUNPAn4
 bDqxSENAGGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBbAAKCRAzarMzb2Z/
 lyQsD/0TFdaepNsyWDafKfVLsE/5nGhGA5h8hRR2x5OwX0ldr/DSbxTMhpnBITsWBt15Mo9hEJD
 7QDFaXu8xHZHQIdT82vtyAiAY6bVfB1iiE78Y/YulQY8ft18RbePQjlNz1XWiI0AdX/RE099fnC
 r0WZQspOfUfB00kzgxQ53ZobAJtB4s+lE8kD/jY/2zJ53aP/rWPlHKVbq1mophf9KgQj1KgY7Rr
 bUOSb/AZ1jpOKyGmppy0jIpe9emhOV/+988s510u8MzevoLamSVva1wMUwOjMLQ+6VuZUZquapv
 oGyKOLm4zFMdSBgRmeu/SliPDeADs2C1BY8LyqGImGimYKw3KKwNYH7QAh7yYzTA+URzVVZJpGH
 OsE0sAcwT7zsL9uHPQ3vyX/GzkCWmmebT036UzbuxYX4vM0ZhfqNDBVz7uKU25ochnk7MTG06xt
 19i8qNGCC0Y8N7FIiFfmXtkU24AOXCv6W4CGAKSHUltnm5XxTOtTNkswV62f2St/WEppFlMILR+
 t2/1qtnfQTf4cxuUVSIVtBOviU2+bX2pcOLvYIOJRihBzqFuIlkoxCN91QLx49YixFiVCep1KCs
 1jd+aqhNCVT2OT1re1QplU0lkIcZlqpm4MU6RoMATptXUP4lzTXAWtqP910mGV5PegT7tevEXNR
 Bz4ZZeQDJlgAlLA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xs_sock_process_cmsg() switches on the TLS record type, and every arm
but TLS_RECORD_TYPE_ALERT returns the -EAGAIN its caller passed in.
The DATA arm clears MSG_EOR in the caller's msghdr, but
xs_sock_recvmsg() has already cleared that flag before the call.
Deriving the record type a second time inside the helper also fires
trace_tls_contenttype() twice for every alert.

Move the alert handling into xs_sock_recv_cmsg() and delete the
helper. Every other record type still returns -EAGAIN. The DATA arm's
account of MSG_EOR moves to xs_sock_recvmsg(), where the flag is
cleared.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtsock.c | 85 ++++++++++++++++++---------------------------------
 1 file changed, 30 insertions(+), 55 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5527f7f8a185..38dd75a23af7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -356,45 +356,6 @@ xs_alloc_sparse_pages(struct xdr_buf *buf, size_t want, gfp_t gfp)
 	return want;
 }
 
-static int
-xs_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
-		     unsigned int *msg_flags, struct cmsghdr *cmsg, int ret)
-{
-	u8 content_type = tls_get_record_type(sock->sk, cmsg);
-	u8 level, description;
-
-	switch (content_type) {
-	case 0:
-		break;
-	case TLS_RECORD_TYPE_DATA:
-		/* TLS sets EOR at the end of each application data
-		 * record, even though there might be more frames
-		 * waiting to be decrypted.
-		 */
-		*msg_flags &= ~MSG_EOR;
-		break;
-	case TLS_RECORD_TYPE_ALERT:
-		tls_alert_recv(sock->sk, msg, &level, &description);
-		/* RFC 8446 Section 6: every alert but a closure alert is
-		 * an error alert, whatever the legacy AlertLevel octet
-		 * says.
-		 */
-		switch (description) {
-		case TLS_ALERT_DESC_CLOSE_NOTIFY:
-		case TLS_ALERT_DESC_USER_CANCELED:
-			ret = -EAGAIN;
-			break;
-		default:
-			ret = -EACCES;
-		}
-		break;
-	default:
-		/* discard this record type */
-		ret = -EAGAIN;
-	}
-	return ret;
-}
-
 static int
 xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 {
@@ -412,6 +373,7 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 		.msg_control = &u,
 		.msg_controllen = sizeof(u),
 	};
+	u8 level, description;
 	int ret;
 
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
@@ -421,23 +383,32 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 	 * kTLS filled in u.cmsg.
 	 */
 	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
-		if (tls_get_record_type(sock->sk, &u.cmsg) ==
-		    TLS_RECORD_TYPE_ALERT) {
-			/* RFC 8446 Section 5.1 requires a record with an
-			 * Alert type to carry exactly one message. An alert
-			 * is two octets. tls_alert_recv() reads both without
-			 * checking the length. alert_kvec caps the count at
-			 * two, so a longer record fills it as well. kTLS
-			 * sets MSG_EOR only once the record has been
-			 * drained.
-			 */
-			if (ret != sizeof(alert) ||
-			    !(msg.msg_flags & MSG_EOR))
-				return -EACCES;
-			iov_iter_revert(&msg.msg_iter, ret);
+		if (tls_get_record_type(sock->sk, &u.cmsg) !=
+		    TLS_RECORD_TYPE_ALERT)
+			return -EAGAIN;
+		/* RFC 8446 Section 5.1: a record with an Alert type carries
+		 * exactly one message, and an alert is two octets.
+		 * tls_alert_recv() reads both without checking the length.
+		 * alert_kvec caps the count at two, so a longer record
+		 * fills it as well. kTLS sets MSG_EOR only once the
+		 * record has been drained.
+		 */
+		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
+			return -EACCES;
+		iov_iter_revert(&msg.msg_iter, ret);
+		tls_alert_recv(sock->sk, &msg, &level, &description);
+		/* RFC 8446 Section 6: every alert but a closure alert is
+		 * an error alert, whatever the legacy AlertLevel octet
+		 * says.
+		 */
+		switch (description) {
+		case TLS_ALERT_DESC_CLOSE_NOTIFY:
+		case TLS_ALERT_DESC_USER_CANCELED:
+			ret = -EAGAIN;
+			break;
+		default:
+			ret = -EACCES;
 		}
-		ret = xs_sock_process_cmsg(sock, &msg, msg_flags, &u.cmsg,
-					   -EAGAIN);
 	}
 	return ret;
 }
@@ -451,6 +422,10 @@ xs_sock_recvmsg(struct socket *sock, struct msghdr *msg, int flags, size_t seek)
 	ret = sock_recvmsg(sock, msg, flags);
 	/* Handle TLS inband control message lazily */
 	if (msg->msg_flags & MSG_CTRUNC) {
+		/* TLS sets EOR at the end of each application data
+		 * record, even though there might be more frames
+		 * waiting to be decrypted.
+		 */
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
 		if (ret == 0 || ret == -EIO)
 			ret = xs_sock_recv_cmsg(sock, &msg->msg_flags, flags);

-- 
2.54.0

