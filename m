Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F1174BD0F1;
	Tue, 15 Sep 2026 16:58:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789491515; cv=none; b=GtVtSPh1XFwbO7Ef7z+zSaRkRV2aPIgmAZS0ko3tZNsUtvdLOKjvpyV/dlSyqjh+Je9LNyoy480Vuc89F78LKUpuQSGChv6LVvYelvxSUEz6W9xjSjz9wDgPqUzWQnhywmVi4+TS4OGCaIWi3ZQgAipDcdsxjob5QQHZ6X+7OEQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789491515; c=relaxed/simple;
	bh=ZFJ4FIvGlBPWqrpHWIRu0z11kYO2hDsLf6Lh3mDHM8w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dGfINguqALD5KQ6JYqyGI/YNUv1SJ78onQOJW6eOfzpIt/y9S3J1EgYbXoEGbzT+6HF2zNWdgDIx6RcC+FydDEWrQ3tUCp3gqkRHp6aISZmrhTMcJfNWjbMufYWKPjsJmzaC+d92o7/+RNGJF51YcOaOVSGLhQ7A8tZRHIKY9LA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=I90ad8/W; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="I90ad8/W"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CDE6A1F00899;
	Tue, 15 Sep 2026 16:58:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789491507;
	bh=7pvwtcbJiVJTSoXq0mtTQ4KVaqoIA/SIQAPR+4GBHWs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=I90ad8/WcpHCZqYhA/cUXLyh76jyqbN1Q7Q0XQxvK5Et5GpSqUsPW8Ltk3CyzFyrN
	 99k7JRX0Lb/HKjazt4yWtSg8NGenj+z2RGXmOpvD9M+62Y95MN2uU8ADfWgNPl0C7O
	 u/KAVRTmes0fNEHwLOv7EBVdEM7JW1YZ6nq9+U2muOu+bIw7N13/UZXzBeewiHW/Qn
	 r8Tlrl+jGRe6rFj0QXqK5KQW6XPahHN7A30B/lteO+oyf3PL3fX1TusRnm4tjptJcV
	 T9n2yCbYpEOEuVkbsk5Ct+zMGDvcpu0jE8Rp1ZXUNSz9pR8RXRMBMiBG2+nK9JVKi1
	 uZ7YUHi2b1FtA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 15 Sep 2026 12:57:45 -0400
Subject: [PATCH v3 4/5] NFSD: report registerable programs in the
 listener_set reply
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-nfsd-norpcb-v3-4-3c60d49ade02@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=10561; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ZFJ4FIvGlBPWqrpHWIRu0z11kYO2hDsLf6Lh3mDHM8w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqXkqvrZiCLj/vfU4YOwZINZRA/qBfEItD63zy
 TwXZ+epFVqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaql5KgAKCRAADmhBGVaC
 FUtLEACioo2yImbWDawoQ3eV4Vuxhpd4fk+7gg2eZ5htwtg6Jtjii8tFxq5sbYVS+j4Yj3sm79w
 BUDXJ2NGAo8GBRjZO2OsydZ6CRkf7DWTvbd16NtNFZDYmbkwFxq/P8mXRXcrszNQpe7ycwcAdhy
 8sxgUKEG+GbM039ngAqxuauiD8lbOz0Ik6pM6FtnBolk2kiyCIITHbOqN7i8BOciWUGCyLZNSBh
 Idk475LleijWOFpVtHrXt18MQq4EMOlkM2zsCE6WIvXG/ZNPJ6LnPuiOKbu4vXbQxqQTTaNrluj
 SdmonfvdfJbQ0fKTyRY8rNzSsyevBXzjo4YkmFhAEVXEvnByAK+Z9uxatH7Tc5AiXmwWq055Dkx
 5nauWiXDrMIVu+bCfobnjsLCMUeNvwDit7okWRQAf0VCx/31c1MAVOf+nlrPc0G1OcSy9N1td7v
 d6Oj5qBd41EgX9o/0SFI/TG2G753SwIt/QUTFwe0LkuFuTDkZY0fFPvNvKjflbCRa1rL1C88kbP
 j4JARpRfzW2GtY0lZtCbaNSIhVfpXTbm8GPC/6i1OmDDtZ4DHdnmOtext3tAZgY6E6RM1jqllGd
 f28OBR0ZdSVz3c4PTucQ9obwtAq4sTq3keuZjKHoZlm4eWrBnYB1riq/4DFlCzqQ22r/M8Kz6NO
 9wZnEusmVrm2ZuA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A caller that owns rpcbind must know what to register. It cannot work
that out for itself: nfsd_acl_version[] is built by CONFIG_NFSD_V2_ACL
and CONFIG_NFSD_V3_ACL, and no netlink command reports what is in it.

Reply to a listener_set that carried userspace-rpcbind with the programs
and versions that nfsd would have registered, plus the listeners to
register them for. Send the reply only when the request asked for it, so
an older caller still gets a bare ack.

nfsd_version_registerable() answers the same question for the reply and
for nfsd_rpcbind_set(), so nfsd_acl_rpcbind_set() goes away. It needs no
nfsacl-specific test: nfsd_acl_version[] has entries only at 2 and 3, so
the NULL pg_vers[] check already rejects everything
nfsd_support_acl_version() would have.

Listeners are reported only for the TCP and UDP classes, which is what
XPT_RPCB_UNREG marks. RDMA never reached rpcbind from the kernel either,
so there is nothing for the owner to register on its behalf.

The reply is sized from its contents rather than GENLMSG_DEFAULT_SIZE,
which listener_get uses and which overflows at ~27 listeners. The cost
is a large contiguous skb: the addr nest carries a full
sockaddr_storage, as listener_get's does, so a request at
NFSD_NL_LISTENER_MAX needs ~148K and alloc_skb() lands on an order-6
page allocation that can fail. Nothing rolls back on failure, matching
the rest of the command, so the extack says the listeners are up and
that a retry fetches the reply. Retrying is safe: a request that matches
the running set recreates nothing.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 146 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h   |   2 +
 fs/nfsd/nfssvc.c |  52 ++++++++++++--------
 3 files changed, 181 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6e57e4d20e75..f32311f2d7cf 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2087,6 +2087,128 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 	return count;
 }
 
+static size_t nfsd_nl_listener_set_msgsize(struct svc_serv *serv)
+{
+	size_t size = GENL_HDRLEN +		    /* genlmsg_iput() */
+		      nla_total_size(0);	    /* userspace-rpcbind */
+	struct svc_xprt *xprt;
+	unsigned int p;
+
+	lockdep_assert_held(&nfsd_mutex);
+
+	for (p = 0; p < serv->sv_nprogs; p++)
+		size += serv->sv_programs[p].pg_nvers *
+			(nla_total_size(0) +		    /* rpcbind nest */
+			 nla_total_size(sizeof(u32)) +	    /* program */
+			 nla_total_size(sizeof(u32)) +	    /* version */
+			 nla_total_size(sizeof(u32)));	    /* flags */
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
+		if (!test_bit(XPT_RPCB_UNREG, &xprt->xpt_flags))
+			continue;
+		size += nla_total_size(0) +		    /* addr nest */
+			nla_total_size(strlen(xprt->xpt_class->xcl_name) + 1) +
+			nla_total_size(sizeof(struct sockaddr_storage));
+	}
+	spin_unlock_bh(&serv->sv_lock);
+
+	return size;
+}
+
+static struct sk_buff *
+nfsd_nl_listener_set_msg(struct genl_info *info, struct net *net,
+			 struct svc_serv *serv)
+{
+	struct svc_xprt *xprt;
+	struct sk_buff *skb;
+	unsigned int p, i;
+	void *hdr;
+	int err;
+
+	lockdep_assert_held(&nfsd_mutex);
+
+	skb = genlmsg_new(nfsd_nl_listener_set_msgsize(serv), GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	hdr = genlmsg_iput(skb, info);
+	if (!hdr) {
+		err = -EMSGSIZE;
+		goto err_free_msg;
+	}
+
+	if (nla_put_flag(skb, NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND)) {
+		err = -EMSGSIZE;
+		goto err_free_msg;
+	}
+
+	for (p = 0; p < serv->sv_nprogs; p++) {
+		const struct svc_program *progp = &serv->sv_programs[p];
+
+		for (i = 0; i < progp->pg_nvers; i++) {
+			struct nlattr *attr;
+			u32 flags = 0;
+
+			if (!nfsd_version_registerable(net, progp, i))
+				continue;
+
+			if (progp->pg_vers[i]->vs_need_cong_ctrl)
+				flags |= NFSD_RPCBIND_FLAGS_NO_UDP;
+
+			attr = nla_nest_start(skb, NFSD_A_SERVER_SOCK_RPCBIND);
+			if (!attr) {
+				err = -EMSGSIZE;
+				goto err_free_msg;
+			}
+			if (nla_put_u32(skb, NFSD_A_RPCBIND_PROGRAM,
+					progp->pg_prog) ||
+			    nla_put_u32(skb, NFSD_A_RPCBIND_VERSION, i) ||
+			    (flags && nla_put_u32(skb, NFSD_A_RPCBIND_FLAGS,
+						  flags))) {
+				err = -EMSGSIZE;
+				goto err_free_msg;
+			}
+			nla_nest_end(skb, attr);
+		}
+	}
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
+		struct nlattr *attr;
+
+		if (!test_bit(XPT_RPCB_UNREG, &xprt->xpt_flags))
+			continue;
+
+		attr = nla_nest_start(skb, NFSD_A_SERVER_SOCK_ADDR);
+		if (!attr) {
+			err = -EMSGSIZE;
+			goto err_serv_unlock;
+		}
+
+		if (nla_put_string(skb, NFSD_A_SOCK_TRANSPORT_NAME,
+				   xprt->xpt_class->xcl_name) ||
+		    nla_put(skb, NFSD_A_SOCK_ADDR,
+			    sizeof(struct sockaddr_storage),
+			    &xprt->xpt_local)) {
+			err = -EMSGSIZE;
+			goto err_serv_unlock;
+		}
+
+		nla_nest_end(skb, attr);
+	}
+	spin_unlock_bh(&serv->sv_lock);
+
+	genlmsg_end(skb, hdr);
+	return skb;
+
+err_serv_unlock:
+	spin_unlock_bh(&serv->sv_lock);
+err_free_msg:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
 /**
  * nfsd_nl_listener_set_doit - set the nfs running sockets
  * @skb: reply buffer
@@ -2100,6 +2222,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
 	const char *bad_xprt = NULL;
+	struct sk_buff *rskb = NULL;
 	unsigned int rpcb_failures;
 	const struct nlattr *attr;
 	bool skipped_rpcb = false;
@@ -2289,12 +2412,35 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 			       "rpcbind did not answer, some listeners are not registered");
 	}
 
+	/*
+	 * Build the reply before the serv can go away, and only on success.
+	 * A caller that got an errno has nothing to register.
+	 */
+	if (!err && userspace_rpcbind) {
+		rskb = nfsd_nl_listener_set_msg(info, net, serv);
+		if (IS_ERR(rskb)) {
+			err = PTR_ERR(rskb);
+			rskb = NULL;
+			/*
+			 * The listeners are up and the errno alone reads as
+			 * if nothing happened. Retrying is safe: a request
+			 * that matches the running set recreates nothing.
+			 */
+			NL_SET_ERR_MSG(info->extack,
+				       "listeners are up but the reply could not be built; retry to fetch it");
+		}
+	}
+
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))
 		nfsd_destroy_serv(net);
 
 out_unlock_mtx:
 	mutex_unlock(&nfsd_mutex);
 
+	/* rskb is only built once err is known to be zero. */
+	if (rskb)
+		return genlmsg_reply(rskb, info);
+
 	return err;
 }
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index dcce45d58322..69e3e92b3ec1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -117,6 +117,8 @@ extern const struct svc_version localio_version1;
 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(struct nfsd_net *nn, int vers, enum vers_op change);
+bool nfsd_version_registerable(struct net *net,
+			       const struct svc_program *progp, u32 version);
 int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(struct nfsd_net *nn);
 int nfsd_create_serv(struct net *net, bool no_rpcbind);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ef520d0562d6..cbc989238710 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -41,11 +41,6 @@
 atomic_t			nfsd_th_cnt = ATOMIC_INIT(0);
 static int			nfsd(void *vrqstp);
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-static int			nfsd_acl_rpcbind_set(struct net *,
-						     const struct svc_program *,
-						     u32, int,
-						     unsigned short,
-						     unsigned short);
 static __be32			nfsd_acl_init_request(struct svc_rqst *,
 						const struct svc_program *,
 						struct svc_process_info *);
@@ -127,7 +122,7 @@ struct svc_program		nfsd_programs[] = {
 	.pg_class		= "nfsd",
 	.pg_authenticate	= svc_set_client,
 	.pg_init_request	= nfsd_acl_init_request,
-	.pg_rpcbind_set		= nfsd_acl_rpcbind_set,
+	.pg_rpcbind_set		= nfsd_rpcbind_set,
 	},
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
@@ -813,18 +808,6 @@ nfsd_support_acl_version(int vers)
 	return false;
 }
 
-static int
-nfsd_acl_rpcbind_set(struct net *net, const struct svc_program *progp,
-		     u32 version, int family, unsigned short proto,
-		     unsigned short port)
-{
-	if (!nfsd_support_acl_version(version) ||
-	    !nfsd_vers(net_generic(net, nfsd_net_id), version, NFSD_TEST))
-		return 0;
-	return svc_generic_rpcbind_set(net, progp, version, family,
-			proto, port);
-}
-
 static __be32
 nfsd_acl_init_request(struct svc_rqst *rqstp,
 		      const struct svc_program *progp,
@@ -859,12 +842,43 @@ nfsd_acl_init_request(struct svc_rqst *rqstp,
 }
 #endif
 
+/**
+ * nfsd_version_registerable - would nfsd register [@progp, @version]?
+ * @net: network namespace to query
+ * @progp: RPC program to query
+ * @version: RPC version to query
+ *
+ * Answers the question for a listener of any protocol. A caller that asks
+ * about one listener must apply vs_need_cong_ctrl itself.
+ *
+ * Return: true when the version is a candidate for rpcbind registration.
+ */
+bool nfsd_version_registerable(struct net *net,
+			       const struct svc_program *progp, u32 version)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	/*
+	 * nfsd_acl_version[] is built by CONFIG_NFSD_V2_ACL and
+	 * CONFIG_NFSD_V3_ACL, so a NULL entry already answers for nfsacl and
+	 * nfsd_support_acl_version() would add nothing here.
+	 */
+	if (version >= progp->pg_nvers || !progp->pg_vers[version])
+		return false;
+
+	/* nfslocalio is hidden and never reaches rpcbind. */
+	if (progp->pg_vers[version]->vs_hidden)
+		return false;
+
+	return nfsd_vers(nn, version, NFSD_TEST);
+}
+
 static int
 nfsd_rpcbind_set(struct net *net, const struct svc_program *progp,
 		 u32 version, int family, unsigned short proto,
 		 unsigned short port)
 {
-	if (!nfsd_vers(net_generic(net, nfsd_net_id), version, NFSD_TEST))
+	if (!nfsd_version_registerable(net, progp, version))
 		return 0;
 	return svc_generic_rpcbind_set(net, progp, version, family,
 			proto, port);

-- 
2.55.0

