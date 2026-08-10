Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63812432E70;
	Mon, 10 Aug 2026 17:39:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383546; cv=none; b=nEJgMzzZHZFv/mH1DWTVa7f+IWlceEZOkHbFBy6/1bLeQXaEQmiTA4KqF+0LkD3Iqd/9XrZe5ISSmSff7fm0OyJZ90oGzrJ/eYtQujwPxp4PQSWmYlE7FVtFGk/fw7RIzikFnObLeDa3/iJStaCHDQyvmu/gmnTiWJyC4pKz2W8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383546; c=relaxed/simple;
	bh=wvCDV6FUUGUKLu+qd8tUSkHX6KpxGk5Xwj978KtfzJA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=HGTZjsOpqQGsWYnmzM6yWKlAc28mZ9g/d2zyiVOI1vOH/K8Nvs+jHXyDYLla86d4ULRHurhOHAs3PT9PVXezI/fu2pmEbXKq8jQw7+SnYnesnJODtGWCY3+aVxUxTuRv/KjbKloMMJ53LBmw+PT2PKkFstAARzXSY+SUlOzwfjQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FjXzEOdJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FjXzEOdJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96CD61F00A3D;
	Mon, 10 Aug 2026 17:39:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383545;
	bh=X1CGXomtQU4g6qOdGivQ1WvTQyymrShiwvPN5yiskEg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FjXzEOdJMtIq4cU8yX8LhNWXjIl6CYLc90IYhlcvb5o3hlFr3tYG3nGfEVeGvV6oV
	 EqLwqCbLvMLiVfqB88NGbpWvxlgZO7K9wfkQbJDfcAF1N6881b/r6Ko+hYkmeImNF3
	 lzovQhKNVQGay99K6KPtO7RbKA6+qWtajosJFcrsFi6qkOI7FBLNdosh6LHyw8hAUs
	 j07bQbAEtX+Sg2LuW8eo4jHLiChLmMQxbPlyFM0RtCqeBrOdT6ftE4YxE4Y8Qs6Ekx
	 XyQNWc0iL4wPe3+0V5SBPUVEiQ/5fWj8m0geZpOIQb0G90dfa27JkHrYf2re06FgK5
	 BsY4DSWjpjJbg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:49 -0400
Subject: [PATCH 2/7] NFSD: cap the number of listeners accepted in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-2-2519fdd5bc1a@kernel.org>
References: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
In-Reply-To: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 "J. Bruce Fields" <bfields@fieldses.org>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2696; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=wvCDV6FUUGUKLu+qd8tUSkHX6KpxGk5Xwj978KtfzJA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyy+HMsMUh/WsODuvmO1Xu1PfDS0WptqlDkD
 Y/vWn+nNpeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMsgAKCRAADmhBGVaC
 Fd7xEAClWvltEm6zzGnaIxLS6go3jwsSmnOk+ADwAZAPh2DWuioWGsUfM6kiuA2KOLlvw6zxUa1
 xOZdlzGZmRyVOWkAWvC2TXVVf08vLOVx0dxte/qhkCtByDgO9yHk6v/buJA7FLtdK4yMsYw1hGE
 fLaYTGG3tr2aiaYXPNQZ+2kqnCgCaAusitRK9ZB26Ple+yT4e2qS9Kn3fsGwr2U8x5PtCMO8Sge
 wjHatple8fbreMar6dTWr5B+mun6/uSpvYcQ6ClOE/LDyHcvq4UU0ZvcasYfmz5++FnymiE4BU1
 uNRc1zulcRnA0mnbj/R6OoaWMjB1PTFH1XpL+xvm+uCIgsPJnLdNvIfywxEvH1i4PnKS2RlHAdZ
 EUfY3vNlRRt0w9nQb2q0ZTEU52JiVgdH9Y7UM6FSXVhnv+cv6yCEA314OOcOfqk6GDyox7JgsSw
 5jJFETrGNe5BCRug5LwjXoBIEjS+nwtw4zdN0RDg3jG7jCTOZmZVj70FcBw2qnnGASlaVvyIVJr
 4039kqnmgU+zoKeiGTiD5Jh+WgLFqPij+uIq5LXWtwW+VzUfE3gMGnmkl52PS+UA1q283pEdvTB
 WkWyUGzvU1Qsrca4dbCLK8y1ul4DU8J8S3bNmEEpLHe3bHfvqT9PnVHfhYruAnAiuUfX5byiM5x
 FeB+qQEdC+ALfpw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() matches each requested listener against the
existing set in a nested loop that is O(N * M) in the requested (N) and
existing (M) counts, run under sv_lock with bottom halves disabled. A
userland request with a very large listener list can therefore spin in
atomic context for a long time.

Reject requests carrying more than NFSD_NL_LISTENER_MAX (1024) entries in
nfsd_nl_validate_listeners(), before any lock is taken. The limit is far
above any realistic configuration.

M is not capped here: write_ports() can add listeners too, via
svc_addsock() and svc_xprt_create(). But each one costs a real socket, so M
is bounded by resources, where N was bounded only by the message size.
Capping N leaves ~1M iterations plus 1024 nla_parse_nested() calls under
sv_lock as the worst case.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 fs/nfsd/nfsctl.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e5844d8454b8..66931caaaaed 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1992,21 +1992,22 @@ static bool nfsd_nl_transport_supported(const char *name)
 	return false;
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
- * a supported transport name, and the address is long enough for its family.
- * Doing this up front lets the callers below assume every entry is valid and
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
@@ -2015,6 +2016,11 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
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

