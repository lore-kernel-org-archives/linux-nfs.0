Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8DC1569F0D;
	Thu, 10 Sep 2026 18:00:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063259; cv=none; b=B19OzvEsqbcJxtQHa+o+JxJU2TFHR6AdChcAdngrcrXYGjnrFMhctQHm8AxQoz9c6C5d+MOsPEAXW3fX1/Tf428cxIQgfxB7k8waDX4OwoREIGTWrWQ0c2j+4wCHUBk/1SDS/5/xSm2Ma9dTtdqZ4D/qKogAk2kBJI1emus5hWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063259; c=relaxed/simple;
	bh=+5iFsTemV8PqtZ70nQIRFiTg3+tvwp5Sgi/gi++uO8g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZvOCY0CeEwCjMNsmWH+pa7+kpCE+ett4eTzUC+uR6/Fh7fdyvzo6fGmxYr65/lSpcx75VrVGrPNK1K2IiK4uEVx5dxp/PBZqZpnTp+I8d2Crd7XtmrcLt2C66iQuC25l26oTzF7Ucf7K8zjknoDERMbX8fFAXRGngHq+NzSMHe4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DjN0hOS0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DjN0hOS0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 045001F000FF;
	Thu, 10 Sep 2026 18:00:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063257;
	bh=wj2HVPTbhD4XSukugvxiG82e0lkkTSYyWfoYmuhwwXY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DjN0hOS0GxKH1nGt6Gl2Qe4kZrVVVUI4c4n7o2wmRIzFWTWW7UAh5Gu4DALK9BG28
	 IMKgbnYQ21nH7i3UwuIovcLC6IIHZ6B8g6NM9tef+f8VR34EAK6+SEMHc1wvVOZ3eG
	 rjTB6LTipGumQ+DGdBBOrAp2/qxafQ0wAVCyOr0Eg86XbnfOcITPOCEaRWvAHv9cCT
	 1opjKHVmG9znQ7049MKMaCekW5k8am+sufgl2eOg+PaTpyTGhDf+IbmN/qpQacDMve
	 6DOQHhVyXvVK82+ULSYgNF3PZh8PH7jpi+/lIf5a9MkXrfWxywKlbCTOXD04NChFAa
	 qJjUOotn3ngoQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:00:37 -0400
Subject: [PATCH 4/5] NFSD: report registerable programs in the listener_set
 reply
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsd-norpcb-v1-4-b4d5182d634c@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=9145; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=+5iFsTemV8PqtZ70nQIRFiTg3+tvwp5Sgi/gi++uO8g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBQpbS2Ij8DQ9X//7oQcxZwzgp8cWgxhFN5e
 sU1M87H44SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwUAAKCRAADmhBGVaC
 FXMZEACgSEFbc/arNz+5Cw0vg9Ll3Iq8rXJM3Bibyu3Qc+gjRhdNTfdp6rZG/WDCAqBiYjTJIgl
 Ox2VkmduWP6QPqY3yFYUptBoiYKxLnvXku/4YR4KzPm2+6YyQ2b+bOewiTvyFQ5y7Pbi+RwkfsR
 vU6B2l9dU7v5cqaspwK0/SUv826XIkA57pkjbqiT4ytrGJB+X5K0OB17/Ibz10wRSPKxIG3VPgQ
 ffVVuMmCbrFOMrsFfe7rHLyJ5TD32diLyudzSiwbLofrRXVYIB7Sw6XYq+cYpyxg8l0+ipFKJ3p
 VbwGhStpTLVoXkeqQSTDmlb3aI0eOMfZxvbAZkYztrC47LU/qNWsXGfKBAkEMbtjB6n2JtJswxu
 QgfUaOzyeidiegMOQtGUAwFb+P/LFAEi599ZfWaHITC1NfFmXkEZSj7f3H+jB1pdh5XEuEb9VOr
 1Jyzk3nJyMRyx3rDmW78nAkOOzdKXdI9NpW1Yx/Lm/oz+5HTBQQ+FvDeONiASyxI57JwFKtYHab
 FemLqBcdG7sseYulaTUM5YVCJV9gl6odRIksUWcWCZhzZD+MiHtgJRJGVMHMdWoBjwcFf9TploA
 fTA3rE99on9hhsN6tioPeHCKF+jDxsy43DimavpKfqMWuZiXANk04ZBvrXuXBlaW+wan7m+/RDh
 KoWbpKHA/kUUnNQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A caller that owns rpcbind must know what to register. It cannot work
that out for itself: nfsd_support_acl_version() reads nfsd_acl_version[],
which CONFIG_NFSD_V2_ACL and CONFIG_NFSD_V3_ACL build, and no netlink
command reports that.

Reply to a listener_set that carried userspace-rpcbind with the programs
and versions that nfsd would have registered, plus the listeners to
register them for. Send the reply only when the request asked for it, so
an older caller still gets a bare ack.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 139 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h   |   2 +
 fs/nfsd/nfssvc.c |  53 +++++++++++++--------
 3 files changed, 175 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 63746334a46f..102149aac2b6 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2079,6 +2079,128 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 	return 0;
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
@@ -2092,6 +2214,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
 	const char *bad_xprt = NULL;
+	struct sk_buff *rskb = NULL;
 	unsigned int rpcb_failures;
 	const struct nlattr *attr;
 	bool skipped_rpcb = false;
@@ -2273,12 +2396,28 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
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
index ef520d0562d6..890458c08f2e 100644
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
@@ -859,12 +842,44 @@ nfsd_acl_init_request(struct svc_rqst *rqstp,
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
+	if (version >= progp->pg_nvers || !progp->pg_vers[version])
+		return false;
+
+	/* nfslocalio is hidden and never reaches rpcbind. */
+	if (progp->pg_vers[version]->vs_hidden)
+		return false;
+
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+	if (progp->pg_prog == NFS_ACL_PROGRAM &&
+	    !nfsd_support_acl_version(version))
+		return false;
+#endif
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

