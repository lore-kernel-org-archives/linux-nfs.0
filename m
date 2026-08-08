Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAB1C31960B;
	Sat,  8 Aug 2026 15:40:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203626; cv=none; b=qtwrdZfL4oi+FN1e5bI4gqd0iNjIeW2eBQNlV2EbgmWZw4JTXdJea5tzm6a0xIvcVMhGKORY4akNn7i3qVFuX1OrlmUxsFAKafKy//6vC5BG62yACpMV2KfGdfjzIgoIHImRivKPZvFb5K4/a7FpUbuuCVWIl09o4Y+txdeWly4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203626; c=relaxed/simple;
	bh=3hnz3WnV3QZqWcoSs4+oBtJk6U+/qtBqJHNTXzr25RA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=eIUswUedz5dZvBnDfAFnAp7ghz87OqobB36NvMrtL4L86A3jSzlovhEN9fCnbChHUTCpfwDg8pij6BFqzlGvXqkb8p1lPPZ+pQ/eoehTqkO8CTXj/bJslXPG1ztuBGJlrcUoCjvxP7NVFXuZiWJw8Xp8DYaaOK5Vfa1lA14IsMw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oR87I9EP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oR87I9EP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 697CD1F00A3D;
	Sat,  8 Aug 2026 15:40:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203624;
	bh=T0hRh7l2rV74IxDoHsEZxW6V7Ia8A+R98l1383av770=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oR87I9EPqv8mCfkg9QjySzFUEn4NCxevb2LJdnZlNAIUiWnfhyT/sCnhdF0Qdir3H
	 MsIVcgbildoBAjehI+Yha9B4oyRwdVnQ/4LxqbXZ2JE4GtiEWaRlogCmp8PgZb/0Mq
	 7ji12JaaDP7IndTxO+a571tqJhJeOj+haRzK2e0pEHszZxZ/xnQ4l/OKn9XXXDVoso
	 D2RtCnZyX81AgQ92MGZmQaMM62wcFhJfV5zqxNHwe8WhKbUbfWHe3ukNTs8xs6FuaV
	 zrN46pcAno/YjI6+KBb/Mekcj88fUR3CkRoAX+Pp5EFQXo959zOc7mX4KReGZpGTgj
	 ABesuH9220qFw==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:11 -0400
Subject: [PATCH v3 3/7] SUNRPC: treat every TLS error alert as fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-3-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1783; i=cel@kernel.org;
 h=from:subject:message-id; bh=3hnz3WnV3QZqWcoSs4+oBtJk6U+/qtBqJHNTXzr25RA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03jU2TfZHMyu9rnlBxziARl9I7P7RSbvAFEC
 JqqwjPK70GJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN4wAKCRAzarMzb2Z/
 l+csEACyWAk7oByYaWFvu/kGnjEANK42eVK7ayx2lqvQvciVOGVrBCF/lpdwDIIizfOztnfPT/O
 uhQwEWg/9pQtvdGdAbiodyoTnZEEtorObootDky0V/lsHz9jxIAk8sejzchWHz1A8VTqhARyHuE
 1ohl7LQJuPJw0IVw1NI3crO3nzHWPDO8Nkqi0l6JH7C/OTOkevAZfDjzPNy+nY+os/SfRAttwLh
 /ks6mJWOc0Yf2vRHnmzYhAAEetgzGYGdQB3OGDNQJWLxs0Dt2loDGcnq7Om5YvufJ+wxNkOmatO
 XzaUYExKoT7flTAKIdTeGEIOuWAkS3k/uwO2GdbY2o2f4zjzZw62Y0stSlXNAhri/XBtvvIVMn+
 pAl2GJRAWQoZO99zA3mI7/s/wZTpLnMKZmQDHw/NpSajSIXXJZZmbcZSqz4UJCi/b+M8qkJZIDR
 qiZsBsJtXLBDAzSXpkYCzq/Z3Nmngz/TtOl9wvxiEa6js/knNO5GvoMJA9nsgm0v174G+IchoN4
 nh4RiqjIWNou4jvtfzrTD8cuyuCBFIe/k9Uba9a66yXU4XlPll9ZnWH5ICSvnCOIFyUm/viLN0U
 mfwLzsouwNRHKFKOxEB2w2R/4RBtTA/l2ZlE7t6PaR3KPUfHRHZKgpWKrUTU1XoNpyaXGE2LbV/
 QcAsrygCc4A5ZIQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_process_cmsg() decides whether an alert ends the session
by reading the alert's level octet. RFC 8446 Section 6 retired that
field. The severity is implicit in the description, and a receiver
treats every alert listed in Section 6.2 as an error alert
"regardless of the AlertLevel in the message". A peer that aborts
with unexpected_message but leaves the legacy octet set to warning
makes the server return -EAGAIN. svc_tcp_recvfrom() then leaves a
dead TLS session attached to an open transport. NFSD keeps polling
it.

Decide from the alert description instead. close_notify and
user_canceled are the closure alerts (RFC 8446 Section 6.1). Every
other description ends the session, including one this kernel does
not recognize.

Fixes: 39067dda1d86 ("SUNRPC: Use new helpers to handle TLS Alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2e5107a1fb89..756db84e4aec 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -257,8 +257,18 @@ svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 		break;
 	case TLS_RECORD_TYPE_ALERT:
 		tls_alert_recv(sock->sk, msg, &level, &description);
-		ret = (level == TLS_ALERT_LEVEL_FATAL) ?
-			-ENOTCONN : -EAGAIN;
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
+			ret = -ENOTCONN;
+		}
 		break;
 	default:
 		/* discard this record type */

-- 
2.54.0

