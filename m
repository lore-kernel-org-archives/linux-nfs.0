Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 262474B7177;
	Mon, 31 Aug 2026 16:15:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192942; cv=none; b=ImQaBcJsyO/qAVN5REYHqmmuC/pUDE3lsLQ4NuGK1Rn7eH/Ax3N90Jw2YfstLfCc0UI//dPosQJNnmnPovuwkiVEAKVTBO5TL910joKWAR4jF/H1iLHzgwbSKpzeBlpW5Woi4e3V5CUQVkBRCmOzU2pxEjDrUpST+YITi/+LAww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192942; c=relaxed/simple;
	bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gYddHJBtUrr9PAOIxw3g8ule7j+rGH2bnp7+GE4/HmPP6coBfUPCZjdOSKyDLcLFJ3gy+6P38pm/5jGyTklbjZhTlka/4K7D7euc0LKsgRj7AvQld7beCFtXVDxE91GbChVuVAEkFjEzQHkakr0+rVu9ciFEaoVqJNFvDv+7J30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FwQ+4nFJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FwQ+4nFJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 362721F000E9;
	Mon, 31 Aug 2026 16:15:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192940;
	bh=f7DIO5UFdyzmop+0FickQyJR+upbMPxvd7WYzoH5UvM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FwQ+4nFJK0h5kunzgMnrcBnBiqAr6MOP/9hUW+bcXgJBCV24tIb4CQeDfQfA3p+Jt
	 KrnST0je5exX4TOiFMOe5KH85e93G6kLQb+ipfVBDqGl16pNbQjDIBiB+WyZpwQtyy
	 V2d4jD9SQfxoSqBsAABI1pRG7WkVOVp1IGiPsGnCL+BczPmjcdjeobUBP1mSfzFbL+
	 0pNdUCDXtcHEKxFnma4d+3BmLaVsqYBufUuUH8cDJ9GAZoBBFsAgYj0kyzuMN0rH7N
	 6YFN8PJlSWhXpT1/gPg90r1dKun6qFDuGHIfzYKcNZWgaHa7oxWJKKZPoFpLDra9jD
	 uqx02RkF90gPQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:44 -0400
Subject: [PATCH v4 02/14] NFSD: validate transport name in listener_set
 before serv creation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-2-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2761; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aJetiop332TzGMjtNxCwp2osCzOlN1SMdSvmKASa+aI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaieu4cKgNR2R4sHpDTZQOh+fGvc/LUHCNfaV
 QewspRHcwKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWongAKCRAADmhBGVaC
 FbXTEACJ8pliZonrFmmFGrBtUJcbeSwXJdZqUXYt9OnDRD0f/qmCKZzFhmDhSR+uRcG1YUYKX80
 QdXi50z268uEENITujKzaozoov/Y6GakWiu14KjnAy/hjZmA4BFyc/7JmkCYEy4rmtao7yI5JBc
 ZdpGxDxKh3vi3JSDwi7V67GYtqVuhjVNPyDLKBJprCA0L3dlAnliR+AxSa4IPn9/OKtLGMl4rXI
 D21uBNjQQBF4k0E5aA05ccM/bLHXB/0I7qGOKgBFx+DDfQubH+xlX34GwKtAoD9SaPmwhCE/80K
 3hrTEIzgyB0BoDqVnSsfRi/PYMzsbgxUoWmQR79MV96Afqz8XRamCqjQ/oP9/IqEywlD78VXwS/
 KBpTLJ0kZPFynzvCDa8u2a2J0hMAWBScxFoG97lVVX5G22UmmPGxN7qJKrrU0mUUohd6fjVDvcn
 1HzXCKl4hzTAcSNbttAfdL6lhRAzeMYRuJcia3DQqwb4XYD/DpNj9OMzSwrWsm2WFA4kpaPLR9D
 eKqw/bGbtUfsgTpwStclaQl2qRuDVx9fStEaQBuWs/y+40oV0vMNHNm8LXLZ7q3w5xU30fwkg2i
 B8u3ztcq+4jB/GJSDJfIXBIAlNTVAY8j/NqKWlLazuWC4SM0qVg8/rFNHBZsJzosljDvhJ/cgmt
 lX5Zg9OET5Ut25w==
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

