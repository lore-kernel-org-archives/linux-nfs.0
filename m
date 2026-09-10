Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C31957D232;
	Thu, 10 Sep 2026 18:00:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063257; cv=none; b=R4Xuv2a4hFgqpR86sGeRZPCX2X7pbaTP7PEiTgXcS7BaheKGnAkVa5iWsTCZ5I5xbJLwOkiWOFz2TvwSTQekaXdP2Dm3eh8LO48v2ZlUHPrEcS87ZwJp5/+tg1GEackk5B/TG9aIh7K2JgtJ8Xm2blAHtX+x/PYYdhT1CF/7a5o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063257; c=relaxed/simple;
	bh=zENH7b8VS6SakqPNlRmEcRWCMYqbT1hHXJdGm8gMVvg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pUq0xry94COX3yycIUDKot5/68GfYPa1ip8mQuLQXaUcG5PIstM0jUtcZEgRrsrql481pG6R2EBMR8iBK5kWHqnaJaB8/NbZgFvvhVpjLnrlOXdhszbBUzWYXPStopi5B4/c26tsGFxWwoiy9GfERA0kUNx9GVBopAOljqztc3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xrv+tH1o; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xrv+tH1o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 642191F00898;
	Thu, 10 Sep 2026 18:00:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063255;
	bh=ujhKR+xAMJLiLYz8s7j2Mat0/rmlxI7pd5yNuRJQ3mI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Xrv+tH1ovf4kwa8B5yDtkQ6agxgpjjxr2bJjhlVZCssfuQC3LkT/El5jcZufIU73D
	 ku83B6BLPKMALObQL8r2kru+p81auH4BNy+cIkz5OleCPwwZc140X530ONaCan2AMj
	 C6hEwhwyTVjt/EoKLdykmLofOkDWfiFzqRnHY/2uzgVxrYKOz+b8NS4f/MGl3wqtQR
	 u7G14+/MKWzFXtN/1k4eh/CIT4OJJgV7gZEhJxf+x8Dv7zXrivI8u7P0TE05SW4oA3
	 qT6aiClWcH1rOCbT83RLvKxocpVxDaMSdhNcQzQkcFrW1zILbz+3mqnD8BHI4EUDAC
	 fAFgxUThltHug==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:00:36 -0400
Subject: [PATCH 3/5] NFSD: honour the userspace-rpcbind flag in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsd-norpcb-v1-3-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
In-Reply-To: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4666; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zENH7b8VS6SakqPNlRmEcRWCMYqbT1hHXJdGm8gMVvg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBQpwoDrkXCPlrKRvUYIzPISrhEl6o6MjYsy
 nfa5iLm8MaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwUAAKCRAADmhBGVaC
 FetnD/9o1JIGDt4c+BF9EzEeCA6bp2t+7ZSX/LK3ELENJZ6jd6jaEss3hLT8eWklPYoLtgxDyrM
 OWvN7UDUmyELJuv6UTdvmyTv62yhTwW+2VgSUlxUvOV8rRxLUlaDiizr1ti832U3izLayJ6xQqE
 e4irESrcXkHhR3zHwNg+2YND8lVo1W42cXN2JiUlgMwmRhGQF3UROxnKNEnztAqoL80wEnK595s
 ysUSFTQuNp4qUPb2uYAs8zVHlfNQMCS+7rIN6chCeu49IEqtV0O5wCWkl8ovbU1cV+lSRKhQvYV
 6OlLNNL9mxzvePWSXuFD6+XXc1NN+YFd0AlfUFGCLEQ3Sbhma9D2cJboyVM85RL6iFg86CG8gOZ
 7ODiTRZMUPhgbT9OmQN2nX3yT4jQUtBNKfOiB/haB9gZtlv5Uz4HfqzSiTW733LKETc761GeR2H
 jg8etPc3qkFFuiKTyzx9D4x8kDfvU2idE3Jby8gm+EU1G7aWAA236LB7MmgTR3nxek236XOs2CQ
 a8qSrNhDBdXTmt1ZfA0P+6R6GC4COpL/QoJsO24Jt9WYf2n+UG4q9jDwGB8NkVOSePUKL/zfweG
 4TJLxnZ+/MyJq7ZvsgyfV4RhgqYBzAmtma9HQgvBplntEEALET58dgrtUtlAbMTaKuXIUmO68QK
 74e1lr8pSFBuIUw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A listener_set request that carries userspace-rpcbind now sets
sv_no_rpcbind on the serv. The kernel then makes no rpcbind call at all,
avoiding synchronous rpcbind RPCs under nfsd_mutex.

lockd is unaffected. It owns a separate svc_serv and still registers NLM.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 23 +++++++++++++++++------
 fs/nfsd/nfsd.h   |  2 +-
 fs/nfsd/nfssvc.c | 14 ++++++++++++--
 3 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1be8f98a293d..63746334a46f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -748,7 +748,7 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net, const struct cred
 		return -EINVAL;
 	trace_nfsd_ctl_ports_addfd(net, fd);
 
-	err = nfsd_create_serv(net);
+	err = nfsd_create_serv(net, false);
 	if (err != 0)
 		return err;
 
@@ -780,7 +780,7 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net, const struct cr
 		return -EINVAL;
 	trace_nfsd_ctl_ports_addxprt(net, transport, port);
 
-	err = nfsd_create_serv(net);
+	err = nfsd_create_serv(net, false);
 	if (err != 0)
 		return err;
 
@@ -2095,6 +2095,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	unsigned int rpcb_failures;
 	const struct nlattr *attr;
 	bool skipped_rpcb = false;
+	bool userspace_rpcbind;
 	bool bad_rpcb = false;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
@@ -2111,15 +2112,25 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
+	userspace_rpcbind = nla_get_flag(info->attrs[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND]);
+
 	mutex_lock(&nfsd_mutex);
 
-	err = nfsd_create_serv(net);
+	nn = net_generic(net, nfsd_net_id);
+
+	if (nn->nfsd_serv && nn->nfsd_serv->sv_no_rpcbind != userspace_rpcbind) {
+		NL_SET_ERR_MSG(info->extack,
+			       "cannot change rpcbind ownership while a server exists");
+		mutex_unlock(&nfsd_mutex);
+		return -EBUSY;
+	}
+
+	err = nfsd_create_serv(net, userspace_rpcbind);
 	if (err) {
 		mutex_unlock(&nfsd_mutex);
 		return err;
 	}
 
-	nn = net_generic(net, nfsd_net_id);
 	serv = nn->nfsd_serv;
 
 	spin_lock_bh(&serv->sv_lock);
@@ -2213,12 +2224,12 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 			continue;
 		}
 
-		flags = skipped_rpcb ? SVC_SOCK_ANONYMOUS : 0;
+		flags = (userspace_rpcbind || skipped_rpcb) ? SVC_SOCK_ANONYMOUS : 0;
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, flags,
 					      current_cred());
 
 		hit_rpcb = false;
-		if (!skipped_rpcb &&
+		if (!userspace_rpcbind && !skipped_rpcb &&
 		    svc_rpcb_failure_count(serv) != rpcb_failures) {
 			skipped_rpcb = true;
 			hit_rpcb = true;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index a145294c59c8..dcce45d58322 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -119,7 +119,7 @@ enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(struct nfsd_net *nn, int vers, enum vers_op change);
 int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(struct nfsd_net *nn);
-int nfsd_create_serv(struct net *net);
+int nfsd_create_serv(struct net *net, bool no_rpcbind);
 void nfsd_destroy_serv(struct net *net);
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index c04ef9d180ce..ef520d0562d6 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -607,7 +607,14 @@ struct svc_rqst *nfsd_current_rqst(void)
 	return NULL;
 }
 
-int nfsd_create_serv(struct net *net)
+/**
+ * nfsd_create_serv - create the svc_serv for a namespace if it has none
+ * @net: network namespace to operate within
+ * @no_rpcbind: true if the caller registers the listeners with rpcbind
+ *
+ * Return: 0 on success or a negative errno.
+ */
+int nfsd_create_serv(struct net *net, bool no_rpcbind)
 {
 	int error;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -635,6 +642,9 @@ int nfsd_create_serv(struct net *net)
 		return -ENOMEM;
 	}
 
+	/* svc_bind() reads this, so set it first. */
+	serv->sv_no_rpcbind = no_rpcbind;
+
 	error = svc_bind(serv, net);
 	if (error < 0) {
 		svc_destroy(&serv);
@@ -775,7 +785,7 @@ nfsd_svc(int n, int *nthreads, struct net *net, const struct cred *cred, const c
 	strscpy(nn->nfsd_name, scope ? scope : utsname()->nodename,
 		sizeof(nn->nfsd_name));
 
-	error = nfsd_create_serv(net);
+	error = nfsd_create_serv(net, false);
 	if (error)
 		goto out;
 	serv = nn->nfsd_serv;

-- 
2.55.0

