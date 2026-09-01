Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BC6E392C5A;
	Tue,  1 Sep 2026 13:40:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270006; cv=none; b=cu4J8GLMFaIHmlsUGZ7sDWRxlMwouASLugroSgWC6h3V3EQlACMkwpJWmdrhNU4UMog6G+zJ/wIOVLhXV0+8G2SrpA05Dow10oD6SMqLA5x3oWY7jr1NgnzZcy1qNl4IY904dSgpJyz54Ov1qFRIo6e7hm3JZYveg5ybE+/5qG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270006; c=relaxed/simple;
	bh=tRmgxww+rxzTihIU6XxzVA4+qqOxvEdXskaEQAJ+8Pg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fBdPAozZR4iV24wVFxJnBUNyq0hX0hS/giAy03frAnoFfgmWPO54lDeRbtgIiV+9Rm6tHNkxF1IDybCWTQz+7XUykdw6yq76lRAWVwSY8nipB+Vu68I2qquX4GstAPXCi6dlZffewQDFCNaj0cGjc7sQm0wW/EfusQjyQgsJLkQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JkpAmDyn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JkpAmDyn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 86D251F00A3E;
	Tue,  1 Sep 2026 13:40:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270005;
	bh=pL3XeMVN1EzXKRu842hzSRvAUH5WEX0PtRHjn0sU1pg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JkpAmDynHq6WoSqdiah24q/01nO0S16uzFoeU19LAOPJrYmNH/F41IZO2ylJBgcVW
	 N5sF+iCI+7vPzdq+oWrJBLYQJGwjd3OuC5ciQfh8VXcma1qR8FV/Hhd1SOwrQn66DX
	 azUowcYFfAAWh2I3ucjn8tDHK+JqzZkvlJzX1GRGRkq6ByaC+hsWleLu0FaYvQ/UaX
	 f5PNIEjRKqx7RO+KIb0rPuVCg0C2Pb51ehIcef6G/niwVkDPEzZMqeLXx948q3fWyK
	 XgvrIAinHBgCjpIZ1tbPl1kcevztZPsFmEOu3DQfejhPOObA8Dt3lwrEUlW+Lo778R
	 1a+3VwtHU8u0g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:39 -0400
Subject: [PATCH v5 01/15] NFSD: cap the number of listeners accepted in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-1-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2930; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=tRmgxww+rxzTihIU6XxzVA4+qqOxvEdXskaEQAJ+8Pg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWuwZ4cFcqw0XUvOq2am0xKHPMtyIyPRIUJi
 pAMLWUIxTOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrgAKCRAADmhBGVaC
 FYC0EADBpVMMtxaUlAGjzrJwXHZMesdpcKwSKt2f/0xaBhm7ftFypPczeHWAp/iTgHyf6owbylT
 oh2n/a1Oz+cUDhS+Xg9H0qq1nemFZCleFG3rKKCEjuFHJrEyF54PsxHSY4GNpIqZ9LurbWqfxep
 AItZSifA+5j55+VIFtcvrCP0pv2hbgpHijF5Zg9B3cN7u0FXPJvM5hU9KihnmqHquJIEJGbsL9E
 SzJzV45UM05UccQ1ycKFToEPbUb8a3C5WBy1PRDTciVdwpJOpdFf86oedihNPYyYILcorrZKhHi
 glQsgEVkyGmdilU+qgMF3/DoVFEUlivaW7i49aavs5VwOuWUrSKfJj6s4WYb82VyUYWOlkuUx3S
 XjlFpbLPMaeqZ0RvXyAc4lJJObxWXGRaItJIDds6Sa0HSneYvxVrllaCtWQk1t/d5IeRCUKQTCe
 GyxMU5JsSnV7KZ2GLO5B/fKhc4SB0wdd8watXfi/E65f4MmA/4QExMbJhFaXrIoJmO848JdXnii
 nQcIKTiMnXiPgIy+iOZCsVM5SWS/WSaepIHkNk34lsgQ5E3CdW2Y6w2/gHTryJS3H+t07oyaYug
 08xr7j8r7YhRKEttorXE2v5XJo/hkKsjDHznZOsoglTyFmUY8qkZEtkyAVs2h0LLZP5zYxSIiLo
 BNvbUqAHHLvvCpA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() matches each requested listener against the
existing set. The nested loop that does this is O(N * M), where N is the
requested count and M is the existing count. The loop runs under sv_lock
with bottom halves disabled. A userland request with a very large listener
list can therefore spin in atomic context for a long time.

Reject a request that carries more than NFSD_NL_LISTENER_MAX (1024)
entries. The check goes in nfsd_nl_validate_listeners(), before the code
takes any lock. The limit is far above any realistic configuration.

This patch does not cap M. Only the message size bounded N; real sockets
bound M. A listener_set result set is the requested set, so that path also
holds M at the cap, but __write_ports_addxprt() adds two listeners per call
and removes none, so repeated calls can push M past it. The worst case
under sv_lock is therefore 1024 * M, plus 1024 nla_parse_nested() calls.
Both interfaces require CAP_NET_ADMIN.

Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5331b89c4281..b6f4d66f612a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1995,21 +1995,22 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+/* Upper bound on the number of listeners a single request may carry. */
+#define NFSD_NL_LISTENER_MAX	1024
+
 /**
  * nfsd_nl_validate_listeners - sanity-check the listener list from userland
  * @info: netlink metadata and command arguments
  *
- * Walk every NFSD_A_SERVER_SOCK_ADDR attribute and confirm that each entry
- * is well-formed: it parses against the policy, carries both an address and
- * a transport name, and the address is long enough for its family. Doing
- * this up front lets the callers below assume every entry is valid and
- * guarantees we make no changes when the request is malformed.
+ * Walk every NFSD_A_SERVER_SOCK_ADDR attribute and confirm that the list is
+ * not oversized and that each entry is well-formed.
  *
  * Return: 0 if every entry is valid, or a negative errno otherwise.
  */
 static int nfsd_nl_validate_listeners(struct genl_info *info)
 {
 	const struct nlattr *attr;
+	unsigned int count = 0;
 	int rem;
 
 	nlmsg_for_each_attr_type(attr, NFSD_A_SERVER_SOCK_ADDR, info->nlhdr,
@@ -2018,6 +2019,11 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		struct sockaddr *sa;
 		int err;
 
+		if (++count > NFSD_NL_LISTENER_MAX) {
+			NL_SET_ERR_MSG(info->extack, "too many listeners");
+			return -E2BIG;
+		}
+
 		err = nla_parse_nested(tb, NFSD_A_SOCK_MAX, attr,
 				       nfsd_sock_nl_policy, info->extack);
 		if (err < 0)

-- 
2.55.0

