Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8E594322F3;
	Mon, 10 Aug 2026 17:39:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383544; cv=none; b=ZVlln33y5CqrD0mTaocewtAsEYUeEFKRgyYr62WASIYWfeScoDgWxdrCKSCFG/IKB6dBTtoieN4HLFuY4fexuRCWEEHLZlhInhIz+nlLrNcA7XimG0xDMbVMQ/x/epwJZh0iKEMSvm43g42ADHowZxbS/aPoo7vTXhE0GwdLjEs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383544; c=relaxed/simple;
	bh=JnXgLEqpQix6o8S4i2Xd1C08UD/tmbEvIEjBhqLN7UY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ktHwceoym1703shmRhQEU2V78YPH4qqTOMzqHjAcvN3lOeTdF1Fn//ePbI9FDw0LMfMpL/xqOlSEDNy1l8yk+ERF/5E61B7aUHs3P5H+UaBen2Nlf9PXJhAq+16Q/JCjGJXLblXeRVIhnBUsF4Qxu9LgjO5KkwVX9R0LPoTf7J4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ObaKTsXG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ObaKTsXG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D847E1F00A3E;
	Mon, 10 Aug 2026 17:39:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383543;
	bh=fBaZ7zzsi43W+QfWC/aOkPWJFwHYEdhrvpew+LuReqg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ObaKTsXGC5HowqLlspyN0qFH7fxEFMdmDiSra4m2KLxIoFMRp4GMs1XLnGAGRxozm
	 G2LMUAA6faENb4txu4mBBapa0eLKQpQsdNiab2zgh0kIRAYxiiZXXh0pt+EolbZzGE
	 Kb2epCkZUu/IqeLnXs28vlsI716K7KvcShjqXbVN56ud84JWxw00mYSUOEVa3DNM7Z
	 Mnut1kugGCZGBmeXKbcwGmLWIKvbtAS1zwS7jpFLXZkHEsvsimGHp3QDqS8b+9fPaL
	 XHSDJsdE2mpMe7aE8Ul991b35OMtaEUcumfH1ucynMhDKb7RXPxccKmc1DzFVf6t0o
	 k0GVb5M1BFRww==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:48 -0400
Subject: [PATCH 1/7] NFSD: validate transport name in listener_set before
 serv creation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-1-2519fdd5bc1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2981; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=JnXgLEqpQix6o8S4i2Xd1C08UD/tmbEvIEjBhqLN7UY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyyl+EFz6cMWQ6YPJaxUnp9ejwtFVejKdM2H
 zdGYmT2nXWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMsgAKCRAADmhBGVaC
 FfEKD/9qoqIWXwgl8tUqWbxFXbth42miQsIhKLT7mjuRXiqFnmGsY9VHXdjF83u4UbbCTh1OV5Z
 cmtwQD5Lgv8EAC714A2DxgokvEm6ntIaZz3lgXMurNkANAnRydCOK+jj+uhTcYVC5qDnlKmW6NI
 sdISjdYLKDUKP/LuSt8JPdQCK8BZBjp8d3iA3p2rn5rTuJF0KiAANNqLVuArmmDSCfktbslI3SN
 t/PCeU0hkA7EW1dX2VRvzjvVty1UOYJTKpGh3V0JWditpaVodWrX8B/6A6NkHNtOUcGKgLejiFY
 eUMb09yCPXLhmRzm+wGWPi66Txe6EEY1sZvr+A1K5PkkFYCqqEDYsDs2vrL0Rba99IG18NT2kgl
 4v1ubgR0WsBqEasUkqL2yqh7cywqmdYCYLJxxnMg9u/idkU7INflKFhTA1LWv5GSGPR+kE22HLx
 AKw3AqdRwm5KOBqUrWzf4WKXAZo470gaeIPKnsaGyvPK38M+Y79p+VfDfyQXA8Drq7PPa4PO31y
 0yS1qOAi1Qj2E+olhROAV/fwC6wOTwkmnPVfEAfZnbz/zSSwd/dcuAxoLh84LO02KZoFVHJ/Gjt
 x5IYO4Eu/zdoQQBdomKhggI47h+Q/OSAhjmLwmbqRhMRLXCfXlXtuT3NgWI2hEEFC2xgNvnfzfv
 P9TWVi+FO894DWw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() holds nfsd_mutex across the whole listener
teardown/rebuild. NFSD_A_SOCK_TRANSPORT_NAME is only checked for
presence, not content, so an arbitrary name reaches
svc_xprt_create_from_sa(), where a name matching no registered class
triggers request_module("svc%s", name) -- a TASK_KILLABLE usermode-helper
upcall run under nfsd_mutex.

Vet the name against the classes NFSD can instantiate (tcp, udp, rdma) in
nfsd_nl_validate_listeners(), which runs before nfsd_mutex is taken.

This narrows the upcall rather than removing it. "rdma" is accepted
unconditionally, so on a kernel where svcrdma is not built it still
reaches request_module("svcrdma") under nfsd_mutex -- as it must for the
modular case, where autoloading is legitimate.

Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 fs/nfsd/nfsctl.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4e5e083d8477..e5844d8454b8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1975,14 +1975,31 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
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
 /**
  * nfsd_nl_validate_listeners - sanity-check the listener list from userland
  * @info: netlink metadata and command arguments
  *
  * Walk every NFSD_A_SERVER_SOCK_ADDR attribute and confirm that each entry
  * is well-formed: it parses against the policy, carries both an address and
- * a transport name, and the address is long enough for its family. Doing
- * this up front lets the callers below assume every entry is valid and
+ * a supported transport name, and the address is long enough for its family.
+ * Doing this up front lets the callers below assume every entry is valid and
  * guarantees we make no changes when the request is malformed.
  *
  * Return: 0 if every entry is valid, or a negative errno otherwise.
@@ -2006,6 +2023,9 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		if (!tb[NFSD_A_SOCK_ADDR] || !tb[NFSD_A_SOCK_TRANSPORT_NAME])
 			return -EINVAL;
 
+		if (!nfsd_nl_transport_supported(nla_data(tb[NFSD_A_SOCK_TRANSPORT_NAME])))
+			return -EPROTONOSUPPORT;
+
 		sa = nla_data(tb[NFSD_A_SOCK_ADDR]);
 		if (nla_len(tb[NFSD_A_SOCK_ADDR]) < sizeof(sa->sa_family))
 			return -EINVAL;

-- 
2.55.0

