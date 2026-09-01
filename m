Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E13B47FAF8;
	Tue,  1 Sep 2026 13:40:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270020; cv=none; b=AG0joMtIbycICvuCIkOCh/umpODleYs/xlv1dyEfyC1N0GBCvWM12BNu/9FaLq8riYtilDUBnnp19ZmCjWD/wwsbCsULPzhl3pmvv5xe/PIv8nK4LsfqLv9QmAwjyGHeKuSpiINwjGDWlbJjTot+RYBgbQrjkH7eRcPZw1E3FvM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270020; c=relaxed/simple;
	bh=1r/MeTdtTiqjG/QVDbFc0lfCvcqVv7N3LlY8u4zmC44=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Q+ciqZMqO/0MbR+/uN157N5YJvp5V/+InDLm8LA4o58+ci5u3bHm3XNJp03Dc1WtdO4r5FywCQ82QylmGfq7OiK2PB9Afxr5KkCNkbMto8LMocY8Dv9pGGVmAnAr+kahFlBj3VXpq6LWuPg8EXmHesmjsYNgpJrAfyG+yGBBC7s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FCh/UC7/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FCh/UC7/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0B6A1F000E9;
	Tue,  1 Sep 2026 13:40:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270018;
	bh=YExOASgIJ2/l4OeTeYY2Iv2oz+KB5P8laUEbMe5fIZ8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FCh/UC7/2h1H+CtPmF1Mv0qiK/frtgAXu80yYVOuc7UVpXk5GEeJJFd2qfm62L1Yc
	 j1vUVv+acaV31vH3e1Sq78JFMlntUphWrgwdGFf0/pozUgeSq8Vt9vROFIw+AuAGYZ
	 8ff39acWFgCal3f7rc7yDPnzkII9y7MS7/B/L/B00V4pKVFEnsKRbXJXp1ZGu5X4La
	 UwkdAyvBAjhyqWjVviXvtGmY+LqKkYBQfhbOfBQxtnV/xhujuhQxlUM6veM5ny6UOM
	 VpJNSbquAukG+xNm53Vfnqv7OJlb50h+LXIWeFkdD+ijFE3H1lLomEGRLQbmjSfssH
	 C2hroMJwtZwoA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:47 -0400
Subject: [PATCH v5 09/15] SUNRPC: stop unregistering listeners once rpcbind
 stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-9-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2139; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1r/MeTdtTiqjG/QVDbFc0lfCvcqVv7N3LlY8u4zmC44=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWwBa2RAcJW2//7w0sglDAH2WRSAt6iNc94Z
 wcZ0yOjIbyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVsAAKCRAADmhBGVaC
 FW5RD/9dznm9oX5bdKYnqQe4Vh7DQ2sVrf9MrQesZ9HWu45xG3iqXtThMd4zfaSKyDR+cR6ySnt
 TLzMJ3kr5A9CpGIcxR1Rhz3gSL96WU/OJg4P7PyExS6E6UCQPoIT1bW7NxZGPzaBs8nFnmzcOr5
 q8cmYGeYLRYEE6SJi1GqJ7QG/UUgK6fjtgPWPBWCYb56LqAmd88v1saZc6ZPpr0qgWJKj2gqmIx
 nw2WRam0tvauBwPMCJllBIkNNYS7+3dB7nGf5211wB0pZF6qffixVReIsLpW3Fb0MXLFfRKOV2U
 +kTREUH0tjFF4hGWg4n5fSQNZs4+awdFTzKdsnRvA4w+VE5UWzW16CqRApfpfFNeGwysBt9Td+7
 ERYuFXm6+9l7vDeRPRQHWwEfzyDWYgcBhdlgjPgeviIenRbFj+/USxDVXQ2UDCI5n9uopMvH+9G
 3dyUSbBKIa15gqxRVOiO6ClXqwcsKxYsFBFQhpd97FPvsMQMPSzinwSmqcXvRyc2yzudPtxMA4N
 okKvl1DqAbrib1JVPkvwwhvOKSsBbFhLgjocQLHZzWIt4atw2oOsur/HMuhGLDAn6QYuC/sBP4y
 Ip30srxyo7bFcaS8wfrNUM13/rlMWlO927q+i0+bL4hwHR8h3PmlbXpCyGdE/t49WpTyliR9ioE
 52ejg7KIoLdXQ4A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_delete_xprt() unregisters each listener it destroys. One
NFSD_CMD_LISTENER_SET that removes listeners therefore pays one local
rpcbind timeout for each of them, under nfsd_mutex, on top of the one the
create loop already bounds.

One failure is enough to know that the rest of the teardown will not fare
better. When the call gets no answer, clear XPT_RPCB_UNREG on every
remaining transport in the same net.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc_xprt.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb..ef35a09b74d7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1101,6 +1101,23 @@ static void call_xpt_users(struct svc_xprt *xprt)
 	spin_unlock(&xprt->xpt_lock);
 }
 
+/*
+ * If rpcbind stops answering, every listener still to be destroyed would
+ * only wait out the same timeout again. Drop the flag on the rest of this
+ * teardown, which is every listener already marked for close.
+ */
+static void svc_xprt_clear_rpcb_unreg(struct svc_serv *serv, struct net *net)
+{
+	struct svc_xprt *xprt;
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
+		if (xprt->xpt_net == net &&
+		    test_bit(XPT_CLOSE, &xprt->xpt_flags))
+			clear_bit(XPT_RPCB_UNREG, &xprt->xpt_flags);
+	spin_unlock_bh(&serv->sv_lock);
+}
+
 /*
  * Remove a dead transport
  */
@@ -1115,11 +1132,15 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
 		struct svc_sock *svsk = container_of(xprt, struct svc_sock,
 						     sk_xprt);
 		struct socket *sock = svsk->sk_sock;
+		unsigned int failures = svc_rpcb_failure_count(serv);
 
 		if (svc_register(serv, xprt->xpt_net, sock->sk->sk_family,
 				 sock->sk->sk_protocol, 0) < 0)
 			pr_warn("failed to unregister %s with rpcbind\n",
 				xprt->xpt_class->xcl_name);
+
+		if (svc_rpcb_failure_count(serv) != failures)
+			svc_xprt_clear_rpcb_unreg(serv, xprt->xpt_net);
 	}
 
 	if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))

-- 
2.55.0

