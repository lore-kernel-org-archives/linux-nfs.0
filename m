Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AAA0550DA4;
	Mon, 31 Aug 2026 16:15:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192954; cv=none; b=bTCFckRzpqnBgqyRw0oROgsupeXW5o2ohaA86PWoEuqjieuESn1AA47mqFhQWiegzhoClu7ZODcRqO5aKzenZJSJDKnXX2beUAPbzxFUKgRDFSqxE8tNtRjid8XcioMDe4RcNBravm2Gh6hzdS0W+1qTVIfuPLw9sI9hBy80AwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192954; c=relaxed/simple;
	bh=FKA2BkMlz5ELGl32gDJPPbAwvFf5JVXLuMfqgnUQM9U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Xsi+h/0K9SSq9hbdJndmIzktt5BDfMY79epp9uysl10O6bbQfMU6nHd8tcLySkAmiXlMpU2ENaeAGFNvVW3p2I9e2OJxmHDswI4XMx0xab1zt+fj6NQ8BM+atBSnyym7/Rpzeg7UBJ6bg8HVgNPAjEa3Pu9ibDaehcEyoxWfzLM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=biNYiHdb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="biNYiHdb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E64FF1F000E9;
	Mon, 31 Aug 2026 16:15:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192952;
	bh=ockaZEjuUu+8Z8u8Q0PDF9tkO0ak/zH6aUQtKJaJl5Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=biNYiHdbdgMbhjVFrV1bJnvmPqnUXYQWX0oJ+16SWn4zHA/7w6x8oZsmH6FyBgjbI
	 0sxlVy2lhG+1U4DHHo6BPCUnq60PdsM74iySwbWnurS/NA+6lYi3W8iFLmbBxhrixO
	 VSKVO56HPuqatyKCbuu5NaSr4wgspf4JsgsDTwTbRl456YTOYw5nJmjOqaM6CL1y2E
	 eLL/nmTMNAdlJ0vUUc+JGAAxKxp15Im9TSW4FHgMr+YGIc4P0eKzXVGShZdW5/3BaX
	 5V4N2Kj97gli6A6NuqbB2JqBNoPeLG1T8FZEFYuhikjctZ7sAXla0MJNb9ND11vkFj
	 4r7JDmq9+tI+A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:51 -0400
Subject: [PATCH v4 09/14] SUNRPC: stop unregistering listeners once rpcbind
 stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-9-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2044; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=FKA2BkMlz5ELGl32gDJPPbAwvFf5JVXLuMfqgnUQM9U=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaijZKWaoLymbn17HCs3riwAw/Q5gs0L7Ow8t
 KSwKt1m/vKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWoowAKCRAADmhBGVaC
 FUnID/9Oj3VQce6hrCQ3f+X7W92g9fuGHVHJ+qqG/6ndJv7AxTGQuJWPTRC3cdb0ZZB+6INe9NF
 ri0vt1PvUq5tWeyOvCaA1FfTrtrXucS8IJi4lzSIv9WuCHiZI4csXP6gxKuqsIcWMuCzqm474ks
 RQmS+Uq2gqR0Zy7p4M6Ay7+5ifddBCrPkyukqo8k3HWivnDDNF+NZMsVK4T+mfZ+abnc6yPBuBf
 y4Qg1hwgKStZLUMUkdAJrM8hkazQ3eL+AceKbyEcvy1zy1z59Tn1Iucbv4tqmR14bCKQDC9HKfv
 gq00oMGdooA4+SzNhiOAZe+NjHxnSrYk82YHh8D3S3kAzS6ArKlGyVdZS0VY/am54isLuyZJcMM
 ai4Na5K6qOutMJgfsZv/pELzKdVzc5IXoqhXXiuesDQto/SOXHzExf+/Ih+Zs/tdXf9zRIVN9tN
 N1S4Nps6P3qodgjlxrqApX174OoBKZM59UUZpI/yH/giod585mEsl5Y/SIm1lcSVUQkSEd/GPYg
 Yd9x2iid16Sl0iWm5/xuDLmuZyqeQjqkghI5ID1ZGHSemWAtugqUufqL4mzPseLDx2573TIaV2r
 /7d0fKJBhFhgVTl/eJ4QtJB7VoGTB36jjxras7pwS1LZjcVjJ4PmaRmezslKCMGEkEf0RaW++CX
 UDh8MvnEn9Oa2Bw==
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

