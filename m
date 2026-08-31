Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50411489865;
	Mon, 31 Aug 2026 16:15:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192940; cv=none; b=J730QCp1NbU3ZL1QJTfVWdzXni7HRY4dSSmHj9Njn466pBnWIiCIbwgfKFZty/+3nlmsi78egeke9rjhYNWDikQ31Zu7z/IAwfooOr9tu03huZhPQDCzGRkk5LOIAz3WaYoqNWA/FaI3FLcUYnbHRyX8FXEtH0NexhEHlLhY3Lw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192940; c=relaxed/simple;
	bh=tRmgxww+rxzTihIU6XxzVA4+qqOxvEdXskaEQAJ+8Pg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RpAWeDQH8NAAzOAnLexr/8SJHZGEmMZDjr4cnklgYJQ/7gHL+H/dHF7U7E8pcrdWi/iuShVA/3uDKmsaJvImhFEd9zyzzcneDuL7lf5a+EI3nIH4NL4l7nflDJYvxs7sYLC+gJtCGXdtsHEa6L481zwymJBdsIRf5w0zB9hRdEI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KWAaBgUy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KWAaBgUy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 84AAF1F00A3D;
	Mon, 31 Aug 2026 16:15:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192939;
	bh=pL3XeMVN1EzXKRu842hzSRvAUH5WEX0PtRHjn0sU1pg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KWAaBgUypGx7j3uz1itdeRGAX8KWjAANJDtY0bgMSfOzSC/bpYjn5LcrP6NLiLWOe
	 3IFsS9jdKgF9Nb3gktAQMRcR+rZz1idOrj/nnWVAHYTPyX1XQPBR2Pl4eGjOerIHF2
	 7jfqejlBrkcRmLzXpqYkqtjO5viRvY11G3Y9ie/OCuxquinVi6t6TshHav3md6mRGy
	 gf+fNxx06Ks8zbpYblzdQJkz98DJyT/b7jSCxBV9Ohbiyl8ncWrhCTVkVEPHDekS81
	 tTQkYKRZtbDg9bi6sPh5yISMi/D1Z+oE3drbwsQvAKUk4h+T9n/iTfmW2Y8qMN0NlI
	 QhyoBy4zsWqLA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:43 -0400
Subject: [PATCH v4 01/14] NFSD: cap the number of listeners accepted in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-1-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaidH81ifZX4VooVLB9lzrNEQDOkWlPY6Mnvf
 dxXhKlCfOyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWonQAKCRAADmhBGVaC
 FYr4D/wL2PRYGe/CPx0uDFZZE7W86rR5IynluV7OKy8ORRWFsH/dlOw3zbAaI73ENHqCWWoEFlr
 kQUo0JvjRd65Sb+5SqByQ0IdKdFjH/fmSLD36aXhDBTiiTV3atITlAXs+mfyjPmfI1YzzoKmHWm
 9OBYlEMzzZa8y9qmrRrFux6LYncp/7UVgujzAyHgx4aCzIeo8R50ua3sZn6ADJ6eTXwfvJEpQht
 ycss2sKaU71hh4gH9uDSus3LWJKCRQorYpPbgryBRDZxV4+R1mUZ4guYHKxwjE6V1EZEihgxvV8
 oJwSHtAPX0JJyNd8AIAD+EmVdtukIH6IArXme3+GNIRNNxVQl5xzZncCijGOnDL5qnVrAjk2phO
 bsE1LHHFk7ltzSsPR7hLoZu1S5odhEcktsuITaMJVBt+eGBiFwrq90Kd9LkuMyTH6SATuoXlNZe
 ndlZbQ9LdAenb024ApTmQrg1BLUO93bFj6RnUVNQy9bwSCjuEIirWqgleW8c7DMq0eMbqX36WMn
 /xN2xHhWovpypfssaaGEyHdA6m12a8uqO64AVtLwlAsrohJKJF/+Mw4/cszYXM/lCqOk3v2pD59
 NNC7rajcAUL/VN3o5w08w0Ebo1tH4v9zMuJLA7GYC974tf3DDYooMd3WaoRHj88tomd2sa6kfc6
 Dp708ZSSNuQebCA==
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

