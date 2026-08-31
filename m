Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F578550DDA;
	Mon, 31 Aug 2026 16:15:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192955; cv=none; b=N0CunRwxNOrwEmsA62/llvwy2ksxeeiocmQ1vXso8BHhZUrUWEbfRb6HNTgqc/5x5oD2ikhXzNLoS5I3Mp2K4Q6/JmUDRV2oDs4HdGIXEhddJHn5x2bz7ISiMmzxQgjc8Ajp//1b5mj1rg+wLY/y9cg/5OXXUA8lepClfzhoAlc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192955; c=relaxed/simple;
	bh=SM2OWu0XleC4V96J3z4sUV5Kxnkpd0r1e2rH1vibgkM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NGxJaR0IEiifa4JZEy2ZMDdJtU5njNpE2EiQBkYzL6g1Zk2sjFiUVtk45gd4w4khBIWDrg3kF5muHIAefwoBaQCOZQprmOuvicehjkPbY5or6T4J7aA53relNf3XsVewUmA1NlJiN/+PiguHrUVgoAwgPGBMAqTApHF15cExLUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fwgWil/u; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fwgWil/u"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 974FE1F00A3E;
	Mon, 31 Aug 2026 16:15:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192954;
	bh=l3TJj1IX1HGJ6W0nzGDz0cyAW5MqVKBuV0o+O9iQ0hc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fwgWil/uXxR+/S3jSu34sjWlYb0l5BDlEOdaz3YoyscRflcvp9titEx9DOR7grorE
	 xSl4A+AS5KTFndvkdewux7XWcS2IWKsRdlnKsTzAZvuCBEQf9VBjpzRD4FkFI3FMD0
	 ghb7yWZ5E9Iooju6dOkzu4pVFZ5Pu1/s76TmgzyahfeZSmcO65qL13oKgf0KkjYY49
	 kKh3rVOb2eKXsMo07Deb0uC8/TQMPx2uXcNekK+Y+tNtuL+fV6AooJYsS+pjwoIo4Y
	 I3UBCekY32qwYmNqxqjD7YLGk92q2FAZTHyCkiFXV8r8Ed1wW7lKwaeJY9Xvqe9fRE
	 u49Z8tXfViB4w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:52 -0400
Subject: [PATCH v4 10/14] NFSD: stop registering with rpcbind after a
 failure in listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-10-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3554; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=SM2OWu0XleC4V96J3z4sUV5Kxnkpd0r1e2rH1vibgkM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaik2cLP0QIoCX8xMhRugEP5bcqI8NQHwBqJD
 2ifud/oaXGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWopAAKCRAADmhBGVaC
 FbHqD/4n8xtKqxf+Jrm+xW5wAD4L8iZtiqwD6FUrIjN0Zo33HX8pI+kRYNQL0JNQM8NSP4yyhk+
 soE/gRW72iqlRh2r1gw0kUkGQgWNA+jTe69QEgTnKV1yL3m9dGfCtnpRJa2FNsa9mx5KMzVz7jJ
 ZNB0otZlK2qZaiX1u4MWhqpq6qFSLaynws+IeNCRHW1m+LoU85olYwFedjfuSrJZniUDZOj0u1l
 iV/EQFjTpSTvq5toKQBX0QUMzLp1uN/eDnuhBJAyyAncsfOMg0OO9TsU0uoV/8oN7XmDp/qKK8S
 L/e2PZV2PYlGdsdl/7aR2C3MyxCM+a5WRuut6HDG3wymtiudusczR+5gRex7b4uD5LEYG+Rvr5l
 A/eqQKMWJi53Z+YPGhe2mLuCBZAWIGVhY05IF5DC3ZdXWe20J+zjf1lSCTRAUsVcR7iddUz4gOY
 NuNJx+gVDeiLE9EF0bhCXGnnyozmGDcmiq7ZoPkQYChsxgOQKGmnITjxoA1koQs2oNP1FU4pbQB
 LVyH/YoW70RvZSFWEv5dQUfcK97xSH6cWq7fG1wD727ao7DzoYO9s3jgyugrryTONnvzrT51RBX
 HmWdkUitjPnLB7KDQf5DZGpEHgipdFyZEeHKOvua62lsERmxVVNQOcF2zH0FUsouEVAJnW6V/ci
 iwdwC7tildwEhuQ==
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

