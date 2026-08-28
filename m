Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 218903932FA;
	Fri, 28 Aug 2026 16:37:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935070; cv=none; b=o2H5sxyeucw6ywcffOLB0lWZTimB3Dh6RT/A8fNdkH3i92JNTtzSlpcjD+m7ZestVNxH5YELSI8ll9nJYBHkjbv1btWIk+QyZgYNgYKPjHQJ0thYtpwxRZxBdC/JHov7zZAthQOvVXLhxNeiFEvcxYFAxdc7IdLXmY4QAfmDJhk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935070; c=relaxed/simple;
	bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Uy4GjlaN2WUHJoSRbhhOuHX2cp43Zvv3BYU735LgTkWvnjEyJ/A8XhcnFJRPti6bsz+jOLrWj0VfV1SND1bE11C+PgMkVUq+TTTH91yPTGYTg/niUw1rZB+CTJ6sMJnLf9hk5lHZMvNEeN+wq0QBx29r5D3FXm8bt6WGKqBigAA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ljUOfsfA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ljUOfsfA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F25581F000E9;
	Fri, 28 Aug 2026 16:37:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935068;
	bh=f7DIO5UFdyzmop+0FickQyJR+upbMPxvd7WYzoH5UvM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ljUOfsfAfBRR6ZCVhGU5c88WgatmyOwaDNfeGJh3Rkn8RjINg51BC001MuqwgrmEe
	 qW9sEjUi72nO4ilolSkXv2LF/SNnkxuq1iWfPrX43HYLZHtquPXrYR/4nry1glZAw/
	 426BdCqnLpk25gISMdfQYgSftqIm3R6CJagLe9Rn5QSmKxMCxrRtLcRwzIetBSui70
	 +jlLTADB7YJmSRLxeBowyPgTBrxFkFXEwDqbX2Pvq7fjtlMO1UKQ760STEcFtIrOco
	 1ki5XjiI/6JHUU7X0pog/p5XayzhPqY1yjEjypAsQxGIXyrAh+lK9dEY/cwopvlWm4
	 2lswT4lknaFwg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:32 -0400
Subject: [PATCH v3 02/14] NFSD: validate transport name in listener_set
 before serv creation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-2-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2761; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblU7ipDBR9hOHCBw4J3hHZKeSediS87zPMNB
 ECizBuP8r6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VAAKCRAADmhBGVaC
 FfUYEADUjJjbSWHOdtHJlppRBlsFrh+hg7vLLU5wqjzVhOgWcKenRqsfmwHGoiOEcPNMN+socBH
 AGqy5C5eWvwBeqNUZyMLkJTvxGSavUR8O1eEtj/NA5ybsOGCHebwhW2aRAw2QxzXJcHU2lq9ikr
 6GasDNLUQ9zV6RpsnEGM8K72NCopXM6DUQvseiHftBEHg+2X0TLLiQJTeC9AiRHd5FVJnPPElYb
 lxxPqfiAsI1Mgv8I+V376PM9wMvlvyOJ7e70ff17MVg76qQWh9VNmIjZtxOUJvzkC8tnhZSjC1N
 jzvh7HhbHbPiLW3If1WBwr4m3FGSaLZCkvpEcjqE0BxhKn72316C3isJ692w6ML5aihvNSQd5yG
 gIiEzMvhAlcPCptimNat07I8XrD3u0pMAbszstnw8IgoCsgI00380osrEUCxlC1DguyrhptPAGY
 TEtYyb3N1IA3zTsXTzPQthCmGfCxZzbrfeDaKVN8J8Tu7UlXyttSxou8R8CqwzVpWsOa/3gqAks
 bRp9FyQ4D3FvEXKDX3O9l4SzOQl/oxeFDl6FkWV5CE6qUYfdyKc3Z/PgLrNN8MEiolscqI4xOLz
 dbS+0BlGierXWEaLCsODvpNSNXGHkO6Tq0W4ag4m3my2mLY7ClV6eHe5wjHtgVpMeCUrqr+QEyW
 Daonu5qrlLmWVtw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() holds nfsd_mutex for the whole listener
teardown and rebuild. The code checks NFSD_A_SOCK_TRANSPORT_NAME for
presence only, and not for content. An arbitrary name therefore reaches
svc_xprt_create_from_sa(). There, a name that matches no registered class
calls request_module("svc%s", name). That call is a TASK_KILLABLE usermode
helper upcall, and it runs under nfsd_mutex.

Check the name against the classes that NFSD can create: tcp, udp and
rdma. The check goes in nfsd_nl_validate_listeners(), which runs before
the code takes nfsd_mutex. The rejection names the offending attribute
through extack, since -EPROTONOSUPPORT on its own does not say which
entry carried the bad name.

This narrows the upcall. It does not remove it. NFSD accepts "rdma"
without a condition, so on a kernel that does not build svcrdma the name
still reaches request_module("svcrdma") under nfsd_mutex. That is
necessary for the modular case, where the autoload is legitimate.

Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
Assisted-by: LLM
Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b6f4d66f612a..d8135f38e69f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1995,6 +1995,23 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+/*
+ * Transport classes NFSD knows how to instantiate. Vetting the name here
+ * keeps a bogus string from reaching svc_xprt_create_from_sa(), where an
+ * unknown name triggers a request_module("svc%s", name) upcall under
+ * nfsd_mutex.
+ */
+static bool nfsd_nl_transport_supported(const char *name)
+{
+	static const char * const supported[] = { "tcp", "udp", "rdma" };
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(supported); i++)
+		if (!strcmp(name, supported[i]))
+			return true;
+	return false;
+}
+
 /* Upper bound on the number of listeners a single request may carry. */
 #define NFSD_NL_LISTENER_MAX	1024
 
@@ -2032,6 +2049,13 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		if (!tb[NFSD_A_SOCK_ADDR] || !tb[NFSD_A_SOCK_TRANSPORT_NAME])
 			return -EINVAL;
 
+		if (!nfsd_nl_transport_supported(nla_data(tb[NFSD_A_SOCK_TRANSPORT_NAME]))) {
+			NL_SET_ERR_MSG_ATTR(info->extack,
+					    tb[NFSD_A_SOCK_TRANSPORT_NAME],
+					    "unsupported transport name");
+			return -EPROTONOSUPPORT;
+		}
+
 		sa = nla_data(tb[NFSD_A_SOCK_ADDR]);
 		if (nla_len(tb[NFSD_A_SOCK_ADDR]) < sizeof(sa->sa_family))
 			return -EINVAL;

-- 
2.55.0

