Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC65747F763;
	Tue,  1 Sep 2026 13:40:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270018; cv=none; b=TwgP5cM470gYn0FO+TkShvNmdbRz0LZ+XjmXPJ6ldX3uFoAGomGkGEX2F08Z9AzHUpvIcvUqGoZi0DvDr157bFuMDlT1w6YvfMmSICgDBvpCOnVgNQ4cvCw8j2iKuqV/70XRX6YK2asD3us0cWSplO3x8LjDyIbMad23uMLpgJc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270018; c=relaxed/simple;
	bh=OxooBR6zP1EObRUZaoecaq02mYeD5P6mm/aldTuwXlY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fp8+5MrdYnjIobBGPjF13plz+tD4ugqoSIgZ0qIodbrKTemVO31lWJ8l8Mpd1uH9ujtecIaPk245bc84/FBCta7Y+VRmP+KF5RUhK5b8Mnf5a7kY5dw6eQG6gXdXEMtOabJCGhxeBtVFK2zU94s6Itm48M8wa85FZqffFCxVz5o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f0gWPQCh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f0gWPQCh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F94C1F00ACF;
	Tue,  1 Sep 2026 13:40:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270016;
	bh=i4VG5NqTo3OXGrkAYOASfBWI3LZV+WyKA2uNOsOM3bU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=f0gWPQCheGTgkZNeOyzxgBX7mT0gjWEyE36a+AdZqsX6TBzq9VKSuc1semShC2Rz1
	 pAPKseRnhNxENNMVj6F+hfkVYD3e9Y9tzVlOPdvdLKb2Oaeo4Mx3tL8NZ6tx27z+Cc
	 1zC2Z3gMjrI/5mVb2K6L1AwVU5DnyyG5ckBdQQWEYyK2AV7T2iFZt4Wr/DcGfZsK+7
	 qBkDlTJn1MWozAvOqEIFpCTc+M+KnFNF8yN6IXaardS5zyjS2lKWvcYx5lQl2xSLBY
	 U0lgawwzzKZfUGvzgFzHK01i/ZwDw864UatjXbourl6gJqvNm0jD34Sj9Ce9Ackner
	 0dpw/OcKHm2LA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:46 -0400
Subject: [PATCH v5 08/15] SUNRPC: stop the svc_unregister() sweep once
 rpcbind stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-8-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1958; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=OxooBR6zP1EObRUZaoecaq02mYeD5P6mm/aldTuwXlY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWvSR+9poLFWt2GoDrViVJeabbe33matKOfR
 tRHctysdB2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrwAKCRAADmhBGVaC
 Fd1GD/9AWtvXqIl3cYusIXfUcnawTaTsvPU9qBGSLuCApyljzguaMCNU5/lgllTJqrk2waF8Vya
 /X0J8IjZbxT/kFIXhyTTV/XTQSQThGekPVqfXnzfsva1ycrlP81pZyTlquGHG+1QpyaJ04HxjVK
 wd6rgEhvhWmNoz0+XatXxWVaUstAYNE7LbWaYWfK4OwGojVXGzeaSPUPydDFv4lf5c3VST6K/rT
 3wrzQNF+DGkdShToHbGHilTY/snPnNtUW87LImdPY4axesYqfO2RVb89R0UIlwwiMwvDmUnIvpI
 6YfkIH5sSZiy3qw4ShnhmBOtAQpvCtvVyPjW28tls/IRKQUmmHyHsHlDz8J5xBi0sn9Ii/KWWQV
 O6+G/BOHsuY26nX+Qnju9whjUxnc8y2QWBN1vpMN0a6gN8VJKpI0idtp16SqIJaDJ+XPKhkUXFI
 krDxDoliFObucGrhflRjrLEtkOND4cYAj7mGWF99BLulaJt1Lk9CsdVDoJubY+DTSotVr6jsXiK
 +y7aPZ+2sPQDC52k/KJjWAPrRMceV680aB0dTy9Us8jtC00FPY4d81MyIGA3NXFrfXXGCkVW7N1
 ppJDF4ClUK+DutRthAlJqirB+rXdU7VIgECeHM5lgcjKDW1+Y6nsgqVutmN7RIzlGWA3M0CFNt+
 A+bg7L1z/jzJqhA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_unregister() clears the rpcbind entry for every non-hidden program and
version. svc_rpcb_setup() runs it to drop stale entries when a serv binds,
and svc_rpcb_cleanup() runs it when one goes away. An nfsd serv with v3 and
v4 enabled sweeps four or five entries, so a local rpcbind that never
replies costs that many timeouts, twice per NFSD_CMD_LISTENER_SET, all
under nfsd_mutex.

Give up after the first call that gets no answer.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 592f2745b028..f73412e123a1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1279,8 +1279,8 @@ int svc_register(struct svc_serv *serv, struct net *net,
  * any "inet6" entries anyway.  So a PMAP_UNSET should be sufficient
  * in this case to clear all existing entries for [program, version].
  */
-static void __svc_unregister(struct net *net, const u32 program, const u32 version,
-			     const char *progname)
+static int __svc_unregister(struct net *net, const u32 program, const u32 version,
+			    const char *progname)
 {
 	int error;
 
@@ -1294,6 +1294,7 @@ static void __svc_unregister(struct net *net, const u32 program, const u32 versi
 		error = rpcb_register(net, program, version, 0, 0);
 
 	trace_svc_unregister(progname, version, error);
+	return error;
 }
 
 /*
@@ -1320,10 +1321,13 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 				continue;
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
-			__svc_unregister(net, progp->pg_prog, i, progp->pg_name);
+			if (__svc_unregister(net, progp->pg_prog, i,
+					     progp->pg_name) == -EIO)
+				goto out;
 		}
 	}
 
+out:
 	rcu_read_lock();
 	sighand = rcu_dereference(current->sighand);
 	spin_lock_irqsave(&sighand->siglock, flags);

-- 
2.55.0

