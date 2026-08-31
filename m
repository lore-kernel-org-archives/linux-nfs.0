Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64C1E4CC269;
	Mon, 31 Aug 2026 16:15:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192950; cv=none; b=ZSnWQL7bKqH/yjyquUczYtd7QcFwe65oGoaLDgGBdFszqLdcYZHXx0AELYdHjKO8HRgMriGRdu3hpC0yhQJNvIsek6LQ64hwJfkHbah0wcuQ9rXMaQvHKV+thyDxMmbbL9XvigCinMWtiSsYyYR3eHsCK8pxIe8TqYovMjDADJA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192950; c=relaxed/simple;
	bh=8BqEPxMa2y9rgo4Ng7eAaQpEsvFB9iEfXzOAyL/uhig=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Sh/838wXV/CYyOugesxihuaJFpO4TE/tYWCbWVJR/Ysq0gwcYRjAQWXOdJ3QCuAkPQ8bXoDeQlXhpKytg+pSUpsDxPzqVYZISXopQVfKJWCw3MNCYsdh7dVPkUO6JJ/gNN5S06FQOOFp1jO0X7Kg1ZAczg3LijTHSAfiMbMavGo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LSAdOfd4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LSAdOfd4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 919631F00A3F;
	Mon, 31 Aug 2026 16:15:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192949;
	bh=ifq9Lngr/8+mD4QMqfJpZRugAPFghjpAp6yjOdVsVA0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LSAdOfd4hUN8xnnN/MBA0LCDhRfwJOUJW8hC+glODpH5HKd6SyQtMfIUzyLDD7xbG
	 FQUVPnKqeWJtwIYEnngVbU7KVlERXcysIlu35LVg2VrJ4ig1sJYFNH5GPCi1RMAgiv
	 5mClqKBP99/lhWDfPD+nzcax1RTHtI7Oj6UpuuZ4Gy+sRgkgw6fkkGgCFq8ernzJnS
	 8vj8H/qZ8PcNwer0qte60GgzpitI3RchOSSUEZ92npqpX9JFBy69nZe2vhXjvpHYx+
	 WPkp3X2m00JRCUlmsavbAbyzgerX/fmYpt9SGyFtIoZrjiFBANC8s/LP+wzkFVWxFY
	 cnLhuhNgIfmag==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:49 -0400
Subject: [PATCH v4 07/14] SUNRPC: stop svc_register() once rpcbind stops
 answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-7-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=931; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8BqEPxMa2y9rgo4Ng7eAaQpEsvFB9iEfXzOAyL/uhig=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaiiWxMMgCV7IlQMOBuB3P0Db+l/hnVE7SU75
 0xNu8+sN6CJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWoogAKCRAADmhBGVaC
 FXQ7EACwuSNXhbor7Pmvw7kc3yzB8T2qBADcLXIdHGNrr45LHlSxnrV94O6R8HyTvKa8Zfkn7Fh
 9pZ9AcR+NiZUEyRsjzvFTMtDpOJofkc3BE0KF+Uzn+hWGciNxpN7Cw2RXhAiKGg6QuMtwyMx/Sa
 Yheo+/eRCURqi12JmGNVR2K37UUOgT5LjOLeIrM0VmuGe3XpE/IXxKeHaqaxK/yq2RVLnlkrJX2
 WLUALmYoB8/myMKE0YUipkMBrGZ397AtNYB97nUzwxX39T/J+kapJ/iYRW2RVW/7qy1Qvs2MF55
 qNmHBPV8ZVMWCUz/3yiQPU/PzlvKsk+1VJaQ9mgJKa7UxfFrBgzt7ybCsv8XADtyLciGJDRd59m
 RweNDLcEp7FozGfWe8adgLlJ9NWdpkgXnrXkbTbm6WHFWHZ5l0Gna0zqMgYsaxuxHz7H1NRP3E+
 R0j7cTBeoC8OE80FioSTtLOeGuwKqG0FwLeMR2tNwo9XH5QpQN9HZ+O3b0YEIG4HpwJoJEu+K8K
 39Gvojr7PI/LABeP7vKm1eVyjS2kbS8EBSbBUiQeIJwbQXSmbJSUU4H+YBNx12V4m93vfHn5Btt
 1gfWkdHzSTvm2I6N7jDxCR9i1obHkbt40Lulv7QEykkyERtWZt4J6TPKwuCCKNOGYAyghci+Vm2
 c9bJN0S5yRkf6sQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_register() walks every program and every version. The break on error
leaves the version loop only, so a program whose call to the local rpcbind
timed out is followed by the next program timing out in the same way. With
the 1s bound on the local rpcbind client, an nfsd serv pays 2s for that,
once for nfsd and once for nfsacl.

Stop the program loop too, but only when the call got no answer.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ca6f90653327..24fd18bb8770 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1258,6 +1258,10 @@ int svc_register(struct svc_serv *serv, struct net *net,
 				break;
 			}
 		}
+
+		/* Give up on trying to register anything if it didn't respond */
+		if (noanswer)
+			break;
 	}
 
 	if (noanswer)

-- 
2.55.0

