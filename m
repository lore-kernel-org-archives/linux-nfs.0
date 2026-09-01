Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5457547F78E;
	Tue,  1 Sep 2026 13:40:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270021; cv=none; b=agXnUhFzVERLo1Osb/dfB5lgOPtmg5V1BI8DUl2/mOFPJS1ftJL2fAzeH0vBfeAGwVjYoi/zqwVi4NhNkRejIppaL6mt4QDRcy/krR+y65+Zayhjp1viFhtK0e9QPI/tOTXN4/P1OlzBDJ4EGJCbUSJGruryiPXRFcJSWDxNsRM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270021; c=relaxed/simple;
	bh=f2Z8k6GcgoIUj3Olxr0Qxt0ELIlZxuGOVQEcHdPGh1g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ky2CkEu5e4vbhWfjw8rFI9fpuM/J6jCehul6gmkOWWKO30Mo57+DsKeXkKM2a/sDBj+vMd5Dboj42YVweR6VmoDdkgzeKBh0t2UsQZWEkbyndVcY4y3eQCtlBafPuTMmRuipHRne+saqX9aSyeyPD0zfgHhMiNurmiaJ26Lu53c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kaNuO9JM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kaNuO9JM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D7761F00A3D;
	Tue,  1 Sep 2026 13:40:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270019;
	bh=bfaSv13nbLfzYE4zUFuADA/CvpnLYYvbl3M88GgwW30=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kaNuO9JM4xr1DJ20MFc9TmDYX4AyS6qhN142JY2zZu3fDki19302w+etFQWdlZDCC
	 RCjWHEx6M/mp1kWOXWgem0RfGExbA4EN11k9X+AyYCgLdanBtklPbYmqx+zM93VY61
	 VpQYo2Xsl1kMuR8WsnkqP8LflSwBGDksppmiPK74MrByvbQPP2eM4UKV2zl04NxqS7
	 N7p31exiXQPyRp2+yP3mkXXmQH9l5qpg6IIXmfUXNdQVKsTyRTeYk9htf0B2jsDg65
	 GRjuhXT4OSkPqtaM8pvV39qyJ4tGlTez86U7EEzOx4el8JzIP3ZSUn5g/5z4xfTC9/
	 0UXx/1DBY81/g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:48 -0400
Subject: [PATCH v5 10/15] NFSD: stop registering with rpcbind after a
 failure in listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-10-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3924; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=f2Z8k6GcgoIUj3Olxr0Qxt0ELIlZxuGOVQEcHdPGh1g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWwJHTytUPCbGK+b5wNAESiX3eTe8WJoABlh
 6dmPT93eiGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVsAAKCRAADmhBGVaC
 FYUYEACIDrKkWyCBPkdTQTM7iGwqpHqALvbicbkvJnW/C6QmtK91mlVB7tnPDDDLITAL6Kd42Pq
 0fp5mtrh3KFE3jlws90p5j5CGofjBCR0+Alz2gr4qyDCYCWk+ug0kLFG5bBuqNK2rz0f8EXRnWQ
 pdcmKCY2cv46OE9dz6kT7IBPw0g9ssBGeV7zxSA40gT3lPa5yZVk/f6w97DOI/6u1J1mV48FNfZ
 5jzvJcyhlfUDs7B2FbTwJMvY7WJm1+C3Ivup9PUWhlUCCwSOSopTq2GVpKemwjf/U8Fc+9cpARY
 Wvp3ckUnCj6JIOA3ZBdyuKYctSLRnhwq7jV3Vjh6tfT73gdI6ScIFxX7dODK13MOwqwS+5jn3bT
 lIS4vf1I0cNtbI1pFFL5U/njgQhELVzs+lgN2EPzaVN5BDsgqSIRxtnh4Exi2qSPvXD53ID2ZF+
 UA7+3besq6gD+LzedvXprQsNfS822Y/BLSMskFvlpG6EfqGH+ewS2cs5biV/jHbQCnZRo9fRgGu
 YUib/v/EIDjDII5cTHaYh882AT0Lk5CRqv4qN3eaob6aQu8Yi3lwdw+r5sJG8WAj64q/AmJpSvQ
 dlPjqtt07Y3zgKoQQuVpxoHpD46qBfj7fKng1vQVMDxfAA8SW42Md80cxWhAhDuIHqtS1IrbiK7
 uRc0oxCPY8YA2bA==
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
 fs/nfsd/nfsctl.c | 42 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 38 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6cbdcee4b733..c6f6bc3b1281 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2092,7 +2092,10 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
 	const char *bad_xprt = NULL;
+	unsigned int rpcb_failures;
 	const struct nlattr *attr;
+	bool skipped_rpcb = false;
+	bool bad_rpcb = false;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
 	struct nfsd_net *nn;
@@ -2182,13 +2185,16 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
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
+		bool hit_rpcb;
+		int flags, ret;
 
 		/* validated up front in nfsd_nl_validate_listeners() */
 		if (nla_parse_nested(tb, NFSD_A_SOCK_MAX, attr,
@@ -2207,12 +2213,27 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 			continue;
 		}
 
-		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
+		flags = skipped_rpcb ? SVC_SOCK_ANONYMOUS : 0;
+		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, flags,
 					      current_cred());
+
+		hit_rpcb = false;
+		if (!skipped_rpcb &&
+		    svc_rpcb_failure_count(serv) != rpcb_failures) {
+			skipped_rpcb = true;
+			hit_rpcb = true;
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
 			bad_xprt = xcl_name;
+			bad_rpcb = hit_rpcb;
 			err = ret;
 		}
 	}
@@ -2224,8 +2245,21 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	 */
 	if (err) {
 		NL_SET_BAD_ATTR(info->extack, bad_attr);
-		NL_SET_ERR_MSG_FMT(info->extack, "cannot create %s listener",
-				   bad_xprt);
+		if (bad_rpcb)
+			NL_SET_ERR_MSG_FMT(info->extack,
+					   "cannot create %s listener; rpcbind did not answer",
+					   bad_xprt);
+		else if (skipped_rpcb)
+			NL_SET_ERR_MSG_FMT(info->extack,
+					   "cannot create %s listener; rpcbind did not answer earlier, so some listeners are not registered",
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

