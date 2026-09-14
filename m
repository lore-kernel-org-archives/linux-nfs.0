Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 936D6364EAF
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401655; cv=none; b=RHHqSBsTuaB5aGcnnLBrnxqLK4CBvP49QFNAfxIckcJNVk8JI+HoapNREy0PesZSZqFJ9j5VQleWX0eApVYrVj3M0gNzKLUpH9W8OIvci02CYp01UHYNR3fB57uFvI2udt9xGHI9ICUT0RcNTl3cILijQ5tXe/GNeIR6Dj51zsc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401655; c=relaxed/simple;
	bh=p4ADDsgB3DJN8mXUFgtZOxKMYpZ3vyCRUXn9RkcZa2Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qncz5kLWz+ZhR2S6MMW5vWUzXVSFXA0NP/TZ3uAlFDKHp0P33JJ+JSdU6vTxJ710/9TDa+mjGQGmtXUahejY1eecwGpfR0ijlhOqjdJLVonVKSgBZbn1CvlJbgpvsD2zGZyUGsLW5WJd3Xwy1oJq4h+H3hmWUc2RGvpfqnl4hrE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dtB/sK+s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dtB/sK+s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6FA91F0089B;
	Mon, 14 Sep 2026 16:00:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401654;
	bh=Z57JVhNcEl6KgiLi7tcOzVe+ljM7Pos9c5JV9JA3tD4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dtB/sK+suhG710DIEjp7bjQx11Z9tQrGyMrH8MzcM3VnAKTCoitDzS9ARnkfE1l6s
	 azum7BHcrd5FoBe8R1E/zG6UHPbWqOjM02FPgMC4umnYFQ1d9ODq+NwenvB73JqrKz
	 BDSez8ABRV7CSu6UEj/ZI6QUkUgXZPXm3046HAnNcg6txAgxPOgXMVb94FmZbDeSnB
	 epmVKxt7o4Kw7sK5Z57gabyiQUL2SiVuH9DVAnLLIVEt9+KMJ97+gVVxTmPAOeYIiQ
	 2TkDO21o29rsH2xR62AGS5YhKnYKkYGHLx6uhRJqg+BtegkYV6w9o330O211bnkaOm
	 dVSky+j5C4Zgg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:31 -0400
Subject: [PATCH RFC nfs-utils v2 03/10] nfsdctl: share the listener nest
 parser
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-3-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2415; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=p4ADDsgB3DJN8mXUFgtZOxKMYpZ3vyCRUXn9RkcZa2Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBowiA9bwWibMb9vaM53hq9zBmMx98IELYQIa
 olW+MFzvvOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMAAKCRAADmhBGVaC
 Feo/D/4sZqargDyP9PnTCFDvUNvWGMPSTHM2cdkHl9GTeNfFtRCc5C7B0AyY69UpK2hlLX1FKp4
 FcP942lzPPNxPJb2f36EFOG4Eb7eG/XIARTNEnIl1lblr1huWsN4jqqSRt/0BCWVS+nuTdIDzQT
 LPE0n/8MtkVQLNYYnp5oDLUxnr3Z+A5M3k+nzFz9B8gNFmMbfeYDF/5FEPY35zmdVmlIob999KS
 h+e6b4vRF2L83SH9XSrS0YfI7pHiS9XyypfgcBAxXlN3u4MhhHXRfsQWP899bHDsCPaXGtAvyx4
 C/Kud4mODpCoHwIb42cP0U9a9Yh6onA/JxdZFxsft+aAbLa4/DC/i6jmGtiNvWqLTd+023T4v69
 bKFdKI5YWSGH8+6IldgAB7LQfWxY3rHFuIAuoJmNslFSEzAfP9nSqmvcJblGzsR9bqVRS8dBmkd
 pkWZ2/XmyoM9KF8l+QO8w+w3MynyZ8JIYlQVc+IoTqsvk7GlVcRBZxodYkLuzYSakVZuqVeO8Ap
 kcKV+Z4rHKi/i4J/3nIN0pHQKtXWBbE/cvQ/Y7PmWB8D1IQ+/gI2xl9NDfTfjjtY2YsG9acZ8NK
 Ch6fpmnW7AxytV3mHmLOK7tAyjDsj7nkukCae8t7mrBBl62vo8GQWFZV8Fy4TRmnh7Dh35PAiTB
 QeqRezK4tFknIJA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

parse_listener_get() unpacks a NFSD_A_SERVER_SOCK_ADDR nest inline. It
also treats every top-level attribute as one of those nests. A
LISTENER_GET reply carries nothing else, so the loop is correct today. A
reply that mixes attributes would count the other attributes as
listeners.

Move the nest walk into parse_sock_nest(). Skip an attribute that is not
a listener. Stop at MAX_NFSD_SOCKETS.

No functional change.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 8733f0377208..dd815ac53489 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -273,6 +273,28 @@ static void parse_version_get(struct genlmsghdr *gnlh)
 	}
 }
 
+/* Unpack one NFSD_A_SERVER_SOCK_ADDR nest. */
+static void parse_sock_nest(struct nlattr *attr, struct server_socket *sock)
+{
+	struct nlattr *a;
+	char *res;
+	int i;
+
+	nla_for_each_nested(a, attr, i) {
+		switch (nla_type(a)) {
+		case NFSD_A_SOCK_TRANSPORT_NAME:
+			res = strncpy(sock->name, nla_data(a),
+				      MAX_CLASS_NAME_LEN);
+			res[MAX_CLASS_NAME_LEN - 1] = '\0'; // just to be sure
+			break;
+		case NFSD_A_SOCK_ADDR:
+			memcpy(&sock->ss, nla_data(a), sizeof(sock->ss));
+			break;
+		}
+		sock->active = true;
+	}
+}
+
 static void parse_listener_get(struct genlmsghdr *gnlh)
 {
 	struct nlattr *attr;
@@ -283,24 +305,11 @@ static void parse_listener_get(struct genlmsghdr *gnlh)
 
 	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
 			  genlmsg_attrlen(gnlh, 0), rem) {
-		struct nlattr *a;
-		char *res;
-		int i;
-
-		nla_for_each_nested(a, attr, i) {
-			switch (nla_type(a)) {
-			case NFSD_A_SOCK_TRANSPORT_NAME:
-				res = strncpy(nfsd_sockets[idx].name, nla_data(a),
-					      MAX_CLASS_NAME_LEN);
-				res[MAX_CLASS_NAME_LEN - 1] = '\0'; // just to be sure
-				break;
-			case NFSD_A_SOCK_ADDR:
-				memcpy(&nfsd_sockets[idx].ss, nla_data(a),
-					sizeof(nfsd_sockets[idx].ss));
-				break;
-			}
-			nfsd_sockets[idx].active = true;
-		}
+		if (nla_type(attr) != NFSD_A_SERVER_SOCK_ADDR)
+			continue;
+		if (idx >= MAX_NFSD_SOCKETS)
+			break;
+		parse_sock_nest(attr, &nfsd_sockets[idx]);
 		++idx;
 	}
 	nfsd_socket_count = idx;

-- 
2.55.0

