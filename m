Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7CD74BD7BD;
	Tue, 15 Sep 2026 16:58:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789491508; cv=none; b=pqsBOBab5fMNJZReG2uHSorg4qa2b6M3GED4Z5GvhANOQHkRfz0CKpvfWtuANE3IGe6Yz2oekE2zreIoXzcf7kt6L8+vnGP8aIROA0Y26It5OcMusDQCRYjKm5aRUDnd/ZdbyKVrsIpjlOsi7iwO2xF5YTv3ZwIWFK2oxKLEMLE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789491508; c=relaxed/simple;
	bh=w8hVnSxhB7CSJMEamGUn2/nMsx+VxVbSzGGcAnKu1Dw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=erFw5ROF4t8Q1bmjSb6WeS9mr+wsAoHMQ/jeNhzWOgNUmFrf1EEiDHSmOXRARs4PNiXWfVOKegjoCch80EEZKPlpVAbm0pYyG3sdIL/FqsszVWYy05Yf+GjcXFvR120wWR8pDBJ1EdyM9px3AZVemugR8BKDbVnTs42ChjLsRI0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jrHnZn+o; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jrHnZn+o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A2F91F00893;
	Tue, 15 Sep 2026 16:58:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789491505;
	bh=sSzSDKtSjNzfxVhYsQdZGlnH5vafz2Jr0mhSSPbOLoc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jrHnZn+ojJvSU3jgk4tDyBeqDR9JizWO4omCRA2UuyewrH8MeBBlqqwqq+aMIfqfo
	 W3xWI010LoXsn9b5EuVG62+NlD7xNSWol1kJTPEyzjVOJRoSibWj6oj6/K/Ej6VgLK
	 iyjtVdmI+0I247oyf+GwrJTvybsE3wsVw2EdTfb/dlYsJ6vE7/G0L4YOCkv21a82Iv
	 IJNx2FOCdThCLb4h+1F1eyiFV7+/T7+uloC4jEMIfedOlx9963NMaLOfxcUYeQh+8w
	 +ElS0CnAIWgEOCvR79B+oTwKRq0IPSFiApil353/f4y3CQxrf6WTPwTMV1KvXRuFQC
	 2NdvQ/0eoIkLA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 15 Sep 2026 12:57:44 -0400
Subject: [PATCH v3 3/5] NFSD: honour the userspace-rpcbind flag in
 listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-nfsd-norpcb-v3-3-3c60d49ade02@kernel.org>
References: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
In-Reply-To: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=7048; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=w8hVnSxhB7CSJMEamGUn2/nMsx+VxVbSzGGcAnKu1Dw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqXkqgGJI00OXowIak4rDsA6fnXZf60sN0f3Fd
 r2asm3Qgw6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaql5KgAKCRAADmhBGVaC
 FURrD/9T3zrxxfW1iWe7tLrLTI9FMlk86JNDMnu9uoEQXZbNIS2lruNz+wnheWwLr7r0QAE9bZO
 +vmG0kSaNXBdm2MWTiLiNndvZwUsuT6fiTXYjI+reqot1LM0evLMLmbdDJ9xNGbainr1ZGkwqqG
 srjt1QP70k+QGgeVj9Ukd1IZ/c4GkUYoNdYaQaXbvObUbFvd2t6SvWvBeHTONxO0owTLnyn3gEX
 QAmSOX5GD+dgz6CB60BMDMV2XSVJaTFMdPJRo9X1Bmi0AtSMwMxQY2bMBRemt0D7WqlFw9s3e5d
 ix7io343525ISi1/FH+8rnNKYTay0aQ+FxE97Ib8wgs4Pj9OL8z77nUt8OQQnmNfgXfdAQkIGSc
 yQ6a61+oWg5ZgRAiWf5YlJoKfs4TmSvh/XXRLc5FxDAtLoo2Vh98QmhTdZU5tKZ8WHy1oqEiDDn
 yTMfoX8fqUve9g+orUV5fuD2UQggdUBXcnNcZKDQsBCjiin4J1QB4bEb9ScoTKaoWapEUUYKZcE
 dFuE/wNQLMDVZXvtfn02vlNxsGkDlTRb/y75gwVvJjkti/fydKhXRQgn5HBxclAQLkBiYsy5QWx
 T29wiQQsRXoCF5g0eVKQ8XoUR6uKWDV2Jjn0HvEYnft4pR92SAGr/8KWO7KynII9euf8276KrOM
 Bb1AEWL6h8gAUpg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A listener_set request that carries userspace-rpcbind now sets
sv_no_rpcbind on the serv. The kernel then makes no rpcbind call at all,
avoiding synchronous rpcbind RPCs under nfsd_mutex.

Ownership cannot change under a live serv. An empty listener list is
exempt: it destroys the serv, and nfsd_destroy_serv() drops whatever
svc_bind() took either way, so teardown is not an ownership change.
Without the exemption a caller that never learned about the flag could
not shut nfsd down, and the extack blamed an ownership change it had not
asked for. nfsd_nl_validate_listeners() returns the entry count so the
gate can tell the two cases apart.

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
 fs/nfsd/nfsctl.c | 49 ++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfsd.h   |  2 +-
 fs/nfsd/nfssvc.c | 14 ++++++++++++--
 3 files changed, 51 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1be8f98a293d..6e57e4d20e75 100644
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
 
@@ -2022,7 +2029,8 @@ static bool nfsd_nl_transport_supported(const char *name)
  * Walk every NFSD_A_SERVER_SOCK_ADDR attribute and confirm that the list is
  * not oversized and that each entry is well-formed.
  *
- * Return: 0 if every entry is valid, or a negative errno otherwise.
+ * Return: the number of entries if every entry is valid, or a negative
+ * errno otherwise.
  */
 static int nfsd_nl_validate_listeners(struct genl_info *info)
 {
@@ -2076,7 +2084,7 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		}
 	}
 
-	return 0;
+	return count;
 }
 
 /**
@@ -2095,11 +2103,13 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	unsigned int rpcb_failures;
 	const struct nlattr *attr;
 	bool skipped_rpcb = false;
+	bool userspace_rpcbind;
 	bool bad_rpcb = false;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
 	struct nfsd_net *nn;
 	bool delete = false;
+	int nlisteners;
 	int err, rem;
 
 	/*
@@ -2107,19 +2117,36 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	 * malformed request fails cleanly without creating a serv or touching
 	 * the existing listeners.
 	 */
-	err = nfsd_nl_validate_listeners(info);
-	if (err)
-		return err;
+	nlisteners = nfsd_nl_validate_listeners(info);
+	if (nlisteners < 0)
+		return nlisteners;
+
+	userspace_rpcbind = nla_get_flag(info->attrs[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND]);
 
 	mutex_lock(&nfsd_mutex);
 
-	err = nfsd_create_serv(net);
+	nn = net_generic(net, nfsd_net_id);
+
+	/*
+	 * An empty list destroys the serv, and nfsd_destroy_serv() drops
+	 * whatever svc_bind() took either way, so teardown is not an
+	 * ownership change. Only a request that leaves a listener standing
+	 * has to agree with the serv it found.
+	 */
+	if (nlisteners && nn->nfsd_serv &&
+	    nn->nfsd_serv->sv_no_rpcbind != userspace_rpcbind) {
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
@@ -2213,12 +2240,12 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
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

