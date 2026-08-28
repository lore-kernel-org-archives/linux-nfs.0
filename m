Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24487377558;
	Fri, 28 Aug 2026 16:37:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935068; cv=none; b=nfpkRzvLdBegLCFxKipOvz5ceMONV8fEdM+Kamzt+rsPA+yNeJ1IdUTZn2y60kP4lMKWohpTRwiyKbTow4iyfTw5EWjGvTr39lQ63cWVIn9mA+oRMtnxeEqnik9V31PzEm/WuN+Y44Kfx3Rcw6IGYFIQncxsiRgZZ9CUtme+QVw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935068; c=relaxed/simple;
	bh=tRmgxww+rxzTihIU6XxzVA4+qqOxvEdXskaEQAJ+8Pg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Cvf33Y7fVQm8Vj4x2NTA8W5xZeiDOvvbT3gitREpXblXrbM5+22zoydLfbGe/ZN6m4zflPiMObjsm28El56h3Z81eTbgYhMvvXKXVOZz7gs7nrT5pormwKTSUuRJ1J5HNFSWCJ69PUiTlv8uZfUmd1sfVW+g0Gnap9B6hF/KQQA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Pj9R9azD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pj9R9azD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BCF71F00A3D;
	Fri, 28 Aug 2026 16:37:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935066;
	bh=pL3XeMVN1EzXKRu842hzSRvAUH5WEX0PtRHjn0sU1pg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Pj9R9azDTzzrP1KJrFA+4ykbFdhQEbvuz4ipsqHyMrKeCKat6BY1Ko8osRoItyigo
	 1UH3aDIm4et/dfMwWVOcOI+k1O6/zCKfZFt8y4sXcdNX+KVAUQgy7yPMyrOFLhcWv1
	 g7JKdAkihnOKR6ShG6RQ24EnDL/nLHh+LUy5tFzGyFdAGHctZz3UF2qFqqfNqx55t6
	 y+0w9HAvfUTeB4ZhjDE/M5Tc2BVPRtI7eV+Oq7g+1QKSQAE2V46i84IhNVCCAPfaOH
	 NSY+AzHgZXzd5M49cGEqR+ZYclEoH1cMXXh5Gi/Gu6olkxYKoA2HjRMDQ4v+Jqnc+g
	 IWd/h7k8kECIg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:31 -0400
Subject: [PATCH v3 01/14] NFSD: cap the number of listeners accepted in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-1-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2930; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=tRmgxww+rxzTihIU6XxzVA4+qqOxvEdXskaEQAJ+8Pg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblUIzSNyeqZzNscZsInYOUudHQlI9k7WbpIG
 xf3hhfVlXeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VAAKCRAADmhBGVaC
 FcEFEADGCBfjmy6pZYyI30IPfmkHH+JOExxOC0g+EbyXlPslIWziP9VyYoSRa7V5Ip7QYZWTlOG
 dhWEBC+UeOqc/hCz90emMCNrfdmzaYUrAo6kMzIi6pGO0Q1ChPONyZsZWh7ZSbD+Q302hUfasPE
 OCfnmxKvezEykNZs1foKiaVgAoWB47eTr7gY82v/RhYoGgJ2GgkPh0HAZ9Gaql2255UHQUIVs1n
 0wWp6uhYbKj5lXwPhBSGGQ4S3OMUmuc8r9LpEpxa/HzrZUR8jOZbjubLqTcyfV7qUhXrHSWPmp4
 OcHSL1xqW2Nab3wOFZvBMp1t62RGsO9iXQWFQ/jhy/3gOzuW/D1dOShEbdSeYBDu+pYcucrKx4q
 oTthHJELzgVCIWAsxBrxdT5ZyptqLBtIQae3A2+X6OV0WpLwARMfjVbEmJ6qKfXJdrt2aaC0DxN
 pPHxutz424I8mMB81crrt0tkoQKuPJYf/qlpGZPhQXZOEvQrM0NxCyQAH6BDCwQwqZ8G1bML1yC
 WYVR5+8FrLeAbkZnbmYqjsCgGqgHc9sCLkxmqUNiXvKSeGsdOMFMCiXWbzjW31N2SHXkHtpYeB1
 kIgpVK04D27lcOxO0wBA7cRMbg2rzhZr+Zpx02RGe44G/0W6Wz8sraZ/zrxZYmqJOWOfunMw/qC
 NZM62MZ30YkdBIg==
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

