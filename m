Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C13D47F791;
	Mon, 14 Sep 2026 15:21:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789399274; cv=none; b=i9eKRow7z8Y7BgR0j6QQD8QcvHEZbfTcSivhElYQ4cnm6cB4pPDCu9ORBazKkgCRcg5QwtFokMM3B8d7cjuyWRaseYtMB7lGm1NDZ4pV0S2dTepxRvwupckmky2aUA90zRyqHB6r2Cy1ZXdG1j9iX7xQeU9wXVIdo57KD0Sn3os=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789399274; c=relaxed/simple;
	bh=C3xajPKbFSHFqX0Wtv9izib5A53bSMe1dMWdnMH5wSM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oc5YFLFJqzDQs+XMrKOUwPAKAJoKDwN+R8aVjkgO4X6eNP7YWLpeBOZpVUqWmkx4xXwOaEGRrLONvoBL/aDW7k12ShWeRYsdyB4dC+zVVPPQCmHserwERi3Vdhp9Y3KnDWk3+ct/V5E+PtT19G2QGXH6o24A1pgYZUjMWwGgbzQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nrLc6nQo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nrLc6nQo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C4A61F00899;
	Mon, 14 Sep 2026 15:21:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789399271;
	bh=VRH/H/+N8Z/Vfxv9jNxARCyZVqpjG1luBuWidiJcDi8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nrLc6nQoC18zeNhjb/yn7dGI8EjwLR1G2/cdp53Fn4bpi6ZmZjCLDbZdV2pCO6tzg
	 FMnDHIIdWhrIzIgwYxkyETW8vBh8kHop2UC8AMmOfbU8z/Hto8U2nH4CC6rTerzYYz
	 bW/e3dlJMzdSqdb2jExGAQPuoX82w3KKKlNOdLI6PcVdAq5xYbfJQSJSKOA/N4Gmug
	 wSYhWszT3dJLLdTMyRUiQTrQa8VRzt/8uqrmSZFKYeFe7kp0G54y5GdxwYQOQeFzKN
	 2/aDcHEytlGGqe2V/9XtFlMkrGjt4boJ3+vidS6TsrJuMngpvxYlPTG5zJyUp7U3H2
	 MgwJHBwi2uXDw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 11:20:40 -0400
Subject: [PATCH v2 3/5] NFSD: honour the userspace-rpcbind flag in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsd-norpcb-v2-3-38263c6f59b2@kernel.org>
References: <20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org>
In-Reply-To: <20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5333; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=C3xajPKbFSHFqX0Wtv9izib5A53bSMe1dMWdnMH5wSM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBDg7RdvDBI+ET24j/jZku3r+TJNeYS1JTYzK
 QYG/FZNmnKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgQ4AAKCRAADmhBGVaC
 FSVLD/0TwpxojxIrLEjzGxYZ9zNCaljn7UBiyvs0jDXCmnK0JnGgPXRJAQLeCANi6OzyW1dxzIT
 NyBAsTfkx4fK2fs+i0qkwZ3bVTn0LsGdokJHMqZJoRElRHx8BX4jlHbOgAUpQHXnFkZLJpWK+sR
 kVtc3N4Mtf1Xx7O51MIKS7/bpTDnrmhFqu2i+jLzFZat5ScLu+CFPlz39eI6f6whFFqLCLlmgye
 kbTZhNQQROiqY87YeNfQtVxhQ/rJ5LmflVKoJtViYjDPtVRjR/MYoW2PBBm9qHTsMHDnv+MY3+c
 EymtDR7D8TejIPu+qGqXylTvlkWXNIbr00wqMEJBSe2rPASoDDJZylHRfl00sURKJV4N9FxADfB
 1WqlgvbGQMarVw1iqbiq0SzgniOIKmRlAvQiXBqyby+aN2T7sm06/X8jJWLGSbR26kSd4jIcZGY
 rjiHKQl35wwJAtVexy1BMSJtdThJltnQWZm44JrRbOaQPHsA0pidGm1e+ViPhy7V/V7E1QBV/FI
 08GIBDow96D/+TkDMUMQZTaFX2N3lF1jEbGlLaiYN0jLxuHFqeu1FIEBwzpeNR0XBRXw9I/l3v9
 KbmREU7ByzLIOA3pOMHttMbleGKlZzKE2gzCfOkec2YHus2eZnE44rduy+ZDxWIURA8gOtVMqC3
 bu9761WAQ3I7mZw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A listener_set request that carries userspace-rpcbind now sets
sv_no_rpcbind on the serv. The kernel then makes no rpcbind call at all,
avoiding synchronous rpcbind RPCs under nfsd_mutex.

The legacy portlist add-fd interface refuses to run against such a serv.
nfsd_create_serv() returns early when the serv exists, so it cannot flip
ownership back, svc_addsock() does not pass SVC_SOCK_ANONYMOUS and so
expects svc_register() to register the listener, and there is no way to
tell the rpcbind owner about it. -EBUSY, matching listener_set. add-xprt
already passes SVC_SOCK_ANONYMOUS and never registered anything.

lockd is unaffected. It owns a separate svc_serv and still registers NLM.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 30 ++++++++++++++++++++++++------
 fs/nfsd/nfsd.h   |  2 +-
 fs/nfsd/nfssvc.c | 14 ++++++++++++--
 3 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1be8f98a293d..207a1bed3928 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -748,7 +748,14 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net, const struct cred
 		return -EINVAL;
 	trace_nfsd_ctl_ports_addfd(net, fd);
 
-	err = nfsd_create_serv(net);
+	/*
+	 * svc_register() is a no-op once userland owns rpcbind, and this
+	 * interface has no way to hand the new listener to that owner.
+	 */
+	if (nn->nfsd_serv && nn->nfsd_serv->sv_no_rpcbind)
+		return -EBUSY;
+
+	err = nfsd_create_serv(net, false);
 	if (err != 0)
 		return err;
 
@@ -780,7 +787,7 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net, const struct cr
 		return -EINVAL;
 	trace_nfsd_ctl_ports_addxprt(net, transport, port);
 
-	err = nfsd_create_serv(net);
+	err = nfsd_create_serv(net, false);
 	if (err != 0)
 		return err;
 
@@ -2095,6 +2102,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	unsigned int rpcb_failures;
 	const struct nlattr *attr;
 	bool skipped_rpcb = false;
+	bool userspace_rpcbind;
 	bool bad_rpcb = false;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
@@ -2111,15 +2119,25 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
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
@@ -2213,12 +2231,12 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
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

