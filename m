Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C1A471D1A;
	Fri, 28 Aug 2026 16:38:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935083; cv=none; b=jrqIhdsn0W+BrZDO0xTu1LPIVdCdkdA199uMfbOnEHht6Zm+XXCiEF1pRsBq1AsjLB140lOFIGkK36GZVW/mG1JUmvwSwnFbYwJmgYkuTlAdcRV/LLNQsTxDEmVqZVbkL8Ygo0c8kDX1dQRxyqnLdHmvBPQaj6SJwWJiB/UmCAs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935083; c=relaxed/simple;
	bh=2x7B3PwxP/3BtOylSFXw7RWPlE8nh0dtG6olsUilqDg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=J5xnVsycTjA8aY5awJDfigxDU7hwePuwppreWKNSS+1mvl2nOGRjQFU+sAUhlFsptCYTSDVche3t/Q8CqyDB2ha3NcT5kqKEKdePczG72Pm+FzDWUjECpo2/3Cv1Z/+KBDdevNmtGbvhbhWUw6fjcGfMZr6+lBybDmwLwqOmbIM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NYXwcTFM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NYXwcTFM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70B3E1F00A3E;
	Fri, 28 Aug 2026 16:38:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935081;
	bh=GtpcXXZ0zNpjKNHNu83pEcU/aeQP2umwafmS+/+dV3c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NYXwcTFMSXbZowLS700IDufTexXFxARuubDvpfSM6xuX7BjoUE8Er1lxUUFNOP+nv
	 Jzzpj46sC0Tkw29iVkeibmIF7eAq0AtTX/mVnyOEcTxg6uWymB/NDLPfBhrg4U0TpE
	 EvqblPcjHZI+uZoyWsDavXMB62wdFcc94/DVU4NEZ8iVu5ndn78GRhEfA/hqfXISZz
	 DiAhTFy70IOB5KVYHLyYptY5jDq9Wc8GNP4e/FB2oeR5d/q4fi15GyCLkNSEmwA1M+
	 MDUDTCJ2XhtBZOzSOzQbcnY/X/PKO+fkdNSYRxjVhY3hZDPyAlPjUZieAs7G5H/EIW
	 hwqs7QHNPEfeQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:40 -0400
Subject: [PATCH v3 10/14] NFSD: stop registering with rpcbind after a
 failure in listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-10-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4092; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=2x7B3PwxP/3BtOylSFXw7RWPlE8nh0dtG6olsUilqDg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblWvWslR176ZcPHGh8CmTK6uBbHSOuLhIslb
 3vX+OKsyQWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VgAKCRAADmhBGVaC
 FTG7D/4/85uR0o1M4S1H1u1Uu+I+M6YuzikKn5LJ/Et6VgTTA+YWILARJfRWlfm00Bu45KQppw1
 P+9NtGD97zdEsMxDnJAzoeSOkbEtUC+H0rMOuQJTX8fwyTI+MtFFXXVOUcXNCN2Zl1gZoqGQ+ko
 V5LIyeknyaXWjrJqPYIGg3rbphCShgDLf3qq/lKIoGJO0ZXz25QWZV7P+IC/cUysF/CKVi8vBb2
 ARwb8NRqimmDlgo4aOrRk9WHRcirtDqcLjRFTwsN5LWohTRPnVsqaaHlKieCQEW92pTT/yDgIFc
 K7hONWclmLVnNeaHE0P8+TzQRuh8dLJ5mc0oxwV06oAvF9cHwTnkh7xQROsK5lF31isZ5ZBOh3A
 nXlAmATLTbozK42CIGEIDwDw9LSBI+vh9DJrvt7QiPXNVwOMWnQYEDwRjG3FiojkKI8ED/2HbCB
 L1g+KAAzqUwxUU0aOzxZt1K3Cmiti5jZpfY7NST1SNfI6gJn1yQCtnQNxKJ/mEyDpQlKy1fgW4h
 bc8tyQBBvpznXLPLNy0pOgt0ah33wB7CcZtdW9qy1rg2fl66XYZANLpnAdWG4IYelzAQWE7vAhv
 qgZmPDKMSPp6qM1RnKmTf/YE3p04aMhClLBSaxdqDCwqWDwHwxvq/MK9rojkjxL0WY4l4kqq10U
 nqWHrqWpJStmNRg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() calls svc_xprt_create_from_sa() once for each
requested listener and passes flags of 0, so every listener registers with
rpcbind on its own. A rpcbind that accepts the connection and never replies
therefore costs one timeout for each entry. With the cap of 1024 entries
the request can hold nfsd_mutex for about 34 minutes, which is roughly 17
times the hung-task threshold.

One failure is enough to know that the next call will not fare better.
Read svc_rpcb_failure_count() before the create loop, and pass
SVC_SOCK_ANONYMOUS for the rest of the request once the count moves.

The entry that moves the count has already paid the timeout, and with v3
enabled svc_register() turns that into -ETIMEDOUT and no listener. Nothing
marks it out from the rest of the request, and a retry of the request
would fail it again, so retry it with SVC_SOCK_ANONYMOUS rather than
leave the set permanently short of whichever entry went first.

A silent rpcbind therefore no longer fails an entry. Report it as its own
condition in the ack, instead of appending it to whatever unrelated error
the last failing entry had.

Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
Assisted-by: LLM
Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Suggested-by: Olga Kornievskaia <okorniev@redhat.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 33 +++++++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6cbdcee4b733..2256c53277b8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2092,7 +2092,9 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
 	const char *bad_xprt = NULL;
+	unsigned int rpcb_failures;
 	const struct nlattr *attr;
+	bool skipped_rpcb = false;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
 	struct nfsd_net *nn;
@@ -2182,13 +2184,15 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	if (delete)
 		svc_xprt_destroy_all(serv, net, false);
 
+	rpcb_failures = svc_rpcb_failure_count(serv);
+
 	/* walk list of addrs again, open any that still don't exist */
 	nlmsg_for_each_attr_type(attr, NFSD_A_SERVER_SOCK_ADDR, info->nlhdr,
 				 GENL_HDRLEN, rem) {
 		struct nlattr *tb[NFSD_A_SOCK_MAX + 1];
 		const char *xcl_name;
 		struct sockaddr *sa;
-		int ret;
+		int flags, ret;
 
 		/* validated up front in nfsd_nl_validate_listeners() */
 		if (nla_parse_nested(tb, NFSD_A_SOCK_MAX, attr,
@@ -2207,8 +2211,20 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 			continue;
 		}
 
-		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
+		flags = skipped_rpcb ? SVC_SOCK_ANONYMOUS : 0;
+		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, flags,
 					      current_cred());
+
+		if (!skipped_rpcb &&
+		    svc_rpcb_failure_count(serv) != rpcb_failures) {
+			skipped_rpcb = true;
+			if (ret < 0)
+				ret = svc_xprt_create_from_sa(serv, xcl_name,
+							      net, sa,
+							      SVC_SOCK_ANONYMOUS,
+							      current_cred());
+		}
+
 		/* always save the latest error */
 		if (ret < 0) {
 			bad_attr = attr;
@@ -2224,8 +2240,17 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	 */
 	if (err) {
 		NL_SET_BAD_ATTR(info->extack, bad_attr);
-		NL_SET_ERR_MSG_FMT(info->extack, "cannot create %s listener",
-				   bad_xprt);
+		if (skipped_rpcb)
+			NL_SET_ERR_MSG_FMT(info->extack,
+					   "cannot create %s listener; rpcbind did not answer",
+					   bad_xprt);
+		else
+			NL_SET_ERR_MSG_FMT(info->extack,
+					   "cannot create %s listener",
+					   bad_xprt);
+	} else if (skipped_rpcb) {
+		NL_SET_ERR_MSG(info->extack,
+			       "rpcbind did not answer, some listeners are not registered");
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))

-- 
2.55.0

