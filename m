Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC9662F3C18;
	Tue,  1 Sep 2026 13:40:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270008; cv=none; b=g2B89950Pp/uGE7V+37C4m9bjoD6RAr6YESHG203VjnChZXcqKRZTdBI5dSEWTfMJ/D922KwlOUVRicNZZrT70y0SYHPwAvYYIyOAcKQFHcnHfFXyyoOgfpraNkSkA6a3GmkT54evth26FLdRPrOpV60yU+QUvAS2RXjeZP1pu8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270008; c=relaxed/simple;
	bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NXOC8IiC6+cbiIoxRgrYIQoxPaxBhHRex0tdNgNAiHQRtfb69ArL4NSaUeatOZ+zFs0XlGz+JFe2zs7mno7BnHPqV+ltf3ZKZ1Pa4R2DkaVgVt4wIYlW3yIVyPRT70hphg5dsa+HF9k4nmNouSr1JslI0QlkqDSJ6DfaG4IOLsQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BnKW3vZx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BnKW3vZx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33E451F00A3D;
	Tue,  1 Sep 2026 13:40:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270006;
	bh=f7DIO5UFdyzmop+0FickQyJR+upbMPxvd7WYzoH5UvM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BnKW3vZxrxuHwWNycigqeLIWzN/bOxUePAv20ekKVg76KgBoSO/CBbZap98SVdTAP
	 TOOT3FJ4yUOpqU+VHTt4a0apDE7wd3cOt8Cx2Pmb0eNUPhhkpuLNv2aSFrZnLMYrs3
	 5ViPncRorCJG8+qMrpSfEMLz8JhPWjXe6pDVtxG1/IEhTrxKJkY9FuHxksW0phQH5w
	 nfaDoiyG+80XdfrK8KawpejLGFFYfc1j6a9SKI1M9pZKlKKwqxwR6dZVT8t05hncEa
	 zYHrIukzZNdvDVF07inmaZhEXuZM/BN+JQ+a451444JdPFrbWHeNO9wjVC/Y5xNs+4
	 nenTP95lMWdDg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:40 -0400
Subject: [PATCH v5 02/15] NFSD: validate transport name in listener_set
 before serv creation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-2-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2761; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWuaHsNrR6zYYfSMArd5NsyaG532BAv1IbcP
 lDaHurfePSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrgAKCRAADmhBGVaC
 FSz3D/9mEWvGywz0hP/R1Ypu96onbBI6AKRDb48NcEZ6LdvoAVUbRrNw3GEr3fydzFtiQF50XLu
 zJBrs1AxMLlUvQYklx0Ihe3Zr0xFuYWdU0YKefxx6fkyClVTkDuh+E7MEm3/7FtPYiT9KWK5N5L
 7iPFYSH8ax0v880YAmEWSew/+VqIJZRlF7PbxTwq4VsqevLPl8bcXRf67A5k/4s6MvNmEXraweG
 s7Hojn1Q3j8+bAzRKH3qcKVbHFRI1h8ocdCCZq3e3XMqy5oUyd1ONJRpYPE50nDcTSgpn4g9ips
 HsDWHCqLPOP1O5HtUqNK4bvlu0vJo1W+Etv5vewWHzJhIXkIc8RrcyUJClZtEgi02zaAfBTYrS4
 7ttN9eQdQsClk8bKcKPU3ToKh04KtXJFBkTal6W2NKKOOe8odfoSIXU4s+BoHIIG9b37HczowCE
 bmVJz+yqB3K/DKIvap/CJOM0c1aCXDsV3da15QJ3+xto8Ray+vQLsmWx5yUhasIIwQ5jdmgUJLk
 mtibP9A1SRG1Ch1rxxhkZDXdcYVOIUILyTpzHt0VG8QVnfrtyaUHKyWpfRUpW5D1FxMhqRzYFJ2
 uGEy2mauYPQrFOtZV/3xmVu1LPG3T2mNAcgl1mPfvd9ahRHVylf4jYCV89wmu6vJigAJQXi/s+G
 JOibkyb9UzgQIUQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() holds nfsd_mutex for the whole listener
teardown and rebuild. The code checks NFSD_A_SOCK_TRANSPORT_NAME for
presence only, and not for content. An arbitrary name therefore reaches
svc_xprt_create_from_sa(). There, a name that matches no registered class
calls request_module("svc%s", name). That call is a TASK_KILLABLE usermode
helper upcall, and it runs under nfsd_mutex.

Check the name against the classes that NFSD can create: tcp, udp and
rdma. The check goes in nfsd_nl_validate_listeners(), which runs before
the code takes nfsd_mutex. The rejection names the offending attribute
through extack, since -EPROTONOSUPPORT on its own does not say which
entry carried the bad name.

This narrows the upcall. It does not remove it. NFSD accepts "rdma"
without a condition, so on a kernel that does not build svcrdma the name
still reaches request_module("svcrdma") under nfsd_mutex. That is
necessary for the modular case, where the autoload is legitimate.

Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
Assisted-by: LLM
Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b6f4d66f612a..d8135f38e69f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1995,6 +1995,23 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+/*
+ * Transport classes NFSD knows how to instantiate. Vetting the name here
+ * keeps a bogus string from reaching svc_xprt_create_from_sa(), where an
+ * unknown name triggers a request_module("svc%s", name) upcall under
+ * nfsd_mutex.
+ */
+static bool nfsd_nl_transport_supported(const char *name)
+{
+	static const char * const supported[] = { "tcp", "udp", "rdma" };
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(supported); i++)
+		if (!strcmp(name, supported[i]))
+			return true;
+	return false;
+}
+
 /* Upper bound on the number of listeners a single request may carry. */
 #define NFSD_NL_LISTENER_MAX	1024
 
@@ -2032,6 +2049,13 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		if (!tb[NFSD_A_SOCK_ADDR] || !tb[NFSD_A_SOCK_TRANSPORT_NAME])
 			return -EINVAL;
 
+		if (!nfsd_nl_transport_supported(nla_data(tb[NFSD_A_SOCK_TRANSPORT_NAME]))) {
+			NL_SET_ERR_MSG_ATTR(info->extack,
+					    tb[NFSD_A_SOCK_TRANSPORT_NAME],
+					    "unsupported transport name");
+			return -EPROTONOSUPPORT;
+		}
+
 		sa = nla_data(tb[NFSD_A_SOCK_ADDR]);
 		if (nla_len(tb[NFSD_A_SOCK_ADDR]) < sizeof(sa->sa_family))
 			return -EINVAL;

-- 
2.55.0

