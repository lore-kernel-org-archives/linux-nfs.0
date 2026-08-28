Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A87EA34EEF3;
	Fri, 28 Aug 2026 16:38:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935081; cv=none; b=nG/8LkdUbl8pvdeC1hoeE5OippnK2sB7a4HGKhSAoqRaTF7Kl5s+iieuL2GDqDgAidOIc0WxD4a/CvxDq2KJns7+Z0D7L1oLDwQNrFLr9R16/zbasH2B26p7np3+Qk+afJ3u3be9ypMhpmWfzepUx5UhIfPrJHWwU87F4uUSrj0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935081; c=relaxed/simple;
	bh=FKA2BkMlz5ELGl32gDJPPbAwvFf5JVXLuMfqgnUQM9U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=nnyrkixH0nt07MMypRupqa9X/oV7pyxzous5xCxLbyl30lprIftZvxI1pLT/ZGHW0kqOlH9aZ/w/xstW6ynzze8EQC9KPXy2y6zB6O0xWPr1hkkQLXCmxnd3CLzyak7x4yMpVPblnnr6J6PwIYtY+0zYdAv+zIJPTEapwpry55c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GmD92sjC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GmD92sjC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B9D491F000E9;
	Fri, 28 Aug 2026 16:37:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935080;
	bh=ockaZEjuUu+8Z8u8Q0PDF9tkO0ak/zH6aUQtKJaJl5Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GmD92sjCCLSPWkad7nMFxt8FkqgrlZy+DjXLH5d1gHKx3/BuilFRBvOm38/EfbEC2
	 LjNqPMRkrZGOsmOLfqUlE4k/f/8oA0X/yGyyzYd/3nlQGNTJoJG+i9G+dVB7jG3RZD
	 8kavgTmwjrg8hHVrnI0GuOXI5LwGb9+MNahZP0JANK+iMecbsEQc+WbAhB/491SFZr
	 L+pdJNu2L9sfelqYsZ7j3wrQs8YxygkE/VwkRKpYpbAHohf8DngzvtqTzQATH3wypn
	 UqWvvkhA2qi+vzM4MbLYZPXifvAMbwEDat44WugSn7kJz0S0Rm1eEXcEsSgm3l3oAm
	 e9pEWfoLYVgDA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:39 -0400
Subject: [PATCH v3 09/14] SUNRPC: stop unregistering listeners once rpcbind
 stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-9-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2044; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=FKA2BkMlz5ELGl32gDJPPbAwvFf5JVXLuMfqgnUQM9U=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblWCAym/muah0F6vWM8YgSIL5RD8Q85pSga3
 +oBcgjcOIWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VgAKCRAADmhBGVaC
 Fe9HEADDlFMqUaSbem32S8QZfH8ZbfhUjcMPLWyFsxE8xMHZ5+exV0yS7Bs7QFIxXS28Xvc13ES
 wK66Qu0yL5GkXPxxD/0FOHtn69ImcmjLySwg1dIlhqJ65aBKaM6LDq1fnoTp8mYHXvjIWN1w/Zn
 Sa8A6zFGuJhTQSASgda8oPCC/glqu+rBb9Vdl75/oU+iofviiUf/J+I3sPwIkOilxY7IMTA6/cS
 ne+uu/26HHpkNfgbw6SYTkib4FHHgnp9Jg1ai5I5Yv+7AZUJyOxrTHLiS7ZBQoU+7FAK5DG28Po
 L6L/u87lKnNHlx5KmPvH04CikXsfT58i1MjDzqA2Y61wAi6iEFfnKrtPEeGTDVo4CKyL0Z90jMa
 7y3hGMKeDC0JlOOkWqlld/cMx21uArVCM5tn+cSjX/xh47IhGvWTEeKNymWt6YtFy1cVSXjymp1
 /5gX107k3fBtlVKMLsSHF6g1pDeOndnOtydD6X2Qe/eJ0JIR/iSb+cGTfp+hiIwguyKv0nQbGuw
 97cfkLgKzoggR0zlE4CVnFQIMGOwxk7ppeYPdSFhqlsKPcLsDJOSQISkGzxGd+jFhZEbYLzooP2
 bMqxfFeEvdtK8WabsULXrQwcC7jCgtcQ1VxCXJEh1b5nlIku4QNlNa82k2Tv1OtYxtU8+CwFV3c
 ZqqYhcbuttwYhbg==
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
 net/sunrpc/svc_xprt.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb..7e471c92f23a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1101,6 +1101,22 @@ static void call_xpt_users(struct svc_xprt *xprt)
 	spin_unlock(&xprt->xpt_lock);
 }
 
+/*
+ * If rpcbind stops answering, every listener still to be destroyed would
+ * only wait out the same timeout again. Drop the flag on all of the
+ * remaining listeners.
+ */
+static void svc_xprt_clear_rpcb_unreg(struct svc_serv *serv, struct net *net)
+{
+	struct svc_xprt *xprt;
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
+		if (xprt->xpt_net == net)
+			clear_bit(XPT_RPCB_UNREG, &xprt->xpt_flags);
+	spin_unlock_bh(&serv->sv_lock);
+}
+
 /*
  * Remove a dead transport
  */
@@ -1115,11 +1131,15 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
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

