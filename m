Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A06E443AA1;
	Tue, 11 Aug 2026 12:03:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449796; cv=none; b=CfePTdWvGnzlA1VkGsRkLMWBuyu5biuHFlo41PNXYWaja76wfswWWvzblZltV8C8CXmics1zSagyHzuIhsJlnSBFeYTfKlusSATdXY3gfc63znN1k8EVxMRM3wK+0YwlriHQ/wIhm3Sw/EhO9+3zglL+0aha9tgeGIhjt7ZKiok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449796; c=relaxed/simple;
	bh=sRE5xJke2nxFvarK96HksthibPjar8XUFDzJSUVh8bo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=slyDIZPFj8PL1hZ0IHLOU36rh9c/O+wM3BC1BRzr0V6dQHPH/T1Gz2eL4lRKzmrUCtScfdpJ4nO0yupFnk6h8MmpFngK0cS2zlI3guV109uAMiQoTEcnuT14xx8g5HhH6xljHcTKc1i3oix70lKwGF9Id0Rn7Z9Il+e11jlSkc4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ii1uYS8i; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ii1uYS8i"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 965871F00A3D;
	Tue, 11 Aug 2026 12:03:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449795;
	bh=SDK8NtQYSDFTW8YWu3lKgc5WnA2MpTS+NwrEmTlcZac=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ii1uYS8iZMMKnwKKAC7rOhMBID4NYZ8YnT+lXTegXS2jFrAdRGNfCc8FU9NRp1AQy
	 78O0zUjtGHEIOyRrBkpTfvv9ONTlaWnTsHY8g2W7djYQjixim3U6xfePGrfn5hDvWQ
	 ozV36HjDWdZi3hPtpzO2PsBvoneCYJpKpBgQZeItSigFNdIimgDupIXTtzg/Rg9VAl
	 LIRtyB++0hvb5TIubVTH7wElIJVb2nTCBE3YCcPzhNTC474G066WoIOTdtBovOZEOQ
	 LvtVsYY+evibV+IPHsZuS9HLMFA3lLkC6ABSUGXVmhhXx6ScNWeC1go4ZewIiR2FCU
	 QvlpuffUMjqug==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:01 -0400
Subject: [PATCH v2 2/8] NFSD: cap the number of listeners accepted in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-2-c0c92b3953c3@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
In-Reply-To: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
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
 h=from:subject:message-id; bh=sRE5xJke2nxFvarK96HksthibPjar8XUFDzJSUVh8bo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew98XTQDgLMe7bvAu0fdCVA3rcTHXuGoSiv1a
 5BQZ2upMoSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfAAKCRAADmhBGVaC
 FetJD/9o5UVHTfjPGqJBDukxVWWrBJCaqTcKGyWQvFOg9ymf/8y4yHCwG6zTwJ2qxBWNtSV5twH
 /Ber1Am0zqBijyq33LV510AysbKQk2I2XKDAR/eaXIYc86+Q/Vu05iZ2RseKqgAvSt+XoyAfTUg
 ka6gO28ZB84v84XjcILeOlDi5eG7REO3S8j8B73RbZjVbausaj+CDr0ESY8NEVrRsb/AWHR5Nt3
 oXOAcEreBp/NtD0Ad6MH5CBKLt96IWaWYy2czMCH9BzKdqRU32oyWQfqdmcM7DjKUbC8tm5J1yQ
 X6Fc3x+T/EACvEYUFZQ7TJnjaS6TnV8cT7RC8mA++hJDYLWyk/y9I80UAsvXjbiQebk0W9eV2Q4
 kFHyJQ2wuAGhZxA4ePaozPZitzfX4fBbZ29ZRVZdzNW9i3h+OXC9PDb7aSZaXmKpz6XLybTXMX0
 RKLwwwVMjHCUXsIvI/8WR+leNmlUPg0bfC6ffz5+C36tVGRmqvc/b+JSaegKfedetP0dO7CnurT
 1tMDwl97dD0FhwZA5lMHOWn2s1MKmXNh1c/2HQIZo4nd1+KLmbmBZljR3UoZlxaIODDTJC8qQCR
 scAsGgYCln2vFyVl9bLaLaNkUoxppRgtEAagA3NPtNWeA/xBUy46lclRxlvQZhXklwi/pvEuSKk
 cCMkZ/Rco4GGiiw==
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

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
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

