Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D014F391E5F;
	Fri, 28 Aug 2026 16:37:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935080; cv=none; b=Lg1M7iRThkUlX2VBgVoPvilkQG3EKiEjeqGlnJ55pelRAaca1TguIzqNviyWJA+O7vMXHMBBAa4ZyEcwvgmfAEVrIpguJKyXIJXXk+cotjeBWwiw7Gor2m9EsxqY71pVRaeejDGW2dyLTcRDUIf0ew/PEHxKZweGJgU+PAp+fTQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935080; c=relaxed/simple;
	bh=RTcXp/XwAZK07kmKnoyjWTw0KieKZtAuYzEGLVY+5hg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZQuoOqasUhSXJeJk1do8eELW4De20Px60SvEpJypndQ0ocsccfbnVJXvMRnq+7X57fUL5HW5VuGDzS6w/PH8NSAtNwTpCrhwtR4FiBnpoChpdEd7gkGLvl9jqoLb/sKUMZ5zac3/7h+7ZiUFi6TLGcwWjmN+9mj+NNMfnIhJuNs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CDClmfhd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CDClmfhd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 136CC1F00A3D;
	Fri, 28 Aug 2026 16:37:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935078;
	bh=9tzxYlwQuDAnUqvOPKUuPXDIwe1U2jXuBsgT+odNOh0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CDClmfhdZge0uVfCkcidYTYSHaDxdklfmzihKZOFrZg9A4ybwLbx2CnSAfJaTSqMf
	 XNYWBm8NPWuNYCk2eiM0d7rKz7Crd+c0cV9tHwtde8PQB0ATMosl2LfvWJH4X6AWVA
	 n2Bhw2OFUqKlPLiwtEktDf5SyTA3R3BKns9O4Svxxn8VlANjDGED1s87/F01dWorm1
	 hulerlZghuBYnTu+f0CVKgUeSyXvoWGuymjnJ+OrQLTKFm0H/e0D/+YkOS5aJqBj4/
	 R3YvSHwaC7pQlwB6RByfWYUu1xjBKiu8Ng/tnSqgh8D0WQaKZWed2NLINQ0bJPc1x6
	 JWuxUtIA00dQg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:38 -0400
Subject: [PATCH v3 08/14] SUNRPC: stop the svc_unregister() sweep once
 rpcbind stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-8-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1962; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=RTcXp/XwAZK07kmKnoyjWTw0KieKZtAuYzEGLVY+5hg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblVpeN/m4T8mawarXPaJ+9twWQfrc3Fv+NF0
 ZupgQepKpeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VQAKCRAADmhBGVaC
 Ff2gEADHQSmcM5qBfnyufH2X3MvUVJcj3F0VAnFdOZNaeR3Y6tThV6ZDrPU3rivkcoYmtd+lncP
 JsyUVY9RGEm4yOeJAsuHk27zyCGoKa/RIIwDNZRzYFA5fjkCOxOrR1WOE+by1Zsh/7r7rpcEBSu
 kMvC+uCjT84aAkd5XfDMeBT8nlfGA9x7jii2Br9P876g9VFNBuogVaANHkjn2do7x79heX5WH8b
 iw38M2Stzr/t+Wg//FaI1a6HMhMNMflQK9U2LYA9n7CXBVKURXWBkluBGBW4vKTH1hNM/7rd7XQ
 I5s/gX37Q5G2tiYC6aVwaiLs6gJQpc24VDGKHwaZhc/Dh2SF/+3j7CLIn4F1TlCVfgMMdjKXgW1
 tAItZPn/fkV/Xiv41/9zqMzZqQC72XWLddNU2ouNdWFinPHKvG2gOcZsU1btP9Qa/t6gZW4q5lQ
 dymMb3e6EigqHridK9HOHpl1LO9PBZF4VuhBSgalJxPxGdRhAWZC2ZOfZlNA26ypdKBMNZ7Bu7q
 naTxWv7BYDCDDsvKtzNxhUrA9Sq+C7LErOJkzOozYYJXsJ5X6buehSHUQ7DWqCUsE589IL6cIpf
 msX14HFHiObusWDVTBdZHgAhVJMZriKUy4Rt1l9zqzwo36k8RK22WnrIVkR0QZ5LfZPMl00ubTv
 TAORfokPVxY/9UA==
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
index e437e99a0b36..bccaeb8dfba8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1277,8 +1277,8 @@ int svc_register(struct svc_serv *serv, struct net *net,
  * any "inet6" entries anyway.  So a PMAP_UNSET should be sufficient
  * in this case to clear all existing entries for [program, version].
  */
-static void __svc_unregister(struct net *net, const u32 program, const u32 version,
-			     const char *progname)
+static int __svc_unregister(struct net *net, const u32 program, const u32 version,
+			    const char *progname)
 {
 	int error;
 
@@ -1292,6 +1292,7 @@ static void __svc_unregister(struct net *net, const u32 program, const u32 versi
 		error = rpcb_register(net, program, version, 0, 0);
 
 	trace_svc_unregister(progname, version, error);
+	return error;
 }
 
 /*
@@ -1318,10 +1319,13 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 				continue;
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
-			__svc_unregister(net, progp->pg_prog, i, progp->pg_name);
+			if (__svc_unregister(net, progp->pg_prog, i,
+					     progp->pg_name) == -ENAVAIL)
+				goto out;
 		}
 	}
 
+out:
 	rcu_read_lock();
 	sighand = rcu_dereference(current->sighand);
 	spin_lock_irqsave(&sighand->siglock, flags);

-- 
2.55.0

